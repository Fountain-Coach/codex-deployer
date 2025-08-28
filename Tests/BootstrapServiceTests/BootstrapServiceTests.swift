import XCTest
@testable import BootstrapService
@testable import TypesensePersistence

final class BootstrapServiceTests: XCTestCase {
    func testCorpusInitSeedsRoles() async throws {
        let svc = TypesensePersistenceService(client: MockTypesenseClient())
        let router = BootstrapRouter(persistence: svc)
        let body = try JSONEncoder().encode(InitIn(corpusId: "c2"))
        let resp = try await router.route(.init(method: "POST", path: "/bootstrap/corpus/init", body: body))
        XCTAssertEqual(resp.status, 200)
    }

    func testSeedRolesEndpoint() async throws {
        let svc = TypesensePersistenceService(client: MockTypesenseClient())
        let router = BootstrapRouter(persistence: svc)
        let body = try JSONEncoder().encode(RoleInitRequest(corpusId: "c3"))
        let resp = try await router.route(.init(method: "POST", path: "/bootstrap/roles/seed", body: body))
        XCTAssertEqual(resp.status, 200)
        let roles = try JSONDecoder().decode(RoleDefaults.self, from: resp.body)
        XCTAssertFalse(roles.drift.isEmpty)
    }

    func testBootstrapBaselinePersistsSlices() async throws {
        let svc = TypesensePersistenceService(client: MockTypesenseClient())
        let router = BootstrapRouter(persistence: svc)
        _ = try await router.route(.init(method: "POST", path: "/bootstrap/roles", body: try JSONEncoder().encode(RoleInitRequest(corpusId: "c4"))))
        let body = try JSONEncoder().encode(BaselineIn(corpusId: "c4", baselineId: "b42", content: "x"))
        let resp = try await router.route(.init(method: "POST", path: "/bootstrap/baseline", body: body))
        XCTAssertEqual(resp.status, 200)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

