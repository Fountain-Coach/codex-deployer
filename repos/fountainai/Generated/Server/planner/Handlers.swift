import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import ServiceShared

/// Planner handlers orchestrating requests to the LLM Gateway and Function
/// Caller services.

public struct Handlers {
    let llm = LLMGatewayClient()
    let functions = LocalFunctionCallerClient()

    public init() {}

    public func plannerReason(_ request: HTTPRequest) async throws -> HTTPResponse {
        guard let objective = try? JSONDecoder().decode(UserObjectiveRequest.self, from: request.body).objective else {
            return HTTPResponse(status: 400)
        }
        let steps = try await llm.chat(objective: objective)
        let data = try JSONEncoder().encode(PlanResponse(objective: objective, steps: steps))
        return HTTPResponse(body: data)
    }

    public func getSemanticArc(_ request: HTTPRequest) async throws -> HTTPResponse {
        guard let id = request.path.split(separator: "/").dropLast().last else {
            return HTTPResponse(status: 404)
        }
        let count = await TypesenseClient.shared.historyCount(for: String(id))
        let data = try JSONEncoder().encode(["summary": "items: \(count)"])
        return HTTPResponse(body: data)
    }
    public func plannerListCorpora(_ request: HTTPRequest) async throws -> HTTPResponse {
        let ids = await TypesenseClient.shared.listCorpora()
        let data = try JSONEncoder().encode(ids)
        return HTTPResponse(body: data)
    }
    public func getReflectionHistory(_ request: HTTPRequest) async throws -> HTTPResponse {
        guard let id = request.path.split(separator: "/").last else {
            return HTTPResponse(status: 404)
        }
        let count = await TypesenseClient.shared.reflectionCount(for: String(id))
        let data = try JSONEncoder().encode(HistoryListResponse(reflections: "\(count)"))
        return HTTPResponse(body: data)
    }
    public func plannerExecute(_ request: HTTPRequest) async throws -> HTTPResponse {
        guard let plan = try? JSONDecoder().decode(PlanExecutionRequest.self, from: request.body) else {
            return HTTPResponse(status: 400)
        }
        let resultData = try await functions.invoke(functionId: plan.steps, payload: Data(plan.objective.utf8))
        let result = String(data: resultData, encoding: .utf8) ?? ""
        let data = try JSONEncoder().encode(ExecutionResult(results: result))
        return HTTPResponse(body: data)
    }
    public func postReflection(_ request: HTTPRequest) async throws -> HTTPResponse {
        guard let model = try? JSONDecoder().decode(ChatReflectionRequest.self, from: request.body) else {
            return HTTPResponse(status: 400)
        }
        let item = Reflection(content: model.message, corpusId: model.corpus_id, question: model.message, reflectionId: UUID().uuidString)
        await TypesenseClient.shared.addReflection(item)
        let resp = ReflectionItem(content: model.message, timestamp: ISO8601DateFormatter().string(from: Date()))
        let data = try JSONEncoder().encode(resp)
        return HTTPResponse(body: data)
    }
}
