// Models for FountainAI LLM Gateway

public struct ChatRequest: Codable {
    public let function_call: String
    public let functions: [FunctionObject]
    public let messages: [MessageObject]
    public let model: String
}

public struct FunctionCallObject: Codable {
    public let name: String
}

public struct FunctionObject: Codable {
    public let description: String
    public let name: String
}

public struct HTTPValidationError: Codable {
    public let detail: [ValidationError]
}

public struct MessageObject: Codable {
    public let content: String
    public let role: String
}

public struct SecurityCheckRequest: Codable {
    public let resources: [String]
    public let summary: String
    public let user: String
}

public struct SecurityDecision: Codable {
    public let decision: String
}

public struct ValidationError: Codable {
    public let loc: [String]
    public let msg: String
    public let type: String
}

public typealias metrics_metrics_getResponse = [String: String]

public typealias chatWithObjectiveResponse = [String: String]


// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
