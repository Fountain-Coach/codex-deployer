import XCTest
@testable import AwarenessService
@testable import TypesensePersistence

final class AwarenessOpenAPIConformanceTests: XCTestCase {
    func testReflectionSummaryMatchesSchema() async throws {
        let svc = TypesensePersistenceService(client: MockTypesenseClient())
        let router = AwarenessRouter(persistence: svc)
        _ = try await svc.addReflection(.init(corpusId: "c1", reflectionId: "r1", question: "q", content: "a"))
        let resp = try await router.route(.init(method: "GET", path: "/corpus/reflections/c1"))
        XCTAssertEqual(resp.status, 200)
        let obj = try JSONSerialization.jsonObject(with: resp.body) as? [String: Any]
        XCTAssertNotNil(obj?["message"]) ; XCTAssertTrue(obj?["message"] is String)
    }

    func testHistorySummaryMatchesSchema() async throws {
        let svc = TypesensePersistenceService(client: MockTypesenseClient())
        let router = AwarenessRouter(persistence: svc)
        _ = try await svc.addBaseline(.init(corpusId: "c2", baselineId: "b1", content: "x"))
        let resp = try await router.route(.init(method: "GET", path: "/corpus/history/c2"))
        XCTAssertEqual(resp.status, 200)
        let obj = try JSONSerialization.jsonObject(with: resp.body) as? [String: Any]
        XCTAssertNotNil(obj?["summary"]) ; XCTAssertTrue(obj?["summary"] is String)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

