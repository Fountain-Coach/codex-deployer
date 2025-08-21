# SSE over MIDI Guide

This short guide shows how to stream Server-Sent Events over a local MIDI 2.0 loopback using the `SSEOverMIDI` package.

## Example

`Examples/SSEOverMIDI/TwoSessions.swift` opens separate sender and receiver `RTPMidiSession`s on localhost and forwards packets between them.

```swift
import MIDI2
import MIDI2Core
import MIDI2Transports
import SSEOverMIDI

let senderSession = RTPMidiSession(localName: "sender")
let receiverSession = RTPMidiSession(localName: "receiver")
```

Run the example from the repository root:

```bash
swift Examples/SSEOverMIDI/TwoSessions.swift
```

## Expected Output

The receiver prints each token as it arrives:

```
Received #0: Hello
Received #1: from
Received #2: two
Received #3: sessions
```

These tokens demonstrate SSE envelopes delivered over a local MIDI 2.0 link.

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
