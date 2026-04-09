# Claude Code Hooks

This directory contains hooks that run automatically during Claude Code workflows.

## Available Hooks

### 1. post-edit-review.sh
**Type:** PostToolUse hook
**Triggers:** After Edit or Write tool usage
**Purpose:** Suggests running code review commands after making code changes

**What it does:**
- Detects when files are modified
- Suggests relevant review commands (/code-review, /security-review, /test-coverage)
- Non-blocking (allows edit to proceed)

### 2. pre-commit-validation.sh
**Type:** PreToolUse hook (for git commit operations)
**Triggers:** Before git commit commands
**Purpose:** Runs validation checks to prevent committing broken code

**What it does:**
- Detects frontend changes → runs `npm run validate`
- Detects backend changes → runs `pytest`
- Blocks commit if validation fails
- Ensures code quality before it enters git history

## Hook Configuration

Hooks are configured in `.claude/settings.json`. See that file for:
- Which hooks are enabled
- Tool matchers (which tools trigger which hooks)
- Hook execution order

## Making Hooks Executable

On Unix systems, hooks need execute permissions:

```bash
chmod +x .claude/hooks/*.sh
```

On Windows with Git Bash, this is handled automatically.

## Testing Hooks

### Test post-edit-review.sh
```bash
# Make a test edit and see the suggestion
echo "test" >> test.txt
```

### Test pre-commit-validation.sh
```bash
# Try to commit with validation errors
cd app/frontend
# Make a breaking change
git add .
git commit -m "test commit"
# Hook should block if validation fails
```

## Disabling Hooks

To temporarily disable hooks, comment them out in `.claude/settings.json`:

```json
{
  "hooks": {
    // "PostToolUse": [ ... ]
  }
}
```

## Hook Best Practices

1. **Fast execution** - Hooks should run quickly (< 5 seconds)
2. **Clear output** - Always explain what the hook is doing
3. **Non-breaking** - PostToolUse hooks should exit 0 to allow operation
4. **Blocking when needed** - PreToolUse hooks can exit 1 to block bad operations
5. **Helpful messages** - Guide users on how to fix issues

## Troubleshooting

**Hook not running:**
- Check `.claude/settings.json` configuration
- Verify hook file has execute permissions
- Check hook script for syntax errors

**Hook always fails:**
- Test the hook script manually: `bash .claude/hooks/script.sh`
- Check that required tools are available (npm, pytest, etc.)
- Verify paths are correct (hooks run from repository root)

## Future Hooks

Ideas for additional hooks:
- Pre-push hook: Run full test suite before pushing
- Post-commit hook: Generate changelog entry
- Pre-PR hook: Verify PR requirements met
