import Foundation

public struct CorpusCreateRequest: Codable, Sendable { public let corpusId: String }
public struct CorpusResponse: Codable, Sendable { public let corpusId: String; public let message: String }

public struct Baseline: Codable, Sendable {
    public let corpusId: String
    public let baselineId: String
    public let content: String
}

public struct Reflection: Codable, Sendable {
    public let corpusId: String
    public let reflectionId: String
    public let question: String
    public let content: String
}

public struct FunctionModel: Codable, Sendable {
    public let functionId: String
    public let name: String
    public let description: String
    public let httpMethod: String
    public let httpPath: String
}

public struct SuccessResponse: Codable, Sendable { public let message: String }

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

