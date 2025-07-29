import Foundation

struct Logger {
    static func logRequest(method: String, path: String, status: Int, duration: Double) {
        let entry: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "method": method,
            "path": path,
            "status": status,
            "duration_ms": Int(duration * 1000)
        ]
        if let data = try? JSONSerialization.data(withJSONObject: entry),
           let text = String(data: data, encoding: .utf8) {
            print(text)
        }
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
