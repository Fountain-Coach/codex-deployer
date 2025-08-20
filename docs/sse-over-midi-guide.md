# SSE over MIDI Guide

This short guide shows how to stream Server-Sent Events over a local MIDI 2.0 loopback using the `SSEOverMIDI` package.

```swift
import MIDI2
import MIDI2Core
import MIDI2Transports
import SSEOverMIDI

let session = RTPMidiSession(localName: "loopback")
let sender = DefaultSseSender(
    rtp: session,
    flex: FlexPacker(),
    sysx: SysEx8Packer(),
    rel: Reliability()
)

let receiver = DefaultSseReceiver(rtp: session, flex: FlexPacker())
receiver.onEvent = { env in
    print("Received: \(env.data ?? "")")
}

try receiver.start()
try sender.send(event: SseEnvelope(ev: "message", seq: 0, data: "hello"))
```

The snippet creates an `RTPMidiSession`, `DefaultSseSender`, and `DefaultSseReceiver` to pass SSE tokens across a loopback transport.

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
