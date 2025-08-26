import Foundation
import FountainCodex

/// Collection of handlers for budget breaker routes.
public actor Handlers {
    public init() {}

    public func budgetCheck(_ request: HTTPRequest, body: BudgetCheckRequest?) async throws -> HTTPResponse {
        guard let body else { return HTTPResponse(status: 400) }
        let response = BudgetCheckResponse(allowed: true, remaining: 0)
        let data = try JSONEncoder().encode(response)
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
    }

    public func budgetHealth(_ request: HTTPRequest, body: NoBody?) async throws -> HTTPResponse {
        let response = BudgetHealthResponse(status: "ok")
        let data = try JSONEncoder().encode(response)
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
