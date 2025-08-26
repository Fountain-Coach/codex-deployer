import XCTest
@testable import TypesensePersistence

final class TypesensePersistenceTests: XCTestCase {
    func testEnsureCollectionsIdempotent() async throws {
        let mock = MockTypesenseClient()
        let svc = TypesensePersistenceService(client: mock)
        await svc.ensureCollections()
        await svc.ensureCollections()
        // Collections should exist and not duplicate
        XCTAssertNotNil(mock.collections["corpora"])
        XCTAssertNotNil(mock.collections["baselines"])
        XCTAssertNotNil(mock.collections["reflections"])
        XCTAssertNotNil(mock.collections["functions"])
    }

    func testCreateAndListCorpora() async throws {
        let mock = MockTypesenseClient()
        let svc = TypesensePersistenceService(client: mock)
        _ = try await svc.createCorpus(.init(corpusId: "alpha"))
        _ = try await svc.createCorpus(.init(corpusId: "beta"))
        let result = try await svc.listCorpora(limit: 10, offset: 0)
        XCTAssertEqual(result.total, 2)
        XCTAssertEqual(result.corpora, ["alpha", "beta"])
        let paged = try await svc.listCorpora(limit: 1, offset: 1)
        XCTAssertEqual(paged.corpora, ["beta"])
    }

    func testBaselinesCRUD() async throws {
        let mock = MockTypesenseClient()
        let svc = TypesensePersistenceService(client: mock)
        _ = try await svc.createCorpus(.init(corpusId: "c1"))
        _ = try await svc.addBaseline(.init(corpusId: "c1", baselineId: "b1", content: "hello"))
        _ = try await svc.addBaseline(.init(corpusId: "c1", baselineId: "b2", content: "world"))
        let (total, baselines) = try await svc.listBaselines(corpusId: "c1", limit: 10, offset: 0)
        XCTAssertEqual(total, 2)
        XCTAssertEqual(Set(baselines.map{ $0.baselineId }), Set(["b1","b2"]))
    }

    func testReflectionsCRUD() async throws {
        let mock = MockTypesenseClient()
        let svc = TypesensePersistenceService(client: mock)
        _ = try await svc.createCorpus(.init(corpusId: "c1"))
        _ = try await svc.addReflection(.init(corpusId: "c1", reflectionId: "r1", question: "q1", content: "a1"))
        _ = try await svc.addReflection(.init(corpusId: "c1", reflectionId: "r2", question: "q2", content: "a2"))
        let (total, reflections) = try await svc.listReflections(corpusId: "c1")
        XCTAssertEqual(total, 2)
        XCTAssertEqual(reflections.first?.corpusId, "c1")
    }

    func testFunctionsRegistry() async throws {
        let mock = MockTypesenseClient()
        let svc = TypesensePersistenceService(client: mock)
        _ = try await svc.addFunction(.init(functionId: "f1", name: "F1", description: "d1", httpMethod: "GET", httpPath: "/f1"))
        _ = try await svc.addFunction(.init(functionId: "f2", name: "F2", description: "d2", httpMethod: "POST", httpPath: "/f2"))
        let (total, list) = try await svc.listFunctions()
        XCTAssertEqual(total, 2)
        XCTAssertEqual(list.map{ $0.functionId }, ["f1","f2"]) // sorted by id
        let f = try await svc.getFunctionDetails(functionId: "f2")
        XCTAssertEqual(f?.name, "F2")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

