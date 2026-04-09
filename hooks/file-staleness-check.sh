#!/usr/bin/env bash
# File staleness guard: blocks Edit/Write on files modified externally since
# the task last accessed them. Uses SCAFFOLDING_TASK_ID env var to scope
# mtime tracking per task session.

set -euo pipefail

# Skip if not running inside a managed task
if [ -z "${SCAFFOLDING_TASK_ID:-}" ]; then
    exit 0
fi

# Read tool input from stdin
INPUT=$(cat)

# Extract file_path using python3 (no jq dependency)
FILE_PATH=$(python3 -c "
import json, sys
try:
    data = json.loads(sys.argv[1])
    # tool_input contains the parameters passed to Edit/Write
    ti = data.get('tool_input', data)
    print(ti.get('file_path', ''))
except Exception:
    print('')
" "$INPUT" 2>/dev/null)

# Skip if no file path extracted
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Skip if the file does not exist yet (new file creation)
if [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

MTIME_STORE="/tmp/scaffolding-mtime-${SCAFFOLDING_TASK_ID}.json"

# Get current mtime
CURRENT_MTIME=$(stat -c %Y "$FILE_PATH" 2>/dev/null || echo "")
if [ -z "$CURRENT_MTIME" ]; then
    exit 0
fi

# Ensure mtime store exists
if [ ! -f "$MTIME_STORE" ]; then
    echo '{}' > "$MTIME_STORE"
fi

# Check and update mtime using python3
python3 -c "
import json, sys

file_path = sys.argv[1]
current_mtime = sys.argv[2]
store_path = sys.argv[3]

try:
    with open(store_path, 'r') as f:
        store = json.load(f)
except (json.JSONDecodeError, FileNotFoundError):
    store = {}

stored_mtime = store.get(file_path)

if stored_mtime is None:
    # First access: record mtime
    store[file_path] = current_mtime
    with open(store_path, 'w') as f:
        json.dump(store, f)
    sys.exit(0)

if stored_mtime == current_mtime:
    # Mtime unchanged: allow the edit.
    # PostToolUse hook (file-staleness-update.sh) will re-record the new
    # mtime after the edit completes.
    sys.exit(0)

# Mtime changed externally
print(
    f'File staleness conflict: {file_path} was modified externally '
    f'(stored mtime={stored_mtime}, current mtime={current_mtime}). '
    f'Re-read the file before editing.',
    file=sys.stderr,
)
sys.exit(2)
" "$FILE_PATH" "$CURRENT_MTIME" "$MTIME_STORE"
