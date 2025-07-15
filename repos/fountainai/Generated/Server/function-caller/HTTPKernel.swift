import Foundation
import ServiceShared

/// Function Caller service kernel. Requires a bearer token when
/// `FUNCTION_CALLER_AUTH_TOKEN` is set. See `docs/environment_variables.md`.

public struct HTTPKernel {
    let router: Router

    public init(handlers: Handlers = Handlers()) {
        self.router = Router(handlers: handlers)
    }

    public func handle(_ request: HTTPRequest) async throws -> HTTPResponse {
        if let token = ProcessInfo.processInfo.environment["FUNCTION_CALLER_AUTH_TOKEN"] {
            let expected = "Bearer \(token)"
            if request.headers["Authorization"] != expected { return HTTPResponse(status: 401) }
        }
        let start = Date()
        let resp = try await router.route(request)
        let duration = Date().timeIntervalSince(start)
        await PrometheusAdapter.shared.record(service: "function-caller", path: request.path)
        await PrometheusAdapter.shared.recordDuration(service: "function-caller", path: request.path, duration: duration)
        await PrometheusAdapter.shared.recordResult(service: "function-caller", path: request.path, success: resp.status < 400)
        Logger.logRequest(method: request.method, path: request.path, status: resp.status, duration: duration)
        return resp
    }
}
