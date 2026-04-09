#!/usr/bin/env bash
# PreToolUse hook: Block destructive rm -rf on critical paths.
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

# Reason: Block piped-to-rm patterns (xargs rm, xargs -I{} rm, etc.)
# before the main rm flag analysis, since these bypass flag detection.
if echo "$CMD" | grep -qE 'xargs\s+(-[^\s]*\s+)*rm\b'; then
    echo "BLOCKED: Piping to rm via xargs is not allowed." >&2
    exit 2
fi

# Only check rm commands
if ! echo "$CMD" | grep -q 'rm '; then
    exit 0
fi

# Reason: Independently detect recursive AND force flags anywhere in the command.
# This catches combined flags (-rf, -fr), separated flags (-r -f), long flags
# (--recursive --force), and any mix thereof.
HAS_RECURSIVE=false
HAS_FORCE=false

# Check for -r/-R in combined short flags or standalone, or --recursive
if echo "$CMD" | grep -qE '(^| )-[a-zA-Z]*[rR]'; then
    HAS_RECURSIVE=true
fi
if echo "$CMD" | grep -qE '(^| )--recursive( |$)'; then
    HAS_RECURSIVE=true
fi

# Check for -f in combined short flags or standalone, or --force
if echo "$CMD" | grep -qE '(^| )-[a-zA-Z]*f'; then
    HAS_FORCE=true
fi
if echo "$CMD" | grep -qE '(^| )--force( |$)'; then
    HAS_FORCE=true
fi

# Not a destructive rm unless both recursive and force are present
if ! $HAS_RECURSIVE || ! $HAS_FORCE; then
    exit 0
fi

# Reason: Use fixed-string prefix matching via python to avoid regex escaping
# issues (e.g. unescaped dots in paths like /.). Python startswith() is exact.
BLOCKED=$(python3 -c "
import sys
cmd = sys.argv[1]
blocked_prefixes = ['/', '/etc', '/var', '/usr', '.']
# Reason: Extract all path-like arguments after rm and its flags
parts = cmd.split()
in_rm = False
for p in parts:
    if p == 'rm':
        in_rm = True
        continue
    if not in_rm:
        continue
    # Skip flags
    if p.startswith('-'):
        continue
    # Check if this argument matches or is under a blocked prefix
    for bp in blocked_prefixes:
        if bp == '/':
            # Only block exact '/' not every absolute path
            if p == '/':
                print(p)
                sys.exit(0)
        elif bp == '.':
            if p == '.' or p == '..':
                print(p)
                sys.exit(0)
        else:
            # Prefix match: block '/etc' and '/etc/foo' etc.
            if p == bp or p.startswith(bp + '/'):
                print(p)
                sys.exit(0)
print('')
" "$CMD")

if [ -n "$BLOCKED" ]; then
    echo "BLOCKED: Destructive rm -rf on '$BLOCKED' is not allowed." >&2
    exit 2
fi

exit 0
