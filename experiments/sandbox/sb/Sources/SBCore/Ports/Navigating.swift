import Foundation

public protocol Navigating: Sendable {
    func snapshot(url: URL, wait: WaitPolicy, store: ArtifactStore?) async throws -> Snapshot
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
