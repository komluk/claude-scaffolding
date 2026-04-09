#!/usr/bin/env bash
# PostToolUse counterpart to file-staleness-check.sh: updates stored mtime
# after a successful Edit/Write so the next PreToolUse check uses the new value.

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
    ti = data.get('tool_input', data)
    print(ti.get('file_path', ''))
except Exception:
    print('')
" "$INPUT" 2>/dev/null)

# Skip if no file path extracted or file doesn't exist
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

MTIME_STORE="/tmp/scaffolding-mtime-${SCAFFOLDING_TASK_ID}.json"

# Get current mtime (after the edit)
CURRENT_MTIME=$(stat -c %Y "$FILE_PATH" 2>/dev/null || echo "")
if [ -z "$CURRENT_MTIME" ]; then
    exit 0
fi

# Update stored mtime to current value
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

store[file_path] = current_mtime
with open(store_path, 'w') as f:
    json.dump(store, f)
" "$FILE_PATH" "$CURRENT_MTIME" "$MTIME_STORE"

exit 0
