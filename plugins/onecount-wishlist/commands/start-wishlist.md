---
name: start-wishlist
description: Initialize Onecount Wishlist app development. Guides through CLI setup, extension generation, and project brief creation.
---

# Start Onecount Wishlist Development

Initialize development for Onecount Wishlist (App 1).

## App Overview

| Attribute | Value |
|-----------|-------|
| App Number | 1 |
| Phase | 1 (Foundation) |
| Complexity | Medium |
| Build Time | 1-2 weeks |
| Dependencies | None |

## Prerequisites

Before proceeding, you need to run Shopify CLI commands.

### Step 1: Create App
```bash
shopify app init

# When prompted:
# - Template: Build a Remix app
# - Language: JavaScript (NOT TypeScript)
# - Name: onecount-wishlist
```

### Step 2: Navigate & Generate Extensions
```bash
cd onecount-wishlist

# Theme App Extension (wishlist button)
shopify app generate extension
# Select: Theme app extension
# Name: wishlist-button

# Customer Account UI (wishlist page)
shopify app generate extension
# Select: Customer account UI extension  
# Name: wishlist-account

# Admin Block (view customer wishlists)
shopify app generate extension
# Select: Admin block
# Name: wishlist-admin
```

### Step 3: Verify Setup
```bash
shopify app dev
```

Say **"continue"** when the app is running.

---

## After User Continues

### Read Generated Structure
Verify these files exist:
- `shopify.app.toml`
- `extensions/wishlist-button/`
- `extensions/wishlist-account/`
- `extensions/wishlist-admin/`
- `app/shopify.server.js`

### Load Project Brief

Check for existing project brief:
1. Look for downloaded `wishlist-claude-setup.zip`
2. Look for `docs/PROJECT_BRIEF.md`
3. If not found, create using analyst-agent

### Create TASK_QUEUE.md

Generate task queue with these epics:

**Epic 1: Foundation Setup**
- T-001: Database schema (Prisma)
- T-002: GDPR webhook handlers
- T-003: Core API routes structure
- T-004: Metafield service

**Epic 2: Theme Extension**
- T-005: Wishlist button block (Liquid)
- T-006: Button JavaScript (add/remove)
- T-007: CSS styling with settings
- T-008: Guest mode handling

**Epic 3: Customer Account**
- T-009: Wishlist page component
- T-010: List management UI
- T-011: Item display with products
- T-012: Share functionality

**Epic 4: Admin Extension**
- T-013: Customer wishlist block
- T-014: Analytics dashboard

**Epic 5: Ecosystem Integration**
- T-015: Notify integration (price/stock alerts)
- T-016: Analytics events

### Sync with Linear (if available)

Create Linear project and issues for all tasks.

### Begin Development

Start with T-001 and follow orchestrator pattern:
1. Create story file
2. Delegate to dev-agent
3. Track progress
4. Continue to next task
