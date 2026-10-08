#!/usr/bin/env bash
# Basic validation that runs before any image is built or deployed.
set -euo pipefail

FILE="site/index.html"

fail() { echo "FAIL: $1"; exit 1; }

[ -s "$FILE" ] || fail "$FILE is missing or empty"
grep -qi '<!doctype html>' "$FILE" || fail "missing <!DOCTYPE html>"
grep -q '<title>.*</title>' "$FILE" || fail "missing <title>"
grep -q 'The Gridiron' "$FILE" || fail "site name not found"
grep -q '__COMMIT__' "$FILE" || fail "build stamp placeholder __COMMIT__ is missing"

# Check that every opened HTML tag is closed in the right order.
python3 tests/check_html.py "$FILE" || fail "HTML structure is broken"

echo "PASS: $FILE looks valid"
