import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public actor BrowserPool {
    public struct Options: Sendable {
        public var executable: String
        public init(executable: String = "chromium") {
            self.executable = executable
        }
    }

    private var processes: [Process] = []

    public init() {}

    @discardableResult
    public func launch(_ options: Options = .init()) throws -> CDPClient {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: options.executable)
        process.arguments = ["--headless=new", "--remote-debugging-port=0"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()

        let handle = pipe.fileHandleForReading
        var buffer = Data()
        var wsURL: URL?
        while wsURL == nil {
            let chunk = try handle.read(upToCount: 512) ?? Data()
            if chunk.isEmpty { break }
            buffer.append(chunk)
            if let str = String(data: buffer, encoding: .utf8) {
                wsURL = parseWebSocketURL(from: str)
            }
        }
        guard let url = wsURL else {
            process.terminate()
            throw BrowserError.websocketURLNotFound
        }
        processes.append(process)
        return CDPClient(endpoint: url)
    }

    private func parseWebSocketURL(from text: String) -> URL? {
        guard let range = text.range(of: "ws://") else { return nil }
        let substring = text[range.lowerBound...]
        let end = substring.firstIndex { $0 == "\n" || $0 == "\r" } ?? substring.endIndex
        return URL(string: String(substring[..<end]))
    }

    public enum BrowserError: Error {
        case websocketURLNotFound
    }

    deinit {
        for p in processes {
            p.terminate()
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
