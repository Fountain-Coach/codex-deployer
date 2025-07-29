import Foundation
import ServiceShared

/// Implements the Function Caller dispatch mechanism. Registered functions are
/// looked up from the shared TypesenseClient and invoked via URLSession.
public struct Handlers {
    let dispatcher = FunctionDispatcher()

    public init() {}

    public func getFunctionDetails(_ request: HTTPRequest) async throws -> HTTPResponse {
        guard let id = request.path.split(separator: "/").last else {
            return HTTPResponse(status: 404)
        }
        guard let fn = await TypesenseClient.shared.functionDetails(id: String(id)) else {
            return HTTPResponse(status: 404)
        }
        let enc = JSONEncoder()
        enc.keyEncodingStrategy = .convertToSnakeCase
        let data = try enc.encode(fn)
        return HTTPResponse(body: data)
    }

    public func listFunctions(_ request: HTTPRequest) async throws -> HTTPResponse {
        let fns = await TypesenseClient.shared.listFunctions()
        let enc = JSONEncoder()
        enc.keyEncodingStrategy = .convertToSnakeCase
        let data = try enc.encode(fns)
        return HTTPResponse(body: data)
    }

    public func invokeFunction(_ request: HTTPRequest) async throws -> HTTPResponse {
        guard let id = request.path.split(separator: "/").dropLast().last else {
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
