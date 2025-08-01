## Code Coverage Report

### Overall repository coverage

Running `swift test --enable-code-coverage` and analysing with `llvm-cov` produced the following totals:

```
TOTAL                                          31320   30826    10.70%   13850 12304    12.55%   98260   87760    10.70%
```

The repository contains **98,260** executable lines, with **10,500** lines covered (approx. **10.70%** line coverage).

### Repository source coverage

Ignoring third-party packages under `.build/checkouts`, the totals are:

```
TOTAL                                            747     885    45.85%     0   0    0.00%    1634     885    45.85%
```

Within repository sources there are **1,634** lines, with **747** covered, giving **45.85%** line coverage.

Coverage results are recalculated after each test run to monitor progress. The project strives for ever more comprehensive test suites across all modules. Recent additions include unit tests for ``APIClient``. New tests now verify ``URLSessionHTTPClient`` behavior and the ``Supervisor`` process termination logic.

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
