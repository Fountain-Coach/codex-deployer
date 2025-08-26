import Foundation

public struct CorpusCreateRequest: Codable, Sendable { public let corpusId: String }
public struct CorpusResponse: Codable, Sendable { public let corpusId: String; public let message: String }

public struct Baseline: Codable, Sendable {
    public let corpusId: String
    public let baselineId: String
    public let content: String

    public init(corpusId: String, baselineId: String, content: String) {
        self.corpusId = corpusId
        self.baselineId = baselineId
        self.content = content
    }
}

public struct Reflection: Codable, Sendable {
    public let corpusId: String
    public let reflectionId: String
    public let question: String
    public let content: String

    public init(corpusId: String, reflectionId: String, question: String, content: String) {
        self.corpusId = corpusId
        self.reflectionId = reflectionId
        self.question = question
        self.content = content
    }
}

public struct FunctionModel: Codable, Sendable {
    public let corpusId: String
    public let functionId: String
    public let name: String
    public let description: String
    public let httpMethod: String
    public let httpPath: String

    public init(corpusId: String, functionId: String, name: String, description: String, httpMethod: String, httpPath: String) {
        self.corpusId = corpusId
        self.functionId = functionId
        self.name = name
        self.description = description
        self.httpMethod = httpMethod
        self.httpPath = httpPath
    }
}

public struct SuccessResponse: Codable, Sendable { public let message: String }

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
