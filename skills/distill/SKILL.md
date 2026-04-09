---
name: distill
description: "Knowledge distillation methodology -- extraction patterns, confidence scoring, and tier routing rules for the /distill command."
---

# Distill Methodology

Guidelines for automated knowledge extraction and consolidation across memory systems.

## Knowledge Candidate Criteria

An insight qualifies as a knowledge candidate when it meets ANY of these:

| Criterion | Source | Example |
|-----------|--------|---------|
| Cross-conversation pattern | 3+ context.md files contain the same insight | "Redis pool exhaustion under SSE load" |
| Architectural decision | design.md contains explicit Decision/Rationale section | "Use pgvector for semantic search" |
| Recurring gotcha/bug | Keyword match in specs: gotcha, bug, pattern, lesson | "POST 301 redirect strips body" |
| Stale reference | File path in memory points to non-existent file | "app/backend/old_module.py" |
| Cross-tier duplicate | Same entry in both KNOWLEDGE.md and agent MEMORY.md | Duplicated bullet point |

## Confidence Scoring

| Occurrences | Confidence | Tier Recommendation |
|-------------|------------|---------------------|
| 5+ conversations | 0.5 - 1.0 | shared (KNOWLEDGE.md) |
| 3-4 conversations | 0.3 - 0.5 | shared (with review) |
| 1-2 conversations | 0.1 - 0.2 | agent-specific MEMORY.md |
| Decision section | 0.7 fixed | shared |
| Pattern keyword | 0.5 fixed | shared |
| Stale reference | 0.9 fixed | cleanup action |

## Tier Routing

| Target | When | Path |
|--------|------|------|
| `shared` | Cross-cutting insight useful to all agents | `.scaffolding/agent-memory/shared/KNOWLEDGE.md` |
| `agent:{name}` | Domain-specific to one agent | `.scaffolding/agent-memory/agents/{name}/MEMORY.md` |
| Overflow | KNOWLEDGE.md would exceed 200 lines | Route to most relevant agent file |

## Output Format

Candidates are structured as:

```
- content: The knowledge text (max 500 chars)
- source: File path or "conversations:N_occurrences"
- source_type: conversation | spec | memory | semantic
- confidence: 0.0-1.0
- target_tier: shared | agent:{name}
- tags: categorization tags
```

## 200-Line Limit Enforcement

KNOWLEDGE.md has a hard limit of 200 lines (auto-injected into every agent context). When merging would exceed this limit:

1. High-confidence candidates (>= 0.7) get priority
2. Lower-confidence candidates overflow to agent-specific files
3. The orchestrator routes overflow to the most relevant agent based on tags

## Dry-Run vs Apply

- **Dry-run** (default): Report what would change, write nothing
- **Apply**: Create timestamped backup, then write merged content
- **Restore**: Revert files from any backup timestamp
