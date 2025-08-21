import XCTest
import MIDI2
import MIDI2Core
@testable import SSEOverMIDI

final class MetricsTests: XCTestCase {
    func testCountersIncrement() {
        let metrics = Metrics()
        let rel = Reliability(metrics: metrics)
        let pkt = Ump128(word0: 0xDEADBEEF, word1: 0, word2: 0, word3: 0)!
        rel.record(seq: 1, frames: [pkt])
        _ = rel.buildAck(h: 1)
        _ = rel.buildNack([2])
        let ctrl = SseEnvelope(ev: "ctrl", seq: 0, data: "{\"nack\":[1]}")
        _ = rel.handleCtrl(ctrl)
        metrics.incSeqGapsDetected()
        let snap = metrics.snapshot()
        XCTAssertEqual(snap.acksSent, 1)
        XCTAssertEqual(snap.nacksSent, 1)
        XCTAssertEqual(snap.retransmits, 1)
        XCTAssertEqual(snap.seqGapsDetected, 1)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
