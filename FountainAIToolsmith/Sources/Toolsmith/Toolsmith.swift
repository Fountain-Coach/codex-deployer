import Foundation

public struct Toolsmith {
    let logger = JSONLogger()

    public init() {}

    @discardableResult
    public func run(tool: String, metadata: [String: String] = [:], requestID: String = UUID().uuidString, operation: () throws -> Void) rethrows -> String {
        let start = Date()
        try operation()
        let end = Date()
        let duration = Int(end.timeIntervalSince(start) * 1000)
        var meta = metadata
        if ProcessInfo.processInfo.environment["OTEL_EXPORT_URL"] != nil {
            let spanID = UUID().uuidString
            let span = Span(trace_id: requestID, span_id: spanID, parent_id: nil, name: tool, start: start, end: end)
            logger.exportSpan(span)
            meta["span_id"] = spanID
        }
        let entry = LogEntry(request_id: requestID, tool: tool, duration_ms: duration, metadata: meta)
        logger.log(entry)
        return requestID
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
