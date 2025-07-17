import XCTest
import IntegrationRuntime
import NIOHTTP1
import ServiceShared

@testable import BaselineAwarenessService
@testable import BaselineAwarenessClient
@testable import BootstrapService
@testable import BootstrapClient
@testable import PersistService
@testable import PersistClient
@testable import FunctionCallerService
@testable import FunctionCallerClient
@testable import PlannerService
@testable import PlannerClient
@testable import ToolsFactoryService
@testable import ToolsFactoryClient
@testable import LLMGatewayService
@testable import LLMGatewayClientSDK

final class ServicesIntegrationTests: XCTestCase {
    var cachePath: String!

    override func setUp() async throws {
        cachePath = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString).path
        setenv("FUNCTIONS_CACHE_PATH", cachePath, 1)
        FileManager.default.createFile(atPath: cachePath, contents: Data(), attributes: nil)
        await TypesenseClient.shared.reset()
        await PrometheusAdapter.shared.reset()
    }

    override func tearDown() async throws {
        await TypesenseClient.shared.reset()
        await PrometheusAdapter.shared.reset()
        unsetenv("FUNCTIONS_CACHE_PATH")
        try? FileManager.default.removeItem(atPath: cachePath)
    }
    func startServer(with kernel: IntegrationRuntime.HTTPKernel) async throws -> (NIOHTTPServer, Int) {
        let server = NIOHTTPServer(kernel: kernel)
        let port = try await server.start(port: 0)
        return (server, port)
    }

    func testBaselineAwarenessHealth() async throws {
        let serviceKernel = BaselineAwarenessService.HTTPKernel()
        let kernel = IntegrationRuntime.HTTPKernel { req in
            let sreq = BaselineAwarenessService.HTTPRequest(method: req.method, path: req.path, headers: req.headers, body: req.body)
            let sresp = try await serviceKernel.handle(sreq)
            return IntegrationRuntime.HTTPResponse(status: sresp.status, body: sresp.body)
        }
        let (server, port) = try await startServer(with: kernel)
        addTeardownBlock { try? await server.stop() }

        let client = BaselineAwarenessClient.APIClient(baseURL: URL(string: "http://127.0.0.1:\(port)")!)
        let data = try await client.sendRaw(BaselineAwarenessClient.health_health_get())
        let status = try JSONDecoder().decode([String: String].self, from: data)
        XCTAssertEqual(status["status"], "ok")
    }

    func testBaselineInitializeAndAdd() async throws {
        let serviceKernel = BaselineAwarenessService.HTTPKernel()
        let kernel = IntegrationRuntime.HTTPKernel { req in
            let sreq = BaselineAwarenessService.HTTPRequest(method: req.method, path: req.path, headers: req.headers, body: req.body)
            let sresp = try await serviceKernel.handle(sreq)
            return IntegrationRuntime.HTTPResponse(status: sresp.status, body: sresp.body)
        }
        let (server, port) = try await startServer(with: kernel)
        addTeardownBlock { try? await server.stop() }

        let client = BaselineAwarenessClient.APIClient(baseURL: URL(string: "http://127.0.0.1:\(port)")!)
        let initBody = BaselineAwarenessClient.InitIn(corpusId: "c1")
        let initResp = try await client.send(BaselineAwarenessClient.initializeCorpus(body: initBody))
        XCTAssertEqual(initResp.message, "created")

        let baselineBody = BaselineAwarenessClient.BaselineRequest(baselineId: "b1", content: "text", corpusId: "c1")
        _ = try await client.send(BaselineAwarenessClient.addBaseline(body: baselineBody))
    }

    func testBaselineHistoryAnalytics() async throws {
        let serviceKernel = BaselineAwarenessService.HTTPKernel()
        let kernel = IntegrationRuntime.HTTPKernel { req in
            let sreq = BaselineAwarenessService.HTTPRequest(method: req.method, path: req.path, headers: req.headers, body: req.body)
            let sresp = try await serviceKernel.handle(sreq)
            return IntegrationRuntime.HTTPResponse(status: sresp.status, body: sresp.body)
        }
        let (server, port) = try await startServer(with: kernel)
        addTeardownBlock { try? await server.stop() }

        let client = BaselineAwarenessClient.APIClient(baseURL: URL(string: "http://127.0.0.1:\(port)")!)
        _ = try await client.send(BaselineAwarenessClient.initializeCorpus(body: .init(corpusId: "a1")))
        _ = try await client.send(BaselineAwarenessClient.addBaseline(body: .init(baselineId: "b1", content: "x", corpusId: "a1")))
        let analytics = try await client.send(BaselineAwarenessClient.listHistoryAnalytics(parameters: .init(corpusId: "a1")))
        XCTAssertEqual(analytics.baselines, 1)
        XCTAssertEqual(analytics.drifts, 0)
        XCTAssertEqual(analytics.patterns, 0)
        XCTAssertEqual(analytics.reflections, 0)
    }

    func testBaselineAnalyticsStream() async throws {
        let kernel = BaselineAwarenessService.HTTPKernel()
        let initBody = try JSONEncoder().encode(BaselineAwarenessService.InitIn(corpusId: "s1"))
        _ = try await kernel.handle(.init(method: "POST", path: "/corpus/init", body: initBody))
        let baseline = BaselineAwarenessService.BaselineRequest(baselineId: "b1", content: "x", corpusId: "s1")
        let bdata = try JSONEncoder().encode(baseline)
        _ = try await kernel.handle(.init(method: "POST", path: "/corpus/baseline", body: bdata))
        let resp = try await kernel.handle(.init(method: "GET", path: "/corpus/history/stream?corpus_id=s1"))
        XCTAssertEqual(resp.headers["Content-Type"], "text/event-stream")
        let text = String(data: resp.body, encoding: .utf8) ?? ""
        XCTAssertTrue(text.contains("event: analytics"))
    }

    func testBaselineAuthMiddleware() async throws {
        setenv("BASELINE_AUTH_TOKEN", "secret", 1)
        let serviceKernel = BaselineAwarenessService.HTTPKernel()
        let kernel = IntegrationRuntime.HTTPKernel { req in
            let sreq = BaselineAwarenessService.HTTPRequest(method: req.method, path: req.path, headers: req.headers, body: req.body)
            let sresp = try await serviceKernel.handle(sreq)
            return IntegrationRuntime.HTTPResponse(status: sresp.status, body: sresp.body)
        }
        let (server, port) = try await startServer(with: kernel)
        addTeardownBlock {
            unsetenv("BASELINE_AUTH_TOKEN")
            try? await server.stop()
        }

        let client = BaselineAwarenessClient.APIClient(baseURL: URL(string: "http://127.0.0.1:\(port)")!)
        var unauthorized = false
        do {
            _ = try await client.send(BaselineAwarenessClient.health_health_get())
        } catch {
            unauthorized = true
        }
        XCTAssertTrue(unauthorized)

        let authedClient = BaselineAwarenessClient.APIClient(baseURL: URL(string: "http://127.0.0.1:\(port)")!, bearerToken: "secret")
        let data = try await authedClient.sendRaw(BaselineAwarenessClient.health_health_get())
        let status = try JSONDecoder().decode([String: String].self, from: data)
        XCTAssertEqual(status["status"], "ok")
    }

    func testFunctionCallerAuthMiddleware() async throws {
        setenv("FUNCTION_CALLER_AUTH_TOKEN", "secret", 1)
        let kernel = FunctionCallerService.HTTPKernel()
        addTeardownBlock { unsetenv("FUNCTION_CALLER_AUTH_TOKEN") }

        let unauthorized = try await kernel.handle(.init(method: "GET", path: "/functions"))
        XCTAssertEqual(unauthorized.status, 401)

        let authorized = try await kernel.handle(.init(method: "GET", path: "/functions", headers: ["Authorization": "Bearer secret"]))
        XCTAssertEqual(authorized.status, 200)
    }

    func testBootstrapSeedRoles() async throws {
        let serviceKernel = BootstrapService.HTTPKernel()
        let kernel = IntegrationRuntime.HTTPKernel { req in
            let sreq = BootstrapService.HTTPRequest(method: req.method, path: req.path, headers: req.headers, body: req.body)
            let sresp = try await serviceKernel.handle(sreq)
            return IntegrationRuntime.HTTPResponse(status: sresp.status, body: sresp.body)
        }
        let (server, port) = try await startServer(with: kernel)
        addTeardownBlock { try? await server.stop() }

        let client = BootstrapClient.APIClient(baseURL: URL(string: "http://127.0.0.1:\(port)")!)
        let data = try await client.sendRaw(BootstrapClient.seedRoles())
        let defaults = try JSONDecoder().decode(BootstrapService.RoleDefaults.self, from: data)
        XCTAssertEqual(defaults.drift, "Analyze drift")
        XCTAssertEqual(defaults.history, "Summarize history")
        XCTAssertEqual(defaults.patterns, "Detect patterns")
        XCTAssertEqual(defaults.semantic_arc, "Synthesize semantic arc")
        XCTAssertEqual(defaults.view_creator, "Create view")
    }

    func testBootstrapInitializeCorpus() async throws {
        let kernel = BootstrapService.HTTPKernel()
        let body = try JSONEncoder().encode(BootstrapService.InitIn(corpusId: "b1"))
        let req = BootstrapService.HTTPRequest(method: "POST", path: "/bootstrap/corpus/init", body: body)
        let resp = try await kernel.handle(req)
        let out = try JSONDecoder().decode(BootstrapService.InitOut.self, from: resp.body)
        XCTAssertEqual(out.message, "created")
        let ids = await TypesenseClient.shared.listCorpora()
        XCTAssertTrue(ids.contains("b1"))
    }

    func testPersistListCorpora() async throws {
        _ = await TypesenseClient.shared.createCorpus(id: "c1")
        let serviceKernel = PersistService.HTTPKernel()
        let kernel = IntegrationRuntime.HTTPKernel { req in
            let sreq = PersistService.HTTPRequest(method: req.method, path: req.path, headers: req.headers, body: req.body)
            let sresp = try await serviceKernel.handle(sreq)
            return IntegrationRuntime.HTTPResponse(status: sresp.status, body: sresp.body)
        }
        let (server, port) = try await startServer(with: kernel)
        addTeardownBlock { try? await server.stop() }

        let client = PersistClient.APIClient(baseURL: URL(string: "http://127.0.0.1:\(port)")!)
        let data = try await client.sendRaw(PersistClient.listCorpora())
        let ids = try JSONDecoder().decode([String].self, from: data)
        XCTAssertEqual(ids, ["c1"])
    }

    func testFunctionCallerListFunctions() async throws {
        let json = #"{"description":"test","functionId":"f1","httpMethod":"GET","httpPath":"http://example.com","name":"fn"}"#.data(using: .utf8)!
        let fn = try JSONDecoder().decode(ServiceShared.Function.self, from: json)
        await TypesenseClient.shared.addFunction(fn)
        let serviceKernel = FunctionCallerService.HTTPKernel()
        let kernel = IntegrationRuntime.HTTPKernel { req in
            let sreq = FunctionCallerService.HTTPRequest(method: req.method, path: req.path, headers: req.headers, body: req.body)
            let sresp = try await serviceKernel.handle(sreq)
            return IntegrationRuntime.HTTPResponse(status: sresp.status, body: sresp.body)
        }
        let (server, port) = try await startServer(with: kernel)
        addTeardownBlock { try? await server.stop() }

      // The Swift OpenAPI generator exposes client types at the module root.
        // Use the FunctionCallerClient namespace to avoid collisions with
        // `PlannerService.FunctionCallerClient`.
      
        let client = FunctionCallerClient.APIClient(baseURL: URL(string: "http://127.0.0.1:\(port)")!)
        let data = try await client.sendRaw(FunctionCallerClient.list_functions())
        let items = try JSONDecoder().decode([FunctionCallerClient.FunctionInfo].self, from: data)
        XCTAssertTrue(items.contains(where: { $0.function_id == "f1" }))
    }

    func testPlannerListCorpora() async throws {
        _ = await TypesenseClient.shared.createCorpus(id: "p1")
        let serviceKernel = PlannerService.HTTPKernel()
        let kernel = IntegrationRuntime.HTTPKernel { req in
            let sreq = PlannerService.HTTPRequest(method: req.method, path: req.path, headers: req.headers, body: req.body)
            let sresp = try await serviceKernel.handle(sreq)
            return IntegrationRuntime.HTTPResponse(status: sresp.status, body: sresp.body)
        }
        let (server, port) = try await startServer(with: kernel)
        addTeardownBlock { try? await server.stop() }

        let client = PlannerClient.APIClient(baseURL: URL(string: "http://127.0.0.1:\(port)")!)
        let data = try await client.sendRaw(PlannerClient.planner_list_corpora())
        let ids = try JSONDecoder().decode([String].self, from: data)
        XCTAssertEqual(ids, ["p1"])
    }

    func testPlannerReason() async throws {
        let kernel = PlannerService.HTTPKernel()
        let objective = "demo"
        let body = try JSONEncoder().encode(PlannerService.UserObjectiveRequest(objective: objective))
        let resp = try await kernel.handle(.init(method: "POST", path: "/planner/reason", body: body))
        let out = try JSONDecoder().decode(PlannerService.PlanResponse.self, from: resp.body)
        XCTAssertEqual(out.objective, objective)
        XCTAssertTrue(out.steps.contains(objective))
    }

    func testPlannerExecute() async throws {
        let echoKernel = IntegrationRuntime.HTTPKernel { _ in
            IntegrationRuntime.HTTPResponse(status: 200, body: Data("done".utf8))
        }
        let echoServer = NIOHTTPServer(kernel: echoKernel)
        let echoPort = try await echoServer.start(port: 0)
        addTeardownBlock { try? await echoServer.stop() }

        let fn = ServiceShared.Function(description: "echo", functionId: "echo", httpMethod: "POST", httpPath: "http://127.0.0.1:\(echoPort)", name: "echo")
        await TypesenseClient.shared.addFunction(fn)

        let kernel = PlannerService.HTTPKernel()
        let plan = PlannerService.PlanExecutionRequest(objective: "demo", steps: "echo")
        let body = try JSONEncoder().encode(plan)
        let resp = try await kernel.handle(.init(method: "POST", path: "/planner/execute", body: body))
        let out = try JSONDecoder().decode(PlannerService.ExecutionResult.self, from: resp.body)
        XCTAssertEqual(out.results, "done")
    }

    func testToolsFactoryListTools() async throws {
        let serviceKernel = ToolsFactoryService.HTTPKernel()
        let kernel = IntegrationRuntime.HTTPKernel { req in
            let sreq = ToolsFactoryService.HTTPRequest(method: req.method, path: req.path, headers: req.headers, body: req.body)
            let sresp = try await serviceKernel.handle(sreq)
            return IntegrationRuntime.HTTPResponse(status: sresp.status, body: sresp.body)
        }
        let (server, port) = try await startServer(with: kernel)
        addTeardownBlock { try? await server.stop() }

        let client = ToolsFactoryClient.APIClient(baseURL: URL(string: "http://127.0.0.1:\(port)")!)
        let data = try await client.sendRaw(ToolsFactoryClient.list_tools())
        let functions = try JSONDecoder().decode([ServiceShared.Function].self, from: data)
        XCTAssertEqual(functions.count, 2)
    }

    func testToolsFactoryRegisterOpenAPI() async throws {
        let kernel = ToolsFactoryService.HTTPKernel()

        // load OpenAPI document for the Function Caller service
        let specURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("FountainAi/openAPI/v1/function-caller.yml")
        let yaml = try Data(contentsOf: specURL)

        _ = try await kernel.handle(.init(method: "POST", path: "/tools/register", headers: ["Content-Type": "application/x-yaml"], body: yaml))
        let list = try await kernel.handle(.init(method: "GET", path: "/tools"))
        let functions = try JSONDecoder().decode([ServiceShared.Function].self, from: list.body)
        XCTAssertGreaterThanOrEqual(functions.count, 5)
    }

    func testFunctionCallerInvokeFlow() async throws {
        // start echo service
        let echoKernel = IntegrationRuntime.HTTPKernel { _ in
            IntegrationRuntime.HTTPResponse(status: 200, body: Data("{}".utf8))
        }
        let echoServer = NIOHTTPServer(kernel: echoKernel)
        let echoPort = try await echoServer.start(port: 0)
        addTeardownBlock { try? await echoServer.stop() }

        // register function via Tools Factory
        let tfKernel = ToolsFactoryService.HTTPKernel()
        let fn = ServiceShared.Function(description: "echo", functionId: "echo", httpMethod: "GET", httpPath: "http://127.0.0.1:\(echoPort)", name: "echo")
        let body = try JSONEncoder().encode([fn])
        _ = try await tfKernel.handle(.init(method: "POST", path: "/tools/register", headers: ["Content-Type": "application/json"], body: body))

        // start function caller
        let fcKernel = FunctionCallerService.HTTPKernel()
        let kernel = IntegrationRuntime.HTTPKernel { req in
            let sreq = FunctionCallerService.HTTPRequest(method: req.method, path: req.path, headers: req.headers, body: req.body)
            let sresp = try await fcKernel.handle(sreq)
            return IntegrationRuntime.HTTPResponse(status: sresp.status, body: sresp.body)
        }
        let (server, port) = try await startServer(with: kernel)
        addTeardownBlock { try? await server.stop() }

        // invoke function
        let client = AsyncHTTPClientDriver()
        addTeardownBlock { try? await client.shutdown() }
        let (buffer, _) = try await client.execute(method: .POST, url: "http://127.0.0.1:\(port)/functions/echo/invoke", headers: HTTPHeaders(), body: nil)
        XCTAssertEqual(buffer.readableBytes, 2)
    }

    func testFunctionCallerInvokeNotFound() async throws {
        let serviceKernel = FunctionCallerService.HTTPKernel()
        let kernel = IntegrationRuntime.HTTPKernel { req in
            let sreq = FunctionCallerService.HTTPRequest(method: req.method, path: req.path, headers: req.headers, body: req.body)
            let sresp = try await serviceKernel.handle(sreq)
            return IntegrationRuntime.HTTPResponse(status: sresp.status, body: sresp.body)
        }
        let (server, port) = try await startServer(with: kernel)
        addTeardownBlock { try? await server.stop() }

        let client = AsyncHTTPClientDriver()
        addTeardownBlock { try? await client.shutdown() }
        let (buffer, _) = try await client.execute(method: .POST, url: "http://127.0.0.1:\(port)/functions/missing/invoke", headers: HTTPHeaders(), body: nil)
        XCTAssertEqual(buffer.readableBytes, 0)
        // expecting 404 response
    }

    func testFunctionCallerInvocationMetrics() async throws {
        let echoKernel = IntegrationRuntime.HTTPKernel { _ in
            IntegrationRuntime.HTTPResponse(status: 200, body: Data())
        }
        let echoServer = NIOHTTPServer(kernel: echoKernel)
        let echoPort = try await echoServer.start(port: 0)
        addTeardownBlock { try? await echoServer.stop() }

        let tfKernel = ToolsFactoryService.HTTPKernel()
        let fn = ServiceShared.Function(description: "echo", functionId: "echo", httpMethod: "POST", httpPath: "http://127.0.0.1:\(echoPort)", name: "echo")
        let body = try JSONEncoder().encode([fn])
        _ = try await tfKernel.handle(.init(method: "POST", path: "/tools/register", headers: ["Content-Type": "application/json"], body: body))

        let fcKernel = FunctionCallerService.HTTPKernel()
        let kernel = IntegrationRuntime.HTTPKernel { req in
            let sreq = FunctionCallerService.HTTPRequest(method: req.method, path: req.path, headers: req.headers, body: req.body)
            let sresp = try await fcKernel.handle(sreq)
            return IntegrationRuntime.HTTPResponse(status: sresp.status, body: sresp.body)
        }
        let (server, port) = try await startServer(with: kernel)
        addTeardownBlock { try? await server.stop() }

        let client = AsyncHTTPClientDriver()
        addTeardownBlock { try? await client.shutdown() }
        _ = try await client.execute(method: .POST, url: "http://127.0.0.1:\(port)/functions/echo/invoke", headers: HTTPHeaders(), body: nil)
        _ = try await client.execute(method: .POST, url: "http://127.0.0.1:\(port)/functions/missing/invoke", headers: HTTPHeaders(), body: nil)

        let (metricsBuffer, _) = try await client.execute(method: .GET, url: "http://127.0.0.1:\(port)/metrics", headers: HTTPHeaders(), body: nil)
        let metrics = String(buffer: metricsBuffer)
        XCTAssertTrue(metrics.contains("invocation_success_total"))
        XCTAssertTrue(metrics.contains("invocation_failure_total"))
    }

    func testLLMGatewayMetrics() async throws {
        let serviceKernel = LLMGatewayService.HTTPKernel()
        let kernel = IntegrationRuntime.HTTPKernel { req in
            let sreq = LLMGatewayService.HTTPRequest(method: req.method, path: req.path, headers: req.headers, body: req.body)
            let sresp = try await serviceKernel.handle(sreq)
            return IntegrationRuntime.HTTPResponse(status: sresp.status, body: sresp.body)
        }
        let (server, port) = try await startServer(with: kernel)
        addTeardownBlock { try? await server.stop() }

        let client = LLMGatewayClientSDK.APIClient(baseURL: URL(string: "http://127.0.0.1:\(port)")!)
        let data = try await client.sendRaw(LLMGatewayClientSDK.metrics_metrics_get())
        XCTAssertGreaterThan(data.count, 0)
        let metrics = String(data: data, encoding: .utf8) ?? ""
        XCTAssertTrue(metrics.contains("requests_total"))
    }

    func testBootstrapPromoteReflection() async throws {
        _ = await TypesenseClient.shared.createCorpus(id: "bp1")
        let reflection = Reflection(content: "new role", corpusId: "bp1", question: "q", reflectionId: "r1")
        await TypesenseClient.shared.addReflection(reflection)
        let kernel = BootstrapService.HTTPKernel()
        let reqPath = "/bootstrap/roles/promote?corpusId=bp1&roleName=test"
        let resp = try await kernel.handle(.init(method: "POST", path: reqPath))
        let info = try JSONDecoder().decode(BootstrapService.RoleInfo.self, from: resp.body)
        XCTAssertEqual(info.name, "test")
        let roles = await TypesenseClient.shared.listRoles(for: "bp1")
        XCTAssertEqual(roles.first?.name, "test")
    }
}
