import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import gateway_server
@testable import FountainCodex
@testable import persist_server
@testable import TypesensePersistence

final class GatewayPersistProxyTests: XCTestCase {
    @MainActor
    func testGatewayProxiesPersistRoutes() async throws {
        // Start a persist upstream on a random port
        let svc = TypesensePersistenceService(client: MockTypesenseClient())
        await svc.ensureCollections()
        let persistKernel = makePersistKernel(service: svc)
        let upstream = NIOHTTPServer(kernel: persistKernel)
        let persistPort = try await upstream.start(port: 0)

        // Prepare route persistence file
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("routes.json")
        struct Route: Codable { var id: String; var path: String; var target: String; var methods: [String]; var rateLimit: Int?; var proxyEnabled: Bool? }
        let route = [Route(id: "persist", path: "/persist", target: "http://127.0.0.1:\(persistPort)", methods: ["GET","POST"], rateLimit: nil, proxyEnabled: true)]
        try JSONEncoder().encode(route).write(to: file)

        // Start the gateway with routeStoreURL pointing to our file
        let manager = CertificateManager(scriptPath: "/usr/bin/true", interval: 3600)
        let server = GatewayServer(manager: manager, plugins: [], zoneManager: nil, routeStoreURL: file)
        Task { try await server.start(port: 9130) }
        try await Task.sleep(nanoseconds: 100_000_000)
        // Make a POST via the gateway to upstream Persist: create corpus
        var req = URLRequest(url: URL(string: "http://127.0.0.1:9130/persist/corpora")!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(["corpusId": "g1"]) 
        let (_, resp) = try await URLSession.shared.data(for: req)
        XCTAssertEqual((resp as? HTTPURLResponse)?.statusCode, 201)

        // Publish a function via gateway proxy
        var fReq = URLRequest(url: URL(string: "http://127.0.0.1:9130/persist/corpora/g1/functions")!)
        fReq.httpMethod = "POST"
        fReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        fReq.httpBody = try JSONEncoder().encode(["functionId": "f1", "name": "F1", "description": "d", "httpMethod": "GET", "httpPath": "/f1"]) 
        let (_, fResp) = try await URLSession.shared.data(for: fReq)
        XCTAssertEqual((fResp as? HTTPURLResponse)?.statusCode, 200)

        // List functions via gateway proxy (global)
        let (data, lResp) = try await URLSession.shared.data(from: URL(string: "http://127.0.0.1:9130/persist/functions")!)
        XCTAssertEqual((lResp as? HTTPURLResponse)?.statusCode, 200)
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(obj?["total"] as? Int, 1)

        // List functions via gateway proxy (by corpus)
        let (cxData, cxResp) = try await URLSession.shared.data(from: URL(string: "http://127.0.0.1:9130/persist/corpora/g1/functions")!)
        XCTAssertEqual((cxResp as? HTTPURLResponse)?.statusCode, 200)
        let cxObj = try JSONSerialization.jsonObject(with: cxData) as? [String: Any]
        XCTAssertEqual(cxObj?["total"] as? Int, 1)

        // Filter via q=F1
        let (qData, qResp) = try await URLSession.shared.data(from: URL(string: "http://127.0.0.1:9130/persist/functions?q=F1")!)
        XCTAssertEqual((qResp as? HTTPURLResponse)?.statusCode, 200)
        let qObj = try JSONSerialization.jsonObject(with: qData) as? [String: Any]
        XCTAssertEqual(qObj?["total"] as? Int, 1)

        try await server.stop()
        try await upstream.stop()
    }
}

extension GatewayServer {
    var boundPort: Int? {
        // Reflection-free trick: hit /routes and read the port from URL is non-trivial; we add a helper if needed.
        // For tests we can assume default of 0 allocated, but we can simulate by trying a series of ports; keeping simple here.
        return nil
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
