## Code Coverage Report

### Overall repository coverage

Running `swift test --enable-code-coverage` and analysing with `llvm-cov` produced the following totals:

```
TOTAL                                          31568   26664    15.53%   14135 11536    18.39%   98950  81708    17.42%
```

The repository contains **98,950** executable lines, with **17,242** lines covered (approx. **17.42%** line coverage).

### Repository source coverage

Ignoring third-party packages under `.build/checkouts`, the totals are:

```
TOTAL                                          1190     370    68.91%     603    93    84.58%    2603     709    72.76%
```

Within repository sources there are **2,603** lines, with **1,894** covered, giving **72.76%** line coverage.

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

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
