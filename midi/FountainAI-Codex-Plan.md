# Codex Plan — FountainAI: Adopt midi2 and Formalize the Flex Bus

**Version:** 1.0  
**Date:** 2025-08-14 14:26 UTC  
**Audience:** Codex, FountainAI Engineering

---

## Scope

Linux-first adoption of `Fountain-Coach/midi2` in **codex-deployer**, promoting a testable, schema-driven **Flex bus** that turns MIDI 2.0 Flex Data into OpenAPI calls and status replies. The bus is transport-agnostic (ALSA/USB/virtual endpoints), with a software loopback for CI.

**Canonical envelope fields:** `v`, `ts`, `corr`, `intent`, `body`. Replies: `ack`, optional `progress`, terminal `success` or `error`. These are preserved from the proposal.  
(See “Payload Specification” and “Flow Examples” in the Flex Bridge PDF.)

---

## Architecture Targets (modules / SPM targets)

- **MIDI2Core** (facade over `Fountain-Coach/midi2`):  
  Typed UMP + Flex envelope encode/decode; JSON Schema validation.
- **Transports**:  
  `LoopbackTransport` (CI), `ALSATransport` (Linux UMP); optional `CoreMIDITransport` (Apple).
- **FlexBridge**:  
  Intent router (envelope ⇄ HTTP); attaches JWT; journaling; replay defense; back‑pressure.
- **FlexBridgeService** (binary/daemon):  
  Loads policy YAML from `/etc/midi2d/*.yaml`, opens transports, runs the event loop and emits replies.

### `MIDITransport` protocol (stable surface)

```swift
public protocol MIDITransport {
    func open() throws
    func close() throws
    func send(umpWords: [UInt32]) throws
    var onReceiveUMP: (([UInt32]) -> Void)? { get set }
}
```

Transports **only** move bytes. All semantics live in `MIDI2Core` + `FlexBridge`.

---

## Authoritative Intent Map

Keep the mapping as code + fixtures (Appendix A in the proposal):
- `llm.chat`
- `planner.reason`
- `planner.execute`
- `tools.register`
- `function.invoke`
- `persist.baseline`
- `awareness.reflect`
- `(custom)` → Unknown Metadata/Text handler

---

## Security & Reliability

- **Auth:** Fetch short‑lived JWT via Gateway; attach to every HTTP call.  
- **Replay defense:** Reject stale `ts`; uniqueness window per sender for `corr`.  
- **Back‑pressure:** Rate limits with `error:backpressure` reply; retry hints included.  
- **Journaling:** Redact tokens, store request/response per `corr` under `/var/log/flexbridge/`.

---

## Step-by-Step PR Plan

**PR‑1 — Introduce midi2 & schema tests**  
- Add SPM dependency on `Fountain-Coach/midi2`.  
- Add `MIDI2Core` facade (types, codecs).  
- Add JSON Schema for envelopes; round‑trip tests + golden vectors per intent.

**PR‑2 — Transport boundary**  
- Add `MIDITransport` protocol + `LoopbackTransport`.  
- Route any existing MIDI code exclusively through the protocol.

**PR‑3 — FlexBridge**  
- Envelope parse → HTTP route → reply (ACK/PROGRESS/ERROR).  
- Add journaling and replay defense.

**PR‑4 — Linux UMP (`ALSATransport`)**  
- Detect endpoints; send/receive golden vectors end‑to‑end.  
- Provide `flexbridge.service` (systemd), wants `alsa-state.service`.

**PR‑5 — CLI & fixtures**  
- `flexctl send|tail|replay`.  
- Commit `examples/` with Appendix request/response shapes and `.ump` golden vectors.

---

## Suggested Tree

```
codex-deployer/
  midi/
    Core/            # MIDI2Core wrapper (types, schema, codecs)
    Transports/      # LoopbackTransport, ALSATransport
    Flex/            # FlexBridge (router, policies, replies)
    Tools/           # flexctl (CLI)
    Tests/           # golden vectors, loopback/alsa tests
```

---

## Definition of Done

- `FlexBridgeService` on Linux: handles `llm.chat`, `planner.execute`, `function.invoke` with replies (ACK/PROGRESS/ERROR).  
- Loopback + ALSA tests pass with golden vectors.  
- Journaling + rate limiting proven in test.  
- systemd unit + example policy YAML committed.

---

## Appendix A — Example Flex envelope (planner.execute)

```json
{
  "v": 1,
  "ts": 1723622400000,
  "corr": "dE8x-7qF",
  "intent": "planner.execute",
  "body": {
    "steps": [
      { "name": "persist.getCorpus",  "arguments": { "corpusId": "fc-main" } },
      { "name": "analytics.summarize","arguments": { "corpusId": "fc-main" } }
    ]
  }
}
```

---

## Appendix B — `flexctl` examples

```bash
# Send an envelope file to the bus
flexctl send --in ./examples/planner.execute.json --corr dE8x-7qF

# Tail replies for a correlation ID
flexctl tail --corr dE8x-7qF

# Replay a golden UMP vector through loopback
flexctl replay --ump ./examples/planner.execute.ump
```
