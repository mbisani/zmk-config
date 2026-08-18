#!/usr/bin/env bash
# Regenerates docs/sofle_choc_pro-keymap.{svg,pdf} and the print-tiled
# docs/sofle_choc_pro-keymap-print.pdf from config/sofle_choc_pro.keymap.
#
# Requires:
#   - python3 (to create a throwaway venv for keymap-drawer:
#     https://github.com/caksoylar/keymap-drawer, and pdfposter to tile
#     the print version: https://pypi.org/project/pdfposter/)
#   - rsvg-convert for the PDF (macOS: `brew install librsvg`)
set -euo pipefail
cd "$(dirname "$0")/.."

VENV=.venv-keymap-drawer
if [ ! -d "$VENV" ]; then
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install --quiet keymap-drawer pdfposter
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

  # The diagram's PDF page is one tall custom size (all layers stacked), which
  # doesn't fit a printed sheet. Tile it across portrait A4 pages, scaled to
  # fill each sheet's width, so it can be printed and taped together.
  "$VENV/bin/pdfposter" -m a4 -p 1x6a4 \
    docs/sofle_choc_pro-keymap.pdf docs/sofle_choc_pro-keymap-print.pdf
else
  echo "rsvg-convert not found, skipping PDF (install librsvg to get one)" >&2
fi

echo "Wrote docs/sofle_choc_pro-keymap.svg$(command -v rsvg-convert >/dev/null && echo ', .pdf, and -print.pdf')"
