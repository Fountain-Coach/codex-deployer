import Foundation

public struct SnapshotBuilder: Sendable {
    public init() {}

    public func build(
        url: URL,
        finalUrl: URL? = nil,
        fetchedAt: Date = Date(),
        status: Int,
        contentType: String,
        html: String,
        text: String,
        meta: [String: String]? = nil,
        network: [Snapshot.Network.Request]? = nil,
        navigation: Snapshot.Page.Navigation? = nil,
        diagnostics: [String]? = nil
    ) -> Snapshot {
        let page = Snapshot.Page(
            uri: url,
            finalUrl: finalUrl,
            fetchedAt: fetchedAt,
            status: status,
            contentType: contentType,
            navigation: navigation
        )
        let rendered = Snapshot.Rendered(html: html, text: text, meta: meta)
        let net = network.map { Snapshot.Network(requests: $0) }
        return Snapshot(
            snapshotId: UUID().uuidString,
            page: page,
            rendered: rendered,
            network: net,
            diagnostics: diagnostics
        )
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
