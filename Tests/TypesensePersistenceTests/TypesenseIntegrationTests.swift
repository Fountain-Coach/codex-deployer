import XCTest
@testable import TypesensePersistence

final class TypesenseIntegrationTests: XCTestCase {
    func testRealTypesenseClientEndToEnd() async throws {
        let env = ProcessInfo.processInfo.environment
        guard let apiKey = env["TYPESENSE_API_KEY"], !apiKey.isEmpty else {
            throw XCTSkip("TYPESENSE_API_KEY not set; skipping integration test")
        }
        let nodes: [String]
        if let urls = env["TYPESENSE_URLS"] { nodes = urls.split(separator: ",").map(String.init) }
        else if let url = env["TYPESENSE_URL"] { nodes = [url] } else {
            throw XCTSkip("TYPESENSE_URL or TYPESENSE_URLS not set; skipping integration test")
        }
        #if canImport(Typesense)
        let client = RealTypesenseClient(nodes: nodes, apiKey: apiKey, debug: false)
        let svc = TypesensePersistenceService(client: client)
        await svc.ensureCollections()
        let corpus = "itest-\(UUID().uuidString.prefix(8))"
        _ = try await svc.createCorpus(.init(corpusId: corpus))
        let fid = "f-\(UUID().uuidString.prefix(8))"
        _ = try await svc.addFunction(.init(corpusId: corpus, functionId: fid, name: "ITest", description: "integration", httpMethod: "GET", httpPath: "/itest"))
        let (_, list) = try await svc.listFunctions(corpusId: corpus, q: "ITest")
        XCTAssertTrue(list.contains { $0.functionId == fid })
        #else
        throw XCTSkip("Typesense module not available; skipping integration test")
        #endif
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

