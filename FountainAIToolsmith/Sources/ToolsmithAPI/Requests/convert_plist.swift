import Foundation

public struct convert_plist: APIRequest {
    public struct Payload: Codable { let args: [String]; let request_id: String? }
    public typealias Response = Data
    public var method: String { "POST" }
    public var path: String { "/libplist" }
    let args: [String]
    public init(args: [String]) { self.args = args }
    public var body: Data? { try? JSONEncoder().encode(Payload(args: args, request_id: nil)) }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
