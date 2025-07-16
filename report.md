## Segment 1 - Preamble

```log
[2025-07-15T20:39:35.640589] Dispatcher started successfully 🟢
[2025-07-15T20:39:35.641076] === New Cycle ===
warning: 'fountainai': found 63 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/planner/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Logger.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/BaselineStore.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dispatcher.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/LLMGatewayClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/FunctionCallerClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/TypesenseClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/planner/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/PrometheusAdapter.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPKernel.swift
warning: 'fountainai': found 64 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/planner/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Logger.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/BaselineStore.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dispatcher.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/LLMGatewayClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/FunctionCallerClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/TypesenseClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/planner/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/PrometheusAdapter.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPKernel.swift
warning: 'fountainai': found 64 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/BaselineStore.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/PrometheusAdapter.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/FunctionCallerClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Logger.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dispatcher.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/LLMGatewayClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/TypesenseClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Models.swift
warning: 'fountainai': found 64 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/BaselineStore.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/PrometheusAdapter.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/FunctionCallerClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Logger.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dispatcher.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/LLMGatewayClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/TypesenseClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Models.swift
warning: 'fountainai': found 64 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/BaselineStore.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/PrometheusAdapter.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/FunctionCallerClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Logger.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dispatcher.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/LLMGatewayClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/TypesenseClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Models.swift
warning: 'fountainai': found 64 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/BaselineStore.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/PrometheusAdapter.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/FunctionCallerClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Logger.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dispatcher.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/LLMGatewayClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/TypesenseClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Models.swift
warning: 'fountainai': found 64 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/BaselineStore.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/PrometheusAdapter.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/FunctionCallerClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Logger.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dispatcher.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/LLMGatewayClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/TypesenseClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Models.swift
warning: 'fountainai': found 59 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/BaselineStore.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/PrometheusAdapter.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/FunctionCallerClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Logger.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dispatcher.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/LLMGatewayClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/TypesenseClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Models.swift
warning: 'fountainai': found 57 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/BaselineStore.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/PrometheusAdapter.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Logger.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dispatcher.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/TypesenseClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPRequest.swift
warning: 'fountainai': found 59 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/BaselineStore.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/PrometheusAdapter.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/FunctionCallerClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Logger.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dispatcher.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/LLMGatewayClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/TypesenseClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/planner/Models.swift
warning: 'fountainai': found 59 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/BaselineStore.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/PrometheusAdapter.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/FunctionCallerClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Logger.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dispatcher.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/LLMGatewayClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/TypesenseClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Models.swift
warning: 'fountainai': found 57 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/BaselineStore.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/PrometheusAdapter.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/FunctionCallerClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/LLMGatewayClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/TypesenseClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Models.swift
warning: 'fountainai': found 59 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/BaselineStore.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/PrometheusAdapter.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/FunctionCallerClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Logger.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dispatcher.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/LLMGatewayClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/TypesenseClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Models.swift
warning: 'fountainai': found 58 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/PrometheusAdapter.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/FunctionCallerClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPKernel.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Logger.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dispatcher.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/planner/LLMGatewayClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/Shared/TypesenseClient.swift
    /srv/deploy/repos/fountainai/Generated/Server/bootstrap/Router.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/Handlers.swift
    /srv/deploy/repos/fountainai/Generated/Server/tools-factory/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/llm-gateway/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/HTTPResponse.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/Models.swift
    /srv/deploy/repos/fountainai/Generated/Server/function-caller/main.swift
    /srv/deploy/repos/fountainai/Generated/Server/persist/Dockerfile
    /srv/deploy/repos/fountainai/Generated/Server/persist/HTTPRequest.swift
    /srv/deploy/repos/fountainai/Generated/Server/planner/Models.swift
[0/1] Planning build
Building for debugging...
[0/33] Write swift-version-24593BA9C3E375BF.txt
```
❌ Issues found:
warning: 'fountainai': found 63 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
warning: 'fountainai': found 64 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
warning: 'fountainai': found 64 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
warning: 'fountainai': found 64 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
warning: 'fountainai': found 64 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
warning: 'fountainai': found 64 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
warning: 'fountainai': found 64 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
warning: 'fountainai': found 59 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
warning: 'fountainai': found 57 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
warning: 'fountainai': found 59 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
warning: 'fountainai': found 59 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
warning: 'fountainai': found 57 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
warning: 'fountainai': found 59 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
warning: 'fountainai': found 58 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
**Suggested Fix:** Review the code around the reported line.

