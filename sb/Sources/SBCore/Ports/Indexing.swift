public protocol Indexing: Sendable {
    func upsert(analysis: Analysis, options: IndexOptions) async throws -> IndexResult
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
