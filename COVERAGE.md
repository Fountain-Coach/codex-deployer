## Code Coverage Report

### Overall repository coverage

Running `swift test --enable-code-coverage` and analysing with `llvm-cov` produced the following totals:

```
TOTAL                                          31882   26550    16.72%   14380 11491    20.09%   99602 81426    18.25%
```

The repository contains **99,602** executable lines, with **18,176** lines covered (approx. **18.25%** line coverage).

### Repository source coverage

Ignoring third-party packages under `.build/checkouts` and test targets, the totals are:

```
TOTAL                                           590     252    57.29%     173     34    80.35%    1369     477    65.16%
```

Within repository sources there are **1,369** lines, with **892** covered, giving **65.16%** line coverage.

Coverage results are recalculated after each test run to monitor progress. The project strives for ever more comprehensive test suites across all modules. Recent additions include unit tests for ``APIClient``. New tests now verify ``URLSessionHTTPClient`` behavior and the ``Supervisor`` process termination logic.
Additional tests now cover ``OpenAPISpec.swiftType`` and the ``camelCased`` string helper. A new ``GatewayServerTests`` suite raises total tests to **27**.
The new ``CertificateManagerTests`` ensure renewal scripts run correctly.
New ``SpecValidatorTests`` and ``ListRecordsRequestTests`` bring the total test count to **31**.
New ``DeleteZoneRequestTests`` ensures zone deletion paths are correct, bringing the total to **32** tests.
The added metrics check raises the suite to **33** tests.
The new ``GetRecordRequestTests`` brings the total test count to **34**.
The added ``PublishingConfigDefaultValues`` test raises the suite to **35** tests.
The new ``TodoEncodingRoundTrip`` test brings the total test count to **36**.
The new ``SecurityRequirementTests`` bring the total test count to **38**.
The new ``HTTPResponseDefaultsTests`` increase the total test count to **40**.
The new ``AsyncHTTPClientDriverTests`` bring the total test count to **41**.
The new ``CreatePrimaryServerRequestTests`` and ``GetPrimaryServerRequestTests`` raise the total test count to **49**.
Additional plugin rewrite and raw data tests raise the total test count to **51**.
The new ``validateZoneFile`` and ``updatePrimaryServer`` request tests raise the total test count to **55**.
The new ``TodoEquality`` and ``TodoDecodingFailsForMissingName`` tests bring the total test count to **57**.
The new ``NIOHTTPServer`` port reuse and concurrency tests and Hetzner DNS model round-trip checks bring the total test count to **62**.
The new ``importZoneFile`` and ``exportZoneFile`` request tests raise the total test count to **66**.
The new ``getZone`` and ``listPrimaryServers`` request tests raise the total test count to **69**.
The new ``PublishingFrontendPlugin`` pass-through and non-GET tests raise the total test count to **71**.
The new ``Route53Client`` error detail tests raise the total test count to **73**.
The new ``BulkRecordsUpdateRequestCodable`` and ``PrimaryServersResponseDecodes`` tests raise the total test count to **75**.

The new ``CertificateManager`` start and stop tests raise the total test count to **77**.
The new server 404 and non-GET tests raise the total test count to **79**.
The new ``PrimaryServerCreateCodable``, ``RecordResponseDecodes``, and ``ZoneCreateRequestCodable`` tests raise the total test count to **82**.
The new ``HTTPRequestTests`` verifying defaults and mutation raise the total test count to **84**.

The new ``TodoDecodingFailsForMissingID``, ``LoadPublishingConfigFailsForMissingFile``, and ``ServerSetsContentTypeHeader`` tests raise the total test count to **87**.

The new ``bulkCreateRecords`` and ``createZone`` request tests raise the total test count to **91**.

The new ``AsyncHTTPClientDriver`` body transmission test and ``HTTPKernel`` error propagation test raise the total test count to **93**.

The new ``HTTPRequest`` initializer and ``HTTPResponse`` mutation tests raise the total test count to **96**.

The new ``TodosNotEqualWithDifferentID`` and ``TodoEncodingProducesExpectedJSON`` tests bring the total test count to **98**.

The new ``SpecValidator`` missing parameter, required flag, and security scheme tests raise the total test count to **101**.
The new ``GatewayPlugin`` default behavior tests and ``PublishingFrontendPlugin`` header check raise the total test count to **103**.

The new ``DeletePrimaryServerRequestTests`` raise the total test count to **105**.

- The new ``bulkUpdateRecords`` and ``updateZone`` request tests raise the total test count to **109**.
- The new ``GatewayServer`` unknown-path and plugin-order tests raise the total test count to **111**.

- The new ``CamelCasedEmptyString`` and ``CamelCasedMultipleUnderscores`` tests raise the total test count to **113**.

- The new ``HTTPResponseStatusMutation`` and ``HTTPResponseBodyMutation`` tests raise the total test count to **115**.

- The new ``OpenAPIParameter`` name and type tests raise the total test count to **117**.
- The new ``GatewayServer`` prepare-order and health content-type tests raise the total test count to **119**.
- The new ``listZones`` identifier retrieval and ``Route53Client`` error detail tests raise the total test count to **122**.

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
