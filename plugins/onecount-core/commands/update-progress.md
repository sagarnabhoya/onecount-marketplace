---
name: update-progress
description: Update PROGRESS.md and sync with Linear. Use after completing tasks, at session end, or when switching context.
---

# Update Progress Tracking

You are updating progress tracking for the current Onecount project.

## Step 1: Read Current State

1. Read `TASK_QUEUE.md` to understand current task status
2. Read `PROGRESS.md` to see session history
3. Check for any pending subagent reports

## Step 2: Gather Updates

Collect information about:
- Tasks completed since last update
- Tasks currently in progress
- Any blockers encountered
- Files created/modified
- Decisions made

## Step 3: Update PROGRESS.md

Add entry with this format:

```markdown
---

## Session Update: [DATE TIME]

### Completed Tasks
- [T-XXX] Task name - SUCCESS/FAILURE
  - Files: list of files
  - Notes: any important notes

### In Progress
- [T-XXX] Task name - current status

### Blockers
- [T-XXX] blocked by [reason]

### Decisions Made
- [Decision]: [Rationale]

### Statistics
- Tasks Completed: X/Y
- Progress: XX%
```

## Step 4: Update TASK_QUEUE.md

Move tasks between sections:
- "Ready to Execute" → "In Progress" (when starting)
- "In Progress" → "Completed" (when done)
- Check if completed tasks unblock others
- Move newly unblocked tasks to "Ready to Execute"

## Step 5: Sync with Linear (If Available)

If Linear MCP is configured:

1. For completed tasks:
   ```
   linear_set_issue_status(issueId, "done")
   linear_add_comment(issueId, completion_report)
   ```

2. For started tasks:
   ```
   linear_set_issue_status(issueId, "in_progress")
   ```

3. For blocked tasks:
   ```
   linear_add_comment(issueId, "BLOCKED: [reason]")
   ```

## Step 6: Report Summary

Output a brief summary:
- Tasks completed this session
- Current progress percentage
- Next recommended tasks
- Any blockers needing resolution
