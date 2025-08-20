import Foundation
import MIDI2
import MIDI2Core
import MIDI2Transports

public final class DefaultSseSender: SseOverMidiSender {
    private let rtp: RTPMidiSession
    private let flex: FlexPacker
    private let sysx: SysEx8Packer
    private let rel: Reliability
    private let metrics: Metrics?
    private var nextSeq: UInt64 = 0
    private let mtu: Int

    public init(rtp: RTPMidiSession, flex: FlexPacker, sysx: SysEx8Packer, rel: Reliability, metrics: Metrics? = nil, mtu: Int = 1200) {
        self.rtp = rtp
        self.flex = flex
        self.sysx = sysx
        self.rel = rel
        self.metrics = metrics
        self.mtu = mtu
    }

    public func send(event: SseEnvelope) throws {
        let data = try JSONEncoder().encode(event)
        metrics?.addSend(bytes: data.count)
        let frames = flex.pack(json: data, group: 0x1, statusBank: 0x01, status: 0x01)
        rel.record(seq: event.seq, frames: frames)
        try rtp.send(umps: frames.map { $0.words })
    }

    public func flush() {}

    public func setWindow(_ n: Int) {}

    public func close() {
        try? rtp.close()
    }

    private func allocateSeq() -> UInt64 {
        defer { nextSeq &+= 1 }
        return nextSeq
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
