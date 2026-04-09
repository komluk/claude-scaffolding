---
name: "Specs: Apply"
description: Implement tasks from a conversation's specs (Experimental)
category: Workflow
tags: [workflow, artifacts, experimental]
---

Implement tasks from a conversation's specs.

**Input**: Optionally specify a conversation_id (e.g., `/specs:apply <conversation_id>`). If omitted, use the current conversation's UUID. If vague or ambiguous, list conversations that have specs directories.

**UUID Enforcement**: The conversation_id MUST be a UUID (format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`). NEVER use descriptive names.

**Steps**

1. **Locate the specs directory**

   Use the current conversation's UUID or the provided one to find:
   `.scaffolding/conversations/{conversation_id}/specs/`

   If no specs directory exists, inform the user and suggest `/specs:new` or `/specs:ff`.

   Always announce: "Using specs from conversation: <conversation_id>"

2. **Read context files**

   Read the available spec files from the specs directory:
   - `proposal.md` - Why and what
   - `design.md` - How (scenarios, decisions, risks)
   - `tasks.md` - Implementation checklist

   **Handle states:**
   - If no `tasks.md` exists: show message, suggest using `/specs:continue` to create it
   - If all tasks are complete: congratulate, suggest archive
   - Otherwise: proceed to implementation

3. **Show current progress**

   Display:
   - Progress: "N/M tasks complete"
   - Remaining tasks overview

4. **Implement tasks (loop until done or blocked)**

   For each pending task:
   - Show which task is being worked on
   - Make the code changes required
   - Keep changes minimal and focused
   - Mark task complete in tasks.md: `- [ ]` -> `- [x]`
   - Continue to next task

   **Pause if:**
   - Task is unclear -> ask for clarification
   - Implementation reveals a design issue -> suggest updating artifacts
   - Error or blocker encountered -> report and wait for guidance
   - User interrupts

5. **On completion or pause, show status**

   Display:
   - Tasks completed this session
   - Overall progress: "N/M tasks complete"
   - If all done: suggest archive
   - If paused: explain why and wait for guidance

**Output During Implementation**

```
## Implementing from specs

Working on task 3/7: <task description>
[...implementation happening...]
Task complete

Working on task 4/7: <task description>
[...implementation happening...]
Task complete
```

**Output On Completion**

```
## Implementation Complete

**Conversation:** <conversation_id>
**Progress:** 7/7 tasks complete

### Completed This Session
- [x] Task 1
- [x] Task 2
...

All tasks complete! You can archive with `/specs:archive`.
```

**Output On Pause (Issue Encountered)**

```
## Implementation Paused

**Conversation:** <conversation_id>
**Progress:** 4/7 tasks complete

### Issue Encountered
<description of the issue>

**Options:**
1. <option 1>
2. <option 2>
3. Other approach

What would you like to do?
```

**Guardrails**
- Keep going through tasks until done or blocked
- Always read context files before starting
- If task is ambiguous, pause and ask before implementing
- If implementation reveals issues, pause and suggest artifact updates
- Keep code changes minimal and scoped to each task
- Update task checkbox immediately after completing each task
- Pause on errors, blockers, or unclear requirements - don't guess