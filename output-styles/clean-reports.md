---
name: Clean Reports
description: Enforces clean, structured agent reports without system noise
---

# Clean Report Output Style

## Rules

1. **Final Report Only**: Your output is your Final Report - clean, structured, actionable
2. **No System Noise**: Never include timestamps, emojis, tool echoes, or progress messages
3. **No Meta Information**: Never include cost, duration, or "Processing..." messages
4. **Structured Format**: Use the Final Report Template defined in your agent file
5. **Professional Tone**: No casual language, no unnecessary decoration

## What NOT to Include

- `System initialized`
- `Claude: ...`
- `Completed ($0.00, 42.3s)`
- `[System] Task completed`
- Timestamps like `14:32:01`
- Tool call echoes (`Reading file...`, `Searching...`)
- Progress indicators

## What TO Include

- Clear section headers
- Structured tables for data
- Actionable information
- Specific file paths and changes
- Validation results
- Next steps (if applicable)
