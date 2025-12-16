---
name: sync-linear
description: Synchronize tasks between local files (TASK_QUEUE.md) and Linear. Handles bidirectional sync with conflict resolution.
---

# Sync with Linear

Synchronize project tasks between local files and Linear.app.

## Step 1: Check Linear Connection

```
Try: linear_get_team
```

If fails:
- Inform user Linear MCP is not configured
- Offer to show setup instructions
- Continue with local-only mode

## Step 2: Determine Sync Direction

Ask user or auto-detect:

1. **Local → Linear** (Push)
   - Use when: Local has newer changes, or initial setup
   - Creates/updates Linear issues from TASK_QUEUE.md

2. **Linear → Local** (Pull)
   - Use when: Team made changes in Linear
   - Updates local files from Linear status

3. **Bidirectional** (Merge)
   - Use when: Changes on both sides
   - Merges with conflict detection

## Step 3: Execute Sync

### For Local → Linear (Push):

1. Read TASK_QUEUE.md and parse all tasks
2. For each task:
   ```
   - Check if Linear issue exists (by task ID in description)
   - If not exists: linear_create_issue(...)
   - If exists: linear_set_issue_status(...) based on local status
   ```

3. Create project if not exists:
   ```
   linear_create_project({
     name: "Onecount [App Name]",
     description: "From PROJECT_BRIEF.md"
   })
   ```

4. Set up dependencies:
   ```
   For each task with "Blocked By":
     linear_add_dependency(blocking_id, blocked_id)
   ```

### For Linear → Local (Pull):

1. Get all project issues:
   ```
   linear_list_issues(projectId)
   ```

2. Update TASK_QUEUE.md:
   - Move tasks to correct sections based on Linear status
   - Add any new issues created in Linear
   - Update task descriptions if changed

3. Update PROGRESS.md:
   - Add sync event
   - Note any changes pulled

### Conflict Resolution:

When same task has different status:

| Local Status | Linear Status | Resolution |
|--------------|---------------|------------|
| Ready | In Progress | Use Linear (someone started) |
| In Progress | Done | Use Linear (someone completed) |
| Done | In Progress | Use Local (revert shouldn't happen) |
| * | * | Ask user |

## Step 4: Validation

After sync, verify:
- [ ] All tasks in TASK_QUEUE.md have Linear issues
- [ ] Statuses match between local and Linear
- [ ] Dependencies are correctly set
- [ ] No orphaned issues

## Step 5: Report

Output sync summary:
```
## Linear Sync Complete

**Direction:** [Push/Pull/Merge]
**Project:** [Linear project URL]

### Changes
- Created: X issues
- Updated: Y issues  
- Status changes: Z

### Current State
- Total tasks: N
- Ready: X
- In Progress: Y
- Completed: Z

[Link to Linear project]
```
