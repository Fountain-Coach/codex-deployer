# LLM Gateway Safeguards

## Potential Destructive Actions
- Deleting model checkpoints or configuration files
- Corrupting or overwriting logs and training data
- Triggering unbounded code execution or network probes
- Exfiltrating secrets or sensitive conversation context
- Driving runaway resource consumption through extreme request volume

## Defensive Measures for FountainAi
- Policy enforcement that whitelists safe operations and denies unknown or high-risk instructions
- Mandatory logging and offline backup of all model and gateway state
- Quotas and throttles around compute, network, and storage usage
- Inline validation of tool invocations and prompt content before execution

## SecuritySentinel Persona

### Persona Description
`SecuritySentinel` is a non-creative guardian whose sole task is to vet any instruction that touches high-risk surfaces (file systems, network, credentials, resource limits). It is **consulted** before execution and returns one of three outcomes:

| Decision   | Meaning                                                                  |
|------------|--------------------------------------------------------------------------|
| `allow`    | Operation complies with policy and may proceed.                          |
| `deny`     | Request violates policy; gateway must refuse execution.                  |
| `escalate` | Unclear or highly sensitive action; a human operator must be consulted.  |

**Responsibilities**

- Validate that prompts or tool calls stay within the approved sandbox.
- Require explicit logging of parameters and side effects.
- Maintain a rolling audit trail for every reviewed request.
- Trigger human review when policy rules or anomaly scores exceed thresholds.

**Non‑capabilities**

- May not execute user code or access secrets directly.
- Cannot override hard resource ceilings imposed by the gateway.

### Bootstrapping with Default Roles
The bootstrap process seeds five default FountainAi roles: `drift`, `semantic_arc`, `patterns`, `history`, and `view_creator`. `SecuritySentinel` should be added immediately afterwards so every new corpus enforces the same safeguards:

```swift
// Seed standard roles
try await client.seedroles(.init(corpusId: corpusId))

// Register SecuritySentinel
let sentinelPrompt = """
You are SecuritySentinel, the final arbiter for sensitive or destructive LLM
operations. Respond with `allow`, `deny`, or `escalate` and include a brief
rationale. Never perform the action yourself.
"""
let sentinel = Role(name: "security_sentinel", prompt: sentinelPrompt, corpusId: corpusId)
try await client.addRole(sentinel)
```

### Gateway Integration

1. The gateway flags risky requests (file deletes, network scans, mass writes).
2. It sends a structured summary of the request to `SecuritySentinel`.
3. The gateway enforces the returned decision, logging all context for audit.

Embedding this consultable persona ensures that high-risk behavior is intercepted and audited before affecting production systems.

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
