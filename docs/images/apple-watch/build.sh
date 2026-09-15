#!/usr/bin/env bash
#
# Rebuilds the Apple Watch documentation diagrams from their draw.io sources.
#
#   ./build.sh
#
# Each .drawio file is exported to an .svg next to it, then post-processed to
# remove draw.io's <foreignObject> labels. Those only render inside a full
# browsing context, so an SVG that relies on them loses all of its text when it
# is used as an <img> — which is how the docs embed it. draw.io always writes a
# plain <text> fallback alongside, and that is what we keep.
#
# Requires the draw.io desktop app.

set -euo pipefail
cd "$(dirname "$0")"

DRAWIO="${DRAWIO:-/Applications/draw.io.app/Contents/MacOS/draw.io}"
[ -x "$DRAWIO" ] || { echo "draw.io not found at $DRAWIO"; exit 1; }

for src in *.drawio; do
  out="${src%.drawio}.svg"

  "$DRAWIO" --export --format svg --crop --border 8 \
            --transparent --theme light --embed-svg-fonts false \
            --output "$out" "$src" > /dev/null 2>&1

  python3 - "$out" <<'PY'
import re, sys

path = sys.argv[1]
svg = open(path).read()

# <switch><foreignObject .../><text ...>…</text></switch>  ->  <text ...>…</text>
svg = re.sub(
    r'<switch>\s*<foreignObject.*?</foreignObject>\s*(.*?)\s*</switch>',
    r'\1', svg, flags=re.S)

# the "Text is not SVG - cannot display" notice draw.io appends for the same reason
svg = re.sub(
    r'<switch>\s*<g requiredFeatures=.*?</switch>', '', svg, flags=re.S)

open(path, 'w').write(svg)
print(f'{path}: {len(re.findall("<foreignObject", svg))} foreignObject left')
PY
done
