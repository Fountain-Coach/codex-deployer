#!/usr/bin/env bash
set -euo pipefail

THRESHOLD="${1:-0}"
MODULE="FountainRuntime"
SWIFT_BIN=$(command -v swift)
LLVM_COV_BIN=$(command -v llvm-cov || echo "$(dirname "$SWIFT_BIN")/../usr/bin/llvm-cov")

echo "[coverage] swift test --enable-code-coverage"
swift test --enable-code-coverage

CODECOV_DIR=$(dirname "$(swift test --show-codecov-path)")
if [[ -n "${GITHUB_ENV:-}" ]]; then
  echo "CODECOV_DIR=$CODECOV_DIR" >> "$GITHUB_ENV"
fi

TEST_BINARY=$(find .build -name '*.xctest' | head -n 1)

echo "[coverage] generating per-file summaries"
"$LLVM_COV_BIN" show "$TEST_BINARY" -instr-profile "$CODECOV_DIR/default.profdata" -summary-only > coverage-summary.txt

MODULE_COV=$("$LLVM_COV_BIN" export -summary-only "$TEST_BINARY" -instr-profile "$CODECOV_DIR/default.profdata" |
  jq '[.data[].files[] | select(.filename | contains("libs/FountainRuntime")) | .summary.lines] |
      reduce .[] as $f ({covered:0,count:0}; {covered: (.covered + $f.covered), count: (.count + $f.count)}) |
      if .count > 0 then (.covered / .count * 100) else 0 end')

printf "[coverage] FountainRuntime line coverage: %.2f%%\n" "$MODULE_COV"

below=$(awk -v cov="$MODULE_COV" -v thr="$THRESHOLD" 'BEGIN {print (cov < thr)}')
if [ "$below" -eq 1 ]; then
  echo "[coverage] FountainRuntime coverage ${MODULE_COV}% below threshold ${THRESHOLD}%"
  exit 1
fi

echo "[coverage] OK"
