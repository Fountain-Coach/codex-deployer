import Foundation
/// Request type for creating a DNS record through the Hetzner API.
/// Encodes `RecordCreate` as the POST body and expects a `RecordResponse`.


public struct CreateRecord: APIRequest {
    public typealias Body = RecordCreate
    public typealias Response = RecordResponse
    public var method: String { "POST" }
    public var path: String { "/records" }
    public var body: Body?
    /// Creates a new request instance.
    /// - Parameter body: The record parameters to send.

    public init(body: Body? = nil) {
        self.body = body
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
