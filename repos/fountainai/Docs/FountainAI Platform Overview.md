# FountainAI Platform Overview[^1]
## What is FountainAI?
FountainAI is a comprehensive platform that combines large language models (LLMs) with a suite of
specialized services to enable advanced AI reasoning, planning, and knowledge management. Its
mission is to provide an AI orchestration environment where an LLM can plan tasks, call external
functions (tools), reflect on results, and analyze changes in knowledge over time. The platform
manages "semantic artifacts" – such as knowledge baselines, drift documents, reflections, and function
definitions – organized into corpora (contexts or workspaces) . By integrating function-calling LLMs
with persistent semantic memory, FountainAI supports use cases like dynamic tool use, step-by-step
task planning, automated self-reflection, and drift analysis to track how information evolves.

## Tools Factory[^2]
The Tools Factory Service is responsible for registering and managing external tools (functions) that
the AI can invoke during its reasoning process . In FountainAI, a "tool" is essentially a function
defined by an OpenAPI specification. The Tools Factory takes in these definitions and stores them in a
shared index (backed by a Typesense search engine) so that they can be discovered and called by other
services (notably the Function Caller) . Key capabilities of the Tools Factory include:
• Registering New Tools: Clients can submit an OpenAPI document (containing one or multiple
function definitions) via the /tools/register endpoint. The service extracts each operation
(function) and saves its metadata (name, description, parameters schema, HTTP endpoint to call,
etc.) for later use . Each tool is associated with a unique operationId (function
identifier) and can be tagged to a specific corpus context (via a corpusId parameter) for
namespacing .
• Listing Available Tools: The /tools endpoint allows retrieval of all registered functions, with
pagination support
for the AI to use.



. This lets the system or users query what tools are currently available

By centralizing function definitions, the Tools Factory enables FountainAI to dynamically expand its
capabilities. When new APIs or functions are registered, the AI can discover and invoke them as needed
to fulfill user objectives.

## Function Caller[^3]
The Function Caller Service is the runtime component that executes the tools/functions registered in
the platform . It serves as a bridge between the LLM’s function-calling intentions and actual HTTP
API calls or other function executions. In practice, when the LLM (via the Planner) decides to use a
function, the Function Caller handles invoking that function and returning the results. Key
functionalities of this service include:
• Function Invocation: The core feature is an invoke endpoint ( POST /functions/
{function_id}/invoke ) that takes a function identifier and input parameters, then performs
the corresponding HTTP request or operation and returns the result


This allows the LLM

