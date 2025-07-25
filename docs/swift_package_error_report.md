# Swift Package Error Patterns

This document summarizes recurring issues related to Swift package creation identified from the commit history. Commits were scanned for messages referencing package problems such as missing products or compile-time failures. Counts reflect the number of commits mentioning each issue.

## Ranked Error Categories

1. **Compile-time errors in the Teatro package** – 10 commits
   - Example commit: `ea19e51` "Fix builder usage and explicit Alignment".
2. **Missing package product for Teatro** – 3 commits
   - Example commit: `6764eee` "Fix TeatroView dependency".
3. **Renaming GUITeatro package to TeatroPlayground** – 1 commit
   - Example commit: `0dba78c` "Rename GUITeatro package to TeatroPlayground".
4. **New package additions (ScreenplayGUI, Dispatcher Mac UI)** – 2 commits
   - Example commits: `2ced714` "Add ScreenplayGUI package", `81c8835` "Add Dispatcher Mac UI starter package".

Compile-time errors were by far the most common theme, often resolved by exporting the Teatro library product or adjusting Linux-specific code. Missing package products caused build failures until dependencies were corrected. Package renaming occurred once to align naming across the repos. Finally, new packages were added with minimal issues.

````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````
