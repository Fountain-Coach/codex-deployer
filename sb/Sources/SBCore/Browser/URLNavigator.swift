import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct URLNavigator: Navigating {
    private let session: URLSession
    private let builder: SnapshotBuilder

    public init(session: URLSession = .shared, builder: SnapshotBuilder = .init()) {
        self.session = session
        self.builder = builder
    }

    public func snapshot(url: URL, wait: WaitPolicy, store: ArtifactStore?) async throws -> Snapshot {
        let (data, response) = try await session.data(from: url)
        let html = String(decoding: data, as: UTF8.self)
        let contentType = (response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Content-Type") ?? "text/html"
        let text = html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        let snap = builder.build(url: url, status: (response as? HTTPURLResponse)?.statusCode ?? 0, contentType: contentType, html: html, text: text)
        try await store?.writeSnapshot(snap)
        return snap
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
