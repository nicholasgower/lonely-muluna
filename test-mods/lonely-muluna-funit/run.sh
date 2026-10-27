#!/usr/bin/env bash
# Headless FUnit runner for lonely-muluna.
#
# Usage:
#   test-mods/lonely-muluna-funit/run.sh
#
# Environment:
#   FACTORIO_BIN   Factorio executable (default: /opt/factorio_space_age_21/bin/x64/factorio)
#   FACTORIO_MODS  Source mod directory containing dependencies
#   TMP_ROOT       Scratch directory (default: /tmp/opencode/lonely-muluna-funit)
#   TIMEOUT        Maximum run time in seconds (default: 900)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

FACTORIO_BIN="${FACTORIO_BIN:-/opt/factorio_space_age_21/bin/x64/factorio}"
FACTORIO_MODS="${FACTORIO_MODS:-/opt/factorio_space_age_21/mods}"
TMP_ROOT="${TMP_ROOT:-/tmp/opencode/lonely-muluna-funit}"
TIMEOUT="${TIMEOUT:-900}"
FACTORIO_PORT="${FACTORIO_PORT:-34199}"

if [[ ! -x "$FACTORIO_BIN" ]]; then
  echo "Factorio binary not found: $FACTORIO_BIN" >&2
  exit 1
fi
if [[ ! -d "$FACTORIO_MODS" ]]; then
  echo "Factorio mod directory not found: $FACTORIO_MODS" >&2
  exit 1
fi

rm -rf "$TMP_ROOT"
mkdir -p "$TMP_ROOT/mods" "$TMP_ROOT/write-data/script-output" "$TMP_ROOT/write-data/saves"

link_mod() {
  local name="$1"
  local source="$2"
  if [[ ! -e "$source" ]]; then
    echo "Required dependency missing: $source" >&2
    exit 1
  fi
  ln -sfn "$source" "$TMP_ROOT/mods/$name"
}

# Prefer a development directory when it is a real mod, otherwise use the
# newest installed zip. This avoids broken symlinks such as a directory entry
# that has no info.json.
link_any() {
  local name="$1"
  local dir="$FACTORIO_MODS/$name"
  if [[ -f "$dir/info.json" ]]; then
    link_mod "$name" "$dir"
    return
  fi

  local source
  source="$(find "$FACTORIO_MODS" -maxdepth 1 -name "${name}_*.zip" \( -type f -o -type l \) | sort -V | tail -n 1)"
  if [[ -z "$source" ]]; then
    echo "Required dependency missing: $name (no directory with info.json or ${name}_*.zip)" >&2
    exit 1
  fi
  ln -sfn "$source" "$TMP_ROOT/mods/$(basename "$source")"
}

# The mod under test and its companion test mod.
link_mod "lonely-muluna" "$REPO_DIR"
link_mod "lonely-muluna-funit" "$SCRIPT_DIR"

# Required dependencies of lonely-muluna and planet-muluna.
link_any "planet-muluna"
link_any "PlanetsLib"
link_any "muluna-graphics"
link_any "enhanced-shadows"
link_any "any-planet-start"
link_any "corrundum"
link_any "secretas"
link_any "Redrawn-Space-Connections"
link_any "aai-signal-transmission"
link_any "alien-biomes-graphics"
link_any "flib"
link_any "bplib"
link_any "space-exploration-graphics"
link_any "space-exploration-graphics-4"
link_any "space-exploration-graphics-5"

# Test framework. The published FUnit release is fine locally; CI pins a
# specific commit in .github/workflows/funit.yml.
link_any "funit"

