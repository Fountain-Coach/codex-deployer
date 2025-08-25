import Foundation

// Placeholder client for llm-gateway (generated code stub)
public struct APIClient {
    public let baseURL: URL
    public init(baseURL: URL) { self.baseURL = baseURL }

    public func send<R: APIRequest>(_ request: R) async throws -> R.Response {
        // Stub: provide no implementation. Replace with generated client.
        fatalError("APIClient.send(_:): generated stub")
    }
}
