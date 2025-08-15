import XCTest
@testable import SBCore

final class SBOrchestratorTests: XCTestCase {
    actor MockNavigator: Navigating {
        func snapshot(url: URL, wait: WaitPolicy, store: ArtifactStore?) async throws -> Snapshot {
            Snapshot(
                snapshotId: "s1",
                page: .init(uri: url, fetchedAt: Date(timeIntervalSince1970: 0), status: 200, contentType: "text/html"),
                rendered: .init(html: "<p>hi</p>", text: "hi")
            )
        }
    }

    actor MockDissector: Dissecting {
        func analyze(from snapshot: Snapshot, mode: DissectionMode, store: ArtifactStore?) async throws -> Analysis {
            Analysis(
                envelope: .init(id: "a1", contentType: "text/html", language: "en"),
                blocks: []
            )
        }
    }

    actor MockIndexer: Indexing {
        private(set) var callCount = 0
        func upsert(analysis: Analysis, options: IndexOptions) async throws -> IndexResult {
            callCount += 1
            return IndexResult(pagesUpserted: 1)
        }
    }

    struct MockStore: ArtifactStore {
        func writeSnapshot(_ snap: Snapshot) async throws {}
        func writeAnalysis(_ analysis: Analysis) async throws {}
        func readSnapshot(id: String) async throws -> Snapshot? { nil }
    }

    func testBrowseAndDissectWithoutIndex() async throws {
        let sb = SB(navigator: MockNavigator(), dissector: MockDissector(), indexer: MockIndexer(), store: nil)
        let (snap, analysis, result) = try await sb.browseAndDissect(
            url: URL(string: "https://example.com")!,
            wait: WaitPolicy(strategy: .domContentLoaded),
            mode: .quick,
            index: nil
        )
        XCTAssertEqual(snap.snapshotId, "s1")
        XCTAssertNotNil(analysis)
        XCTAssertNil(result)
    }

    func testBrowseAndDissectWithIndex() async throws {
        let indexer = MockIndexer()
        let sb = SB(navigator: MockNavigator(), dissector: MockDissector(), indexer: indexer, store: nil)
        let opts = IndexOptions(enabled: true)
        let (_, _, result) = try await sb.browseAndDissect(
            url: URL(string: "https://example.com")!,
            wait: WaitPolicy(strategy: .domContentLoaded),
            mode: .quick,
            index: opts
        )
        XCTAssertEqual(result?.pagesUpserted, 1)
        let calls = await indexer.callCount
        XCTAssertEqual(calls, 1)
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
