
# FountainAI Codex Agent: **SSE-over-MIDI 2.0 Networking** — Start‑to‑Finish Implementation Instructions

> Version: 1.0 (2025‑08‑20)  
> Owner: Codex Orchestrator (single agent)  
> Target stack: **Swift‑native**, no Docker/shell in orchestration path.  
> Purpose: Implement end‑to‑end transport of **OpenAI‑style SSE streams** over **MIDI 2.0 UMP** carried on **RTP‑MIDI over IP**, with discovery, timing, minimal reliability, tests, and packaging.

---

## 0) Executive Summary

This document is a **complete plan** for a single Codex agent to deliver a working, shippable prototype of **SSE‑over‑MIDI2 networking** for FountainAI peers. It specifies:

- A tiny **FountainAI SSE envelope** (JSON/CBOR).  
- Mapping to **MIDI 2.0 UMP** via **Flex Data** (small/streaming) and **SysEx8/MDS** (large).  
- **RTP‑MIDI** carrier with **Bonjour/mDNS** discovery.  
- **MIDI‑CI** handshake to announce capabilities and a vendor **Profile**.  
- **JR Timestamps** for smoothness, plus a **light ACK/NACK** reliability layer.  
- A **Swift Package** with sender/receiver, tests, and metrics.  
- Acceptance criteria and checklists.

Where precise bit‑level packing is required (UMP Flex and SysEx8/MDS), this plan defines interfaces and guardrails; implementers must follow the official specs for the final bit layout.


---

## 1) Scope & Non‑Goals

**In scope**

- MIDI 2.0 UMP framing (Flex, SysEx8/MDS) for app data.  
- RTP‑MIDI transport over UDP/IP with Bonjour discovery.  
- MIDI‑CI: Function Blocks, Profile enablement (vendor), basic Property Exchange.  
- JR Clock/Timestamps usage where available.  
- Minimal reliability (ACK/NACK, small retransmit buffer).  
- Swift‑native code, SPM package, XCTest, example app.  
- Metrics emitted in Swift (no external agents).

**Out of scope**

- Exact bit constants copied from the specs. (Follow spec at implementation time.)  
- NAT traversal and global WAN hardening. (Use LAN/VPN environments.)  
- Full DTLS‑SRTP stack. (Document options; not mandatory for v1.)


---

## 2) Architecture Overview

```text
OpenAI SSE Source
      │ (events: message/error/done)
      ▼
FountainAI Envelope (JSON/CBOR)       ──────>  Reliability layer (seq, ack, nack, window)
      │
      ├─(small)─> UMP Flex Data       ──────>  RTP‑MIDI payload (coalesced)  ──> UDP/IP
      │
      └─(large)─> UMP SysEx8/MDS      ──────>  RTP‑MIDI payload (coalesced)  ──> UDP/IP

Discovery: Bonjour/mDNS  ────> RTP‑MIDI session  
Negotiation: MIDI‑CI (Group 0): Function Blocks + Profile + Property Exchange  
Timing: JR Clock + JR Timestamps (when supported)
```

**Groups**

- **Group 0**: Control (MIDI‑CI, Property Exchange, acks/heartbeats).  
- **Group 1..N**: Data lanes (SSE streams). Optionally one lane per model/session.


---

## 3) Envelope Schema (App Layer)

Prefer **UTF‑8 JSON** for Flex; allow **CBOR** for compact binary.

```jsonc
{
  "v": 1,                      // schema version
  "ev": "message|error|done",  // SSE type
  "id": "opaque|optional",     // SSE id
  "ct": "application/json",    // content-type (optional)
  "seq": 123456789,            // monotonic stream seq
  "frag": { "i": 0, "n": 3 },  // fragment index & total (optional)
  "ts": 1724142123.123,        // wallclock seconds (optional)
  "data": "<slice-or-full-payload>"
}
```

**Reliability control messages** (sent on Group 0 as envelopes with `ev:"ctrl"`):

```jsonc
{ "v":1, "ev":"ctrl", "ack": 12345 }
{ "v":1, "ev":"ctrl", "nack": [12346,12347] }
{ "v":1, "ev":"ctrl", "window": 256 }          // receiver window
{ "v":1, "ev":"ctrl", "hb": true }             // heartbeat
```


---

## 4) UMP Mapping Strategy

### 4.1 Flex Data (for small, frequent messages)

- Use **Flex Data** with **Format** = Complete / Start / Continue / End.  
- Choose **Status Bank** for textual/metadata payloads (UTF‑8), or an alternative bank for binary CBOR.  
- Respect **multi‑UMP message sequencing rules** (no interleaving unrelated content between Start and End, aside from real‑time exceptions).  
- Payload sizing: implement chunker that fits each 128‑bit UMP’s data field after headers.  
- If an envelope exceeds the multi‑UMP limit, split at **app level** using `frag` or switch to **SysEx8/MDS**.

