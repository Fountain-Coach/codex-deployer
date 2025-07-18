FountainAI Platform Overview
What is FountainAI?
FountainAI is a comprehensive platform that combines large language models (LLMs) with a suite of
specialized services to enable advanced AI reasoning, planning, and knowledge management. Its
mission is to provide an AI orchestration environment where an LLM can plan tasks, call external
functions (tools), reflect on results, and analyze changes in knowledge over time. The platform
manages "semantic artifacts" – such as knowledge baselines, drift documents, reflections, and function
definitions – organized into corpora (contexts or workspaces) 1 . By integrating function-calling LLMs
with persistent semantic memory, FountainAI supports use cases like dynamic tool use, step-by-step
task planning, automated self-reflection, and drift analysis to track how information evolves.

Tools Factory
The Tools Factory Service is responsible for registering and managing external tools (functions) that
the AI can invoke during its reasoning process 2 . In FountainAI, a "tool" is essentially a function
defined by an OpenAPI specification. The Tools Factory takes in these definitions and stores them in a
shared index (backed by a Typesense search engine) so that they can be discovered and called by other
services (notably the Function Caller) 3 . Key capabilities of the Tools Factory include:
• Registering New Tools: Clients can submit an OpenAPI document (containing one or multiple
function definitions) via the /tools/register endpoint. The service extracts each operation
(function) and saves its metadata (name, description, parameters schema, HTTP endpoint to call,
etc.) for later use 4 5 . Each tool is associated with a unique operationId (function
identifier) and can be tagged to a specific corpus context (via a corpusId parameter) for
namespacing 6 .
• Listing Available Tools: The /tools endpoint allows retrieval of all registered functions, with
pagination support
for the AI to use.

7

8

. This lets the system or users query what tools are currently available

By centralizing function definitions, the Tools Factory enables FountainAI to dynamically expand its
capabilities. When new APIs or functions are registered, the AI can discover and invoke them as needed
to fulfill user objectives.

Function Caller
The Function Caller Service is the runtime component that executes the tools/functions registered in
the platform 9 . It serves as a bridge between the LLM’s function-calling intentions and actual HTTP
API calls or other function executions. In practice, when the LLM (via the Planner) decides to use a
function, the Function Caller handles invoking that function and returning the results. Key
functionalities of this service include:
• Function Invocation: The core feature is an invoke endpoint ( POST /functions/
{function_id}/invoke ) that takes a function identifier and input parameters, then performs
the corresponding HTTP request or operation and returns the result 10

1

11 . This allows the LLM

to trigger any available tool by name (the function_id corresponds to the operationId
defined when the tool was registered).
• Function Management: The Function Caller can list all registered functions ( GET /
functions ) and provide details of a specific function ( GET /functions/{function_id} )
12

13 . This mirrors the data from Tools Factory, ensuring the AI agent knows what functions

exist and how to call them. Each function’s metadata includes its human-readable name,
description, HTTP method and path, and a schema for expected parameters 14 15 .
By acting as a “dynamic operationId-to-HTTP call mapping factory”, the Function Caller enables LLMdriven function orchestration 16 . In other words, the AI can plan a series of function calls (by their
IDs) and rely on this service to carry out the actual operations and retrieve results, which can then be
fed back into the LLM’s reasoning process.

