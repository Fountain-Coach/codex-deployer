## Code Coverage Report

### Overall repository coverage

Running `swift test --enable-code-coverage` and analysing with `llvm-cov` produced the following totals:

```
TOTAL                                          31315   30821    10.68%   13846 12300    12.54%   98248   87754    10.68%
```

The repository contains **98,248** executable lines, with **10,494** lines covered (approx. **10.68%** line coverage).

### Repository source coverage

Ignoring third-party packages under `.build/checkouts`, the totals are:

```
TOTAL                                            746     884    45.77%     0   0    0.00%    1630     884    45.77%
```

Within repository sources there are **1,630** lines, with **746** covered, giving **45.77%** line coverage.

Coverage results are recalculated after each test run to monitor progress. The project strives for ever more comprehensive test suites across all modules. Recent additions include unit tests for ``APIClient``.

---
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
