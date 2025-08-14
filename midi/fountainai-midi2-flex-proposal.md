# FountainAI Proposal: MIDI 2.0 Flex Data as a Communication Layer

![[Flex-Bridge.png]]

**Version:** 1.0  
**Status:** Draft  
**Authors:** FountainAI Engineering  
**Date:** 2025-08-14

---

## 1. Purpose

This document proposes adding **MIDI 2.0 Flex Data** as a real-time, low-overhead control and metadata channel between physical controllers, stage systems, and the FountainAI service ecosystem.  

By encoding compact JSON “control envelopes” inside MIDI Flex Data messages, any MIDI 2.0-capable device can trigger, parameterize, and receive responses from FountainAI’s OpenAPI-defined services — without adding new API endpoints or transport layers.

---

## 2. Background

FountainAI services are currently accessed over HTTP using the published OpenAPIs (see `gateway.yml`, `planner.yml`, `tools-factory.yml`, `function-caller.yml`, `persist.yml`, `baseline-awareness.yml`, etc.). These cover LLM chat, planning, execution, tool registration, persistence, and analytics.  

MIDI 2.0 introduces **Flex Data**, a general-purpose, UTF-8-capable metadata carrier that can embed human-readable strings and arbitrary vendor data in the same low-latency channel as performance messages. Flex Data is transport-agnostic and can be used for structured commands as well as textual display.

---

## 3. Goals

1. Enable **hands-on, hardware-driven orchestration** of FountainAI services from MIDI controllers, footswitches, sequencers, or stage automation rigs.
2. Provide a **human-readable + machine-readable** payload format: user-facing labels in Ruby fields, machine-parseable JSON in the data body.
3. Support **bi-directional communication**:
   - Device → FountainAI: trigger planner, execute steps, chat, register tools, invoke functions, persist baselines.
   - FountainAI → Device: send acknowledgements, status updates, summaries.
4. Maintain **backward compatibility** with existing APIs — no service needs to change; Flex acts as a side-band bridge.

---

## 4. Architecture Overview

### 4.1 Flex Bridge Service
A dedicated microservice sits between MIDI 2.0 input and the FountainAI HTTP API layer:

- **Input**: Listens to UMP (Universal MIDI Packet) streams, parsing Flex Data.
- **Routing**: Decodes envelopes, validates, maps `intent` to corresponding OpenAPI route.
- **Output**: Sends HTTP requests with JSON body; receives responses.
- **Response Encoding**: Optionally sends back a Flex Data reply (ACK, progress, or error) with correlation ID.

### 4.2 Mapping Intents to Services

| **Intent**             | **FountainAI Endpoint**                                           |
|------------------------|--------------------------------------------------------------------|
| `llm.chat`             | POST LLM Gateway `/chat`                                          |
| `planner.reason`       | POST Planner `/planner/reason`                                    |
| `planner.execute`      | POST Planner `/planner/execute`                                   |
| `tools.register`       | POST Tools-Factory `/tools/register`                              |
| `function.invoke`      | POST Function-Caller `/functions/{id}/invoke`                     |
| `persist.baseline`     | POST Persistence `/corpora/{corpusId}/baselines`                  |
| `awareness.reflect`    | POST Baseline Awareness `/corpus/reflections`                     |
| *(custom)*             | Routed to `Unknown Metadata/Performance Text` handler            |

---

## 5. Payload Specification

**Envelope** (embedded in Flex Data text or vendor field):

```json
{
  "v": 1,
  "ts": 1723622400000,
  "corr": "dE8x-7qF",
  "intent": "planner.execute",
  "body": {
    "objective": "Draft release notes from baseline BA-2025-08",
    "steps": [
      {"name": "persist.getBaseline", "arguments": {"corpusId": "fc-main", "baselineId": "BA-2025-08"}},
      {"name": "analytics.summarize", "arguments": {"corpusId": "fc-main"}}
    ]
  }
}
```

**Transport options**:
- **Ruby / RubyLanguage**: Ruby carries short human label; JSON in main data payload.
- **Unknown Metadata Text**: Pure JSON for machine commands.

