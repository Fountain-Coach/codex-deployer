import Foundation

public actor SB {
    let navigator: any Navigating
    let dissector: any Dissecting
    let indexer: any Indexing
    let store: ArtifactStore?

    public init(navigator: any Navigating, dissector: any Dissecting,
                indexer: any Indexing, store: ArtifactStore?) {
        self.navigator = navigator
        self.dissector = dissector
        self.indexer = indexer
        self.store = store
    }

    public func browseAndDissect(url: URL, wait: WaitPolicy, mode: DissectionMode,
                                 index: IndexOptions?) async throws -> (Snapshot, Analysis?, IndexResult?) {
        let snap = try await navigator.snapshot(url: url, wait: wait, store: store)
        let analysis = try await dissector.analyze(from: snap, mode: mode, store: store)
        let res = (index?.enabled ?? false) ? try await indexer.upsert(analysis: analysis, options: index!) : nil
        return (snap, analysis, res)
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
