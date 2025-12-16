# Onecount Plugin Marketplace for Claude Code

> **Swiss precision for Shopify** - Complete plugin ecosystem for building the 15-app Onecount suite.

## 🚀 Quick Start

### Install the Marketplace

```bash
# In Claude Code, run:
/plugin marketplace add onesita/onecount-marketplace
```

### Install Core Plugin (Required)

```bash
/plugin install onecount-core@onecount-ecosystem
```

### Install App-Specific Plugins

```bash
# Example: Install Wishlist plugin
/plugin install onecount-wishlist@onecount-ecosystem

# Or install all Phase 1 apps
/plugin install onecount-wishlist@onecount-ecosystem
/plugin install onecount-notify@onecount-ecosystem
```

## 📦 Available Plugins

### Core Plugins

| Plugin | Description |
|--------|-------------|
| `onecount-core` | **Install First** - Orchestrator, Linear integration, progress tracking |
| `onecount-shopify-validator` | Auto-validates GraphQL, Polaris, and Liquid code |

### App Plugins (15 Total)

| # | Plugin | Phase | Key Features |
|---|--------|-------|--------------|
| 1 | `onecount-wishlist` | 1 | Multiple lists, sharing, Theme Extension |
| 2 | `onecount-notify` | 1 | BYOAPI email/SMS, webhooks |
| 3 | `onecount-reviews` | 2 | Photo/video reviews, Q&A |
| 4 | `onecount-loyalty` | 2 | Points, tiers, Checkout UI |
| 5 | `onecount-promos` | 3 | Shopify Functions discounts |
| 6 | `onecount-upsell` | 3 | Checkout recommendations |
| 7 | `onecount-bundles` | 3 | Cart transform functions |
| 8 | `onecount-customizer` | 3 | Product options |
| 9 | `onecount-gifts` | 4 | Gift cards, store credit |
| 10 | `onecount-seo` | 4 | Meta tags, structured data |
| 11 | `onecount-inventory` | 4 | Stock tracking, alerts |
| 12 | `onecount-b2b` | 4 | Wholesale pricing |
| 13 | `onecount-forms` | 4 | Contact, quote forms |
| 14 | `onecount-verify` | 4 | Age verification |
| 15 | `onecount-analytics` | 4+ | Unified customer data |

## 🎯 How It Works

### Orchestrator Pattern

The core plugin enforces the orchestrator pattern:

```
┌─────────────────────────────────────────────────────────────┐
│                    MAIN THREAD (Orchestrator)                │
│                                                              │
│  ✅ Reads project docs (BRIEF, PRD, ARCHITECTURE)           │
│  ✅ Maintains TASK_QUEUE.md with dependency graph           │
│  ✅ Delegates tasks to subagents                            │
│  ✅ Tracks progress in PROGRESS.md + Linear                 │
│  ❌ NEVER writes implementation code                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
         ┌─────────────┼─────────────┐
         ▼             ▼             ▼
   ┌─────────┐   ┌─────────┐   ┌─────────┐
   │dev-agent│   │graphql- │   │polaris- │
   │         │   │agent    │   │agent    │
   └─────────┘   └─────────┘   └─────────┘
```

### Linear Integration

Progress is tracked in both Linear and local files:

```
User Action → Update TASK_QUEUE.md → Sync to Linear → Update PROGRESS.md
```

### Automatic Validation

The Shopify validator plugin hooks into file saves:

```
Write .jsx file → Validate Polaris components → Report errors
Write .graphql → Validate against schema → Report errors
Write .liquid → Validate theme syntax → Report errors
```

## 📋 Commands

### Core Commands

| Command | Description |
|---------|-------------|
| `/start-project` | Initialize new Onecount app project |
| `/execute-task` | Delegate next task to subagent |
| `/update-progress` | Update PROGRESS.md and sync Linear |
| `/sync-linear` | Bidirectional Linear synchronization |

### Validation Commands

| Command | Description |
|---------|-------------|
| `/validate-shopify` | Validate all Shopify code in project |

### App-Specific Commands

| Command | App | Description |
|---------|-----|-------------|
| `/start-wishlist` | Wishlist | Initialize Wishlist development |
| `/start-notify` | Notify | Initialize Notify development |
| ... | ... | ... |

## 🤖 Agents

### Core Agents

| Agent | Tools | Purpose |
|-------|-------|---------|
| `orchestrator-agent` | Read, Write, Edit, TodoWrite | Coordinate development |
| `dev-agent` | Read, Write, Edit, Bash | General implementation |
| `graphql-agent` | Read, Write, Edit | Shopify GraphQL + validation |
| `polaris-agent` | Read, Write, Edit | Polaris UI components |
| `qa-agent` | Read, Write, Bash | Testing and validation |

### Specialized Agents (per app)

Each app plugin provides additional specialized agents:
- Theme extension agents
- Function development agents
- Integration agents

## 🔧 Configuration

### Linear MCP Setup

1. Get API key from Linear.app → Settings → API
2. Add to Claude Code MCP config:

```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "@linear/mcp-server"],
      "env": {
        "LINEAR_API_KEY": "lin_api_xxxxx"
      }
    }
  }
}
```

### Team Configuration

Add to `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "onecount": {
      "source": {
        "source": "github",
        "repo": "onesita/onecount-marketplace"
      }
    }
  },
  "enabledPlugins": [
    "onecount-core@onecount",
    "onecount-shopify-validator@onecount"
  ]
}
```

## 📁 Project Structure

When using these plugins, your project will have:

```
project-root/
├── docs/
│   ├── PROJECT_BRIEF.md
│   ├── PRD.md
│   ├── ARCHITECTURE.md
│   └── UX_SPEC.md
├── stories/
│   ├── story-001-setup.md
│   └── story-002-database.md
├── TASK_QUEUE.md          # Task tracking
├── PROGRESS.md            # Session logs
├── CLAUDE.md              # Project memory
├── .claude/
│   └── agents/            # Auto-loaded from plugins
├── app/                   # Shopify app code
├── extensions/            # Shopify extensions
└── prisma/
    └── schema.prisma
```

## 🔄 Workflow Example

```bash
# 1. Start new project
/start-wishlist

# 2. Run CLI commands as instructed
shopify app init
shopify app generate extension

# 3. Say "continue" when ready

# 4. Claude creates project structure and task queue

# 5. Execute tasks
/execute-task
# Claude delegates to dev-agent, updates progress

# 6. Check progress
/update-progress
# Claude updates PROGRESS.md and syncs Linear

# 7. Continue until complete
```

## 🏗️ Building Your Own App Plugin

Use the template in `plugins/onecount-wishlist/` as reference:

```
your-app-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── start-yourapp.md
├── agents/
│   └── yourapp-agent.md
├── skills/
│   └── yourapp/
│       └── SKILL.md
└── hooks/ (optional)
```

## 📄 License

MIT License - Onesita Tech

## 🤝 Support

- Documentation: [Coming Soon]
- Issues: GitHub Issues
- Email: support@onesita.tech
