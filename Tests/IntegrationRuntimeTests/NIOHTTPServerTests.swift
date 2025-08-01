import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import FountainCodex

final class NIOHTTPServerTests: XCTestCase {
    /// Starts the server and verifies a simple request receives a response.
    func testServerResponds() async throws {
        let kernel = HTTPKernel { _ in HTTPResponse(status: 200, body: Data("hi".utf8)) }
        let server = NIOHTTPServer(kernel: kernel)
        let port = try await server.start(port: 0)
        let url = URL(string: "http://127.0.0.1:\(port)/")!
        let (data, response) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
        XCTAssertEqual(String(data: data, encoding: .utf8), "hi")
        try await server.stop()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
