import Foundation
import FountainCodex

/// Plugin that logs chain-of-thought responses when requested.
/// When a `/chat` request includes `include_cot: true`, any `cot`
/// field returned in the response body is appended to a log file.
public struct CoTLogger: GatewayPlugin {
    private let logURL: URL

    /// Creates a new logger.
    /// - Parameter logURL: Destination file for captured reasoning steps.
    public init(logURL: URL = URL(fileURLWithPath: "logs/cot.log")) {
        self.logURL = logURL
    }

    /// Saves chain-of-thought steps when present and requested.
    /// - Parameters:
    ///   - response: Response returned from the routed handler.
    ///   - request: Original request that may contain the `include_cot` flag.
    /// - Returns: The unmodified response.
    public func respond(_ response: HTTPResponse, for request: HTTPRequest) async throws -> HTTPResponse {
        guard request.path == "/chat" else { return response }
        guard let reqJSON = try? JSONSerialization.jsonObject(with: request.body) as? [String: Any],
              (reqJSON["include_cot"] as? Bool) == true else { return response }
        guard let respJSON = try? JSONSerialization.jsonObject(with: response.body) as? [String: Any],
              let cot = respJSON["cot"] else { return response }
        let line = "\(cot)\n"
        do {
            let dir = logURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            if !FileManager.default.fileExists(atPath: logURL.path) {
                _ = FileManager.default.createFile(atPath: logURL.path, contents: nil)
            }
            let handle = try FileHandle(forWritingTo: logURL)
            defer { try? handle.close() }
            try handle.seekToEnd()
            try handle.write(contentsOf: Data(line.utf8))
        } catch {
            // ignore logging errors
        }
        return response
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

