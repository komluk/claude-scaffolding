---
name: "Specs: Sync"
description: Sync design specs from a conversation to main specs
category: Workflow
tags: [workflow, specs, experimental]
---

Sync design specs from a conversation's specs directory to main specs.

This is an **agent-driven** operation - you will read the conversation's design.md and directly edit main specs to apply the changes. This allows intelligent merging (e.g., adding a scenario without copying the entire requirement).

**Input**: Optionally specify a conversation_id after `/specs:sync`. If omitted, use the current conversation's UUID. If vague or ambiguous, list conversations that have specs directories.

**UUID Enforcement**: The conversation_id MUST be a UUID (format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`). NEVER use descriptive names.

**Steps**

1. **Locate the specs directory**

   Use the current conversation's UUID or the provided one to find:
   `.scaffolding/conversations/{conversation_id}/specs/`

   If no specs directory exists, inform the user and stop.

2. **Read the design spec**

   Read `.scaffolding/conversations/{conversation_id}/specs/design.md`.

   The design.md contains scenarios, requirements, and implementation decisions that may need to be synced to the main specs.

   If no design.md found, inform user and stop.

3. **Identify syncable content**

   From design.md, extract:
   - New requirements (scenarios with Given/When/Then)
   - Modified requirements
   - Key decisions that affect specs

4. **Apply changes to main specs**

   For each syncable item:

   a. **Read the main spec** at `.scaffolding/openspec/specs/<capability>/spec.md` (may not exist yet)

   b. **Apply changes intelligently**:

      **New Requirements:**
      - If requirement doesn't exist in main spec -> add it
      - If requirement already exists -> update it to match

      **Modified Requirements:**
      - Find the requirement in main spec
      - Apply the changes (add scenarios, modify descriptions)
      - Preserve content not mentioned in the design

   c. **Create new main spec** if capability doesn't exist yet:
      - Create `.scaffolding/openspec/specs/<capability>/spec.md`
      - Add Purpose section
      - Add Requirements section

5. **Show summary**

   After applying all changes, summarize:
   - Which capabilities were updated
   - What changes were made (requirements added/modified)

**Key Principle: Intelligent Merging**

Unlike programmatic merging, you can apply **partial updates**:
- The design.md represents *intent*, not a wholesale replacement
- Use your judgment to merge changes sensibly
- Preserve existing content not affected by the change

**Output On Success**

```
## Specs Synced: <conversation_id>

Updated main specs:

**<capability-1>**:
- Added requirement: "New Feature"
- Modified requirement: "Existing Feature" (added 1 scenario)

Main specs are now updated.
```

**Guardrails**
- Read both design.md and main specs before making changes
- Preserve existing content not mentioned in design.md
- If something is unclear, ask for clarification
- Show what you're changing as you go
- The operation should be idempotent - running twice should give same result