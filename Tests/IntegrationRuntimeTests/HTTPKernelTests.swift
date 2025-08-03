import XCTest
@testable import FountainCodex

final class HTTPKernelTests: XCTestCase {
    /// Ensures the ``HTTPKernel`` routes requests to the correct handler.
    func testKernelRoutesRequest() async throws {
        let kernel = HTTPKernel { req in
            if req.path == "/hello" {
                return HTTPResponse(status: 200, body: Data("world".utf8))
            }
            return HTTPResponse(status: 404)
        }
        let request = HTTPRequest(method: "GET", path: "/hello")
        let response = try await kernel.handle(request)
        XCTAssertEqual(response.status, 200)
        XCTAssertEqual(String(data: response.body, encoding: .utf8), "world")
    }

    /// Ensures errors thrown by the route are propagated to the caller.
    func testKernelPropagatesErrors() async {
        enum SampleError: Error { case boom }
        let kernel = HTTPKernel { _ in throw SampleError.boom }
        do {
            _ = try await kernel.handle(HTTPRequest(method: "GET", path: "/"))
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is SampleError)
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
