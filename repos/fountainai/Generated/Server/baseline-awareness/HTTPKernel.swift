import Foundation
import ServiceShared

/// Baseline Awareness service kernel. Requires a bearer token when
/// `BASELINE_AUTH_TOKEN` is set. See `docs/environment_variables.md`.

public struct HTTPKernel {
    let router: Router

    public init(handlers: Handlers = Handlers()) {
        self.router = Router(handlers: handlers)
    }

    public func handle(_ request: HTTPRequest) async throws -> HTTPResponse {
        if let token = ProcessInfo.processInfo.environment["BASELINE_AUTH_TOKEN"] {
            let expected = "Bearer \(token)"
            if request.headers["Authorization"] != expected {
                return HTTPResponse(status: 401)
            }
        }
        let start = Date()
        let resp = try await router.route(request)
        let duration = Date().timeIntervalSince(start)
        await PrometheusAdapter.shared.record(service: "baseline-awareness", path: request.path)
        await PrometheusAdapter.shared.recordDuration(service: "baseline-awareness", path: request.path, duration: duration)
        return resp
    }
}
