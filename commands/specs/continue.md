---
name: "Specs: Continue"
description: Continue working on a change - create the next artifact (Experimental)
category: Workflow
tags: [workflow, artifacts, experimental]
---

Continue working on a change by creating the next artifact.

**Input**: Optionally specify a conversation_id after `/specs:continue`. If omitted, use the current conversation's UUID. If vague or ambiguous, list conversations that have specs directories.

**UUID Enforcement**: The conversation_id MUST be a UUID (format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`). NEVER use descriptive names.

**Steps**

1. **Locate the specs directory**

   Use the current conversation's UUID or the provided one to find:
   `.scaffolding/conversations/{conversation_id}/specs/`

   If no specs directory exists, inform the user and suggest `/specs:new`.

2. **Check current status**

   Check which artifacts exist in the specs directory:
   - `proposal.md` - exists or not
   - `design.md` - exists or not
   - `tasks.md` - exists or not

3. **Act based on status**:

   ---

   **If all 3 artifacts exist**:
   - Congratulate the user
   - Suggest: "All artifacts created! You can now implement with `/specs:apply` or archive with `/specs:archive`."
   - STOP

   ---

   **If artifacts are missing** (create in order: proposal -> design -> tasks):

   Pick the FIRST missing artifact in dependency order:

   a. **If `proposal.md` is missing**: Create it
      - Ask the user what the change is about if unclear
      - Write proposal.md with Why, What Changes, Capabilities, Impact, Agent Assignment, Rollback Plan
      - STOP after creating

   b. **If `design.md` is missing** (proposal.md exists): Create it
      - Read `proposal.md` for context
      - Write design.md with scenarios (Given/When/Then), implementation decisions, file changes, risks
      - STOP after creating

   c. **If `tasks.md` is missing** (proposal.md + design.md exist): Create it
      - Read `proposal.md` and `design.md` for context
      - Write tasks.md with checkbox task list
      - STOP after creating

4. **After creating an artifact, show progress**

   Display which artifacts exist and which are still needed.

**Output**

After each invocation, show:
- Which artifact was created
- Current progress (N/3 artifacts complete)
- What's next
- Prompt: "Run `/specs:continue` to create the next artifact"

**Artifact Creation Guidelines**

- Always read existing artifacts for context before creating a new one
- Follow the dependency order: proposal -> design -> tasks
- proposal.md: Ask user about the change if not clear. Fill in Why, What Changes, Capabilities, Impact.
- design.md: Document scenarios (Given/When/Then), technical decisions, architecture, implementation approach, risks.
- tasks.md: Break down implementation into checkboxed tasks.

**Guardrails**
- Create ONE artifact per invocation
- Always read dependency artifacts before creating a new one
- Never skip artifacts or create out of order
- If context is unclear, ask the user before creating
- Verify the artifact file exists after writing before marking progress