### 4.2 SysEx8 / Mixed Data Set (for large messages)

- Use when envelope payloads are **multi‑KB**.  
- Leverage built‑in start/continue/end chunking and stream identifiers.  
- Keep RTP packet sizes below ~1200 bytes for Wi‑Fi resilience.


---

## 5) Networking (RTP‑MIDI over UDP/IP)

- **Discovery**: Bonjour/mDNS advertises a service, e.g. `_rtpmidi2-ump._udp.local`. TXT keys include:  
  `ump=1, groups=8, profiles=fountainai.sse, mtu=1200`
- **Session**: standard RTP‑MIDI handshake; maintain SSRC and sequence numbers.  
- **Coalescing**: Pack multiple small UMPs per RTP packet, under MTU.  
- **Timing**: Include JR Timestamps where available; otherwise rely on arrival order plus app `seq`.


---

## 6) MIDI‑CI & Profile

- On **Group 0**, exchange **Function Blocks** to expose available Groups.  
- Enable a vendor **Profile**: `com.fountainai.sse` (UUID‑like identifier).  
- **Property Exchange** publishes a small JSON with transport params:

```jsonc
{
  "laneGroups": [1,2],
  "mtu": 1200,
  "maxFlexUmps": 32,
  "maxAppFrags": 8,
  "supportsSysEx8": true,
  "ackPeriodMs": 200
}
```


---

## 7) Reliability & Flow Control

- **Monotonic `seq`** per stream; deduplicate on receive.  
- **ACK** the highest contiguous `seq` regularly (e.g., every 200ms).  
- **NACK** explicit gaps after a short grace (e.g., 100–200ms).  
- **Retransmit buffer** size (e.g., last 512 envelopes).  
- **Receiver window** advertises max unacked envelopes.  
- **Sender pacing** reduces rate if NACKs or RTT spikes occur.  
- **Heartbeat** when idle (1–2s).


---

## 8) Swift Package Layout

```
FountainSSEOverMIDI2/
├─ Package.swift
├─ Sources/
│  ├─ Core/
│  │  ├─ Envelope.swift
│  │  ├─ FlexPacker.swift        // UMP Flex packing/unpacking
│  │  ├─ SysEx8Packer.swift      // UMP SysEx8/MDS packing/unpacking
│  │  ├─ Reliability.swift       // seq/ack/nack/window logic
│  │  ├─ Timing.swift            // JR Timestamp helpers
│  ├─ RTP/
│  │  ├─ RTPMidiSession.swift    // sockets, coalescing, SSRC, seq
│  │  ├─ Bonjour.swift           // mDNS advertise/discover
│  ├─ MIDI/
│  │  ├─ MidiCI.swift            // Function Blocks, Profile, Property Exchange
│  │  ├─ Groups.swift            // group allocation utilities
│  ├─ API/
│  │  ├─ SseSender.swift         // public send API
│  │  ├─ SseReceiver.swift       // public receive API (callbacks)
│  │  ├─ Metrics.swift           // gauges & counters
│  └─ Demo/
│     ├─ DemoApp.swift           // minimal CLI/GUI demo (SwiftUI optional)
└─ Tests/
   ├─ CoreTests/
   ├─ RTPTests/
   ├─ MIDITests/
   └─ IntegrationTests/
```

> Keep **Swift‑only**; use Apple’s Network framework / CoreMIDI 2.0 wherever available.


---

## 9) Public API (Swift)

### 9.1 Envelope

```swift
public struct SseEnvelope: Codable, Equatable {
    public var v: Int = 1
    public var ev: String            // "message" | "error" | "done" | "ctrl"
    public var id: String?
    public var ct: String?
    public var seq: UInt64
    public var frag: (i: Int, n: Int)?
    public var ts: Double?
    public var data: String

    public init(ev: String, id: String? = nil, ct: String? = "application/json",
                seq: UInt64, frag: (Int, Int)? = nil, ts: Double? = nil, data: String) {
        self.ev = ev; self.id = id; self.ct = ct; self.seq = seq; self.frag = frag; self.ts = ts; self.data = data
    }
}
```

### 9.2 Sender

```swift
public protocol SseOverMidiSender {
    func send(event: SseEnvelope) throws
    func flush()                        // force packetization
    func setWindow(_ n: Int)
    func close()
}
```

### 9.3 Receiver

```swift
public protocol SseOverMidiReceiver {
    var onEvent: ((SseEnvelope) -> Void)? { get set }
    func start() throws
    func stop()
}
```


---

## 10) Key Implementations (Sketches)

> **Note**: Bit packing for UMP Flex/SysEx8 must match the official spec. The functions below define interfaces and guardrails; fill in the constants per spec while implementing.

