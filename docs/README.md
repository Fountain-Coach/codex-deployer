# Developer Documentation

This directory collects generated documentation derived from inline `///` comments.
As modules gain documentation, brief summaries are added here.

## Current Highlights
- **PublishingFrontend** – lightweight static HTTP server for serving the `/Public` directory.
- **HTTPKernel** – simple asynchronous router used by the gateway and publishing frontend.
- **HetznerDNSClient** – Swift wrapper for the Hetzner DNS API with typed requests.
- **DNSProvider** – abstraction over DNS APIs with stubs for Route53.
- **AsyncHTTPClientDriver** and **URLSessionHTTPClient** – documented HTTP clients powering network requests. The former now includes top-level class docs and dedicated tests verifying request execution.
- **NIOHTTPServer** – documented server adapter built on SwiftNIO.
- **NIOHTTPServer.kernel**, **group**, and **channel** – internal server properties now described.
- **HTTPHandler** – internal request dispatcher within `NIOHTTPServer` is now thoroughly documented.
- **NIOHTTPServer.init** – initializer now documents kernel and event loop group parameters.
- **LoggingPlugin** – prints requests and responses for debugging.
- **GatewayPlugin** – protocol for request and response middleware.
- **GatewayPlugin.prepare** and **respond** – default implementations now explain parameters and return values.
- **CertificateManager** – runs periodic certificate renewal scripts.
- **SpecLoader** – parses OpenAPI specifications from JSON or YAML.
- **ClientGenerator** and **ServerGenerator** – emit Swift client and server code from specs.
- **GeneratorCLI** – command line interface for the code generators.
- **CreateRecord** – documented request wrapper for adding DNS records.
- **HTTPRequest** and **HTTPResponse** – request/response models now fully documented.
- **NoBody** – placeholder type for empty request bodies is now documented.
- **APIRequest** – protocol now documents HTTP method, path, and body fields.
- **APIClient** – initializer and URLSession extension now documented for clarity.
- **URLSessionHTTPClientTests** – updated for Linux compatibility ensuring network client coverage.
- **OpenAPISpec.swiftType** – documented helper converting schemas to Swift types.
- **String.camelCased** – extension for transforming snake case identifiers.
- **Agent.main** – entry point usage instructions are now documented.
- **publishing-frontend CLI** – documented main entrypoint starting the static server.
- **clientgen-service CLI** – wrapper around GeneratorCLI is now documented.
- **GatewayServerTests** – verifies the gateway's health endpoint.
- **GatewayServer** – documentation now covers health and metrics endpoints.
- **Service** and **Supervisor** – properties and lifecycle methods documented.
- **SpecValidator** – checks OpenAPI documents for duplicate IDs and unresolved references.
- **SpecValidator.validateSchema** – documents recursive schema reference checks and path placeholder enforcement.
- **listRecords** and **listPrimaryServers** – request types now include documentation.
- **bulkUpdateRecords**, **deleteZone**, **updateZone**, **exportZoneFile**, **importZoneFile** – additional DNS client requests documented.
- **bulkCreateRecords** and **createZone** – request types now document bulk record creation and zone provisioning.
- **getRecord** and **updateRecord** – request types now include usage documentation.
- **getZone** – request type now documents zone retrieval parameters.
- **listPrimaryServersParameters.zoneId** – optional zone filter now clarified.
- **PublishingConfig.port** and **rootPath** – documented properties clarifying server binding and static directory.
- **Todo.id** and **Todo.name** – documented properties clarifying task identifiers and titles.
- **OpenAPISpec** – root model now documents components, servers, security schemes, and requirements.
- **Route53Client** – stub methods now describe the unimplemented error responses.
- **FountainOps Todo** – generated model now documents its properties.
- **createPrimaryServer** and **getPrimaryServer** – request types now document server creation and retrieval.
- **validateZoneFile** and **updatePrimaryServer** – request types now document zone file validation and primary server updates.
- **deletePrimaryServer** – request and parameters now document primary server deletion.
- **GatewayServer** – internal components like the certificate manager and plugin stack are now described.
- **GatewayServer.start** and **stop** – documentation now explains certificate manager activation and graceful shutdown.
- **APIClient.baseURL**, **session**, and **defaultHeaders** – stored properties document connection details.
- **HetznerDNSClient.api** – underlying HTTP client property now documented.
- **ServerGenerator emit helpers** – private functions now describe generated source responsibilities.
- **BulkRecordsCreateRequest** and **validateZoneFileResponse** – documented models for batch record creation and zone validation feedback.
- **PublishingFrontendPlugin.rootPath** – documented property describing the static file directory.
- **PublishingFrontend.server**, **group**, and **config** – internal properties now describe server instance, event loop management, and runtime configuration.
- **BulkRecordsUpdateRequest**, **BulkRecordsUpdateResponse**, **RecordUpdate**, and **PrimaryServer** – documented models covering batch record updates and primary server metadata.
- **PrimaryServerCreate**, **PrimaryServerResponse**, **PrimaryServersResponse**, **Record**, **RecordCreate**, **RecordResponse**, **RecordsResponse**, **Zone**, **ZoneCreateRequest**, **ZoneResponse**, **ZoneUpdateRequest**, and **ZonesResponse** – additional Hetzner DNS models now fully documented.
- **CertificateManager.start**, **stop**, and **triggerNow** – document timer scheduling, cancellation semantics, and on-demand execution.
- **HTTPRequest.method**, **path**, **headers**, and **body** – properties now describe their respective roles.
- **HTTPResponse.status**, **headers**, and **body** – properties now clarify response components.
- **HTTPKernel.handle** – now documents error propagation from routing closures.
- **run-tests.sh** – helper script bundling release build and coverage test steps.
- **PublishingFrontendPlugin.respond** – documents parameters and emitted `Content-Type` header when serving files.
- **bulkUpdateRecords.method** and **path**, **updateZone.method** and **path** – request properties now describe HTTP verbs and endpoint resolution.
- **GatewayServer.plugins** – documents plugin execution order for request preparation and response processing.

Documentation coverage will expand alongside test coverage.

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
