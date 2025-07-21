# 🚀 “LLM-First” Typesense GUI — Concept Brief

![[TypesenseGui-Mock.png]]

*A chat-centric interface that lets Codex / GPT prompts drive search, while giving humans instant, transparent insight into what Typesense is doing under the hood.*

---

## 1 Design Goals

| Goal | Why it matters |
|------|----------------|
| **Chat is the primary control surface** | Prompts originate from agents (Codex, GPT-4o, etc.) or a human operator. |
| **Transparent retrieval** | Show which documents, filters, embeddings, and ranking rules produced each answer. |
| **Rapid iteration loop** | Let users tweak the prompt, system instructions, or RAG parameters and re-run instantly. |
| **Corpus-aware** | Surface FountainAI corpora & semantic filters so the LLM can switch context on the fly. |
| **Ops-grade visibility** | Latency, token + vector costs, node health, and API usage visible at a glance. |

---

## 2 Key Screens & Components

| Screen | Purpose | Essential Widgets |
|--------|---------|-------------------|
| **Chat Workspace** | Primary prompt / reply view | • Prompt composer (system / tool / user roles)<br>• Streaming LLM answer<br>• Inline citation chips linked to Typesense hits |
| **Retrieval Inspector** | Side-by-side diff of LLM text ↔︎ Typesense results | • Ranked hit table (score, highlight, distance)<br>• Raw JSON toggle<br>• “Re-rank” button |
| **Prompt History** | Rewind & branch conversations | • Timeline showing tool calls, retries, errors<br>• One-click “fork” into new tab |
| **Schema & Corpus Browser** | Manage collections without leaving chat | • Tree of corpora → collections → fields<br>• Quick actions: clone, toggle embeddings, add synonym |
| **Ops Dashboard** | Keep the cluster & billing healthy | • QPS, latency, error-rate graphs<br>• Token + vector cost estimator ⓘ<br>• Node status (green / amber / red) |

---

## 3 Interaction Flow

1. **Enter / receive prompt** → GUI forwards to LLM.  
2. **LLM calls `typesense.search`** → GUI shows *“🔎 Searching…”*.  
3. **Typesense responds** with JSON hits & metrics.  
4. **LLM streams final answer**; citations render as expandable chips.  
5. **User or agent tweaks** corpus / filters → loop back to step 2 (hot-reload).

---

## 4 Under-the-Hood Architecture

```mermaid
graph TD
    A[SwiftUI Chat View] -->|Prompt| LLM
    LLM -->|Tool call: typesense.search| TSClient
    TSClient -->|REST / RAG API| TypesenseCluster
    TypesenseCluster --> TSClient
    TSClient --> LLM
    LLM -->|Answer + citations| A
    TSClient -->|Raw hits & metrics| InspectorView
    TypesenseCluster -->|Metrics| OpsDashboard
```

---

## 5 UI Details & Best Practices

- **Dual-pane layout**: chat left, inspector right (auto-collapse on mobile).  
- **Hotkeys**: ⇧⏎ send, ⌥↑/↓ cycle prompts, ⌘P collection palette.  
- **Theming**: Tailwind-inspired tokens in TeatroViewEngine; honours system dark mode.  
- **Streaming UX**: SSE / WebSocket; show token counter + latency badge live.  
- **Security**: Role-based JWT; scoped API keys injected into tool calls; clipboard redaction for PII.

---

## 6 Priority Evaluation for Codex-Deployer

The Codex-deployer currently automates Swift builds and patch application across the FountainAI monorepo. TeatroView already includes a minimal Typesense GUI, and the workflow generates a Typesense client from the OpenAPI spec.

1. **Tooling readiness** – The dispatcher handles builds but lacks explicit hooks for live UI reloads.
2. **Client generation** – Existing scripts produce a usable Typesense client, so the GUI can rely on those artifacts.
3. **Roadmap fit** – The project roadmap mentions a visual dashboard, aligning with this GUI's inspector and ops views.

Overall priority: **Medium**. Implementing the LLM-first GUI complements current tasks but should not block core deployment features.

````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````
