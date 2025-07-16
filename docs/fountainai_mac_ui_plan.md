# FountainAI Mac Desktop UI Development Plan

This document outlines an iterative approach for building a macOS desktop application that integrates the FountainAI microservices with the Teatro View Engine for rendering user interfaces. The goal is to combine the service clients generated from the OpenAPI specifications with Teatro's declarative views to deliver a native Mac experience.

## 1. Prepare the FountainAI Services

1. Clone the `fountainai` repository and ensure all services build successfully.
2. Start the services locally via `docker compose` or Xcode schemes. Configure the environment variables described in [environment_variables.md](environment_variables.md) such as `TYPESENSE_URL`, `TYPESENSE_API_KEY` and `OPENAI_API_KEY` so the services can reach their dependencies.
3. Verify basic health endpoints using the generated clients.

## 2. Generate and Integrate API Clients

1. Use the OpenAPI definitions under `FountainAi/openAPI/v1/` and `v2/` to generate Swift clients for each service (`planner`, `function-caller`, `bootstrap`, `baseline-awareness`, etc.).
2. Publish the clients as Swift packages or local dependencies.
3. In your Mac app project, add these packages through Swift Package Manager so the UI layer can call the services directly.

## 3. Build a Thin Data Layer

1. Wrap the service clients in a small data controller that exposes high level operations (e.g. `planObjective()`, `executePlan()`, `listReflections()`).
2. Handle authentication tokens and base URLs from the same environment variables listed above.
3. Ensure calls are async and return Combine publishers or Swift `async` results for easy binding in the UI.

## 4. Assemble Teatro Views

1. Design screens using Teatro's `Renderable` types — `Stage`, `VStack`, `Text`, and any custom views required.
2. Map responses from the data layer into renderable components (for example, transform a `PlanResponse` into a list of steps with `VStack`).
3. Utilize Teatro's rendering backends to preview in SwiftUI or export HTML/SVG as needed.

## 5. Create the macOS Application Shell

1. Set up a new SwiftUI-based Mac app project in Xcode.
2. Embed Teatro views inside SwiftUI wrappers as demonstrated in `Docs/Addendum` of the Teatro repository to enable live previews.
3. Connect UI actions (buttons, forms) to the data layer methods so the app invokes FountainAI services when users interact with the interface.

## 6. Iterate with Feedback

1. Start with a minimal planner UI: a text field for the objective and a results area rendering the plan.
2. Gradually integrate more endpoints (function execution, baseline management, reflection history) using the same pattern.
3. Track issues and enhancements in the repository and update the implementation roadmap under `Docs/ImplementationPlan` in the Teatro repo as new tasks emerge.

## 7. Testing and Environment Management

1. Use the tests already defined in the FountainAI clients and Teatro framework. Run `swift test -v` in each repository after changes to ensure compatibility.
2. Document any new environment variables or configuration changes in [environment_variables.md](environment_variables.md) so other developers can replicate the setup.

---

Following this plan will produce a fully featured macOS application that leverages FountainAI's microservices and Teatro's declarative rendering system.
