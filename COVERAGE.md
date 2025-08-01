## Code Coverage Report

### Overall repository coverage

Running `swift test --enable-code-coverage` and analysing with `llvm-cov` produced the following totals:

```
TOTAL                                          31264   28203     9.79%   13901 12291    11.58%   98355   87885    10.65%
```

The repository contains **98,355** executable lines, with **10,470** lines covered (approx. **10.65%** line coverage).

### Repository source coverage

Ignoring third-party packages under `.build/checkouts`, the totals are:

```
TOTAL                                            747     885    45.85%     0   0    0.00%    1634     885    45.85%
```

Within repository sources there are **1,634** lines, with **747** covered, giving **45.85%** line coverage.

Coverage results are recalculated after each test run to monitor progress. The project strives for ever more comprehensive test suites across all modules. Recent additions include unit tests for ``APIClient``. New tests now verify ``URLSessionHTTPClient`` behavior and the ``Supervisor`` process termination logic.
Additional tests now cover ``OpenAPISpec.swiftType`` and the ``camelCased`` string helper. A new ``GatewayServerTests`` suite raises total tests to **27**.
The new ``CertificateManagerTests`` ensure renewal scripts run correctly.

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
