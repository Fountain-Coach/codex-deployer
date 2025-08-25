// Placeholder request protocol for llm-gateway (generated code stub)
public protocol APIRequest {
    associatedtype Response: Decodable
    associatedtype Body: Encodable
    var method: String { get }
    var path: String { get }
    var body: Body? { get }
}