This mirrors the data from Tools Factory, ensuring the AI agent knows what functions
description, HTTP method and path, and a schema for expected parameters .
By acting as a “dynamic operationId-to-HTTP call mapping factory”, the Function Caller enables LLMdriven function orchestration . In other words, the AI can plan a series of function calls (by their
## Bootstrap Service[^4]
AI agent) and streamlines the process of seeding it with default information . Think of it as a onestop orchestrator for starting an AI session with all necessary defaults (roles, baseline knowledge, etc.)
corpus and immediately seeds it with some defaults . Under the hood, this call performs
GPT roles via another endpoint; and (3) it enqueues a default reflection (called "role-healthcheck") into the corpus . The default roles are pre-defined prompts or personas for the
existing corpus with the five standard GPT role prompts . These roles might represent
enqueue a default reflection (the "role-health-check") at any time for a given corpus,
This means if the system's reflection identifies a useful new perspective or rule, that
triggering immediate analysis . A baseline could be a chunk of knowledge or data (text or
• Store the baseline content in the Awareness/Persistence layer .
analysis (identifying themes or patterns in the content) . These analyses are persisted as
the corpus . The history is an accumulation of all semantic changes, and the semantic arc is a
the corpus and immediately understand new data . The Bootstrap Service thus ties together the
## Baseline Awareness Service[^5]
corpus . It is essentially the brain of FountainAI for tracking what the AI knows (baselines), how it
creates a fresh container for semantic content identified by a corpus ID . All subsequent data
A baseline might be an initial snapshot of information or a significant
A drift document typically represents changes or differences from a previous baseline –
patterns related to the corpus . Narrative patterns analysis might extract common themes,
providing a prompt/question and the AI’s reflective answer. The service
GET /corpus/reflections/{corpus_id} . Reflections are a form of automated
made, etc.) over time . Moreover, it can generate a summarized history or "semantic arc"
history
and
how the narrative/knowledge evolved . The semantic arc is essentially an insight into the
## Planner Service[^6]
When a user provides a high-level goal or problem, the Planner service is responsible for breaking
accomplish it . Under the hood, the Planner likely engages an LLM (via the LLM Gateway)
step . The request includes the plan (which could be a list of function calls with
(function outputs) in order . This two-phase approach (plan then execute) allows for
about . This suggests the Planner can operate in the context of different knowledge bases
reflections/{corpus_id}/semantic-arc )
This is likely used to provide the LLM
reflection . This is similar to the Awareness service’s reflection addition, suggesting the
## LLM Gateway[^7]
(LLM), especially one that supports OpenAI-style function calling . This gateway allows FountainAI to
chat session or query with the LLM . The request typically contains the conversation
available functions (tools) that the LLM can choose to call . The LLM Gateway packages
let the model decide when to use a function .
• Model Agnosticism: The gateway is designed to work with any LLM that supports the functioncalling interface, not just a single model . This means FountainAI could be configured to use
toolset . It abstracts the details of the LLM API and provides a streamlined interface for the Planner

## Persistence Layer[^8]
artifacts using a Typesense engine . All data related to corpora – baselines, drifts, reflections,
existing corpora ( GET /corpora )
A corpus is identified by a unique ID and acts as a
This includes the baseline content and an ID for that baseline version
Drift
functions adds a function record to a corpus
There are also global endpoints to list all
{functionId} ) from the persistent store

