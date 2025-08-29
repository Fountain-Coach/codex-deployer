import Foundation

/// Chat message used in ``ChatRequest``.
public struct MessageObject: Codable {
    public let role: String
    public let content: String
    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

/// Function description for ``ChatRequest``.
public struct FunctionObject: Codable {
    public let name: String
    public let description: String?
    public init(name: String, description: String? = nil) {
        self.name = name
        self.description = description
    }
}

/// Explicit function call request.
public struct FunctionCallObject: Codable {
    public let name: String
    public init(name: String) { self.name = name }
}

/// Function call option for ``ChatRequest``.
public enum FunctionCall: Codable {
    case auto
    case named(FunctionCallObject)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self), value == "auto" {
            self = .auto
        } else {
            let obj = try container.decode(FunctionCallObject.self)
            self = .named(obj)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .auto:
            try container.encode("auto")
        case .named(let obj):
            try container.encode(obj)
        }
    }
}

/// Request body for the chat endpoint.
public struct ChatRequest: Codable {
    public let model: String
    public let messages: [MessageObject]
    public let functions: [FunctionObject]?
    public let function_call: FunctionCall?
    public let include_cot: Bool?
    public init(model: String, messages: [MessageObject], functions: [FunctionObject]? = nil, function_call: FunctionCall? = nil, include_cot: Bool? = nil) {
        self.model = model
        self.messages = messages
        self.functions = functions
        self.function_call = function_call
        self.include_cot = include_cot
    }
}

/// Request sent to the sentinel consult endpoint.
public struct SecurityCheckRequest: Codable {
    public let summary: String
    public let user: String
    public let resources: [String]
    public init(summary: String, user: String, resources: [String]) {
        self.summary = summary
        self.user = user
        self.resources = resources
    }
}

/// Response returned by the sentinel containing its decision.
public struct SecurityDecision: Codable {
    public let decision: String
    public init(decision: String) { self.decision = decision }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
