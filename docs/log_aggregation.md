# Log Aggregation Setup

FountainAI services emit structured JSON logs to `STDOUT`. You can forward these logs to a centralized system using Docker's logging drivers or a sidecar agent.

## Docker Compose Example

Add a `logging` section to each service to ship logs to a collector such as Loki:

```yaml
services:
  function-caller:
    build: ../../Generated/Server/function-caller
    logging:
      driver: loki
      options:
        loki-url: "http://loki:3100"
```

Replace `loki-url` with your aggregator endpoint. The same pattern applies to the Tools Factory and other services.

For manual deployments, run a tool like `fluent-bit` or `promtail` to stream logs from Docker to the aggregator.

```
© 2025 Contexter alias Benedikt Eickhoff, https://fountain.coach. All rights reserved.
Unauthorized copying or distribution is strictly prohibited.
```
