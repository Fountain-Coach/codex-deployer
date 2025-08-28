import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Yams
@testable import AwarenessService
@testable import TypesensePersistence

final class RuntimeSchemaValidationTests: XCTestCase {
    @MainActor
    func testSummaryMatchesYAMLSchema() async throws {
        // Start awareness via NIO kernel
        let svc = TypesensePersistenceService(client: MockTypesenseClient())
        await svc.ensureCollections()
        let router = AwarenessRouter(persistence: svc)
        _ = try await router.route(.init(method: "POST", path: "/corpus/init", body: try JSONEncoder().encode(InitIn(corpusId: "cspec"))))
        let _ = try await router.route(.init(method: "POST", path: "/corpus/baseline", body: try JSONEncoder().encode(BaselineRequest(corpusId: "cspec", baselineId: "b1", content: "x"))))

        // Call /corpus/summary/{corpus_id}
        let kernel = makeAwarenessKernel(service: svc)
        let server = NIOHTTPServer(kernel: kernel)
        let port = try await server.start(port: 0)
        let (data, resp) = try await URLSession.shared.data(from: URL(string: "http://127.0.0.1:\(port)/corpus/summary/cspec")!)
        XCTAssertEqual((resp as? HTTPURLResponse)?.statusCode, 200)
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Load YAML schema
        let url = URL(fileURLWithPath: "openapi/v1/baseline-awareness.yml")
        let text = try String(contentsOf: url)
        let yaml = try Yams.load(yaml: text) as? [String: Any]
        let hist = ((yaml?["components"] as? [String: Any])?["schemas"] as? [String: Any])?["HistorySummaryResponse"] as? [String: Any]
        XCTAssertNotNil(hist)
        XCTAssertTrue(OpenAPISchemaValidator.validate(object: obj ?? [:], against: hist!))
        try await server.stop()
    }
}

