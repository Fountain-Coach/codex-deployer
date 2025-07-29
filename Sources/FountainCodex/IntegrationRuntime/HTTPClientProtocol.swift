import NIOCore
import NIOHTTP1

public protocol HTTPClientProtocol {
    func execute(method: HTTPMethod, url: String, headers: HTTPHeaders, body: ByteBuffer?) async throws -> (ByteBuffer, HTTPHeaders)
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
