---
name: start-project
description: Initialize a new Onecount app project with orchestrator pattern. Creates PROJECT_BRIEF, sets up Linear tracking, and prepares for autonomous development.
---

# Start New Onecount Project

You are initializing a new Onecount ecosystem app project. Follow the orchestrator pattern strictly.

## Step 1: Detect Linear MCP

First, check if Linear MCP is available:
- Try calling `linear_get_team`
- If SUCCESS → Use Linear mode (sync to Linear + local files)
- If FAILURE → Ask user preference:
  1. Set up Linear (provide setup guide)
  2. Continue with local files only

## Step 2: Identify Which App

Ask the user which Onecount app they want to work on:

| # | App | Phase | Key Extensions |
|---|-----|-------|----------------|
| 1 | Wishlist | 1 | Theme Extension, Customer Account UI |
| 2 | Notify | 1 | Webhooks, BYOAPI integrations |
| 3 | Reviews | 2 | Theme Extension, Customer Account UI |
| 4 | Loyalty | 2 | Checkout UI, Shopify Functions |
| 5 | Promos | 3 | Shopify Functions (discounts) |
| 6 | Upsell | 3 | Checkout UI Extension |
| 7 | Bundles | 3 | Shopify Functions (cart transform) |
| 8 | Customizer | 3 | Theme Extension |
| 9 | Gifts | 4 | Gift Card API |
| 10 | SEO | 4 | Theme Extension |
| 11 | Inventory | 4 | Webhooks |
| 12 | B2B | 4 | Shopify Functions |
| 13 | Forms | 4 | Theme Extension |
| 14 | Verify | 4 | BYOAPI integrations |
| 15 | Analytics | 4+ | All integrations |

## Step 3: Check for Existing Project Brief

Look for existing project brief in:
- `docs/PROJECT_BRIEF.md`
- `{app-name}-claude-setup/docs/PROJECT_BRIEF.md`
- Any downloaded project package

If found, ask user: "I found an existing project brief. Should I use it or create a new one?"

## Step 4: Shopify CLI Prerequisites

CRITICAL: Output prerequisites BEFORE creating any files:

```markdown
## ⚠️ PRE-REQUISITES: Run These Commands First

Claude cannot create Shopify apps from scratch. Run these CLI commands:

### Step 1: Create App
\`\`\`bash
shopify app init
# Select: Build a Remix app
# Select: JavaScript (NOT TypeScript)
# Name: onecount-[app-name]
\`\`\`

### Step 2: Generate Extensions
[List specific extensions for this app]

### Step 3: Verify
\`\`\`bash
cd onecount-[app-name]
shopify app dev
\`\`\`

Say **"continue"** when ready.
```

## Step 5: Create/Load Project Structure

Once user says "continue":

1. Read generated files (shopify.app.toml, extensions/*)
2. Create or verify project structure:
   ```
   docs/
   ├── PROJECT_BRIEF.md
   ├── PRD.md
   ├── UX_SPEC.md
   ├── ARCHITECTURE.md
   stories/
   TASK_QUEUE.md
   PROGRESS.md
   CLAUDE.md
   .claude/agents/
   ```

3. If using Linear:
   - Create Linear project
   - Create issues from TASK_QUEUE.md
   - Set up dependencies

## Step 6: Begin Orchestration

Remind the orchestrator rules:

❌ NEVER write implementation code in main thread
❌ NEVER create components directly
✅ Delegate ALL implementation to subagents
✅ Track progress in PROGRESS.md (and Linear if available)
✅ Update TASK_QUEUE.md after each task

## Output

After setup, provide:
1. Summary of project state
2. Next available tasks from TASK_QUEUE.md
3. Recommended first task to delegate
