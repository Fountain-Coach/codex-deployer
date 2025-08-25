import Foundation
import ServiceShared

/// Implements the Function Caller dispatch mechanism. Registered functions are
/// looked up from the shared TypesenseClient and invoked via URLSession.
public struct Handlers {
    let dispatcher = FunctionDispatcher()

    public init() {}

    public func getFunctionDetails(_ request: HTTPRequest) async throws -> HTTPResponse {
        guard let raw = request.path.split(separator: "/").last?.split(separator: "?").first else {
            return HTTPResponse(status: 404)
        }
        guard let fn = await TypesenseClient.shared.functionDetails(id: String(raw)) else {
            return HTTPResponse(status: 404)
        }
        let enc = JSONEncoder()
        enc.keyEncodingStrategy = .convertToSnakeCase
        let data = try enc.encode(fn)
        return HTTPResponse(body: data)
    }

    public func listFunctions(_ request: HTTPRequest) async throws -> HTTPResponse {
        let items = await TypesenseClient.shared.listFunctions()
        let comps = URLComponents(string: request.path)
        let page = comps?.queryItems?.first(where: { $0.name == "page" }).flatMap { Int($0.value ?? "") } ?? 1
        let pageSize = comps?.queryItems?.first(where: { $0.name == "page_size" }).flatMap { Int($0.value ?? "") } ?? 20
        let start = max(0, (page - 1) * pageSize)
        let end = min(start + pageSize, items.count)
        let pageItems = start < items.count ? Array(items[start..<end]) : []
        let envelope = FunctionListResponse(functions: pageItems, page: page, page_size: pageSize, total: items.count)
        let enc = JSONEncoder()
        enc.keyEncodingStrategy = .convertToSnakeCase
        let data = try enc.encode(envelope)
        return HTTPResponse(body: data)
    }

    public func invokeFunction(_ request: HTTPRequest) async throws -> HTTPResponse {
        guard let id = request.path.split(separator: "/").dropLast().last?.split(separator: "?").first else {
            return HTTPResponse(status: 404)
        }
        do {
            let result = try await dispatcher.invoke(functionId: String(id), payload: request.body)
            return HTTPResponse(body: result)
        } catch FunctionDispatcher.DispatchError.notFound {
            let data = try JSONEncoder().encode(ErrorResponse(error_code: "not_found", message: "Function not found"))
            return HTTPResponse(status: 404, body: data)
        } catch FunctionDispatcher.DispatchError.invalidParams {
            let data = try JSONEncoder().encode(ErrorResponse(error_code: "validation_error", message: "Invalid parameters"))
            return HTTPResponse(status: 400, body: data)
        } catch FunctionDispatcher.DispatchError.server(let code) {
            let data = try JSONEncoder().encode(ErrorResponse(error_code: "dispatch_error", message: "Remote error"))
            return HTTPResponse(status: code, body: data)
        } catch {
            let data = try JSONEncoder().encode(ErrorResponse(error_code: "internal_error", message: error.localizedDescription))
            return HTTPResponse(status: 500, body: data)
        }
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
