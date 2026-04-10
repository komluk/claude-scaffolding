# scaffolding

Give Claude Code 11 specialized agents, 30 skills, safety hooks, and auto-routing — in one install.

Instead of Claude answering everything directly, it routes your messages to the right specialist:

> You say "fix the login bug" → Claude auto-routes to **debugger** → debugger investigates → **developer** fixes it.

No special commands. Just talk normally.

---

## Get started in 10 seconds

### Method A — Plugin marketplace (recommended)

**Requirements:** Claude Code CLI only

First, add the marketplace (one-time setup):

```bash
/plugin marketplace add komluk/scaffolding
```

Then install the plugin:

```bash
/plugin install scaffolding@komluk-scaffolding
```

After install, initialize the project:

```bash
/scaffolding:init-scaffolding
```

This creates the `.scaffolding/` directory, copies `CLAUDE.md` and `settings.json` to your project. **This step is required** — the plugin cannot auto-initialize due to Claude Code plugin system limitations.

Then **restart Claude Code** (close and reopen) to load the new CLAUDE.md and settings.

That's it. Start talking — Claude will auto-route to the right agent.

### Method B — install.sh (manual)

**Requirements:** git, python3, Claude Code CLI

```bash
git clone https://github.com/komluk/scaffolding
cd scaffolding
./install.sh --target /path/to/your/project/.claude
```

The installer auto-detects your test commands, project name, and other settings. Hit Enter to accept defaults, or customize anything. Your choices are saved to `~/.scaffolding.env` and can be changed later.

---

## Updating

### Plugin method

```bash
/plugin update scaffolding@komluk-scaffolding
```

Or full reinstall:

```bash
/plugin uninstall scaffolding@komluk-scaffolding
/plugin install scaffolding@komluk-scaffolding
```

### install.sh method

```bash
cd scaffolding
git pull
./install.sh --refresh
```

---

## What's inside

```
11 agents      analyst, architect, researcher, developer, debugger,
               reviewer, optimizer, tech-writer, devops,
               gitops, coordinator

30 skills      api-design, error-handling, pattern-recognition,
               testing-strategy, python-patterns, mui-styling, ...

14 commands    /workflow, /init-openspec, /context, and more

7 hooks        pre-commit validation, block destructive commands,
               block env file writes, ...

2 workflows    workflow  — full 8-step pipeline (analyst → architect → developer → reviewer → ...)
               coordinate — LLM-planned minimal pipeline for everything else
```

### Agents at a glance

| Agent | What it handles |
|-------|----------------|
| analyst | Requirements, feasibility, proposals |
| architect | System design, API design, multi-file planning |
| researcher | External APIs, libraries, best practices |
| developer | Code, bug fixes, features, tests, UI |
| debugger | Errors, unexpected behavior |
| reviewer | Code review, security analysis |
| optimizer | Performance, database, queries |
| tech-writer | README, CHANGELOG, docs |
| devops | CI/CD, deployment, infrastructure |
| gitops | Git operations, commits, merges, push |
| coordinator | Decomposes complex tasks into agent sequences |

---

## What's NOT included

These features need a running backend and are not part of this plugin:

- **Semantic memory MCP** — requires Postgres + pgvector
- **/workflow command** — requires FastAPI + Redis worker
- **/distill command** — requires distill CLI + database

Skills that reference these features degrade gracefully — they skip the unavailable section instead of failing. See [docs/locked-to-project/](docs/locked-to-project/README.md) for details.

---

## Troubleshooting

### Agents not routing / Claude answers directly
Make sure you ran `/scaffolding:init-scaffolding` after installing the plugin. This copies `CLAUDE.md` to your project — without it, Claude doesn't know about the agents.

### "Agent type 'developer' not found"
Plugin agents are namespaced. Use `scaffolding:developer` not `developer`. The `CLAUDE.md` copied by `/scaffolding:init-scaffolding` already handles this — if you see this error, re-run `/scaffolding:init-scaffolding`.

### Plugin install says "not found in any marketplace"
Re-add the marketplace first:
```bash
/plugin marketplace add komluk/scaffolding
```

### .scaffolding/ folder missing
Run `/scaffolding:init-scaffolding` — it creates the full directory structure.

---

## License

MIT
