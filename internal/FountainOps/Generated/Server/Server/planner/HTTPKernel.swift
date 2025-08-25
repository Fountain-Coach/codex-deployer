import Foundation
import ServiceShared

/// Planner service kernel. Requires a bearer token when
/// `PLANNER_AUTH_TOKEN` is set. See `docs/environment_variables.md`.
public struct HTTPKernel {
    let router: Router

    public init(handlers: Handlers = Handlers()) {
        self.router = Router(handlers: handlers)
    }

    public func handle(_ request: HTTPRequest) async throws -> HTTPResponse {
        if let token = ProcessInfo.processInfo.environment["PLANNER_AUTH_TOKEN"] {
            let expected = "Bearer \(token)"
            if request.headers["Authorization"] != expected {
                return HTTPResponse(status: 401)
            }
        }
        let resp = try await router.route(request)
        await PrometheusAdapter.shared.record(service: "planner", path: request.path)
        return resp
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
