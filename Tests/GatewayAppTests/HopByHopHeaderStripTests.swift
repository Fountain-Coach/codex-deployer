import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import gateway_server
import FountainRuntime

final class HopByHopHeaderStripTests: XCTestCase {
    @MainActor
    func testHopByHopHeadersStripped() async throws {
        actor HeaderBox {
            private var storage: [String: String] = [:]
            func update(_ h: [String: String]) { storage = h }
            func snapshot() -> [String: String] { storage }
        }
        let box = HeaderBox()
        let kernel = HTTPKernel { req in
            await box.update(req.headers)
            return HTTPResponse(status: 200, headers: ["Content-Type": "text/plain"], body: Data("ok".utf8))
        }
        let upstream = NIOHTTPServer(kernel: kernel)
        let upstreamPort = try await upstream.start(port: 0)

        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("routes.json")
        struct Route: Codable { var id: String; var path: String; var target: String; var methods: [String]; var rateLimit: Int?; var proxyEnabled: Bool? }
        let routes = [Route(id: "t", path: "/t", target: "http://127.0.0.1:\(upstreamPort)", methods: ["GET"], rateLimit: nil, proxyEnabled: true)]
        try JSONEncoder().encode(routes).write(to: file)

        let server = GatewayServer(plugins: [], zoneManager: nil, routeStoreURL: file)
        let port = 9154
        Task { try await server.start(port: port) }
        try await Task.sleep(nanoseconds: 100_000_000)

        func metrics() async throws -> [String: Int] {
            let url = URL(string: "http://127.0.0.1:\(port)/metrics")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return (try JSONSerialization.jsonObject(with: data) as? [String: Int]) ?? [:]
        }
        let m0 = try await metrics()
        let base200 = m0["gateway_responses_status_200_total"] ?? 0

        var req = URLRequest(url: URL(string: "http://127.0.0.1:\(port)/t")!)
        req.setValue("keep-alive", forHTTPHeaderField: "Connection")
        req.setValue("chunked", forHTTPHeaderField: "Transfer-Encoding")
        req.setValue("100-continue", forHTTPHeaderField: "Expect")
        req.setValue("1", forHTTPHeaderField: "X-Test")
        let (_, resp) = try await URLSession.shared.data(for: req)
        XCTAssertEqual((resp as? HTTPURLResponse)?.statusCode, 200)

        let headers = await box.snapshot()
        let lower = Dictionary(uniqueKeysWithValues: headers.map { ($0.key.lowercased(), $0.value) })
        XCTAssertNil(lower["connection"])
        XCTAssertNil(lower["transfer-encoding"])
        XCTAssertNil(lower["expect"])
        XCTAssertEqual(lower["x-test"], "1")

        let m1 = try await metrics()
        XCTAssertEqual(m1["gateway_responses_status_200_total"] ?? 0, base200 + 1)

        try await server.stop(); try await upstream.stop()
    }
}

