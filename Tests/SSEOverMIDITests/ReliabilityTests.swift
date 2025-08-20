import XCTest
import MIDI2
import MIDI2Core
@testable import SSEOverMIDI

final class ReliabilityTests: XCTestCase {
    func testNackRetransmission() {
        let rel = Reliability()
        let pkt = Ump128(word0: 0xDEADBEEF, word1: 0, word2: 0, word3: 0)!
        rel.record(seq: 1, frames: [pkt])
        let nack = SseEnvelope(ev: "ctrl", seq: 2, data: "{\"nack\":[1]}")
        let resend = rel.handleCtrl(nack)
        XCTAssertEqual(resend?[1]?.first?.word0, pkt.word0)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
