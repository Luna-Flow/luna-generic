#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
module_root="$(cd "$script_dir/../.." && pwd)"
cases_dir="$script_dir/cases"
temp_root="$(mktemp -d "${TMPDIR:-/tmp}/luna-generic-compile-fail.XXXXXX")"
trap 'rm -rf "$temp_root"' EXIT

cp "$module_root/moon.mod" "$temp_root/moon.mod"
cp -R "$module_root/src" "$temp_root/src"

if ! (cd "$temp_root" && moon check src --target all --deny-warn); then
  echo "luna-generic source must compile before API fixtures can run" >&2
  exit 1
fi

case_count=0
for case_dir in "$cases_dir"/*; do
  [ -d "$case_dir" ] || continue
  case_name="$(basename "$case_dir")"
  fixture_pkg="$temp_root/src/compile_fail_fixture/$case_name"
  mkdir -p "$fixture_pkg"
  cp "$case_dir/fixture.mbt" "$fixture_pkg/fixture.mbt"
  cat > "$fixture_pkg/moon.pkg" <<'PKG'
import {
  "Luna-Flow/luna-generic" @lf_alg,
}
PKG
  expected="$(cat "$case_dir/expected.txt")"
  if [[ -z "$expected" || "$expected" != *"|"* ]]; then
    echo "expected.txt must contain ERROR_CODE|diagnostic fragment: $case_name" >&2
    exit 1
  fi
  expected_code="${expected%%|*}"
  expected_fragment="${expected#*|}"

  for target in wasm wasm-gc js native; do
    log="$temp_root/$case_name-$target.log"
    if (cd "$temp_root" && moon check "src/compile_fail_fixture/$case_name" --target "$target" --output-json) >"$log" 2>&1; then
      echo "compile-fail fixture unexpectedly compiled: $case_name ($target)" >&2
      cat "$log" >&2
      exit 1
    fi
    if ! python3 "$script_dir/check_diagnostics.py" "$log" "$expected_code" "$expected_fragment"; then
      echo "fixture failed for an unexpected reason: $case_name ($target)" >&2
      cat "$log" >&2
      exit 1
    fi
  done

  cp "$case_dir/positive.mbt" "$fixture_pkg/fixture.mbt"
  for target in wasm wasm-gc js native; do
    if ! (cd "$temp_root" && moon check "src/compile_fail_fixture/$case_name" --target "$target") >"$log" 2>&1; then
      echo "positive control did not compile: $case_name ($target)" >&2
      cat "$log" >&2
      exit 1
    fi

  done

  case_count=$((case_count + 1))
  echo "rejected as expected: $case_name"
done

if [ "$case_count" -eq 0 ]; then
  echo "no compile-fail API fixtures found" >&2
  exit 1
fi

echo "passed $case_count compile-fail fixtures on wasm, wasm-gc, js, and native"
