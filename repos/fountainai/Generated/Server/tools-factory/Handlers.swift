import Foundation
import ServiceShared
import Parser
import Yams

/// Implements the Tools Factory persistence logic backed by ``TypesenseClient``.
public struct Handlers {
    let typesense: TypesenseClient

    public init(typesense: TypesenseClient = .shared) {
        self.typesense = typesense
        Task {
            if await typesense.listFunctions().isEmpty {
                let f1 = Function(description: "test1", functionId: "test1", httpMethod: "GET", httpPath: "http://example.com/test1", name: "test1")
                let f2 = Function(description: "test2", functionId: "test2", httpMethod: "GET", httpPath: "http://example.com/test2", name: "test2")
                await typesense.addFunction(f1)
                await typesense.addFunction(f2)
            }
        }
    }

    /// Registers one or more functions defined by an OpenAPI document.
    /// The request body may contain JSON or YAML. Each operationId is mapped to
    /// a ``Function`` persisted via ``TypesenseClient``.
    public func registerOpenapi(_ request: HTTPRequest) async throws -> HTTPResponse {
        let data = request.body

        if let list = try? JSONDecoder().decode([Function].self, from: data) {
            for fn in list { await typesense.addFunction(fn) }
            let enc = JSONEncoder()
            enc.keyEncodingStrategy = .convertToSnakeCase
            let respData = try enc.encode(list)
            return HTTPResponse(body: respData)
        }

        let spec: OpenAPISpec
        do {
            if let decoded = try? JSONDecoder().decode(OpenAPISpec.self, from: data) {
                spec = decoded
            } else if let string = String(data: data, encoding: .utf8),
                      let yaml = try? Yams.load(yaml: string),
                      let json = try? JSONSerialization.data(withJSONObject: yaml),
                      let decoded = try? JSONDecoder().decode(OpenAPISpec.self, from: json) {
                spec = decoded
            } else {
                throw SpecValidator.ValidationError("invalid document")
            }
            try SpecValidator.validate(spec)
        } catch let error as SpecValidator.ValidationError {
            let payload = try JSONEncoder().encode(ErrorResponse(error_code: "validation_error", message: error.message))
            return HTTPResponse(status: 422, body: payload)
        } catch {
            let payload = try JSONEncoder().encode(ErrorResponse(error_code: "parse_error", message: "Unable to parse document"))
            return HTTPResponse(status: 422, body: payload)
        }

        var functions: [Function] = []
        if let paths = spec.paths {
            for (path, item) in paths {
                if let op = item.get {
                    let schemaData = op.requestBody?.content["application/json"]?.schema
                    let schemaString = schemaData.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
                    functions.append(Function(description: op.operationId,
                                                functionId: op.operationId,
                                                httpMethod: "GET",
                                                httpPath: path,
                                                name: op.operationId,
                                                parametersSchema: schemaString))
                }
                if let op = item.post {
                    let schemaData = op.requestBody?.content["application/json"]?.schema
                    let schemaString = schemaData.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
                    functions.append(Function(description: op.operationId,
                                                functionId: op.operationId,
                                                httpMethod: "POST",
                                                httpPath: path,
                                                name: op.operationId,
                                                parametersSchema: schemaString))
                }
                if let op = item.put {
                    let schemaData = op.requestBody?.content["application/json"]?.schema
                    let schemaString = schemaData.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
                    functions.append(Function(description: op.operationId,
                                                functionId: op.operationId,
                                                httpMethod: "PUT",
                                                httpPath: path,
                                                name: op.operationId,
                                                parametersSchema: schemaString))
                }
                if let op = item.delete {
                    let schemaData = op.requestBody?.content["application/json"]?.schema
                    let schemaString = schemaData.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
                    functions.append(Function(description: op.operationId,
                                                functionId: op.operationId,
                                                httpMethod: "DELETE",
                                                httpPath: path,
                                                name: op.operationId,
                                                parametersSchema: schemaString))
                }
            }
        }

        for fn in functions { await typesense.addFunction(fn) }
        let enc = JSONEncoder()
        enc.keyEncodingStrategy = .convertToSnakeCase
        let respData = try enc.encode(functions)
        return HTTPResponse(body: respData)
    }

    /// Returns all stored function definitions.
    public func listTools(_ request: HTTPRequest) async throws -> HTTPResponse {
        let items = await typesense.listFunctions()
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(items)
        return HTTPResponse(body: data)
    }
}
