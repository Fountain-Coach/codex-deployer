## Code Coverage Report

### Overall repository coverage

Running `swift test --enable-code-coverage` and analysing with `llvm-cov` produced the following totals:

```
TOTAL                                          31667   26647    15.85%   14204 11535    18.79%   99150 81688    17.61%
```

The repository contains **99,150** executable lines, with **17,462** lines covered (approx. **17.61%** line coverage).

### Repository source coverage

Ignoring third-party packages under `.build/checkouts`, the totals are:

```
TOTAL                                           590     289    51.02%     173     56    67.63%    1362     541    60.28%
```

Within repository sources there are **1,362** lines, with **821** covered, giving **60.28%** line coverage.

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

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
