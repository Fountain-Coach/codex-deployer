import Foundation

public protocol APIRequest {
    associatedtype Response: Decodable
    var method: String { get }
    var path: String { get }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
