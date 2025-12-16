# Onecount Plugin Integration Guide

## How Everything Works Together

This document explains how the Onecount Claude Code plugins integrate with your existing project briefer workflow and Linear MCP.

---

## 🔄 Workflow Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         ONECOUNT DEVELOPMENT FLOW                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   1. INSTALL PLUGINS                                                     │
│      │                                                                   │
│      ├── /plugin marketplace add onesita/onecount-marketplace           │
│      ├── /plugin install onecount-core                                  │
│      └── /plugin install onecount-[app-name]                            │
│                                                                          │
│   2. START PROJECT                                                       │
│      │                                                                   │
│      ├── /start-[app-name] command                                      │
│      ├── Check for existing project brief (from downloads)              │
│      ├── Detect Linear MCP availability                                 │
│      └── Output Shopify CLI prerequisites                               │
│                                                                          │
│   3. USER RUNS CLI                                                       │
│      │                                                                   │
│      ├── shopify app init                                               │
│      ├── shopify app generate extension (for each extension)            │
│      ├── shopify app dev                                                │
│      └── Says "continue"                                                │
│                                                                          │
│   4. PROJECT SETUP                                                       │
│      │                                                                   │
│      ├── Load/create PROJECT_BRIEF.md                                   │
│      ├── Create TASK_QUEUE.md from project brief tasks                  │
│      ├── Create PROGRESS.md                                             │
│      ├── Create Linear project + issues (if available)                  │
│      └── Load specialized agents from plugins                           │
│                                                                          │
│   5. ORCHESTRATED DEVELOPMENT                                            │
│      │                                                                   │
│      ├── /execute-task → Delegate to subagent                           │
│      │   ├── dev-agent (implementation)                                 │
│      │   ├── graphql-agent (Shopify API)                                │
│      │   ├── polaris-agent (UI components)                              │
│      │   └── qa-agent (validation)                                      │
│      │                                                                   │
│      ├── AUTOMATIC HOOKS                                                │
│      │   ├── PostToolUse → Log to PROGRESS.md                          │
│      │   ├── PostToolUse → Validate Shopify code                        │
│      │   └── Stop → Session summary                                     │
│      │                                                                   │
│      └── DUAL-WRITE (Linear + Local)                                    │
│          ├── Update TASK_QUEUE.md                                       │
│          ├── Update Linear issue status                                 │
│          └── Update PROGRESS.md                                         │
│                                                                          │
│   6. COMPLETION                                                          │
│      │                                                                   │
│      ├── All tasks in "Completed" section                               │
│      ├── Linear shows 100% progress                                     │
│      └── Ready for App Store submission                                 │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 📦 Plugin Architecture

### Core Plugin (onecount-core)

**Always install first.** Provides:

| Component | Purpose |
|-----------|---------|
| `/start-project` | Initialize any Onecount app |
| `/execute-task` | Delegate tasks to subagents |
| `/update-progress` | Update tracking files + Linear |
| `/sync-linear` | Bidirectional Linear sync |
| `orchestrator-agent` | Enforces orchestrator pattern |
| `dev-agent` | General implementation |
| `graphql-agent` | Shopify GraphQL + validation |
| `polaris-agent` | Polaris UI components |
| `qa-agent` | Testing and validation |
| `hooks.json` | Automatic progress tracking |
| `.mcp.json` | Linear MCP configuration |

### App-Specific Plugins

Each app plugin (e.g., `onecount-wishlist`) provides:

| Component | Purpose |
|-----------|---------|
| `/start-[app]` | App-specific initialization |
| `skills/[app]/SKILL.md` | Complete app specification |
| App-specific agents | Specialized for that app |

---

## 🔗 Integration with Existing Project Briefs

If you've already created project briefs using the project-briefer skill:

### Option 1: Downloaded Project Package

```
1. User has: wishlist-claude-setup.zip
2. Extract to working directory
3. /start-wishlist detects existing docs/
4. Loads PROJECT_BRIEF.md, TASK_QUEUE.md, etc.
5. Continues from existing progress
```

### Option 2: Fresh Start

```
1. /start-wishlist
2. No existing brief detected
3. Plugin creates new project structure
4. Uses skill file for specifications
```

### Merging Existing Brief with Plugin

