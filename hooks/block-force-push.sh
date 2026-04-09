#!/usr/bin/env bash
# PreToolUse hook: Block git push with --force, -f, or --force-with-lease.
# Exit 2 = abort (block the tool call), Exit 0 = allow.

set -euo pipefail

# Reason: try/except ensures empty string on malformed JSON so hook exits 0
# (allow) instead of exit 1 (warn-but-proceed) which would let the op execute.
CMD=$(python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except Exception:
    print('')
")

# Only check git push commands
if ! echo "$CMD" | grep -q 'git push'; then
    exit 0
fi

# Block --force, --force-with-lease, or standalone -f flag
if echo "$CMD" | grep -qE '(--force-with-lease|--force)\b'; then
    echo "BLOCKED: Force push is not allowed. Remove --force or --force-with-lease flag." >&2
    exit 2
fi

# Reason: Match -f anywhere in a combined flag group (e.g. -fu, -uf) not just standalone.
if echo "$CMD" | grep -qE '(^| )-[a-zA-Z]*f'; then
    echo "BLOCKED: Force push (-f) is not allowed." >&2
    exit 2
fi

exit 0
