import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import BaselineAwarenessService

/// Simple URLProtocol based HTTP server used for integration tests.
@preconcurrency public class HTTPServer: URLProtocol {
    /// Shared kernel used to handle HTTP requests.
    nonisolated(unsafe) static var kernel: HTTPKernel?

    /// Register the kernel that will handle incoming requests.
    public static func register(kernel: HTTPKernel) {
        self.kernel = kernel
        // Silence warning about unused return value.
        _ = URLProtocol.registerClass(HTTPServer.self)
    }

    public override class func canInit(with request: URLRequest) -> Bool {
        request.url?.host == "localhost"
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override public func startLoading() {
        guard let kernel = HTTPServer.kernel, let url = self.request.url else {
            self.client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        let req = HTTPRequest(
            method: self.request.httpMethod ?? "GET",
            path: url.path,
            headers: self.request.allHTTPHeaderFields ?? [:],
            body: self.request.httpBody ?? Data()
        )
        let client = self.client
        let strongSelf = self
        Task { @Sendable in
            do {
                let resp = try await kernel.handle(req)
                let httpResponse = HTTPURLResponse(
                    url: url,
                    statusCode: resp.status,
                    httpVersion: "HTTP/1.1",
                    headerFields: resp.headers
                )!
                client?.urlProtocol(strongSelf, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(strongSelf, didLoad: resp.body)
                client?.urlProtocolDidFinishLoading(strongSelf)
            } catch {
                client?.urlProtocol(strongSelf, didFailWithError: error)
            }
        }
    }

    override public func stopLoading() {}
}