### 10.1 Flex pack/unpack (interfaces)

```swift
public enum UmpGroup: UInt8 { case control = 0, sse1 = 1 }

public struct Ump128 {
    public var w0: UInt32; public var w1: UInt32; public var w2: UInt32; public var w3: UInt32
}

public enum FlexFormat: UInt8 { case complete, start, `continue`, end }

public struct FlexChunk {
    public var group: UmpGroup
    public var format: FlexFormat
    public var statusBank: UInt8
    public var status: UInt8
    public var payload: [UInt8]    // up to data capacity for one UMP
}

public protocol FlexPacker {
    func pack(json: Data, group: UmpGroup, statusBank: UInt8, status: UInt8) -> [Ump128]
    func unpack(umps: [Ump128]) -> [Data] // returns complete JSON blobs
}
```

### 10.2 SysEx8/MDS pack/unpack (interfaces)

```swift
public protocol SysEx8Packer {
    func pack(streamID: UInt8, blob: Data, group: UmpGroup) -> [Ump128] // multi‑UMP
    func unpack(umps: [Ump128]) -> [(streamID: UInt8, blob: Data)]
}
```

### 10.3 RTP‑MIDI session (coalescing, MTU)

```swift
public final class RTPMidiSession {
    public init(localName: String, mtu: Int = 1200) { /* ... */ }
    public func open() throws { /* sockets, handshake */ }
    public func close() { /* ... */ }

    public func send(umps: [Ump128]) { /* coalesce < mtu; write UDP */ }
    public var onReceiveUmps: (([Ump128]) -> Void)?
}
```

### 10.4 Reliability (ACK/NACK)

```swift
public final class Reliability {
    private(set) var highestAcked: UInt64 = 0
    private var buffer: [UInt64: [Ump128]] = [:] // for retransmit

    public func record(seq: UInt64, frames: [Ump128]) {
        buffer[seq] = frames
        if buffer.count > 512 { buffer.removeValue(forKey: buffer.keys.sorted().first!) }
    }

    public func buildAck(h: UInt64) -> SseEnvelope {
        SseEnvelope(ev: "ctrl", seq: h, data: #"{"ack":\#(h)}"#)
    }

    public func handleCtrl(_ env: SseEnvelope) -> [UInt64: [Ump128]]? {
        // parse env.data for {"nack":[...]}; return map seq->frames to resend
        return nil
    }
}
```

### 10.5 Sender facade

```swift
public final class DefaultSseSender: SseOverMidiSender {
    private let rtp: RTPMidiSession
    private let flex: FlexPacker
    private let sysx: SysEx8Packer
    private let rel: Reliability
    private var nextSeq: UInt64 = 0
    private let mtu: Int

    public init(rtp: RTPMidiSession, flex: FlexPacker, sysx: SysEx8Packer, rel: Reliability, mtu: Int = 1200) {
        self.rtp = rtp; self.flex = flex; self.sysx = sysx; self.rel = rel; self.mtu = mtu
    }

    public func send(event: SseEnvelope) throws {
        let json = try JSONEncoder().encode(event)
        let frames = flex.pack(json: json, group: .sse1, statusBank: 0x01, status: 0x01)
        rel.record(seq: event.seq, frames: frames)
        rtp.send(umps: frames)
    }

    public func flush() {}
    public func setWindow(_ n: Int) {}
    public func close() { rtp.close() }

    private func allocateSeq() -> UInt64 { defer { nextSeq += 1 }; return nextSeq }
}
```

### 10.6 Receiver facade

```swift
public final class DefaultSseReceiver: SseOverMidiReceiver {
    public var onEvent: ((SseEnvelope) -> Void)?
    public var onCtrl: ((SseEnvelope) -> Void)?
    private let rtp: RTPMidiSession
    private let flex: FlexPacker
    private let sysx: SysEx8Packer
    private let rel: Reliability
    private var expectedSeq: UInt64 = 0
    private var pending: Set<UInt64> = []

    public init(rtp: RTPMidiSession, flex: FlexPacker, sysx: SysEx8Packer, rel: Reliability) {
        self.rtp = rtp; self.flex = flex; self.sysx = sysx; self.rel = rel
        self.rtp.onReceiveUmps = { [weak self] packets in
            guard let self else { return }
            // unpack SysEx8 and Flex packets then decode SseEnvelope
            // emit onEvent/onCtrl and track seq for ACK/NACK via Reliability
        }
    }

    public func start() throws { try rtp.open() }
    public func stop() { try? rtp.close() }
}
```


---

## 11) Example Usage