```javascript
// Plugin checks these locations:
const briefLocations = [
  'docs/PROJECT_BRIEF.md',           // Standard location
  '../*-claude-setup/docs/',         // Downloaded package
  'PROJECT_BRIEF.md',                // Root level
];

// If found, loads and uses existing brief
// If not, creates new from skill template
```

---

## 📊 Linear Integration Details

### Auto-Detection

```
On /start-project or /start-[app]:

1. Try: linear_get_team()
2. If SUCCESS → "Linear detected! Creating project..."
3. If FAIL → "Linear not configured. Options:
              1. Set up Linear (instructions)
              2. Continue local-only"
```

### Dual-Write Strategy

**Every task update writes to BOTH:**

| Action | TASK_QUEUE.md | Linear | PROGRESS.md |
|--------|---------------|--------|-------------|
| Start task | Move to "In Progress" | Set status | Log start |
| Complete task | Move to "Completed" | Set "done" + comment | Log completion |
| Block task | Add note | Add comment | Log blocker |
| New task | Add to queue | Create issue | Log creation |

### Linear Project Structure

```
Linear Project: "Onecount Wishlist"
├── Labels
│   ├── Epic-1: Setup
│   ├── Epic-2: Theme Extension
│   ├── Epic-3: Customer Account
│   └── Epic-4: Admin
├── Issues (from TASK_QUEUE.md)
│   ├── T-001: Database schema
│   ├── T-002: GDPR webhooks
│   └── ...
└── Dependencies (from task blockedBy)
```

---

## 🎛️ Hooks Configuration

### PostToolUse Hooks

Triggered after Write/Edit operations:

```json
{
  "PostToolUse": [
    {
      "matcher": "Write|Edit|MultiEdit",
      "hooks": [
        {
          "type": "command",
          "command": "echo '[PROGRESS] File modified' >> PROGRESS.md"
        }
      ]
    }
  ]
}
```

### PreToolUse Hooks

Warn if no task is in progress:

```json
{
  "PreToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "grep -q 'In Progress' TASK_QUEUE.md || echo 'WARNING: No task in progress'"
        }
      ]
    }
  ]
}
```

### Session End Hooks

Clean up when stopping:

```json
{
  "Stop": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "echo '---\nSession End: $(date)' >> PROGRESS.md"
        }
      ]
    }
  ]
}
```

---

## 🔧 Customization

### Adding New Agents

Create in `.claude/agents/` (project) or `~/.claude/agents/` (global):

```markdown
---
name: my-custom-agent
description: Custom agent for specific task
tools: Read, Write, Edit
---

Your system prompt here...
```

### Adding New Commands

Create in plugin's `commands/` folder:

```markdown
---
name: my-command
description: What this command does
---

Instructions for Claude...
```

### Extending Skills

Add to plugin's `skills/` folder:

```
skills/
└── my-skill/
    └── SKILL.md
```

---

## 🚨 Troubleshooting

### Linear Not Detected

```
Symptoms: "Linear MCP not found"
Solutions:
1. Check MCP config file exists
2. Verify API key is correct (lin_api_xxx)
3. Restart Claude Code
4. Run: npx -y @linear/mcp-server (test if installed)
```

### Progress Not Updating

```
Symptoms: PROGRESS.md not updated
Solutions:
1. Check hooks are enabled: /plugin list
2. Verify onecount-core is installed
3. Check file permissions
```

### Tasks Not Syncing

```
Symptoms: Linear and local don't match
Solutions:
1. Run /sync-linear
2. Choose appropriate direction (push/pull)
3. Resolve any conflicts
```

### Validation Failures

```
Symptoms: GraphQL/Polaris validation errors
Solutions:
1. Run /validate-shopify for full report
2. Fix errors shown
3. Re-validate
```

---

## 📋 Quick Reference

### Essential Commands

```bash
# Start any app
/start-[appname]

# Execute next task
/execute-task

# Update progress
/update-progress

# Sync with Linear
/sync-linear

# Validate Shopify code
/validate-shopify
```

### Key Files

| File | Purpose |
|------|---------|
| `TASK_QUEUE.md` | Current task status |
| `PROGRESS.md` | Session logs |
| `docs/PROJECT_BRIEF.md` | Project vision |
| `stories/*.md` | Task contracts for subagents |

### Agent Selection

| Task Type | Agent |
|-----------|-------|
| Database/API | dev-agent |
| GraphQL queries | graphql-agent |
| UI components | polaris-agent |
| Testing | qa-agent |
| Code review | qa-agent |
