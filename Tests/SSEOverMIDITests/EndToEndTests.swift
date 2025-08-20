import XCTest
import MIDI2
import MIDI2Core
import MIDI2Transports
@testable import SSEOverMIDI

final class EndToEndTests: XCTestCase {
    func testLossyLoopbackStream() throws {
        let flex = FlexPacker()
        let senderRel = Reliability()
        let receiverRel = Reliability()
        let loop = LoopbackTransport()
        var output: [String] = []
        var expectedSeq: UInt64 = 0

        var pending: [Ump128] = []
        loop.onReceiveUMP = { words in
            guard let pkt = Ump128(words: words) else { return }
            pending.append(pkt)
            let blobs = flex.unpack(umps: pending)
            if !blobs.isEmpty { pending.removeAll() }
            for blob in blobs {
                if let env = try? JSONDecoder().decode(SseEnvelope.self, from: blob) {
                    if env.seq != expectedSeq {
                        let missing = Array(expectedSeq..<env.seq)
                        let nack = receiverRel.buildNack(missing)
                        if let resend = senderRel.handleCtrl(nack) {
                            for seq in missing {
                                if let frames = resend[seq] {
                                    for f in frames {
                                        try? loop.send(umpWords: f.words)
                                    }
                                }
                            }
                        }
                        expectedSeq = env.seq
                    }
                    output.append(env.data ?? "")
                    expectedSeq &+= 1
                }
            }
        }

        let total = 1000
        let drop: Set<Int> = [10, 500, 900]
        for i in 0..<total {
            let env = SseEnvelope(ev: "message", seq: UInt64(i), data: "t")
            let data = try JSONEncoder().encode(env)
            let frames = flex.pack(json: data, group: 0x1, statusBank: 0x1, status: 0x1)
            senderRel.record(seq: env.seq, frames: frames)
            if drop.contains(i) { continue }
            for f in frames { try loop.send(umpWords: f.words) }
        }

        if expectedSeq < UInt64(total) {
            let missing = Array(expectedSeq..<UInt64(total))
            let nack = receiverRel.buildNack(missing)
            if let resend = senderRel.handleCtrl(nack) {
                for seq in missing {
                    if let frames = resend[seq] {
                        for f in frames { try? loop.send(umpWords: f.words) }
                    }
                }
            }
        }

        XCTAssertEqual(output.count, total)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
