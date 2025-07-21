import Foundation

public struct createConversationModel: APIRequest {
    public typealias Body = ConversationModelCreateSchema
    public typealias Response = ConversationModelSchema
    public var method: String { "POST" }
    public var path: String { "/conversations/models" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}
