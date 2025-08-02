## Code Coverage Report

### Overall repository coverage

Running `swift test --enable-code-coverage` and analysing with `llvm-cov` produced the following totals:

```
TOTAL                                          31516   26416    16.18%   14094 11322    19.67%   98875   81315    17.76%
```

The repository contains **98,875** executable lines, with **17,560** lines covered (approx. **17.76%** line coverage).

### Repository source coverage

Ignoring third-party packages under `.build/checkouts`, the totals are:

```
TOTAL                                          1129     387    65.72%     555   103    81.44%    2493     754    69.76%
```

Within repository sources there are **2,493** lines, with **1,739** covered, giving **69.76%** line coverage.

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

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
