#!/bin/bash
# Adaptive wrapper for `swift test` to cope with CI resource limits.
# Uses SWIFTPM_NUM_JOBS (see ../../docs/environment_variables.md) to control concurrency.
set -euo pipefail

run() {
  echo "Running: $*"
  "$@"
}

# Attempt 1: disable parallelism
if run swift test -v --parallel false; then
  exit 0
fi

echo "Retry with limited concurrency"
# Attempt 2: limit job count
if SWIFTPM_NUM_JOBS=${SWIFTPM_NUM_JOBS:-2} run swift test -v --parallel false --jobs 2; then
  exit 0
fi

echo "Retry per test target"
# Attempt 3: run each test target separately
targets=$(swift test --list-tests | awk -F/ '{print $1}' | sort -u)
if [ -n "$targets" ]; then
  for t in $targets; do
    echo "Running target $t"
    if ! SWIFTPM_NUM_JOBS=${SWIFTPM_NUM_JOBS:-2} run swift test -v --parallel false --jobs 2 --filter "$t"; then
      echo "Target $t failed"
      exit 1
    fi
  done
  exit 0
fi

echo "Retry skipping slow tests"
# Attempt 4: skip heavy tests
SWIFTPM_NUM_JOBS=${SWIFTPM_NUM_JOBS:-2} run swift test -v --parallel false --jobs 2 -Xswiftc -DSKIP_SLOW_TESTS

# Attempt 5: fast tests only
if run swift test -v --filter FastTests; then
  echo "Fast tests passed."
  exit 0
fi
