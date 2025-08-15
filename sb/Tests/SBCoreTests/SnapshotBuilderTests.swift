import XCTest
@testable import SBCore

final class SnapshotBuilderTests: XCTestCase {
    func testBuildSnapshotWithMetaAndNetwork() throws {
        let builder = SnapshotBuilder()
        let url = URL(string: "https://example.com")!
        let request = Snapshot.Network.Request(url: url, type: .Document, status: 200, body: "<html></html>")
        let snap = builder.build(
            url: url,
            status: 200,
            contentType: "text/html",
            html: "<p>hi</p>",
            text: "hi",
            meta: ["title": "hi"],
            network: [request]
        )
        XCTAssertEqual(snap.page.uri, url)
        XCTAssertEqual(snap.rendered.meta?["title"], "hi")
        XCTAssertEqual(snap.network?.requests?.first?.body, "<html></html>")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
