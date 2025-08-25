import Foundation

public struct retrieveAllConversationModels: APIRequest {
    public typealias Body = NoBody
    public typealias Response = retrieveAllConversationModelsResponse
    public var method: String { "GET" }
    public var path: String { "/conversations/models" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
