import XCTest
@testable import SBCore

final class ModelCodingTests: XCTestCase {
    func testSnapshotCodingRoundTrip() throws {
        let snap = Snapshot(
            snapshotId: "s1",
            page: .init(uri: URL(string: "https://example.com")!, fetchedAt: Date(timeIntervalSince1970: 0), status: 200, contentType: "text/html"),
            rendered: .init(html: "<p>hi</p>", text: "hi"),
            network: .init(requests: []),
            diagnostics: ["ok"]
        )
        let data = try JSONEncoder().encode(snap)
        let decoded = try JSONDecoder().decode(Snapshot.self, from: data)
        XCTAssertEqual(decoded.snapshotId, "s1")
        XCTAssertEqual(decoded.page.status, 200)
    }

    func testAnalysisCodingRoundTrip() throws {
        let analysis = Analysis(
            envelope: .init(id: "a1", contentType: "text/html", language: "en"),
            blocks: [Block(id: "b1", kind: .paragraph, text: "hi", span: [0,2])]
        )
        let data = try JSONEncoder().encode(analysis)
        let decoded = try JSONDecoder().decode(Analysis.self, from: data)
        XCTAssertEqual(decoded.envelope.id, "a1")
        XCTAssertEqual(decoded.blocks.first?.id, "b1")
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
