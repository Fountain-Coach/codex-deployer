// Models for Baseline Awareness Service

public struct BaselineRequest: Codable {
    public let baselineId: String
    public let content: String
    public let corpusId: String
}

public struct DriftRequest: Codable {
    public let content: String
    public let corpusId: String
    public let driftId: String
}

public struct HistorySummaryResponse: Codable {
    public let summary: String
}

public struct InitIn: Codable {
    public let corpusId: String
}

public struct InitOut: Codable {
    public let message: String
}

public struct PatternsRequest: Codable {
    public let content: String
    public let corpusId: String
    public let patternsId: String
}

public struct ReflectionRequest: Codable {
    public let content: String
    public let corpusId: String
    public let question: String
    public let reflectionId: String
}

public struct ReflectionSummaryResponse: Codable {
    public let message: String
}

public struct HistoryAnalyticsResponse: Codable {
    public let baselines: Int
    public let drifts: Int
    public let patterns: Int
    public let reflections: Int
}

public typealias readSemanticArcResponse = String

public typealias addReflectionResponse = String

public typealias addDriftResponse = String

public typealias listHistoryAnalyticsResponse = HistoryAnalyticsResponse

public typealias addPatternsResponse = String

public typealias health_health_getResponse = String

public typealias addBaselineResponse = String


© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
