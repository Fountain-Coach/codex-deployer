import XCTest
import NIOCore
import NIOHTTP1
@testable import FountainCodex

final class AsyncHTTPClientDriverTests: XCTestCase {
    /// Ensures the driver performs requests and returns responses.
    func testExecutePerformsRequest() async throws {
        let kernel = HTTPKernel { req in
            XCTAssertEqual(req.headers["X-Req"], "1")
            return HTTPResponse(status: 200, headers: ["X-Reply": "ok"], body: Data("pong".utf8))
        }
        let server = NIOHTTPServer(kernel: kernel)
        let port = try await server.start(port: 0)

        let client = AsyncHTTPClientDriver()
        let (buffer, headers) = try await client.execute(method: .GET, url: "http://127.0.0.1:\(port)", headers: HTTPHeaders([( "X-Req", "1")]), body: nil)
        XCTAssertEqual(buffer.getString(at: 0, length: buffer.readableBytes), "pong")
        XCTAssertEqual(headers.first(name: "X-Reply"), "ok")

        try await client.shutdown()
        try await server.stop()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
