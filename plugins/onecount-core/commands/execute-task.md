---
name: execute-task
description: Execute the next available task by delegating to the appropriate subagent. Follows orchestrator pattern - main thread NEVER writes implementation code.
---

# Execute Task

Delegate the next available task to a subagent for implementation.

## CRITICAL RULES

❌ **NEVER** write implementation code in this thread
❌ **NEVER** create components, tests, or source files directly
❌ **NEVER** read entire source files into main thread context
✅ **ALWAYS** delegate to subagents via Task tool
✅ **ALWAYS** update TASK_QUEUE.md and PROGRESS.md
✅ **ALWAYS** sync with Linear if available

## Step 1: Identify Next Task

1. Read TASK_QUEUE.md
2. Find tasks in "Ready to Execute" section
3. Select highest priority task (or let user choose)
4. Verify story file exists: `stories/story-XXX-[name].md`

## Step 2: Prepare Story File

If story file doesn't exist, create it with this template:

```markdown
# Story [T-XXX]: [Title]

## Context
[Brief context from PRD.md and ARCHITECTURE.md]
[Include ONLY information needed for this specific task]

## Requirements
[Copy acceptance criteria from PRD/TASK_QUEUE]

## Technical Specification
[Relevant architecture details]
[Database schema if needed]
[API contracts if needed]

## Implementation Guide
[Step-by-step instructions]
[File locations and naming]
[Patterns to follow]

## Files to Create/Modify
- [ ] path/to/file1.js
- [ ] path/to/file2.jsx

## Validation
- [ ] npm run lint passes
- [ ] npm run typecheck passes (if applicable)
- [ ] npm test passes
- [ ] Shopify validation passes (if Shopify code)

## Completion Report Format
When complete, report:
- STATUS: SUCCESS/FAILURE/BLOCKED
- FILES_CREATED: [list]
- FILES_MODIFIED: [list]
- TESTS: X/Y passing
- NOTES: [any important notes]
- UNBLOCKS: [task IDs this enables]
```

## Step 3: Select Subagent

Based on task type, choose appropriate agent:

| Task Type | Agent | Tools |
|-----------|-------|-------|
| Setup/Infrastructure | dev-agent | Read, Write, Edit, Bash |
| Database | database-agent | Read, Write, Edit, Bash |
| API Routes | api-agent | Read, Write, Edit, Bash |
| UI Components | ui-agent | Read, Write, Edit |
| Shopify GraphQL | graphql-agent | Read, Write, Edit + Shopify MCP |
| Polaris UI | polaris-agent | Read, Write, Edit + Shopify MCP |
| Shopify Functions | function-agent | Read, Write, Edit, Bash |
| Liquid Templates | liquid-agent | Read, Write, Edit + Shopify MCP |
| Testing | qa-agent | Read, Write, Edit, Bash |
| Documentation | docs-agent | Read, Write, Edit |

## Step 4: Delegate Task

Use the Task tool to delegate:

```
Task(
  agent: "[agent-name]",
  prompt: "Execute story file: stories/story-XXX.md

Read the story file and implement all requirements.
Follow the implementation guide exactly.
Run all validation commands before reporting.
Report completion using the specified format."
)
```

## Step 5: Update Status

### Before Delegation:
1. Update TASK_QUEUE.md: Move task to "In Progress"
2. Update PROGRESS.md: Log task start
3. If Linear: `linear_set_issue_status(issueId, "in_progress")`

### After Completion:
1. Parse subagent completion report
2. Update TASK_QUEUE.md: Move task to "Completed" or handle failure
3. Update PROGRESS.md: Log completion details
4. If Linear: 
   - `linear_set_issue_status(issueId, "done")`
   - `linear_add_comment(issueId, completion_report)`
5. Check for newly unblocked tasks
6. Move unblocked tasks to "Ready to Execute"

## Step 6: Handle Results

### On SUCCESS:
- Celebrate briefly
- Identify next task
- Offer to continue or pause

### On FAILURE:
- Analyze error from report
- Determine if fixable
- Either re-delegate with fixes or escalate to user

### On BLOCKED:
- Identify missing dependency
- Check if dependency exists in task queue
- If not, create new task for dependency
- Prioritize dependency task
- Re-queue blocked task
