import Foundation
import Crypto

public protocol ToolAdapter {
    var tool: String { get }
    func run(args: [String]) throws -> (Data, Int32)
}

public struct Router {
    let adapters: [String: ToolAdapter]
    let validator = Validation()

    public init(adapters: [String: ToolAdapter]) {
        self.adapters = adapters
    }

    public func route(_ request: HTTPRequest) async throws -> HTTPResponse {
        if request.method == "GET" && request.path == "/openapi.yaml" {
            let url = URL(fileURLWithPath: "Sources/ToolServer/openapi.yaml")
            let data = try Data(contentsOf: url)
            return HTTPResponse(status: 200, headers: ["Content-Type": "application/yaml"], body: data)
        }

        guard request.method == "POST" else { return HTTPResponse(status: 405) }
        let parts = request.path.split(separator: "/").map(String.init)
        guard parts.count == 2, let adapter = adapters[parts[1]] else { return HTTPResponse(status: 404) }

        let payload = try JSONDecoder().decode(ToolRequest.self, from: request.body)
        try validator.validate(args: payload.args)
        let start = Date()
        let (output, code) = try adapter.run(args: payload.args)
        let duration = Int(Date().timeIntervalSince(start) * 1000)
        let hash = SHA256.hash(data: Data(payload.args.joined(separator: " ").utf8)).compactMap { String(format: "%02x", $0) }.joined()
        let log = LogEntry(request_id: payload.request_id ?? UUID().uuidString, tool: adapter.tool, args_hash: hash, duration_ms: duration, exit_code: code)
        if let logData = try? JSONEncoder().encode(log) { print(String(data: logData, encoding: .utf8)!) }
        return HTTPResponse(status: Int(code == 0 ? 200 : 500), body: output)
    }
}

public struct ToolRequest: Codable {
    public let args: [String]
    public let request_id: String?
}

public struct LogEntry: Codable {
    let request_id: String
    let tool: String
    let args_hash: String
    let duration_ms: Int
    let exit_code: Int32
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
