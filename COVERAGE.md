## Code Coverage Report

### Overall repository coverage

Running `swift test --enable-code-coverage` and analysing with `llvm-cov` produced the following totals:

```
TOTAL                                          31315   28166    10.06%   13942 12280    11.92%   98473   87817    10.82%
```

The repository contains **98,473** executable lines, with **10,656** lines covered (approx. **10.82%** line coverage).

### Repository source coverage

Ignoring third-party packages under `.build/checkouts`, the totals are:

```
TOTAL                                            937     411    56.14%     410   119    70.98%    2126     808    61.99%
```

Within repository sources there are **2,126** lines, with **1,318** covered, giving **61.99%** line coverage.

Coverage results are recalculated after each test run to monitor progress. The project strives for ever more comprehensive test suites across all modules. Recent additions include unit tests for ``APIClient``. New tests now verify ``URLSessionHTTPClient`` behavior and the ``Supervisor`` process termination logic.
Additional tests now cover ``OpenAPISpec.swiftType`` and the ``camelCased`` string helper. A new ``GatewayServerTests`` suite raises total tests to **27**.
The new ``CertificateManagerTests`` ensure renewal scripts run correctly.
New ``SpecValidatorTests`` and ``ListRecordsRequestTests`` bring the total test count to **31**.
New ``DeleteZoneRequestTests`` ensures zone deletion paths are correct, bringing the total to **32** tests.
The added metrics check raises the suite to **33** tests.
The new ``GetRecordRequestTests`` brings the total test count to **34**.
The added ``PublishingConfigDefaultValues`` test raises the suite to **35** tests.
The new ``TodoEncodingRoundTrip`` test brings the total test count to **36**.

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
