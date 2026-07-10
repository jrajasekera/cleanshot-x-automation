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
assert_contains "$help_output" "plan-exact-capture"
assert_contains "$help_output" "verify-images"
assert_contains "$help_output" "contact-sheet"

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

plan_json="$($CLI plan-exact-capture --pixel-width 1280 --pixel-height 2856 --device-pixel-ratio 2 --display 1)"
python3 -c '
import json, sys
plan = json.load(sys.stdin)
assert plan["requested_pixel_width"] == 1280
assert plan["requested_pixel_height"] == 2856
assert plan["required_logical_width"] > 0
assert plan["required_logical_height"] > 0
assert plan["target_device_pixel_ratio"] == 2
assert isinstance(plan["fits_logical_surface"], bool)
assert isinstance(plan["dpr_matches_display"], bool)
assert isinstance(plan["fits_fixed_area"], bool)
assert plan["recommended_capture_path"] in {"cleanshot-fixed-area", "virtual-renderer"}
' <<<"$plan_json"

if command -v magick >/dev/null 2>&1; then
  qa_tmp="$(mktemp -d -t cleanshotx-qa.XXXXXX)"
  trap 'rm -rf "$qa_tmp"' EXIT
  magick -size 40x30 xc:red "$qa_tmp/a.png"
  magick -size 40x30 xc:blue "$qa_tmp/b.png"
  a_hash_before="$(shasum -a 256 "$qa_tmp/a.png")"
  b_hash_before="$(shasum -a 256 "$qa_tmp/b.png")"

  "$CLI" verify-images \
    --expect-pixel-width 40 --expect-pixel-height 30 \
    "$qa_tmp/a.png" "$qa_tmp/b.png" >/dev/null
  "$CLI" contact-sheet \
    --output "$qa_tmp/contact.png" --tile 2x1 \
    "$qa_tmp/a.png" "$qa_tmp/b.png" >/dev/null
  [[ -s "$qa_tmp/contact.png" ]] || fail "contact-sheet did not create an image"
  [[ "$(shasum -a 256 "$qa_tmp/a.png")" == "$a_hash_before" ]] || fail "contact-sheet modified its first input"
  [[ "$(shasum -a 256 "$qa_tmp/b.png")" == "$b_hash_before" ]] || fail "contact-sheet modified its second input"

  if "$CLI" contact-sheet \
    --output "$qa_tmp/a.png" --force \
    "$qa_tmp/a.png" "$qa_tmp/b.png" >/dev/null 2>&1; then
    fail "contact-sheet allowed an input/output collision"
  fi
  if "$CLI" contact-sheet \
    --output "$qa_tmp/contact.png" \
    "$qa_tmp/a.png" "$qa_tmp/b.png" >/dev/null 2>&1; then
    fail "contact-sheet replaced an existing output without --force"
  fi
  "$CLI" contact-sheet \
    --output "$qa_tmp/contact.png" --force \
    "$qa_tmp/a.png" "$qa_tmp/b.png" >/dev/null

  rm -rf "$qa_tmp"
  trap - EXIT
fi

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
