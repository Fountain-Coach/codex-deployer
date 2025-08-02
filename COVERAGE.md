## Code Coverage Report

### Overall repository coverage

Running `swift test --enable-code-coverage` and analysing with `llvm-cov` produced the following totals:

```
TOTAL                                          31439   26679    15.14%   14032 11547    17.71%   98722   81746    17.20%
```

The repository contains **98,722** executable lines, with **16,976** lines covered (approx. **17.20%** line coverage).

### Repository source coverage

Ignoring third-party packages under `.build/checkouts`, the totals are:

```
TOTAL                                           933     334    64.20%     408    76    81.37%    2092     622    70.27%
```

Within repository sources there are **2,092** lines, with **1,470** covered, giving **70.27%** line coverage.

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

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
