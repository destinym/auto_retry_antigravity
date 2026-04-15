#!/usr/bin/env bash
set -euo pipefail

AG_WB_DIR="/Applications/Antigravity.app/Contents/Resources/app/out/vs/code/electron-browser/workbench"
AG_PANEL_DIR="/Applications/Antigravity.app/Contents/Resources/app/extensions/antigravity"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$SCRIPT_DIR"
SRC_WB="$SRC_DIR/auto-retry.js"
SRC_PANEL="$SRC_DIR/auto-retry-panel.js"

if [[ ! -f "$SRC_WB" || ! -f "$SRC_PANEL" ]]; then
  echo "Missing source scripts in $SRC_DIR"
  echo "Expected: auto-retry.js and auto-retry-panel.js"
  exit 1
fi

# Backup targets (once)
if [[ -f "$AG_WB_DIR/workbench.html" && ! -f "$AG_WB_DIR/workbench.html.bak" ]]; then
  cp "$AG_WB_DIR/workbench.html" "$AG_WB_DIR/workbench.html.bak"
fi
if [[ -f "$AG_PANEL_DIR/cascade-panel.html" && ! -f "$AG_PANEL_DIR/cascade-panel.html.bak" ]]; then
  cp "$AG_PANEL_DIR/cascade-panel.html" "$AG_PANEL_DIR/cascade-panel.html.bak"
fi

# Copy scripts
cp "$SRC_WB" "$AG_WB_DIR/auto-retry.js"
cp "$SRC_PANEL" "$AG_PANEL_DIR/auto-retry-panel.js"

# Inject script tags if missing
python3 - <<'PY'
from pathlib import Path

wb = Path("/Applications/Antigravity.app/Contents/Resources/app/out/vs/code/electron-browser/workbench/workbench.html")
if wb.exists():
    s = wb.read_text()
    if "auto-retry.js" not in s:
        s = s.replace("</body>", "  <script src=\"auto-retry.js\"></script>\n</body>")
        wb.write_text(s)

panel = Path("/Applications/Antigravity.app/Contents/Resources/app/extensions/antigravity/cascade-panel.html")
if panel.exists():
    s = panel.read_text()
    if "auto-retry-panel.js" not in s:
        s = s.replace("</body>", "  <script src=\"auto-retry-panel.js\"></script>\n</body>")
        panel.write_text(s)
PY

echo "Reinstall complete. Please restart Antigravity."
