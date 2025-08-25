import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct TypesenseIndexer: Indexing {
    public init() {}

    public func upsert(analysis: Analysis, options: IndexOptions) async throws -> IndexResult {
        guard let ts = options.typesense, let baseURL = ts.url, let apiKey = ts.apiKey else {
            throw TypesenseError.missingConfiguration
        }
        var result = IndexResult()

        if let collection = options.pagesCollection {
            let doc = PageDoc(
                id: analysis.envelope.id,
                url: analysis.envelope.source?.uri,
                host: analysis.envelope.source?.uri?.host,
                status: nil,
                contentType: analysis.envelope.contentType,
                lang: analysis.envelope.language,
                title: analysis.summaries?.abstract,
                textSize: analysis.blocks.reduce(0) { $0 + $1.text.count },
                fetchedAt: analysis.envelope.source?.fetchedAt.map { Int($0.timeIntervalSince1970) },
                labels: nil
            )
            try await importDocs([doc], collection: collection, baseURL: baseURL, apiKey: apiKey, timeoutMs: ts.timeoutMs)
            result.pagesUpserted = 1
        }

        if let collection = options.segmentsCollection {
            var docs: [SegmentDoc] = []
            for block in analysis.blocks {
                let entityIDs = analysis.semantics?.entities?
                    .filter { e in e.mentions.contains { $0.block == block.id } }
                    .map { $0.id }
                let doc = SegmentDoc(
                    id: block.id,
                    pageId: analysis.envelope.id,
                    kind: block.kind.rawValue,
                    text: block.text,
                    pathHint: nil,
                    offsetStart: block.span?[0],
                    offsetEnd: block.span?[1],
                    entities: entityIDs
                )
                docs.append(doc)
            }
            if !docs.isEmpty {
                try await importDocs(docs, collection: collection, baseURL: baseURL, apiKey: apiKey, timeoutMs: ts.timeoutMs)
                result.segmentsUpserted = docs.count
            }
        }

        if let collection = options.entitiesCollection, let entities = analysis.semantics?.entities {
            let docs = entities.map { e in
                EntityDoc(
                    id: e.id,
                    name: e.name,
                    type: e.type.rawValue,
                    pageCount: 1,
                    mentions: e.mentions.count
                )
            }
            if !docs.isEmpty {
                try await importDocs(docs, collection: collection, baseURL: baseURL, apiKey: apiKey, timeoutMs: ts.timeoutMs)
                result.entitiesUpserted = docs.count
            }
        }

        return result
    }

    private func importDocs<T: Encodable>(_ docs: [T], collection: String, baseURL: URL, apiKey: String, timeoutMs: Int?) async throws {
        var url = baseURL
        url.appendPathComponent("collections")
        url.appendPathComponent(collection)
        url.appendPathComponent("documents")
        url.appendPathComponent("import")

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue(apiKey, forHTTPHeaderField: "X-TYPESENSE-API-KEY")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let timeout = timeoutMs {
            req.timeoutInterval = TimeInterval(timeout) / 1000.0
        }

        let encoder = JSONEncoder()
        let payload = try docs.map { doc -> String in
            let data = try encoder.encode(doc)
            return String(decoding: data, as: UTF8.self)
        }.joined(separator: "\n")
        req.httpBody = payload.data(using: .utf8)

        let (_, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw TypesenseError.upstreamError
        }
    }

    public enum TypesenseError: Error {
        case missingConfiguration
        case upstreamError
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
