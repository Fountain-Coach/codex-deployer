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
        if request.method == "GET" {
            switch request.path {
            case "/openapi.yaml":
                let url = URL(fileURLWithPath: "Sources/ToolServer/openapi.yaml")
                let data = try Data(contentsOf: url)
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/yaml"], body: data)
            case "/_health":
                let data = Data("{\"status\":\"ok\"}".utf8)
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
            case "/metrics":
                let uptime = Int(ProcessInfo.processInfo.systemUptime)
                let body = Data("uptime_seconds \(uptime)\n".utf8)
                return HTTPResponse(status: 200, headers: ["Content-Type": "text/plain"], body: body)
            default:
                break
            }
        }

        guard request.method == "POST" else { return HTTPResponse(status: 405) }
        let parts = request.path.split(separator: "/").map(String.init)
        guard parts.count == 2, let adapter = adapters[parts[1]] else { return HTTPResponse(status: 404) }

        let payload = try JSONDecoder().decode(ToolRequest.self, from: request.body)
        try validator.validate(args: payload.args)
        let start = Date()
        let (output, code) = try adapter.run(args: payload.args)
        let end = Date()
        let duration = Int(end.timeIntervalSince(start) * 1000)
        let hash = SHA256.hash(data: Data(payload.args.joined(separator: " ").utf8)).compactMap { String(format: "%02x", $0) }.joined()
        var metadata = ["args_hash": hash, "exit_code": String(code)]
        let logger = JSONLogger()
        if let trace = request.headers["X-Trace-ID"] {
            let spanID = UUID().uuidString
            let span = Span(trace_id: trace, span_id: spanID, parent_id: request.headers["X-Span-ID"], name: adapter.tool, start: start, end: end)
            logger.exportSpan(span)
            metadata["span_id"] = spanID
        }
        let log = LogEntry(request_id: payload.request_id ?? UUID().uuidString, tool: adapter.tool, duration_ms: duration, metadata: metadata)
        logger.log(log)
        return HTTPResponse(status: Int(code == 0 ? 200 : 500), body: output)
    }
}

public struct ToolRequest: Codable {
    public let args: [String]
    public let request_id: String?
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