Bootstrap Service
The Bootstrap Service handles the initialization and setup of a new corpus (a working context for an
AI agent) and streamlines the process of seeding it with default information 17 . Think of it as a onestop orchestrator for starting an AI session with all necessary defaults (roles, baseline knowledge, etc.)
and for adding new content with immediate analysis. Its key responsibilities and endpoints include:
• Corpus Initialization: The endpoint POST /bootstrap/corpus/init creates a new empty
corpus and immediately seeds it with some defaults 18 . Under the hood, this call performs
multiple steps: (1) it calls the Baseline Awareness service to create a new corpus entry
(essentially reserving an ID for a new knowledge base); (2) it seeds the corpus with five default
GPT roles via another endpoint; and (3) it enqueues a default reflection (called "role-healthcheck") into the corpus 19 20 . The default roles are pre-defined prompts or personas for the
GPT model, ensuring the agent starts with some baseline behaviors or perspectives.
• Seeding GPT Roles: The POST /bootstrap/roles/seed endpoint explicitly populates an
existing corpus with the five standard GPT role prompts 21 22 . These roles might represent
different viewpoints or skills (for example, Analyst, Critic, Explainer, etc., although the specific
roles are defined in the system) that the AI can adopt. Seeding roles ensures the AI has a multifaceted starting point for reasoning.
• Default Reflection and Role Promotion: The POST /bootstrap/corpus/reflect can
enqueue a default reflection (the "role-health-check") at any time for a given corpus 23 ,
prompting the system to generate a reflective analysis (often a Q&A or diagnostic about the
current roles’ performance). Additionally, POST /bootstrap/roles/promote will take the
latest reflection (specifically the result of a role health check) and convert it into a new GPT role
24
25 . This means if the system's reflection identifies a useful new perspective or rule, that
insight can be turned into a permanent role prompt for future interactions.
• Adding Baselines with Analysis: One of the most powerful features is POST /bootstrap/
baseline , which allows the user to add a new baseline document to the corpus along with
triggering immediate analysis 26 . A baseline could be a chunk of knowledge or data (text or
JSON) that the user considers the ground truth or starting content. When this endpoint is called,
the service will:
• Store the baseline content in the Awareness/Persistence layer 27 .
• Kick off real-time analysis streams for drift and patterns. Specifically, it opens two server-sent
event (SSE) channels – one that streams a drift analysis (comparing the new baseline with prior
state to detect what has changed or "drifted") and another that streams a narrative patterns
analysis (identifying themes or patterns in the content) 28 . These analyses are persisted as
special entries (tagged with the baseline ID plus "-drift" and "-patterns") once completed.

2

• Schedule follow-up background jobs to update the history aggregation and semantic arc for
the corpus 29 . The history is an accumulation of all semantic changes, and the semantic arc is a
synthesized overview or storyline of the corpus’s knowledge over time.
All these steps happen in one call to /bootstrap/baseline , providing a convenient way to enrich
the corpus and immediately understand new data 30 . The Bootstrap Service thus ties together the
other services (Awareness, Roles, Persistence) to simplify starting and updating an AI agent’s
knowledge base.

Baseline Awareness Service
The Baseline Awareness Service manages the knowledge state and semantic analytics for each
corpus 31 . It is essentially the brain of FountainAI for tracking what the AI knows (baselines), how it
changes (drift), what patterns emerge, and what reflections have been made. Its core functions and
endpoints include:
• Corpus Management: The service can initialize a new corpus ( POST /corpus/init ), which
creates a fresh container for semantic content identified by a corpus ID 32 . All subsequent data
(baselines, drifts, etc.) will be tied to this corpus.
• Baselines and Drift: You can add a baseline text or document to the corpus via POST /
corpus/baseline

33 . A baseline might be an initial snapshot of information or a significant

update. Complementary to baselines, POST /corpus/drift allows adding a drift document
34 . A drift document typically represents changes or differences from a previous baseline –

essentially capturing how the state has shifted. The Awareness service likely computes or stores
these drifts (in practice, as noted, the Bootstrap service triggers drift analysis automatically when
adding a baseline).
• Narrative Patterns: Through POST /corpus/patterns , the service can store narrative
patterns related to the corpus 35 . Narrative patterns analysis might extract common themes,
story arcs, or other structural patterns from the content, which help in understanding the overall
narrative or evolution of the data.
• Reflections: The Awareness service records reflections – which are question/answer pairs or
insights generated by the AI about the corpus. Clients can add a reflection via POST /corpus/
reflections

36 , providing a prompt/question and the AI’s reflective answer. The service

stores these as part of the corpus’s knowledge. You can also list all reflections in a corpus with
GET /corpus/reflections/{corpus_id} 37 38 . Reflections are a form of automated
semantic reasoning where the AI thinks about what it knows or about its own processes, aiding
in planning and self-correction.
• History and Semantic Arc: The service keeps a history of all changes in the corpus. GET /
corpus/history/{corpus_id} returns the change log (baselines added, drifts, reflections
made, etc.) over time 39 40 . Moreover, it can generate a summarized history or "semantic arc"
for the corpus: GET /corpus/summary/{corpus_id} gives a semantic summary of the
history 41

42 , and

GET /corpus/semantic-arc produces a more analytical construct of

how the narrative/knowledge evolved 43 44 . The semantic arc is essentially an insight into the
corpus’s journey – highlighting key developments, shifts in theme or sentiment, and overall
progress of understanding.
In summary, the Baseline Awareness Service is crucial for semantic reasoning and memory. It not
only stores raw data (baselines and updates) but also layers on interpretation – tracking differences
(drift), extracting patterns, and allowing the system to reflect and summarize. This ensures the
FountainAI agent remains aware of its knowledge state and can reason about its own knowledge (metacognition).

3