```swift
let session = RTPMidiSession(localName: "FountainPeer-A", mtu: 1200)
let sender = DefaultSseSender(rtp: session, flex: MyFlexPacker(), sysx: MySysEx8Packer(), rel: Reliability())

try session.open()

var seq: UInt64 = 0
func sendToken(_ s: String) {
    let env = SseEnvelope(ev: "message", seq: seq, data: s)
    try? sender.send(event: env)
    seq += 1
}
```


---

## 12) Tests (XCTest)

- **CoreTests**
  - Envelope (encode/decode; fragmentation join).  
  - FlexPacker round‑trip for random payload sizes.  
  - SysEx8Packer round‑trip for multi‑KB blobs.

- **RTPTests**
  - Coalescing under MTU; split across packets; reorder simulation.  
  - Loss simulation with NACK/resent.

- **MIDITests**
  - MIDI‑CI mock responder; Profile + Property Exchange JSON validation.

- **IntegrationTests**
  - End‑to‑end: generate 10k tokens; induce 3% packet loss; assert final stream text equal.  
  - JR Timestamp smoke test (if supported on platform).


---

## 13) Metrics

Expose a `Metrics` facade (in‑memory, thread‑safe):

- `send_bytes_total`, `recv_bytes_total`  
- `pkt_coalesced_avg`, `mtu_violations`  
- `acks_sent`, `nacks_sent`, `retransmits`  
- `seq_gaps_detected`, `reorder_depth_max`  
- `rtt_ms_p50/p95` (from ack timing)  


---

## 14) Security Guidance

- Preferred: run on **trusted LAN** or **WireGuard**.  
- Option: wrap RTP in **DTLS‑SRTP**.  
- Authenticate peers via an mTLS side‑channel if needed (not required for v1).


---

## 15) Delivery Milestones (for Codex)

1. **Day 1–2**: SPM scaffold, Envelope, Flex/SysEx8 interfaces, RTP session stub, Bonjour stub.  
2. **Day 3–4**: Flex pack/unpack + unit tests; basic RTP coalescing + loopback tests.  
3. **Day 5–6**: Receiver reassembly, Reliability (ack/nack), Integration test (lossy).  
4. **Day 7**: MIDI‑CI profile/property exchange mocks + tests.  
5. **Day 8**: JR timestamping helpers; metrics.  
6. **Day 9**: Demo app (send/receive tokens), docs polish.  
7. **Day 10**: Review, acceptance tests, version tag `v0.1.0`.

> Adjust to your cadence; this is a guideline for a single, focused iteration.


---

## 16) Acceptance Criteria

- Send/receive **100k tokens** at ≥ 1k tokens/sec over LAN with packet loss ≤ 1%, final reassembled text **exact match**.  
- Loss injection 3–5%: NACK + retransmit maintains correctness; throughput ≥ 500 tokens/sec.  
- Flex and SysEx8 both verified via tests.  
- MIDI‑CI Profile enables successfully; Property Exchange JSON exchanged.  
- Metrics exported and non‑zero during run.  
- No shell/Docker required to run demo; **Swift build + run only**.


---

## 17) Developer Notes & Guardrails

- Keep **UMP packing isolated** behind `FlexPacker` / `SysEx8Packer` for spec compliance and future updates.  
- Unit‑test boundary sizes (exact UMP payload capacities, multi‑UMP limits).  
- Never interleave unrelated Flex sequences between **Start..End**.  
- Keep RTP packet under **~1200 bytes** for Wi‑Fi (allow config).  
- Consider **back‑pressure**: if receiver window shrinks, slow down.  
- Optional: offer **CBOR** for smaller envelopes when latency spikes.


---

## 18) Demo App (optional SwiftUI)

- Two panes: **Sender** (type text → tokenized stream) and **Receiver** (live tokens).  
- Status lights: Bonjour discovered, RTP connected, MIDI‑CI OK, JR clock OK.  
- Metrics HUD: bytes/s, RTT, NACKs, reorder depth.


---

## 19) Appendix: Pseudo‑constants (fill from spec)

- UMP Message Type values for Flex and SysEx8/MDS.  
- Flex **Status Bank** and **Status** for “metadata text” lane.  
- JR Clock / JR Timestamp embedding examples.  
- RTP‑MIDI header fields used in coalescing.  

> **Implementation note**: Reference the latest MIDI 2.0 UMP, Flex Data, and SysEx8/MDS specification documents for authoritative constants.


---

## 20) Hand‑off Checklist

- [ ] `FountainSSEOverMIDI2` SPM builds on macOS.  
- [ ] Unit tests & integration tests pass locally.  
- [ ] Demo app streams LLM tokens over LAN between two hosts.  
- [ ] README includes Envelope spec, API docs, and limitations.  
- [ ] Profile ID (`com.fountainai.sse`) and Property schema documented.  
- [ ] Version tagged and CHANGELOG started.

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
