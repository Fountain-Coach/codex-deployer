import Foundation

public struct chatWithObjective: APIRequest {
    public typealias Body = ChatRequest
    public typealias Response = chatWithObjectiveResponse
    public var method: String { "POST" }
    public var path: String { "/chat" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