---

## 6. Flow Examples

**Example A: Footswitch triggers an execution plan**
1. Flex Bridge receives `planner.execute` envelope.
2. Sends to Planner `/planner/execute`.
3. Sends ACK Flex Data back with `corr` + status.

**Example B: Live baseline recording**
1. MIDI sequencer sends `persist.baseline` with corpus/baseline IDs + content reference.
2. Bridge posts to Persistence `/corpora/{corpusId}/baselines`.
3. Awareness service picks up for drift/pattern analysis.

---

## 7. Security Considerations
- **Auth**: Bridge fetches JWT via Gateway `/auth/token` and attaches to all requests.
- **Replay prevention**: `corr` IDs + timestamp validation.
- **Filtering**: Whitelist allowable `intent` values per device.
- **Rate limiting**: Back-pressure in high-burst scenarios.

---

## 8. Advantages
- **Unified control surface**: Instruments, pedals, and consoles can orchestrate AI flows.
- **Low latency**: Runs over MIDI transport (USB, BLE-MIDI, network MIDI).
- **Human + machine readable**: Clear stage feedback and machine-parsable commands.
- **Extensible**: Can grow with FountainAI APIs without protocol redesign.

---

## 9. Next Steps
1. Prototype Flex Bridge (Rust or Swift) with 3 intents: `llm.chat`, `planner.execute`, `function.invoke`.
2. Test against physical MIDI 2.0 device and soft UMP loopback.
3. Add ACK messaging, batching, and error mapping.
4. Extend to remaining services.

---

## Appendix A: Intent-to-Endpoint Map and Request/Response Shapes

### 1) `llm.chat` → LLM Gateway
**Request:**
```json
POST /chat
{
  "messages": [
    {"role": "user", "content": "Hello, FountainAI!"}
  ],
  "functions": []
}
```
**Response:**
```json
{
  "id": "chat-123",
  "object": "chat.completion",
  "choices": [
    {"index": 0, "message": {"role": "assistant", "content": "Hello there!"}}
  ]
}
```

### 2) `planner.reason` → Planner
**Request:**
```json
POST /planner/reason
{
  "objective": "Summarize corpus fc-main",
  "constraints": []
}
```
**Response:**
```json
{
  "plan": [
    {"name": "persist.getCorpus", "arguments": {"corpusId": "fc-main"}},
    {"name": "analytics.summarize", "arguments": {"corpusId": "fc-main"}}
  ]
}
```

### 3) `planner.execute` → Planner
**Request:**
```json
POST /planner/execute
{
  "steps": [
    {"name": "persist.getCorpus", "arguments": {"corpusId": "fc-main"}},
    {"name": "analytics.summarize", "arguments": {"corpusId": "fc-main"}}
  ]
}
```
**Response:**
```json
{
  "status": "success",
  "results": [
    {"step": "persist.getCorpus", "output": {...}},
    {"step": "analytics.summarize", "output": {...}}
  ]
}
```

### 4) `tools.register` → Tools-Factory
**Request:**
```json
POST /tools/register?corpusId=fc-main
Content-Type: multipart/form-data
(openapi_file)
```
**Response:**
```json
{
  "status": "registered",
  "toolId": "tool-xyz"
}
```

### 5) `function.invoke` → Function-Caller
**Request:**
```json
POST /functions/tool-xyz/invoke
{
  "arguments": {"param1": "value"}
}
```
**Response:**
```json
{
  "status": "success",
  "returnValue": {...}
}
```

### 6) `persist.baseline` → Persistence
**Request:**
```json
POST /corpora/fc-main/baselines
{
  "baselineId": "BA-2025-08",
  "content": "Baseline text..."
}
```
**Response:**
```json
{
  "status": "stored",
  "baselineId": "BA-2025-08"
}
```

### 7) `awareness.reflect` → Baseline Awareness
**Request:**
```json
POST /corpus/reflections
{
  "corpusId": "fc-main",
  "reflection": "Summary or insight"
}
```
**Response:**
```json
{
  "status": "recorded"
}
```

---
