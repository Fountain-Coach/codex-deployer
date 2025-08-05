## Code Coverage Report

### Overall repository coverage

Running `swift test --enable-code-coverage` and analysing with `llvm-cov` produced the following totals:

```
TOTAL                                          32175   26013    19.15%   14604 11167    23.53%  100252 80099    20.10%
```

The repository contains **100,252** executable lines, with **20,153** lines covered (approx. **20.10%** line coverage).

### Repository source coverage

Ignoring third-party packages under `.build/checkouts` and test targets, the totals are:

```
TOTAL                                           591     209    64.64%     174     30    82.76%    1383     414    70.07%
```

Within repository sources there are **1,383** lines, with **969** covered, giving **70.07%** line coverage.

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
The new ``NIOHTTPServer`` port reuse and concurrency tests bring the total test count to **62**.
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
- The new ``DeleteRecordRequest`` and ``UpdateRecordRequest`` tests raise the total test count to **125**.
- The new ``SchemaProperty`` dictionary and fallback tests raise the total test count to **127**.
- The new ``URLSessionHTTPClient`` empty-body and multi-header tests raise the total test count to **129**.
- The new ``SpecLoader`` empty-file and invalid UTF-8 tests raise the total test count to **131**.

- The new ``ServiceInitializerStoresArguments``, ``PublishingConfigCustomValues``, and ``TodosNotEqualWithDifferentName`` tests raise the total test count to **133**.

- The new ``CamelCasedLeadingUnderscore``, ``CamelCasedNumbers``, and ``EmitRequestGeneratesQueryParameter`` tests raise the total test count to **136**.

- The new ``SpecValidator`` empty title, parameter name, and parameter location tests raise the total test count to **139**.
- The new ``CamelCasedTrailingUnderscore`` and ``CamelCasedUppercaseInput`` tests raise the total test count to **141**.
- The new ``ZoneUpdateRequestCodable`` and ``ZonesResponseDecodes`` tests raise the total test count to **143**.
- The new ``LoadPublishingConfigFailsForInvalidYAML`` and ``LoadPublishingConfigFailsForNonNumericPort`` tests raise the total test count to **145**.
- The new ``UpdateRecordSetsAuthHeader`` and ``DeleteRecordSetsAuthHeader`` tests raise the total test count to **147**.
- The new ``AsyncHTTPClientDriver`` unreachable host test and metrics endpoint header and body tests raise the total test count to **150**.
- The new ``LoggingPlugin`` header and body preservation tests raise the total test count to **152**.

- The new ``PublishingFrontendPlugin`` nested-file and header-preservation tests raise the total test count to **154**.
- The new ``LoadPublishingConfigUsesDefaultRootPathWhenMissing`` and ``LoadPublishingConfigUsesDefaultPortWhenMissing`` tests raise the total test count to **156**.
- The new ``APIClient`` NoBody and header omission tests raise the total test count to **158**.
- The new ``ServerServesNestedFile`` and ``LoadPublishingConfigUsesDefaultsWhenFileEmpty`` tests raise the total test count to **160**.
- The new ``CreateRecordEncodesBody`` and ``ListZonesSetsAuthHeader`` tests raise the total test count to **162**.
- The new ``Route53Client`` error description and user-info tests raise the total test count to **164**.
- The new ``ServiceDefaults`` test raises the total test count to **165**.
---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
