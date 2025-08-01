# FountainAI Playground Guidelines

The FountainAI Playground is a lightweight space for experimenting with GUI ideas. It is **not** intended for production deployments. Treat it as a sandbox where UI prototypes can evolve without affecting live services.

Keep API tokens and other secrets private. Follow the setup described in [environment_variables.md](environment_variables.md) and store tokens in your environment rather than hard-coding them. The playground should read configuration from those variables just like the dispatcher.

To start exploring, create a simple view that fetches data from a FountainAI service. Begin with mock responses so you can focus on the UI layout before integrating network calls. Once you are comfortable with the view structure, swap in the real service clients and build on that foundation.

````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````
