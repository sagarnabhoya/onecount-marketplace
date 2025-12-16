#!/bin/bash

# Onecount App Plugin Generator
# This script creates plugin structure for remaining Onecount apps

# App configurations (name, phase, complexity, key_features)
declare -A APPS
APPS["notify"]="2|1|High|BYOAPI email/SMS, webhooks, templates"
APPS["reviews"]="3|2|Medium-High|Photo/video reviews, Q&A, SEO integration"
APPS["loyalty"]="4|2|High|Points, tiers, referrals, Checkout UI, Functions"
APPS["promos"]="5|3|High|Shopify Functions discounts, BOGO, flash sales"
APPS["upsell"]="6|3|Medium-High|Checkout recommendations, AI suggestions"
APPS["bundles"]="7|3|Medium|Cart transform functions, bundle builder"
APPS["customizer"]="8|3|Medium-High|Product options, conditional logic"
APPS["gifts"]="9|4|Medium|Gift cards, store credit, wrap options"
APPS["seo"]="10|4|Medium|Meta tags, structured data, reviews integration"
APPS["inventory"]="11|4|Medium|Stock tracking, audit trail, Notify integration"
APPS["b2b"]="12|4|High|Wholesale pricing, company accounts, Functions"
APPS["forms"]="13|4|Low-Medium|Contact, quote, survey forms"
APPS["verify"]="14|4|Low-Medium|Age verification, BYOAPI providers"
APPS["analytics"]="15|4+|High|Unified customer profiles, RFM, all integrations"

BASE_DIR="/home/claude/onecount-marketplace/plugins"

for app in "${!APPS[@]}"; do
    IFS='|' read -r num phase complexity features <<< "${APPS[$app]}"
    
    PLUGIN_DIR="$BASE_DIR/onecount-$app"
    
    # Create plugin.json
    cat > "$PLUGIN_DIR/.claude-plugin/plugin.json" << EOF
{
  "name": "onecount-$app",
  "description": "Onecount ${app^} app (App $num) plugin with specialized agents, commands, and project brief integration. Phase $phase app: $features",
  "version": "1.0.0",
  "author": {
    "name": "Onesita Tech",
    "email": "sagar@onesita.tech"
  },
  "license": "MIT",
  "keywords": ["onecount", "$app", "shopify", "phase$phase"],
  "commands": ["./commands/"],
  "agents": ["./agents/"],
  "skills": ["./skills/"]
}
EOF

    # Create skill directory
    mkdir -p "$PLUGIN_DIR/skills/${app}-app"
    
    # Create basic SKILL.md
    cat > "$PLUGIN_DIR/skills/${app}-app/SKILL.md" << EOF
# Onecount ${app^} App Skill

## App Overview

| Attribute | Value |
|-----------|-------|
| App Name | Onecount ${app^} |
| App Number | $num |
| Phase | $phase |
| Complexity | $complexity |
| Key Features | $features |

## Technical Specification

See the project brief and ecosystem documents for complete specifications.

## Extensions Required

[To be populated based on project brief]

## Ecosystem Connections

[To be populated based on ECOSYSTEM_CONNECTIONS.md]

## CLI Prerequisites

\`\`\`bash
shopify app init
# Name: onecount-$app
# Template: Remix
# Language: JavaScript
\`\`\`

Generate extensions as specified in project brief.
EOF

    # Create start command
    cat > "$PLUGIN_DIR/commands/start-$app.md" << EOF
---
name: start-$app
description: Initialize Onecount ${app^} app development (App $num, Phase $phase)
---

# Start Onecount ${app^} Development

Initialize development for Onecount ${app^} (App $num).

## App Overview

| Attribute | Value |
|-----------|-------|
| App Number | $num |
| Phase | $phase |
| Complexity | $complexity |
| Key Features | $features |

## Prerequisites

1. Read the project brief for this app
2. Run Shopify CLI commands
3. Generate required extensions
4. Start development server

Say **"continue"** when ready.

## After Continue

1. Load project brief
2. Create TASK_QUEUE.md
3. Setup Linear (if available)
4. Begin orchestrated development
EOF

    echo "Created plugin: onecount-$app"
done

echo "All plugins generated!"