## Segment 2 - error: emit-module command failed with exit code 1 (use -v to see invocation)

```log
error: emit-module command failed with exit code 1 (use -v to see invocation)
[2/34] Emitting module BaselineAwarenessServer
```
❌ Issues found:
error: emit-module command failed with exit code 1 (use -v to see invocation)
**Suggested Fix:** Review the code around the reported line.

## Segment 3 - /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift:6:16: error: static property 'kernel' is not concurrency-safe because it is nonisolated global shared mutable state

```log
/srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift:6:16: error: static property 'kernel' is not concurrency-safe because it is nonisolated global shared mutable state
 4 | 
 5 | public class HTTPServer: URLProtocol {
 6 |     static var kernel: HTTPKernel?
```
❌ Issues found:
HTTPServer.swift:6 -> /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift:6:16: error: static property 'kernel' is not concurrency-safe because it is nonisolated global shared mutable state
**Suggested Fix:** Review the code around the reported line.

## Segment 4 - |                |- error: static property 'kernel' is not concurrency-safe because it is nonisolated global shared mutable state

```log
   |                |- error: static property 'kernel' is not concurrency-safe because it is nonisolated global shared mutable state
   |                |- note: convert 'kernel' to a 'let' constant to make 'Sendable' shared state immutable
   |                |- note: add '@MainActor' to make static property 'kernel' part of global actor 'MainActor'
   |                `- note: disable concurrency-safety checks if accesses are protected by an external synchronization mechanism
 7 | 
 8 |     public static func register(kernel: HTTPKernel) {
[3/34] Emitting module LLMGatewayServer
[4/34] Emitting module PersistServer
[5/34] Emitting module BootstrapServer
[6/34] Compiling BaselineAwarenessServer HTTPServer.swift
```
❌ Issues found:
|                |- error: static property 'kernel' is not concurrency-safe because it is nonisolated global shared mutable state
**Suggested Fix:** Review the code around the reported line.

## Segment 5 - /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift:6:16: error: static property 'kernel' is not concurrency-safe because it is nonisolated global shared mutable state

```log
/srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift:6:16: error: static property 'kernel' is not concurrency-safe because it is nonisolated global shared mutable state
 4 | 
 5 | public class HTTPServer: URLProtocol {
 6 |     static var kernel: HTTPKernel?
```
❌ Issues found:
HTTPServer.swift:6 -> /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift:6:16: error: static property 'kernel' is not concurrency-safe because it is nonisolated global shared mutable state
**Suggested Fix:** Review the code around the reported line.

## Segment 6 - |                |- error: static property 'kernel' is not concurrency-safe because it is nonisolated global shared mutable state

```log
   |                |- error: static property 'kernel' is not concurrency-safe because it is nonisolated global shared mutable state
   |                |- note: convert 'kernel' to a 'let' constant to make 'Sendable' shared state immutable
   |                |- note: add '@MainActor' to make static property 'kernel' part of global actor 'MainActor'
   |                `- note: disable concurrency-safety checks if accesses are protected by an external synchronization mechanism
 7 | 
 8 |     public static func register(kernel: HTTPKernel) {

/srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift:10:21: warning: result of call to 'registerClass' is unused
 8 |     public static func register(kernel: HTTPKernel) {
 9 |         self.kernel = kernel
10 |         URLProtocol.registerClass(HTTPServer.self)
   |                     `- warning: result of call to 'registerClass' is unused
11 |     }
12 | 
[7/34] Emitting module PlannerServer

[2025-07-15T20:39:35.641322] Starting swift build...
[2025-07-15T20:39:44.496319] swift build failed with exit code 1
```
❌ Issues found:
|                |- error: static property 'kernel' is not concurrency-safe because it is nonisolated global shared mutable state
HTTPServer.swift:10 -> /srv/deploy/repos/fountainai/Generated/Server/baseline-awareness/HTTPServer.swift:10:21: warning: result of call to 'registerClass' is unused
|                     `- warning: result of call to 'registerClass' is unused
**Suggested Fix:** Review the code around the reported line.

