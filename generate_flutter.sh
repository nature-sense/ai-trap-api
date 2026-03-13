#!/usr/bin/env bash
# generate_flutter.sh — Run from the Flutter project root:
#   ./api/generate_flutter.sh
#
# Requires:
#   brew install openapi-generator
#
# Generated code is written to lib/api/ (add that directory to .gitignore).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPEC="$SCRIPT_DIR/openapi.yaml"
OUT="lib/api"

# ── Check dependencies ────────────────────────────────────────────────────────

if ! command -v openapi-generator &>/dev/null; then
  echo "Error: openapi-generator not found."
  echo "Install with: brew install openapi-generator"
  exit 1
fi

# ── Update submodule to latest spec ──────────────────────────────────────────

echo "Updating api submodule..."
git submodule update --remote api

# ── Generate ──────────────────────────────────────────────────────────────────

echo "Generating Dart/dio client from $SPEC -> $OUT"

openapi-generator generate \
  --input-spec     "$SPEC" \
  --generator-name dart-dio \
  --output         "$OUT" \
  --additional-properties=pubName=trap_api,pubAuthor=nature-sense,nullSafe=true \
  --skip-validate-spec

# ── Remove files Flutter doesn't need ────────────────────────────────────────

rm -rf "$OUT/doc" "$OUT/test" "$OUT/.openapi-generator"

echo ""
echo "Done. Generated client is in $OUT/"
echo "Run 'flutter pub get' in $OUT/ if this is the first time."