Planner Service
The Planner Service is the component that enables LLM-driven planning and orchestration of tasks
45 . When a user provides a high-level goal or problem, the Planner service is responsible for breaking
it down (with the help of the LLM) into a sequence of actionable steps, usually in the form of function
calls (tools to use) and then executing those steps. The Planner’s key features include:
• Generating Plans (Reasoning): The endpoint POST /planner/reason takes a user’s
objective (a description of what the user wants to achieve) and produces a step-by-step plan to
accomplish it 46 47 . Under the hood, the Planner likely engages an LLM (via the LLM Gateway)
along with context about available tools and relevant knowledge, asking the LLM to devise a
sequence of function calls or actions to reach the goal. The output is typically a list of steps or a
structured plan (for example, a list of function names with arguments – effectively an LLMgenerated program).
• Executing Plans: After a plan is created, POST /planner/execute will run the plan step by
step 48 49 . The request includes the plan (which could be a list of function calls with
parameters), and the Planner service will iterate through each function call, invoke it using the
Function Caller, and gather the results. The final response includes the outcome of each step
(function outputs) in order 50 51 . This two-phase approach (plan then execute) allows for
human verification or modification of the plan before running it, and also mirrors how chain-ofthought planning can be separated from action execution.
• Corpora Awareness: GET /planner/corpora lists all available corpus IDs the planner knows
about 52 . This suggests the Planner can operate in the context of different knowledge bases
(for different users, domains, or sessions) and may select information or tools relevant to the
specified corpus when planning.
• Integrating Reflections: The Planner service also has endpoints to retrieve reflection history
and semantic arc for a corpus ( GET /planner/reflections/{corpus_id} and /planner/
reflections/{corpus_id}/semantic-arc ) 53

54 . This is likely used to provide the LLM

with context about what has been learned or what insights have been gathered previously, so it
can plan with that in mind. There’s also a POST /planner/reflections/ endpoint to add a
new reflection by providing a message (prompt) and letting the system generate and store the
reflection 55 56 . This is similar to the Awareness service’s reflection addition, suggesting the
Planner can trigger reflective thinking as part of the workflow (for example, asking the LLM to
analyze or critique the result after executing a plan step).
In essence, the Planner is the conductor that leverages the LLM’s capabilities to reason about tasks and
decide on using tools. It works closely with the LLM Gateway (for the actual reasoning step) and with
the Function Caller (for executing chosen actions). By maintaining awareness of corpora and reflections,
it ensures that plans are informed by the AI’s knowledge base and past insights.

LLM Gateway
The LLM Gateway is a service that acts as a proxy/facade to the underlying large language model
(LLM), especially one that supports OpenAI-style function calling 57 . This gateway allows FountainAI to
interface with different LLM providers or models in a consistent way. Its main responsibilities include:
• Handling Chat Requests: The primary endpoint is POST /chat , which is used to conduct a
chat session or query with the LLM 58 . The request typically contains the conversation
context (history of messages), the user's latest prompt or objective, and importantly, a list of
available functions (tools) that the LLM can choose to call 59 60 . The LLM Gateway packages

4

this information and sends it to the actual LLM (for example, an OpenAI GPT-4 API or another
model endpoint).
• Function-Calling Support: Because the request includes a functions list and an instruction to
the model that it can invoke functions, the LLM can decide to output a function call as part of its
response. The LLM Gateway captures such function call responses and can route them to the
Function Caller. In many cases, the Planner service (or whatever client calls /chat) will loop:
sending the user query, getting either an answer or a function call, executing the call via
Function Caller, and then sending the result back to the LLM via this gateway, until the LLM
produces a final answer. The function_call field in the request can also be set to "auto" to
let the model decide when to use a function 61 .
• Model Agnosticism: The gateway is designed to work with any LLM that supports the functioncalling interface, not just a single model 57 . This means FountainAI could be configured to use
different models (OpenAI, Azure, local models, etc.) without other services needing to know the
specifics. The /chat endpoint ensures the prompt, functions, and parameters are formatted
correctly for the model.
In summary, the LLM Gateway delegates the reasoning to the AI model given a user’s objective and
toolset 59 . It abstracts the details of the LLM API and provides a streamlined interface for the Planner
(or other components) to get model-generated decisions and responses. By including tool information
in the prompt, it enables the model to perform augmented reasoning – i.e., use tools when necessary to
fetch information or perform actions.

