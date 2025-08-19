import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct JSONLogger {
    func log(_ entry: LogEntry) {
        if let data = try? JSONEncoder().encode(entry), let line = String(data: data, encoding: .utf8) {
            print(line)
        }
    }

    func exportSpan(_ span: Span) {
        guard let urlString = ProcessInfo.processInfo.environment["OTEL_EXPORT_URL"],
              let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(span)
        URLSession.shared.dataTask(with: request).resume()
    }
}

struct LogEntry: Codable {
    let request_id: String
    let tool: String
    let duration_ms: Int
    let metadata: [String: String]
}

struct Span: Codable {
    let trace_id: String
    let span_id: String
    let parent_id: String?
    let name: String
    let start: Date
    let end: Date
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

