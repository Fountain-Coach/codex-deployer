# 🧪 Tutorial: Achieving 100% Test Coverage in Swift (Linux) with Codex + Coverage Matrix

## 📌 What You'll Achieve

By the end of this tutorial, you will:  
✅ Automatically extract code coverage with LLVM  
✅ Identify uncovered and partially covered code  
✅ Create a machine-readable action matrix (`agent.md`)  
✅ Use Codex to generate the **exact missing tests**  
✅ Iteratively reach **100% test coverage**

---

## 🧰 Prerequisites

- Swift (>=5.8) installed on Ubuntu
- `llvm-cov` and `llvm-profdata` (comes with `clang`)
- A Swift Package Manager project
- Access to Codex (or an LLM with coding capabilities)

---

## 🧭 Part 1: Enable Code Coverage

```bash
swift test --enable-code-coverage
```

Generates `.profraw` files in:

```
.build/debug/codecov/
```

---

## 🧭 Part 2: Merge Coverage Data

```bash
llvm-profdata merge -sparse .build/debug/codecov/*.profraw -o default.profdata
```

---

## 🧭 Part 3: Export Coverage to JSON

Find your test binary:

```bash
ls .build/debug/*.xctest
```

Then run:

```bash
llvm-cov export \
  .build/debug/<YourTestBinary>.xctest \
  -instr-profile=default.profdata \
  -format=json > coverage.json
```

---

## 🧭 Part 4: Prompt Codex to Build a Coverage Matrix

Use this prompt:

```
# 🧠 CONTEXT:
# This is a Swift Package on Ubuntu.
# Code coverage was collected via swift test + llvm-profdata + llvm-cov.
# We have a `coverage.json` file with full coverage data.

# ✅ GOAL:
# Create a markdown task matrix (agent.md) identifying all test coverage gaps.

# 🧪 STEPS:
# 1. Parse `coverage.json`
# 2. Identify uncovered or partially covered functions or lines
# 3. Propose test inputs for each uncovered path
# 4. Output this matrix:

# | Feature | File(s) or Area | Action | Status | Blockers | Tags |
# Use emoji for `Status`: ✅, ⏳, ⚠️, ❌
# Use Tags like: test, parser, cli, docs, ci

# 5. Save as `agent.md` at the project root.
```

---

## 🧭 Part 5: Use Codex to Generate Missing Tests

Take each row from the matrix and prompt Codex, like:

```
// File: LoginManager.swift
// Action: Add test for password < 8
// Suggest test input to cover this case.
```

Example output:

```swift
func testPasswordTooShort() {
    let manager = LoginManager()
    XCTAssertFalse(manager.validate(username: "user", password: "123"))
}
```

---

## 🧭 Part 6: Re-Run and Iterate

```bash
swift test --enable-code-coverage
llvm-profdata merge -sparse .build/debug/codecov/*.profraw -o default.profdata
llvm-cov report \
  .build/debug/<YourTestBinary>.xctest \
  -instr-profile=default.profdata
```

Repeat until test coverage = ✅ 100%.

---

## 🗂 Example `agent.md`

```markdown
| Feature           | File               | Action                              | Status | Blockers              | Tags   |
|------------------|--------------------|-------------------------------------|--------|------------------------|--------|
| Short password    | LoginManager.swift | Add test for password < 8           | ✅     |                        | test   |
| Audio error path  | AudioEngine.swift  | Simulate engine startup failure     | ⚠️     | Mock engine unavailable| test   |
| Trim whitespace   | FountainParser.swift | Change `var` to `let`               | ✅     |                        | parser |
```

---

## 🎯 Summary

You now have a fully automated workflow to:  
- Extract LLVM test coverage  
- Generate a Codex-readable action matrix  
- Prompt Codex for precise test case stubs  
- Reach and maintain 100% test coverage 🎯