Persistence Layer
The Persistence Service is the backbone that stores and indexes all of FountainAI’s knowledge
artifacts using a Typesense engine 1 . All data related to corpora – baselines, drifts, reflections,
functions, history – is persisted via this service so that it can be queried and retrieved efficiently by the
other components. Key aspects of the persistence layer include:
• Corpus Storage: The service enables creation of new corpora ( POST /corpora ) and listing
existing corpora ( GET /corpora ) 62

63 . A corpus is identified by a unique ID and acts as a

namespace for all associated data (this prevents, for example, tools or reflections from different
projects or users from mixing together).
• Baseline and Drift Storage: When a baseline snapshot is added to the system, the persistence
service stores it under the corresponding corpus ( POST /corpora/{corpusId}/baselines )
64

65 . This includes the baseline content and an ID for that baseline version 66

67 . Drift

documents or analyses would similarly be stored, typically as separate entries (often with a
naming convention linking them to a baseline). By saving baselines and drifts, the platform
builds a time-indexed record of knowledge states, which can later be searched or analyzed.
• Function Indexing: All function (tool) definitions registered via the Tools Factory are ultimately
saved through the persistence layer as well. The endpoint POST /corpora/{corpusId}/
functions adds a function record to a corpus 68

69 . There are also global endpoints to list all

functions ( GET /functions ) and get details of a specific function ( GET /functions/
{functionId} ) from the persistent store 70

71 . This ensures the Function Caller and Planner

can quickly lookup available functions. Each stored function entry includes its unique ID, name,
description, and the HTTP method/path for invocation 72 73 .
• Reflection and History Storage: Reflections generated by the AI are stored via POST /
corpora/{corpusId}/reflections

74

75 , which records the reflection question and

answer content under the corpus. The persistence service also supports retrieving all reflections
with pagination ( GET /corpora/{corpusId}/reflections ) 76 77 . Additionally, although
not shown in the snippet above, the history of changes (baselines added, drifts, reflections, etc.)

5

for each corpus would be stored and could be retrieved to support the history timeline and
semantic arc features.
Because it is Typesense-backed, the persistence layer likely provides not just simple storage but also
semantic indexing and search capabilities. This means the AI can perform semantic lookups – for
example, finding which past reflection or baseline is relevant to a new query – using vector search or
full-text search. By maintaining a structured yet searchable memory, the persistence service allows
FountainAI to scale its knowledge and retrieve relevant information when reasoning.

Platform Architecture and Data Flow
FountainAI’s architecture is composed of these modular services that work in concert to achieve
intelligent behavior. The typical data and task flow in the platform might look like the following:
1. Bootstrapping an AI Agent: When starting a new session or agent, a client (or the system) calls
the Bootstrap Service to create a new corpus and seed it. The bootstrap process will coordinate
with the Baseline Awareness Service to initialize the corpus and with the Roles/Reflection
subsystems to add default GPT roles and a health-check reflection 19 20 . This sets up a fresh
knowledge base and some initial self-monitoring capability for the AI.
2. Registering Tools: If there are external functions or APIs the AI might use, they are registered
via the Tools Factory, which stores their definitions in the Persistence Layer (Typesense index).
Now the AI’s "toolbox" is populated with functions it can call, and the Function Caller service is
aware of these tools 3 9 . (Tools can also be added or updated on the fly as the system is
running.)
3. User Objective and Planning: The user provides an objective or query to the Planner Service.
The Planner then prepares a prompt that includes the user's request and contextual information
(relevant baseline knowledge, recent history or reflections, and the list of available functions)
59 . It sends this to the LLM Gateway via a /chat request, delegating the reasoning to the
LLM 78 . The LLM, seeing the objective and the tool options, may respond with a proposed plan
or directly with a function call as the next step (thanks to the function-calling interface). For
example, the LLM might decide: "To answer this, I should call the search_tool function with
argument X".
4. Function Orchestration: If the LLM’s response includes a function call, the Planner/LLM
Gateway will invoke the Function Caller to execute that call. The Function Caller looks up the
function’s details (endpoint, method, etc.) and performs the HTTP request or operation 10 . The
result (e.g., the API response) is returned to the LLM via the Gateway. The LLM then continues
reasoning with that new information. This loop may repeat, with the LLM calling multiple tools in
sequence (this is the orchestration process), until it arrives at an answer or a complete plan.
5. Completing the Plan: Once the LLM has formulated a full solution or all necessary steps, the
Planner service compiles this into a structured Plan (a series of steps). If not already executed
during the reasoning loop, the client can call planner/execute to run any remaining steps
through the Function Caller 50 . The outputs of each step are collected and delivered.
6. Reflection and Learning: After or during execution, the system can generate reflections to
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
