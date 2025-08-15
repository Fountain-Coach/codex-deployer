public protocol Dissecting: Sendable {
    func analyze(from snapshot: Snapshot, mode: DissectionMode, store: ArtifactStore?) async throws -> Analysis
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
