import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import gateway_server
@testable import AwarenessService
@testable import TypesensePersistence
@testable import RateLimiterGatewayPlugin

final class RateLimitProxyTests: XCTestCase {
    @MainActor
    func test429OnSecondRequest() async throws {
        // Upstream awareness
        let svc = TypesensePersistenceService(client: MockTypesenseClient())
        await svc.ensureCollections()
        let awarenessKernel = makeAwarenessKernel(service: svc)
        let upstream = NIOHTTPServer(kernel: awarenessKernel)
        let upstreamPort = try await upstream.start(port: 0)

        // Routes with very low limit
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("routes.json")
        struct Route: Codable { var id: String; var path: String; var target: String; var methods: [String]; var rateLimit: Int?; var proxyEnabled: Bool? }
        let routes = [Route(id: "awareness", path: "/awareness", target: "http://127.0.0.1:\(upstreamPort)", methods: ["GET","POST"], rateLimit: 1, proxyEnabled: true)]
        try JSONEncoder().encode(routes).write(to: file)

        // Gateway with rate limiter enabled
        let limiter = RateLimiterGatewayPlugin(defaultLimit: 1)
        let server = GatewayServer(plugins: [], zoneManager: nil, routeStoreURL: file, certificatePath: nil, rateLimiter: limiter)
        let port = 9132
        Task { try await server.start(port: port) }
        try await Task.sleep(nanoseconds: 100_000_000)

        // First request should pass
        let url = URL(string: "http://127.0.0.1:\(port)/awareness/health")!
        let (_, r1) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((r1 as? HTTPURLResponse)?.statusCode, 200)
        // Second immediately should hit 429
        let (_, r2) = try await URLSession.shared.data(from: url)
        XCTAssertEqual((r2 as? HTTPURLResponse)?.statusCode, 429)

        try await server.stop(); try await upstream.stop()
    }
}

