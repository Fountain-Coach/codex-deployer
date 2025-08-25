import Foundation

public struct Dissector: Dissecting {
    public init() {}

    public func analyze(from snapshot: Snapshot, mode: DissectionMode, store: ArtifactStore?) async throws -> Analysis {
        let text = snapshot.rendered.text
        let paragraphs = text.split(whereSeparator: { $0 == "\n" })
        var blocks: [Block] = []
        var offset = 0
        for (idx, para) in paragraphs.enumerated() {
            let str = String(para)
            let start = offset
            let end = start + str.count
            let block = Block(id: "b\(idx)", kind: .paragraph, text: str, span: [start, end])
            blocks.append(block)
            offset = end + 1 // account for newline
        }

        let envelope = Analysis.Envelope(
            id: snapshot.snapshotId,
            source: .init(uri: snapshot.page.uri, fetchedAt: snapshot.page.fetchedAt),
            contentType: snapshot.page.contentType,
            language: "und",
            bytes: snapshot.rendered.html.utf8.count
        )

        var semantics: Analysis.Semantics? = nil
        if mode != .quick {
            let entityPattern = try NSRegularExpression(pattern: "[A-Z][a-zA-Z]+")
            var entitiesDict: [String: Entity] = [:]
            for block in blocks {
                let nsText = block.text as NSString
                let matches = entityPattern.matches(in: block.text, range: NSRange(location: 0, length: nsText.length))
                for match in matches {
                    let name = nsText.substring(with: match.range)
                    let globalStart = (block.span?[0] ?? 0) + match.range.location
                    let globalEnd = globalStart + match.range.length
                    let mention = Entity.Mention(block: block.id, span: [globalStart, globalEnd])
                    if var existing = entitiesDict[name] {
                        existing.mentions.append(mention)
                        entitiesDict[name] = existing
                    } else {
                        entitiesDict[name] = Entity(id: "e\(entitiesDict.count)", name: name, type: .OTHER, mentions: [mention])
                    }
                }
            }
            let entities = Array(entitiesDict.values)

            var claims: [Claim]? = nil
            if mode == .deep {
                claims = blocks.enumerated().map { idx, block in
                    Claim(
                        id: "c\(idx)",
                        text: block.text,
                        stance: .AUTHOR_ASSERTED,
                        hedge: .MEDIUM,
                        evidence: [Claim.Evidence(block: block.id, span: block.span)]
                    )
                }
            }

            semantics = Analysis.Semantics(entities: entities, claims: claims)
        }

        var summaries: Analysis.Summaries? = nil
        if let first = blocks.first {
            summaries = Analysis.Summaries(abstract: first.text)
        }

        let analysis = Analysis(envelope: envelope, blocks: blocks, semantics: semantics, summaries: summaries)
        try await store?.writeAnalysis(analysis)
        return analysis
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
