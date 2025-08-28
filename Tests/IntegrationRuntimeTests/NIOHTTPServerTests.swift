import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import FountainRuntime

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

    /// Stopping the server should free the port allowing a subsequent bind.
    func testServerReleasesPortOnStop() async throws {
        let kernel = HTTPKernel { _ in HTTPResponse(status: 204) }
        let server = NIOHTTPServer(kernel: kernel)
        let port = try await server.start(port: 0)
        try await server.stop()
        let server2 = NIOHTTPServer(kernel: kernel)
        let boundPort = try await server2.start(port: port)
        XCTAssertEqual(boundPort, port)
        try await server2.stop()
    }

    /// The server should handle multiple simultaneous requests.
    func testServerHandlesConcurrentRequests() async throws {
        let kernel = HTTPKernel { _ in HTTPResponse(status: 200, body: Data("ok".utf8)) }
        let server = NIOHTTPServer(kernel: kernel)
        let port = try await server.start(port: 0)
        let url = URL(string: "http://127.0.0.1:\(port)/")!
        async let first = URLSession.shared.data(from: url)
        async let second = URLSession.shared.data(from: url)
        let (d1, r1) = try await first
        let (d2, r2) = try await second
        XCTAssertEqual((r1 as? HTTPURLResponse)?.statusCode, 200)
        XCTAssertEqual((r2 as? HTTPURLResponse)?.statusCode, 200)
        XCTAssertEqual(String(data: d1, encoding: .utf8), "ok")
        XCTAssertEqual(String(data: d2, encoding: .utf8), "ok")
        try await server.stop()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
