import Foundation
import Crypto
import Toolsmith

public protocol ToolAdapter {
    var tool: String { get }
    func run(args: [String]) throws -> (Data, Int32)
}

public struct Router {
    let adapters: [String: ToolAdapter]
    let validator = Validation()
    let manifest: ToolManifest
    let toolsmith = Toolsmith()

    public init(adapters: [String: ToolAdapter], manifest: ToolManifest) {
        self.adapters = adapters
        self.manifest = manifest
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
            case "/manifest":
                let data = try JSONEncoder().encode(manifest)
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
            default:
                break
            }
        }

        guard request.method == "POST" else { return HTTPResponse(status: 405) }
        let parts = request.path.split(separator: "/").map(String.init)
        guard parts.count == 2, let adapter = adapters[parts[1]] else { return HTTPResponse(status: 404) }

        let payload = try JSONDecoder().decode(ToolRequest.self, from: request.body)
        try validator.validate(args: payload.args)
        let hash = SHA256.hash(data: Data(payload.args.joined(separator: " ").utf8)).compactMap { String(format: "%02x", $0) }.joined()
        var output = Data()
        var code: Int32 = -1
        try toolsmith.run(tool: adapter.tool, metadata: ["args_hash": hash], requestID: payload.request_id ?? UUID().uuidString) {
            let result = try adapter.run(args: payload.args)
            output = result.0
            code = result.1
        }
        return HTTPResponse(status: Int(code == 0 ? 200 : 500), body: output)
    }
}

public struct ToolRequest: Codable {
    public let args: [String]
    public let request_id: String?
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
