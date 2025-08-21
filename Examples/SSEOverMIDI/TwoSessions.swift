import MIDI2
import MIDI2Core
import MIDI2Transports
import SSEOverMIDI

let senderSession = RTPMidiSession(localName: "sender")
let receiverSession = RTPMidiSession(localName: "receiver")

let flex = FlexPacker()
let sysx = SysEx8Packer()
let senderRel = Reliability()
let receiverRel = Reliability()

let sender = DefaultSseSender(rtp: senderSession, flex: flex, sysx: sysx, rel: senderRel)
let receiver = DefaultSseReceiver(rtp: receiverSession, flex: flex, sysx: sysx, rel: receiverRel)

sender.listen(to: receiver)

senderSession.onReceiveUmps = { packets in
    receiverSession.onReceiveUmps?(packets)
}

receiver.onEvent = { env in
    print("Received #\(env.seq): \(env.data ?? "")")
}
receiver.onCtrl = { env in
    if let resend = receiverRel.handleCtrl(env) {
        for frames in resend.values {
            for f in frames { try? senderSession.send(umps: [f.words]) }
        }
    }
}

try senderSession.open()
try receiver.start()

let tokens = ["Hello", "from", "two", "sessions"]
for (i, t) in tokens.enumerated() {
    let env = SseEnvelope(ev: "message", seq: UInt64(i), data: t)
    try sender.send(event: env)
    sender.flush()
}

sender.close()
receiver.stop()

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
