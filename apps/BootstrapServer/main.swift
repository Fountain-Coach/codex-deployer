import Foundation
import TypesensePersistence
import BootstrapService
import Dispatch
#if os(Linux)
import Glibc
#else
import Darwin
#endif

final class SimpleHTTPRuntime: @unchecked Sendable {
    enum RuntimeError: Error { case socket, bind, listen }
    let router: BootstrapService.BootstrapRouter
    let port: Int32
    private var serverFD: Int32 = -1

    init(router: BootstrapService.BootstrapRouter, port: Int32 = 8082) { self.router = router; self.port = port }

    func start() throws {
        #if os(Linux)
        serverFD = socket(AF_INET, Int32(SOCK_STREAM.rawValue), 0)
        #else
        serverFD = socket(AF_INET, SOCK_STREAM, 0)
        #endif
        guard serverFD >= 0 else { throw RuntimeError.socket }
        var opt: Int32 = 1
        setsockopt(serverFD, SOL_SOCKET, SO_REUSEADDR, &opt, socklen_t(MemoryLayout.size(ofValue: opt)))
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = in_port_t(UInt16(port).bigEndian)
        addr.sin_addr = in_addr(s_addr: in_addr_t(0))
        let bindResult = withUnsafePointer(to: &addr) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { ptr in bind(serverFD, ptr, socklen_t(MemoryLayout<sockaddr_in>.size)) } }
        guard bindResult >= 0 else { throw RuntimeError.bind }
        guard listen(serverFD, 16) >= 0 else { throw RuntimeError.listen }
        DispatchQueue.global().async { [weak self] in self?.acceptLoop() }
    }

    private func acceptLoop() {
        while true {
            var addr = sockaddr()
            var len: socklen_t = socklen_t(MemoryLayout<sockaddr>.size)
            let fd = accept(serverFD, &addr, &len)
            if fd >= 0 { DispatchQueue.global().async { self.handle(fd: fd) } }
        }
    }

    private func handle(fd: Int32) {
        var buffer = [UInt8](repeating: 0, count: 4096)
        let n = read(fd, &buffer, buffer.count)
        guard n > 0 else { close(fd); return }
        let data = Data(buffer[0..<n])
        guard let request = parseRequest(data) else { close(fd); return }
        // True SSE streaming path
        if request.path.hasPrefix("/bootstrap/baseline") && request.path.contains("sse=1") {
            Task {
                await self.streamBaselineSSE(fd: fd, request: request)
            }
            return
        }
        Task {
            let resp = try await router.route(request)
            let respData = serialize(resp)
            respData.withUnsafeBytes { _ = write(fd, $0.baseAddress!, respData.count) }
            close(fd)
        }
    }

    private func writeAll(_ fd: Int32, _ data: Data) {
        data.withUnsafeBytes { ptr in
            var written = 0
            while written < data.count {
                let n = write(fd, ptr.baseAddress! + written, data.count - written)
                if n <= 0 { break }
                written += n
            }
        }
    }

    private func streamBaselineSSE(fd: Int32, request: BootstrapService.HTTPRequest) async {
        // Write HTTP headers for chunked SSE
        let headers = "HTTP/1.1 200 OK\r\nContent-Type: text/event-stream\r\nCache-Control: no-cache\r\nConnection: keep-alive\r\nTransfer-Encoding: chunked\r\n\r\n"
        writeAll(fd, Data(headers.utf8))
        // Decode body
        guard let input = try? JSONDecoder().decode(BootstrapService.BaselineIn.self, from: request.body) else {
            _ = write(fd, "0\r\n\r\n".data(using: .utf8)!)
            close(fd)
            return
        }
        // Prepare events and persist
        let events = (try? await router.prepareBaselineEvents(input: input)) ?? ["event: error\ndata: {}\n\n"]
        // Stream each event as chunk
        for e in events {
            let chunk = Data(e.utf8)
            let size = String(format: "%X\r\n", chunk.count)
            writeAll(fd, Data(size.utf8))
            writeAll(fd, chunk)
            writeAll(fd, Data("\r\n".utf8))
            // small delay to simulate streaming
            usleep(50_000)
        }
        // One heartbeat/comment to keep-alive
        let hb = Data(": heartbeat\n\n".utf8)
        let hbSize = String(format: "%X\r\n", hb.count)
        writeAll(fd, Data(hbSize.utf8))
        writeAll(fd, hb)
        writeAll(fd, Data("\r\n".utf8))
        // End of chunks
        writeAll(fd, Data("0\r\n\r\n".utf8))
        close(fd)
    }

    private func parseRequest(_ data: Data) -> BootstrapService.HTTPRequest? {
        guard let string = String(data: data, encoding: .utf8) else { return nil }
        let parts = string.components(separatedBy: "\r\n\r\n")
        let headerLines = parts[0].split(separator: "\r\n")
        guard let requestLine = headerLines.first else { return nil }
        let tokens = requestLine.split(separator: " ")
        guard tokens.count >= 2 else { return nil }
        let method = String(tokens[0])
        let path = String(tokens[1])
        return BootstrapService.HTTPRequest(method: method, path: path, body: parts.count>1 ? Data(parts[1].utf8) : Data())
    }

    private func serialize(_ resp: BootstrapService.HTTPResponse) -> Data {
        var text = "HTTP/1.1 \(resp.status)\r\n"
        text += "Content-Length: \(resp.body.count)\r\n"
        for (k,v) in resp.headers { text += "\(k): \(v)\r\n" }
        text += "\r\n"
        var data = Data(text.utf8)
        data.append(resp.body)
        return data
    }
}

// Bootstrap runtime
do {
    let svc: TypesensePersistenceService
    if let url = ProcessInfo.processInfo.environment["TYPESENSE_URL"] ?? ProcessInfo.processInfo.environment["TYPESENSE_URLS"],
       let apiKey = ProcessInfo.processInfo.environment["TYPESENSE_API_KEY"], !apiKey.isEmpty {
        let urls = url.contains(",") ? url.split(separator: ",").map(String.init) : [url]
        #if canImport(Typesense)
        let client = RealTypesenseClient(nodes: urls, apiKey: apiKey, debug: false)
        svc = TypesensePersistenceService(client: client)
        #else
        svc = TypesensePersistenceService(client: MockTypesenseClient())
        #endif
    } else {
        svc = TypesensePersistenceService(client: MockTypesenseClient())
    }
    Task { await svc.ensureCollections() }
    let router = BootstrapService.BootstrapRouter(persistence: svc)
    let runtime = SimpleHTTPRuntime(router: router, port: 8082)
    try runtime.start()
    print("bootstrap listening on :8082")
    dispatchMain()
} catch {
    print("Failed to start bootstrap: \(error)")
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
