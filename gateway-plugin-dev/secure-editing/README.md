# FountainAI Secure Editing Tools

This plugin exposes classic Unix editing utilities—ed/ex, sed, and awk—through a unified, non-interactive API. It enables language models to apply deterministic text transformations on files while the service enforces path and command validation for safety.

## OpenAPI 3.1 Wrapper

```yaml
openapi: 3.1.0
info:
  title: FountainAI Text Edit Service
  version: 1.0.0
  description: |
    Unified wrapper around ed/ex, sed, and awk for non-interactive editing.  
    The `tool` field selects which underlying command runs on a target file.

servers:
  - url: https://api.fountainai.example/v1

paths:
  /edit:
    post:
      summary: Apply text-editing commands with ed/ex, sed, or awk
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [tool, path, commands]
              properties:
                tool:
                  type: string
                  enum: [ed, ex, sed, awk]
                  description: Which tool to invoke.
                path:
                  type: string
                  description: Absolute or relative file path to edit.
                commands:
                  type: array
                  items:
                    type: string
                  description: |
                    List of commands for the chosen tool, executed sequentially.
                  example: ["%s/foo/bar/g", "wq"]
      responses:
        "200":
          description: File edited successfully
          content:
            application/json:
              schema:
                type: object
                properties:
                  status:
                    type: string
                    example: success
                  output:
                    type: string
                    description: Captured stdout/stderr.
        "400":
          description: Invalid request or command error
          content:
            application/json:
              schema:
                type: object
                properties:
                  status:
                    type: string
                    example: error
                  message:
                    type: string
        "404":
          description: File not found
        "500":
          description: Server error

components:
  securitySchemes:
    apiKeyAuth:
      type: apiKey
      in: header
      name: X-API-Key

security:
  - apiKeyAuth: []
```

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
