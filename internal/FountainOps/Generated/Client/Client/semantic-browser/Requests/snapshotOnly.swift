import Foundation

public struct snapshotOnly: APIRequest {
    public typealias Body = SnapshotRequest
    public typealias Response = SnapshotResponse
    public var method: String { "POST" }
    public var path: String { "/v1/snapshot" }
    public var body: Body?

    public init(body: Body? = nil) {
        self.body = body
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
