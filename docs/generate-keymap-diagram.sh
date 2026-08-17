#!/usr/bin/env bash
# Regenerates docs/sofle_choc_pro-keymap.{svg,pdf} from config/sofle_choc_pro.keymap.
#
# Requires:
#   - python3 (to create a throwaway venv for keymap-drawer:
#     https://github.com/caksoylar/keymap-drawer)
#   - rsvg-convert for the PDF (macOS: `brew install librsvg`)
set -euo pipefail
cd "$(dirname "$0")/.."

VENV=.venv-keymap-drawer
if [ ! -d "$VENV" ]; then
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install --quiet keymap-drawer
fi

KD="$VENV/bin/keymap"
TMP_YAML=$(mktemp)
trap 'rm -f "$TMP_YAML"' EXIT

"$KD" parse -z config/sofle_choc_pro.keymap -o "$TMP_YAML"
"$KD" draw \
  -d boards/arm/sofle_choc_pro/sofle_choc_pro-layouts.dtsi \
  -l default_layout \
  "$TMP_YAML" \
  -o docs/sofle_choc_pro-keymap.svg

if command -v rsvg-convert >/dev/null; then
  rsvg-convert -f pdf docs/sofle_choc_pro-keymap.svg -o docs/sofle_choc_pro-keymap.pdf
else
  echo "rsvg-convert not found, skipping PDF (install librsvg to get one)" >&2
fi

echo "Wrote docs/sofle_choc_pro-keymap.svg$(command -v rsvg-convert >/dev/null && echo ' and .pdf')"