cat > "$TMP_ROOT/mods/mod-list.json" <<'JSON'
{
  "mods": [
    { "name": "base", "enabled": true },
    { "name": "elevated-rails", "enabled": true },
    { "name": "quality", "enabled": true },
    { "name": "recycler", "enabled": true },
    { "name": "space-age", "enabled": true },
    { "name": "lonely-muluna", "enabled": true },
    { "name": "lonely-muluna-funit", "enabled": true },
    { "name": "funit", "enabled": true },
    { "name": "planet-muluna", "enabled": true },
    { "name": "PlanetsLib", "enabled": true },
    { "name": "muluna-graphics", "enabled": true },
    { "name": "enhanced-shadows", "enabled": true },
    { "name": "any-planet-start", "enabled": true },
    { "name": "corrundum", "enabled": true },
    { "name": "secretas", "enabled": true },
    { "name": "Redrawn-Space-Connections", "enabled": true },
    { "name": "aai-signal-transmission", "enabled": true },
    { "name": "alien-biomes-graphics", "enabled": true },
    { "name": "flib", "enabled": true },
    { "name": "bplib", "enabled": true },
    { "name": "space-exploration-graphics", "enabled": true },
    { "name": "space-exploration-graphics-4", "enabled": true },
    { "name": "space-exploration-graphics-5", "enabled": true }
  ]
}
JSON

SERVER_SETTINGS_SOURCE="$(dirname "$FACTORIO_BIN")/../../data/server-settings.example.json"
if [[ ! -f "$SERVER_SETTINGS_SOURCE" ]]; then
  echo "server-settings.example.json not found at $SERVER_SETTINGS_SOURCE" >&2
  exit 1
fi
sed 's/"auto_pause": true/"auto_pause": false/' "$SERVER_SETTINGS_SOURCE" > "$TMP_ROOT/server-settings.json"

cat > "$TMP_ROOT/config.ini" <<EOF
; version=13
[path]
read-data=__PATH__executable__/../../data
write-data=$TMP_ROOT/write-data

[general]
locale=en
EOF

LOG="$TMP_ROOT/stdout.log"

echo "Running Lonely Muluna FUnit suite..."
echo "  binary: $FACTORIO_BIN"
echo "  mods:   $TMP_ROOT/mods"
echo "  log:    $LOG"

FACTORIO_ARGS=(
  --config "$TMP_ROOT/config.ini"
  --mod-directory "$TMP_ROOT/mods"
  --start-server-load-scenario lonely-muluna-funit/__funit__lonely_muluna
  --port "$FACTORIO_PORT"
  --server-settings "$TMP_ROOT/server-settings.json"
  --no-log-rotation
)
if "$FACTORIO_BIN" --help 2>&1 | grep -q -- '--disable-audio'; then
  FACTORIO_ARGS+=(--disable-audio)
fi

set +e
"$FACTORIO_BIN" "${FACTORIO_ARGS[@]}" >"$LOG" 2>&1 &
FACTORIO_PID=$!
set -e

finished=0
for ((i = 0; i < TIMEOUT; i++)); do
  if grep -q '====END====' "$LOG" 2>/dev/null; then
    finished=1
    break
  fi
  if ! kill -0 "$FACTORIO_PID" 2>/dev/null; then
    break
  fi
  sleep 1
done

if kill -0 "$FACTORIO_PID" 2>/dev/null; then
  kill "$FACTORIO_PID" 2>/dev/null || true
fi
wait "$FACTORIO_PID" 2>/dev/null || true

if [[ ! -f "$LOG" ]]; then
  echo "No Factorio log was produced at $LOG." >&2
  exit 1
fi

if [[ "$finished" -ne 1 ]]; then
  echo "FUnit did not reach ====END==== within ${TIMEOUT}s." >&2
  grep -nE '__FUNIT__|Error|error|FAILURE|ERROR' "$LOG" | tail -n 80 >&2 || true
  tail -n 80 "$LOG" >&2 || true
  exit 1
fi

if grep -qE '__FUNIT__.*(FAILURE__|ERROR__)' "$LOG"; then
  echo "FUnit reported failures:" >&2
  grep -nE '__FUNIT__.*(FAILURE__|ERROR__)' "$LOG" >&2
  exit 1
fi

echo "FUnit suite passed."
grep -oE '__FUNIT__[^ ]*====BEGIN [0-9]+ TESTS====' "$LOG" | tail -n 1 || true
grep -c '__FUNIT__.*SUCCESS__' "$LOG" | sed 's/^/SUCCESS lines: /' || true
REPORT="$TMP_ROOT/write-data/script-output/funit-report-lonely-muluna.json"
if [[ -f "$REPORT" ]]; then
  echo "Report: $REPORT"
fi
