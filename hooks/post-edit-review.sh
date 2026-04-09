#!/bin/bash
# Post-Edit Hook: Auto-review after file edits
#
# This hook triggers after Edit or Write tool usage
# Requires Claude to run code review immediately

cat >&2 <<'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 POST-EDIT HOOK: CODE REVIEW SUGGESTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Code changes detected. Consider running code review:

  /code-review    - Full code review
  /security-review - Security-focused review
  /test-coverage  - Test coverage analysis

NOTE: This is a SUGGESTION. Run review when completing
a feature or before committing significant changes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

# Exit 0 to allow the edit to proceed
exit 0
