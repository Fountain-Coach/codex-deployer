import XCTest
@testable import PublishingFrontend

final class DNSClientTests: XCTestCase {
    func testRoute53Stub() async throws {
        let client = Route53Client()
        do {
            _ = try await client.listZones()
            XCTFail("expected failure")
        } catch {
            // expected not implemented
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