This ensures the Function Caller and Planner
description, and the HTTP method/path for invocation .
which records the reflection question and
with pagination ( GET /corpora/{corpusId}/reflections ) . Additionally, although
Bootstrapping an AI Agent: When starting a new session or agent, a client (or the system) calls
subsystems to add default GPT roles and a health-check reflection . This sets up a fresh
Registering Tools: If there are external functions or APIs the AI might use, they are registered
aware of these tools . (Tools can also be added or updated on the fly as the system is
User Objective and Planning: The user provides an objective or query to the Planner Service.
It sends this to the LLM Gateway via a /chat request, delegating the reasoning to the
LLM . The LLM, seeing the objective and the tool options, may respond with a proposed plan
Function Orchestration: If the LLM’s response includes a function call, the Planner/LLM
function’s details (endpoint, method, etc.) and performs the HTTP request or operation . The
Completing the Plan: Once the LLM has formulated a full solution or all necessary steps, the
through the Function Caller . The outputs of each step are collected and delivered.
Reflection and Learning: After or during execution, the system can generate reflections to
Awareness (and persistence) as part of the corpus’s history . Over time, a series of
Updating Knowledge – Baseline & Drift: Whenever new information is introduced (e.g., the
changes compared to previous knowledge . The narrative patterns analysis might reveal
Iterative Improvement: The next time the user asks a question or sets an objective, the Planner
system’s capabilities dynamically .
"semantic arc" that highlights the evolution of themes and insights . This helps in
get information or perform actions . This means the AI is not limited to its trained knowledge;
reflections are stored in the corpus . They serve two purposes: (1) to provide transparency

promotion) – effectively learning new personas or approaches to improve performance .
piece of information (a new baseline) differs from previous knowledge . This is crucial in longrunning applications (like coaching or monitoring systems) where the situation may change
approach a problem . This capability is vital for complex tasks (e.g., “Help me analyze my
delivering a thoughtful and evolving AI assistant .
[^1]: [FountainAI Platform Overview PDF](FountainAI%20Platform%20Overview.pdf)
[^2]: [Tools Factory API](../FountainAi/openAPI/v1/tools-factory.yml)
[^3]: [Function Caller API](../FountainAi/openAPI/v1/function-caller.yml)
[^4]: [Bootstrap API](../FountainAi/openAPI/v1/bootstrap.yml)
[^5]: [Baseline Awareness API](../FountainAi/openAPI/v1/baseline-awareness.yml)
[^6]: [Planner API](../FountainAi/openAPI/v1/planner.yml)
[^7]: [LLM Gateway API](../FountainAi/openAPI/v2/llm-gateway.yml)
[^8]: [Persistence API](../FountainAi/openAPI/v1/persist.yml)

```
```
```
evaluate the outcome. The Planner or Bootstrap might call the Awareness service (or use its own
/planner/reflections endpoint) to pose questions like "Did the plan succeed? What could
be improved?" to the LLM. These reflections (and their answers) get stored in the Baseline
Awareness (and persistence) as part of the corpus’s history 36 74 . Over time, a series of
reflections provides a form of automated feedback loop where the AI learns from each attempt or
update.
7. Updating Knowledge – Baseline & Drift: Whenever new information is introduced (e.g., the
user uploads new data or the world changes), it can be added as a new baseline via the

6

Bootstrap or Awareness service. Upon adding a baseline, the drift analysis kicks in to highlight
changes compared to previous knowledge 30 . The narrative patterns analysis might reveal
new themes or shifts in tone. All these are stored and the semantic history is updated so that
future queries to the LLM can leverage the historical context and avoid repeating past mistakes
or omissions.
8. Iterative Improvement: The next time the user asks a question or sets an objective, the Planner
and LLM will have access to a richer context: a full history of what happened, prior solutions,
reflections on what worked or failed, and updated knowledge. The AI can reason semantically
about this context (using the Awareness service’s summaries or semantic arc if needed) to
produce better plans. In some cases, a reflection might suggest creating a new tool or a new role
– which can then be fed back into the Tools Factory or Bootstrap (role promotion) to extend the
system’s capabilities dynamically 24 .
All components communicate typically over RESTful APIs (as evidenced by their OpenAPI specs). The
architecture is microservice-based, but all parts are orchestrated to give the effect of an intelligent, selfimproving agent. The Persistence layer (with Typesense) ensures that any component can quickly
query the stored knowledge (for example, the Planner might search past reflections or baselines to
decide which tools to use or what the user might really need). This design allows FountainAI to be
extensible (new tools or models can be integrated), context-aware (through persistent memory of
past interactions and content), and robust (by iterating plans with reflection and detecting drift to adapt
to new information).

Key Use Cases and Features
FountainAI’s unique architecture supports several advanced use cases and features that set it apart
from a basic LLM interface. Some of the main capabilities include:
• Semantic Reasoning and Knowledge Summarization: The platform can perform deep
semantic analytics on the information in a corpus. By using baselines, drift documents, and
narrative pattern analysis, FountainAI can understand and summarize how a body of knowledge
changes over time. For example, it can provide a semantic summary of the corpus history or a
"semantic arc" that highlights the evolution of themes and insights 79 43 . This helps in
reasoning about the context; the AI can explain what has been happening or how a situation
developed, which is crucial for domains like personal coaching, long-term projects, or
storytelling.
• Dynamic Function Orchestration: FountainAI allows LLMs to orchestrate external functions
as part of their reasoning. Through the Tools Factory and Function Caller, an LLM can access a
library of operations (APIs, database queries, calculations, etc.) and invoke them in real time to
get information or perform actions 16 . This means the AI is not limited to its trained knowledge;
it can, for instance, call a web search API, fetch user data, or execute computations on the fly.
The Planner service specifically uses this to break objectives into function call plans, enabling
complex workflows to be automated by the AI (this is akin to having the AI write and execute
code to solve a problem).
• Automated Reflection and Self-Improvement: A standout feature of FountainAI is its ability to
perform automated reflection. After completing tasks or at certain intervals, the AI can
generate reflections – effectively asking itself questions like “What did I learn?”, “What went
wrong?”, or “How can I do better next time?” – and then answering them using the LLM. These
reflections are stored in the corpus 36 74 . They serve two purposes: (1) to provide transparency
and explanations of the AI’s thought process (useful for users to understand the AI’s reasoning),
and (2) to create a feedback loop where the AI’s future planning can avoid past errors. Moreover,

7

FountainAI can even turn insightful reflections into new role prompts (using the Bootstrap role
promotion) – effectively learning new personas or approaches to improve performance 24 .
• Drift Analysis and Change Detection: The platform is designed to handle scenarios where
information updates or evolves. Drift analysis automatically detects and records how a new
piece of information (a new baseline) differs from previous knowledge 28 . This is crucial in longrunning applications (like coaching or monitoring systems) where the situation may change
gradually – the AI remains aware of what’s new or what trend is forming. By logging drifts and
patterns, FountainAI can alert users to important changes or adapt its advice and plans
accordingly. For example, in a business coaching context, if new sales data shows a shift (drift) in
customer behavior, the AI would note that and adjust its recommendations.
• Structured Multi-Step Planning: Instead of answering questions in one go, FountainAI
emphasizes step-by-step planning for complex objectives. The LLM (via the Planner) can output
intermediate steps or sub-goals, possibly with function calls at each step, to systematically
approach a problem 80 50 . This capability is vital for complex tasks (e.g., “Help me analyze my
financial data and draft a report”) where the solution involves multiple actions (gather data,
analyze trends, generate text) – the AI can plan these actions, execute them, and adjust as
needed. It’s essentially the AI doing problem decomposition and execution autonomously.
• Contextual Adaptation with Roles: With its concept of GPT roles, FountainAI can inject
different perspectives or skills into the AI’s responses. The default roles seeded during bootstrap
give the AI a balanced starting persona set, but as the system encounters new challenges, it can
create or learn new roles. This could be seen as having multiple experts in one AI – e.g., a
“Planner” role, a “Critic” role, a “DomainExpert” role – and switching between them or consulting
them internally. This role-based reasoning makes the AI’s output more robust, as it can selfcheck or iterate through various approaches before presenting a final answer.
Overall, FountainAI is built for robust, explainable, and adaptive AI interactions. It goes beyond
single-turn Q&A by maintaining a memory of past interactions and knowledge, by enabling tool use for
extended capabilities, and by incorporating mechanisms for self-reflection and adjustment. This makes
it suitable for applications like personal coaching agents, complex decision-support systems, research
assistants, or any scenario where an AI needs to continuously learn and reason in a changing
environment. The combination of its core components ensures that the AI can plan actions, execute
them, learn from the outcomes, and refine its knowledge, aligning with the platform’s mission of
delivering a thoughtful and evolving AI assistant 16 31 .

1

62

63

64

65

66

67

68

69

70

71

72

73

74

75

76

77

persist.yml

file://file-TRqbobR7N5nnLYBFVtBrrj
2

3

4

5

6

7

8

tools-factory.yml

file://file-LM2mLuM9u824cSCq6a7zc5
9

10

11

12

13

14

15

16

function-caller.yml

file://file-FdchupWBgtkS5mdyD1kmdL
17

18

19

20

21

22

23

24

25

26

27

28

29

30

bootstrap.yml

40

41

42

43

44

79

54

55

56

80

planner.yml

file://file-DmYhEPkgHVt6irpdeuDKFN
31

32

33

34

35

36

37

38

39

baseline-awareness.yml

file://file-U4Nr8WUFJLz9Y5LfZTMPvo
45

46

47

48

49

50

51

52

53

file://file-KJtBPERcsKwyoZZyUPQNqx
57

58

59

60

61

78

llm-gateway.yml

file://file-42vkSwoNDubFcKjxsVFAYV

8


© 2025 Contexter alias Benedikt Eickhoff, https://fountain.coach. All rights reserved.
Unauthorized copying or distribution is strictly prohibited.
