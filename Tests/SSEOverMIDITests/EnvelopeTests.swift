import XCTest
import MIDI2Core
@testable import SSEOverMIDI

final class EnvelopeTests: XCTestCase {
    func testEncodeDecode() throws {
        let env = SseEnvelope(ev: "message", seq: 42, data: "hello")
        let data = try JSONEncoder().encode(env)
        let round = try JSONDecoder().decode(SseEnvelope.self, from: data)
        XCTAssertEqual(round, env)
    }

    private func join(_ fragments: [SseEnvelope]) throws -> SseEnvelope {
        guard let first = fragments.first, let total = first.frag?.n else {
            throw NSError(domain: "Join", code: 1)
        }
        let sorted = fragments.sorted { ($0.frag?.i ?? 0) < ($1.frag?.i ?? 0) }
        XCTAssertEqual(sorted.count, total)
        let joined = sorted.compactMap { $0.data }.joined()
        return SseEnvelope(ev: first.ev, seq: first.seq, data: joined)
    }

    func testFragmentationJoin() throws {
        let frags = [
            SseEnvelope(ev: "message", seq: 1, frag: .init(i: 0, n: 3), data: "Hel"),
            SseEnvelope(ev: "message", seq: 2, frag: .init(i: 1, n: 3), data: "lo "),
            SseEnvelope(ev: "message", seq: 3, frag: .init(i: 2, n: 3), data: "World")
        ]
        let joined = try join(frags)
        XCTAssertEqual(joined.data, "Hello World")
        XCTAssertNil(joined.frag)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
