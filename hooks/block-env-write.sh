#!/usr/bin/env bash
# PreToolUse hook: Block writes to .env files.
# Exit 2 = abort (block the tool call), Exit 0 = allow.

set -euo pipefail

# Reason: try/except ensures empty string on malformed JSON so hook exits 0
# (allow) instead of exit 1 (warn-but-proceed) which would let the op execute.
TOOL_INPUT=$(python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    ti = d.get('tool_input', {})
    # Output file_path (for Edit/Write) and command (for Bash) separated by newline
    print(ti.get('file_path', ''))
    print(ti.get('command', ''))
except Exception:
    print('')
    print('')
")

FILE_PATH=$(echo "$TOOL_INPUT" | head -1)
CMD=$(echo "$TOOL_INPUT" | tail -1)

# Check Edit/Write tool: block if file_path targets .env
if [ -n "$FILE_PATH" ]; then
    BASENAME=$(basename "$FILE_PATH")
    # Block if basename is exactly ".env" or starts with ".env."
    if [ "$BASENAME" = ".env" ] || echo "$BASENAME" | grep -q '^\.env\.'; then
        echo "BLOCKED: Writing to $BASENAME is not allowed. Environment files must be edited manually." >&2
        exit 2
    fi
fi

# Check Bash tool: block commands that redirect output to .env files
# Reason: Catch patterns like "echo ... > .env", "cat ... > .env", "tee .env"
if [ -n "$CMD" ]; then
    if echo "$CMD" | grep -qE '(>|>>)\s*\.env(\s|$|\.)|tee\s+(-a\s+)?\.env(\s|$|\.)'; then
        echo "BLOCKED: Writing to .env via shell redirect/tee is not allowed. Environment files must be edited manually." >&2
        exit 2
    fi
fi

exit 0
