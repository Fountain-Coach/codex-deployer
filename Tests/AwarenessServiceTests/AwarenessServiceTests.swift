import XCTest
@testable import AwarenessService
@testable import TypesensePersistence

final class AwarenessServiceTests: XCTestCase {
    func makeRouter() -> AwarenessRouter {
        let svc = TypesensePersistenceService(client: MockTypesenseClient())
        return AwarenessRouter(persistence: svc)
    }

    func testHealth() async throws {
        let router = makeRouter()
        let resp = try await router.route(.init(method: "GET", path: "/health"))
        XCTAssertEqual(resp.status, 200)
        let obj = try JSONSerialization.jsonObject(with: resp.body) as? [String: Any]
        XCTAssertEqual(obj?["status"] as? String, "ok")
    }

    func testInitAndBaselineAndSummaryFlow() async throws {
        let svc = TypesensePersistenceService(client: MockTypesenseClient())
        let router = AwarenessRouter(persistence: svc)
        // init corpus
        let initBody = try JSONEncoder().encode(InitIn(corpusId: "c1"))
        let initResp = try await router.route(.init(method: "POST", path: "/corpus/init", body: initBody))
        XCTAssertEqual(initResp.status, 200)
        // add baseline
        let baseBody = try JSONEncoder().encode(BaselineRequest(corpusId: "c1", baselineId: "b1", content: "hello"))
        let baseResp = try await router.route(.init(method: "POST", path: "/corpus/baseline", body: baseBody))
        XCTAssertEqual(baseResp.status, 200)
        // add reflection
        let reflBody = try JSONEncoder().encode(ReflectionRequest(corpusId: "c1", reflectionId: "r1", question: "q", content: "a"))
        let reflResp = try await router.route(.init(method: "POST", path: "/corpus/reflections", body: reflBody))
        XCTAssertEqual(reflResp.status, 200)
        // summary
        let sumResp = try await router.route(.init(method: "GET", path: "/corpus/summary/c1"))
        XCTAssertEqual(sumResp.status, 200)
        let sum = try JSONDecoder().decode(HistorySummaryResponse.self, from: sumResp.body)
        XCTAssertTrue(sum.summary.contains("baselines=1"))
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

