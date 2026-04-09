---
name: agent-memory
description: "3-tier persistent memory protocol for cross-session knowledge accumulation. Use when agents need to read, write, or manage memory files."
---

# Agent Memory Protocol

3-tier persistent memory system for cross-session knowledge accumulation.

## Memory Tiers

| Tier | Path | Scope | Written By | Read By |
|------|------|-------|------------|---------|
| **Shared** | `.scaffolding/agent-memory/shared/KNOWLEDGE.md` | Whole project | Any agent | All agents |
| **Agent** | `.scaffolding/agent-memory/agents/{agent-name}/MEMORY.md` | Per agent | Owning agent | Own agent + architect |
| **Conversation** | `.scaffolding/conversations/{conversation_id}/agent-memory/context.md` | Per conversation | Any agent in conversation | Agents in same conversation |

## Automatic Injection

Memory is auto-injected into agent context via `recall_for_agent()` in the task execution pipeline. When a task starts, the system reads:
1. `.scaffolding/agent-memory/shared/KNOWLEDGE.md` (always)
2. `.scaffolding/agent-memory/agents/{agent-name}/MEMORY.md` (when agent_name is known)
3. `.scaffolding/conversations/{id}/agent-memory/context.md` (when conversation_id is provided)

This means agents receive memory context automatically. Manual reading on first turn is optional but recommended for verifying latest data.

## On First Turn

Before starting work, optionally read available memory for latest content (skip if files don't exist):

1. Read `.scaffolding/agent-memory/shared/KNOWLEDGE.md`
2. Read `.scaffolding/agent-memory/agents/{your-agent-name}/MEMORY.md`
3. If `conversation_id` is provided in task context: Read `.scaffolding/conversations/{conversation_id}/agent-memory/context.md`

## Before Completing

Write significant findings to the appropriate tier:

### Shared Knowledge (KNOWLEDGE.md)
Save here:
- Project architecture facts confirmed across multiple tasks
- Deployment gotchas and infrastructure quirks
- Cross-cutting patterns (e.g. how Redis is used, how tasks flow)
- Known bugs or limitations that affect multiple agents

Do NOT save:
- Agent-specific patterns (use agent memory)
- Task-specific context (use conversation memory)
- Anything already in CLAUDE.md or docs/

### Agent Memory (MEMORY.md)
Save here:
- Patterns specific to your agent's domain (e.g. developer saves coding patterns)
- Lessons learned from mistakes in your domain
- File locations you frequently need
- Recurring debugging insights

Do NOT save:
- Generic project facts (use shared knowledge)
- One-time task details
- Speculative or unverified conclusions

### Conversation Memory (context.md)
Save here:
- Decisions made during this conversation
- Findings from investigation (debugger -> developer handoff)
- Context needed by downstream agents in the same conversation chain
- Original intent and requirements clarifications

Do NOT save:
- Permanent knowledge (use shared or agent memory)
- Raw data or large code snippets

### Read-Only Agents

Agents with `disallowedTools: Write, Edit` (architect, reviewer) cannot write to `.scaffolding/agent-memory/` directly. These agents should report findings in their output, and writable agents in the same conversation chain can persist them.

## Format Guidelines

- Max 200 lines per file (auto-injected memory has 200-line limit)
- Use markdown headers to organize by topic
- Include dates `[YYYY-MM-DD]` for time-sensitive entries
- Remove outdated entries proactively
- Use concise bullet points, not prose

## File Creation

If memory files don't exist, create them with the appropriate header:

```markdown
# Shared Knowledge
<!-- Cross-agent project knowledge. Max 200 lines. -->
```

```markdown
# {Agent Name} Memory
<!-- Agent-specific patterns and lessons. Max 200 lines. -->
```

```markdown
# Conversation {conversation_id} Context
<!-- Decisions and findings for this conversation chain. -->
```

## Conversation Recall

Conversation memory is always available via file-based recall. When a task runs with a `conversation_id`, the system reads `context.md` and injects it into the agent's context. No database setup is required for conversation-tier memory.
