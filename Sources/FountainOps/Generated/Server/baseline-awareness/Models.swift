// Models for Baseline Awareness Service

public struct BaselineRequest: Codable, Sendable {
    public let baselineId: String
    public let content: String
    public let corpusId: String

    public init(baselineId: String, content: String, corpusId: String) {
        self.baselineId = baselineId
        self.content = content
        self.corpusId = corpusId
    }
}

public struct DriftRequest: Codable, Sendable {
    public let content: String
    public let corpusId: String
    public let driftId: String

    public init(content: String, corpusId: String, driftId: String) {
        self.content = content
        self.corpusId = corpusId
        self.driftId = driftId
    }
}

public struct HistorySummaryResponse: Codable, Sendable {
    public let summary: String
}

public struct InitIn: Codable, Sendable {
    public let corpusId: String
}

public struct InitOut: Codable, Sendable {
    public let message: String
}

public struct PatternsRequest: Codable, Sendable {
    public let content: String
    public let corpusId: String
    public let patternsId: String

    public init(content: String, corpusId: String, patternsId: String) {
        self.content = content
        self.corpusId = corpusId
        self.patternsId = patternsId
    }
}

public struct ReflectionRequest: Codable, Sendable {
    public let content: String
    public let corpusId: String
    public let question: String
    public let reflectionId: String

    public init(content: String, corpusId: String, question: String, reflectionId: String) {
        self.content = content
        self.corpusId = corpusId
        self.question = question
        self.reflectionId = reflectionId
    }
}

public struct ReflectionSummaryResponse: Codable, Sendable {
    public let message: String
}

public struct HistoryAnalyticsResponse: Codable, Sendable {
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
