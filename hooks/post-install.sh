#!/usr/bin/env bash
# post-install.sh — runs after plugin installation
# Creates .scaffolding/ structure and copies CLAUDE.md + settings.json to the project
set -euo pipefail

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-.}"

# --- Step 1: Create .scaffolding directory structure ---
echo "[scaffolding] Creating .scaffolding/ directory structure..."
mkdir -p "$PROJECT_ROOT/.scaffolding/conversations"
mkdir -p "$PROJECT_ROOT/.scaffolding/agent-memory/shared"
mkdir -p "$PROJECT_ROOT/.scaffolding/agent-memory/agents"
mkdir -p "$PROJECT_ROOT/.scaffolding/worktrees"
mkdir -p "$PROJECT_ROOT/.scaffolding/openspec/specs"
mkdir -p "$PROJECT_ROOT/.scaffolding/openspec/schemas"
mkdir -p "$PROJECT_ROOT/.scaffolding/reports"
echo "[scaffolding] ✓ .scaffolding/ structure created"

# --- Step 2: Add .scaffolding/ to .gitignore ---
if [ -f "$PROJECT_ROOT/.gitignore" ]; then
  if ! grep -q "^\.scaffolding/" "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
    echo "" >> "$PROJECT_ROOT/.gitignore"
    echo "# Claude Scaffolding (auto-added by plugin)" >> "$PROJECT_ROOT/.gitignore"
    echo ".scaffolding/" >> "$PROJECT_ROOT/.gitignore"
    echo "[scaffolding] ✓ Added .scaffolding/ to .gitignore"
  else
    echo "[scaffolding] ✓ .scaffolding/ already in .gitignore"
  fi
else
  echo "# Claude Scaffolding (auto-added by plugin)" > "$PROJECT_ROOT/.gitignore"
  echo ".scaffolding/" >> "$PROJECT_ROOT/.gitignore"
  echo "[scaffolding] ✓ Created .gitignore with .scaffolding/"
fi

# --- Step 3: Copy CLAUDE.md if not present ---
PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
if [ ! -f "$PROJECT_ROOT/CLAUDE.md" ]; then
  if [ -f "$PLUGIN_DIR/CLAUDE.md" ]; then
    cp "$PLUGIN_DIR/CLAUDE.md" "$PROJECT_ROOT/CLAUDE.md"
    echo "[scaffolding] ✓ Copied CLAUDE.md to project root"
  fi
else
  echo "[scaffolding] ✓ CLAUDE.md already exists, skipping"
fi

# --- Step 4: Copy settings.json if not present ---
mkdir -p "$PROJECT_ROOT/.claude"
if [ ! -f "$PROJECT_ROOT/.claude/settings.json" ]; then
  if [ -f "$PLUGIN_DIR/settings.json" ]; then
    cp "$PLUGIN_DIR/settings.json" "$PROJECT_ROOT/.claude/settings.json"
    echo "[scaffolding] ✓ Copied settings.json to .claude/"
  fi
else
  echo "[scaffolding] ✓ .claude/settings.json already exists, skipping"
fi

echo "[scaffolding] Post-install complete. Agent routing + OpenSpec ready."
