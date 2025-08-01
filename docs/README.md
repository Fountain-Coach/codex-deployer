# Developer Documentation

This directory collects generated documentation derived from inline `///` comments.
As modules gain documentation, brief summaries are added here.

## Current Highlights
- **PublishingFrontend** – lightweight static HTTP server for serving the `/Public` directory.
- **HTTPKernel** – simple asynchronous router used by the gateway and publishing frontend.
- **HetznerDNSClient** – Swift wrapper for the Hetzner DNS API with typed requests.
- **DNSProvider** – abstraction over DNS APIs with stubs for Route53.
- **AsyncHTTPClientDriver** and **URLSessionHTTPClient** – documented HTTP clients powering network requests.
- **NIOHTTPServer** – documented server adapter built on SwiftNIO.
- **HTTPHandler** – internal request dispatcher within `NIOHTTPServer` is now thoroughly documented.
- **LoggingPlugin** – prints requests and responses for debugging.
- **GatewayPlugin** – protocol for request and response middleware.
- **CertificateManager** – runs periodic certificate renewal scripts.
- **SpecLoader** – parses OpenAPI specifications from JSON or YAML.
- **ClientGenerator** and **ServerGenerator** – emit Swift client and server code from specs.
- **GeneratorCLI** – command line interface for the code generators.
- **CreateRecord** – documented request wrapper for adding DNS records.
- **HTTPRequest** and **HTTPResponse** – request/response models now fully documented.
- **APIClient** – initializer and URLSession extension now documented for clarity.
- **URLSessionHTTPClientTests** – updated for Linux compatibility ensuring network client coverage.
- **OpenAPISpec.swiftType** – documented helper converting schemas to Swift types.
- **String.camelCased** – extension for transforming snake case identifiers.
- **Agent.main** – entry point usage instructions are now documented.
- **GatewayServerTests** – verifies the gateway's health endpoint.

Documentation coverage will expand alongside test coverage.

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
