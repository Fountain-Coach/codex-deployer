import Foundation
import MIDI2
import MIDI2Core
import MIDI2Transports

public final class DefaultSseReceiver: SseOverMidiReceiver {
    public var onEvent: ((SseEnvelope) -> Void)?
    private let rtp: RTPMidiSession
    private let flex: FlexPacker

    public init(rtp: RTPMidiSession, flex: FlexPacker) {
        self.rtp = rtp
        self.flex = flex
        self.rtp.onReceiveUmps = { [weak self] packets in
            guard let self else { return }
            var umps: [Ump128] = []
            for words in packets {
                if let pkt = Ump128(words: words) {
                    umps.append(pkt)
                }
            }
            for blob in self.flex.unpack(umps: umps) {
                if let env = try? JSONDecoder().decode(SseEnvelope.self, from: blob) {
                    self.onEvent?(env)
                }
            }
        }
    }

    public func start() throws {
        try rtp.open()
    }

    public func stop() {
        try? rtp.close()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
