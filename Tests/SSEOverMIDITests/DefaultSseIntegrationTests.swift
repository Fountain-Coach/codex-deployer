import XCTest
import MIDI2
import MIDI2Core
import MIDI2Transports
@testable import SSEOverMIDI

final class DefaultSseIntegrationTests: XCTestCase {
    func testLargePayloadUsesSysEx8() throws {
        let session = RTPMidiSession(localName: "loop", enableDiscovery: false, enableCINegotiation: false)
        let flex = FlexPacker()
        let sysx = SysEx8Packer()
        let senderRel = Reliability()
        let receiverRel = Reliability()
        let sender = DefaultSseSender(rtp: session, flex: flex, sysx: sysx, rel: senderRel)
        let receiver = DefaultSseReceiver(rtp: session, flex: flex, sysx: sysx, rel: receiverRel)
        sender.listen(to: receiver)
        try receiver.start()

        var mts: [UInt32] = []
        var batch: [[UInt32]] = []
        session.onReceiveUMP = { words in
            mts.append(words[0] >> 28)
            batch.append(words)
        }

        var received: [String] = []
        let exp = expectation(description: "recv")
        receiver.onEvent = { env in
            received.append(env.data ?? "")
            exp.fulfill()
        }

        let payload = String(repeating: "x", count: 5 * 1024)
        let env = SseEnvelope(ev: "message", seq: 0, data: payload)
        try sender.send(event: env)
        sender.flush()
        session.onReceiveUmps?(batch)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(received.first, payload)
        XCTAssertTrue(mts.contains(0x5))
    }

    func testAckNackRetransmissionRestoresOrder() throws {
        let session = RTPMidiSession(localName: "loss", enableDiscovery: false, enableCINegotiation: false)
        try session.open()
        let flex = FlexPacker()
        let senderRel = Reliability()
        let receiverRel = Reliability()
        var output: [String] = []
        var expectedSeq: UInt64 = 0
        var pending: [Ump128] = []
        session.onReceiveUmps = { packets in
            for words in packets {
                guard let pkt = Ump128(words: words) else { continue }
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
                                        try? session.send(umps: frames.map { $0.words })
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
        }

        let total = 10
        let drop: Set<Int> = [3]
        for i in 0..<total {
            let env = SseEnvelope(ev: "message", seq: UInt64(i), data: "t")
            let data = try JSONEncoder().encode(env)
            let frames = flex.pack(json: data, group: 0x1, statusBank: 0x1, status: 0x1)
            senderRel.record(seq: env.seq, frames: frames)
            if drop.contains(i) { continue }
            try session.send(umps: frames.map { $0.words })
        }

        if expectedSeq < UInt64(total) {
            let missing = Array(expectedSeq..<UInt64(total))
            let nack = receiverRel.buildNack(missing)
            if let resend = senderRel.handleCtrl(nack) {
                for seq in missing {
                    if let frames = resend[seq] {
                        try? session.send(umps: frames.map { $0.words })
                    }
                }
            }
        }

        XCTAssertEqual(output.count, total)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
