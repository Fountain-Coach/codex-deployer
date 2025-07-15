import Foundation
import FoundationNetworking
import BaselineAwarenessService

public class HTTPServer: URLProtocol, @unchecked Sendable {
    /// Shared kernel protected by an actor for concurrency safety.
    private actor KernelBox {
        var kernel: HTTPKernel?
        func set(_ kernel: HTTPKernel) { self.kernel = kernel }
        func get() -> HTTPKernel? { kernel }
    }

    private static let kernelBox = KernelBox()

    public static func register(kernel: HTTPKernel) async {
        await kernelBox.set(kernel)
        _ = URLProtocol.registerClass(HTTPServer.self)
    }

    public override class func canInit(with request: URLRequest) -> Bool {
        request.url?.host == "localhost"
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override public func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        let method = request.httpMethod ?? "GET"
        let headers = request.allHTTPHeaderFields ?? [:]
        let body = request.httpBody ?? Data()
        Task { [self] in
            guard let kernel = await HTTPServer.kernelBox.get() else {
                await MainActor.run { client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse)) }
                return
            }
            let req = HTTPRequest(method: method, path: url.path, headers: headers, body: body)
            do {
                let resp = try await kernel.handle(req)
                let httpResponse = HTTPURLResponse(url: url, statusCode: resp.status, httpVersion: "HTTP/1.1", headerFields: resp.headers)!
                await MainActor.run {
                    client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
                    client?.urlProtocol(self, didLoad: resp.body)
                    client?.urlProtocolDidFinishLoading(self)
                }
            } catch {
                await MainActor.run { client?.urlProtocol(self, didFailWithError: error) }
            }
        }
    }

    override public func stopLoading() {}
}
