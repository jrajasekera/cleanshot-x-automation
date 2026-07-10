#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="$ROOT_DIR/scripts/cleanshotx"

fail() {
  echo "test-cli: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  [[ "$haystack" == *"$needle"* ]] || fail "expected output to contain: $needle"
}

bash -n "$CLI"

help_output="$($CLI --help)"
assert_contains "$help_output" "doctor [--smoke-test]"
assert_contains "$help_output" "capture-window-interactive-to-file"
assert_contains "$help_output" "--expect-pixel-width"

fixed_url="$($CLI capture-area-to-file \
  --x 10 --y 20 --width 300 --height 200 --display 1 \
  --wait-ms 250 --expect-pixel-width 600 --expect-pixel-height 400 \
  --output /tmp/cleanshot-dry-run.png --dry-run)"
assert_contains "$fixed_url" "cleanshot://capture-area?"
assert_contains "$fixed_url" "width=300"
assert_contains "$fixed_url" "action=copy"
[[ "$fixed_url" != *"wait-ms"* ]] || fail "local wait option leaked into CleanShot URL"

interactive_output="$($CLI capture-window-to-file --output /tmp/window.png --dry-run 2>&1)"
assert_contains "$interactive_output" "Interactive CleanShot capture"

if "$CLI" capture-fullscreen-to-file --output /tmp/invalid.png --wait-ms nope --dry-run >/dev/null 2>&1; then
  fail "invalid --wait-ms unexpectedly succeeded"
fi

display_json="$($CLI display-info)"
python3 -c '
import json, sys
rows = json.load(sys.stdin)
assert rows and rows[0]["display"] == 1
assert rows[0]["logical_width"] > 0
assert rows[0]["logical_height"] > 0
assert rows[0]["capture_pixel_width"] >= rows[0]["logical_width"]
assert rows[0]["capture_pixel_height"] >= rows[0]["logical_height"]
' <<<"$display_json"

if [[ "${CLEANSHOT_LIVE_TEST:-0}" == "1" ]]; then
  live_output="${TMPDIR:-/tmp}/cleanshot-live-test.png"
  rm -f "$live_output"
  "$CLI" capture-area-to-file \
    --x 0 --y 0 --width 200 --height 120 --display 1 \
    --expect-pixel-width 400 --expect-pixel-height 240 \
    --output "$live_output" --timeout 15
  [[ -s "$live_output" ]] || fail "live capture did not create an image"
  rm -f "$live_output"
fi

echo "test-cli: passed"
