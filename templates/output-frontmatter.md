# Agent Output Frontmatter Schema

All agents MUST use this exact YAML frontmatter block as the first element of their output.

## Required Fields

```yaml
---
agent: {agent-name}                                    # Must match agent file name
task: {description}                                    # Task description or ST-XXX reference
status: success | partial_success | blocked | failed   # Completion status
gate: passed | failed | not_applicable                 # Quality gate result
score: XX/100 | n/a                                    # Numerical for scored agents, n/a otherwise
files_modified: N                                      # Integer count of files changed
next_agent: {name} | none | user_decision              # Next agent in chain
---
```

## Optional Fields

```yaml
issues: []                    # List of issues found (primarily for reviewer)
severity: none | low | medium | high | critical   # Highest severity issue found
```

## Field Rules

- `gate: not_applicable` -- Use when the task does not involve a formal quality gate
- `score: n/a` -- Use for agents without scoring rubrics (architect, developer, debugger, tech-writer, devops)
- `score: XX/100` -- Required for researcher (pass: >=80), architect (pass: >=85, planning mode), performance-optimizer
- `next_agent: none` -- Use when no follow-up agent is needed
- `next_agent: user_decision` -- Use when the user should decide the next step
- `issues` and `severity` -- Optional, used primarily by reviewer but available to all agents
