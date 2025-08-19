import Foundation

public protocol APIRequest {
    associatedtype Response: Decodable
    var method: String { get }
    var path: String { get }
    var body: Data? { get }
}

public extension APIRequest {
    var body: Data? { nil }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
