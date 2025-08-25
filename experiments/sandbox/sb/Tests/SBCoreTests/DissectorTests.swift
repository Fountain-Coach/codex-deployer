import XCTest
import SBCore

final class DissectorTests: XCTestCase {
    func testAnalyzeQuickProducesBlocksOnly() async throws {
        let snapshot = SnapshotBuilder().build(
            url: URL(string: "https://example.com")!,
            status: 200,
            contentType: "text/html",
            html: "<p>Hello World</p>",
            text: "Hello World"
        )
        let dissector = Dissector()
        let analysis = try await dissector.analyze(from: snapshot, mode: .quick, store: nil)
        XCTAssertEqual(analysis.blocks.count, 1)
        XCTAssertNil(analysis.semantics?.entities)
    }

    func testAnalyzeDeepProducesEntitiesAndClaims() async throws {
        let text = "Hello Alice\nBob loves Swift"
        let snapshot = SnapshotBuilder().build(
            url: URL(string: "https://example.com")!,
            status: 200,
            contentType: "text/plain",
            html: text,
            text: text
        )
        let dissector = Dissector()
        let analysis = try await dissector.analyze(from: snapshot, mode: .deep, store: nil)
        XCTAssertEqual(analysis.blocks.count, 2)
        XCTAssertNotNil(analysis.semantics?.entities)
        XCTAssertNotNil(analysis.semantics?.claims)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
