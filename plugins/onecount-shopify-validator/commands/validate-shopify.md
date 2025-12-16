---
name: validate-shopify
description: Validate all Shopify code in the current project - GraphQL queries, Polaris components, and Liquid templates.
---

# Validate Shopify Code

Run comprehensive validation on all Shopify-related code in the project.

## Step 1: Initialize Shopify Context

```
learn_shopify_api(api: "admin")
```

Save the conversationId for subsequent calls.

## Step 2: Find and Validate GraphQL

### Find GraphQL Files
Look in:
- `app/graphql/*.js`
- `app/routes/*.js` (inline queries)
- `extensions/*/src/run.graphql` (Functions)

### Extract GraphQL Strings
Parse files for:
- Template literals with `graphql` tag
- Strings containing `query` or `mutation`
- `.graphql` files

### Validate Each Query
```
validate_graphql_codeblocks(
  api: "admin",  // or appropriate function API
  codeblocks: [{ content: "query {...}" }],
  conversationId: [saved_id]
)
```

Report results:
- ✅ Valid queries
- ❌ Invalid queries with error details

## Step 3: Find and Validate Polaris Components

### Find Component Files
Look in:
- `app/routes/app.*.jsx` (App home pages)
- `extensions/*/src/*.jsx` (Extensions)

### Determine API Type
| Location | API |
|----------|-----|
| `app/routes/app.*` | polaris-app-home |
| `extensions/*-admin/*` | polaris-admin-extensions |
| `extensions/*-checkout/*` | polaris-checkout-extensions |
| `extensions/*-customer-account/*` | polaris-customer-account-extensions |

### Validate Each Component
```
validate_component_codeblocks(
  api: [determined_api],
  code: [{ content: "<jsx content>" }],
  conversationId: [saved_id]
)
```

Report results:
- ✅ Valid components
- ❌ Invalid components with error details

## Step 4: Find and Validate Liquid (Themes/Extensions)

### Find Liquid Files
Look in:
- `extensions/*/blocks/*.liquid`
- `extensions/*/snippets/*.liquid`
- `extensions/*/assets/*.liquid`

### Validate Theme Files
```
validate_theme(
  absoluteThemePath: [extension_path],
  filesCreatedOrUpdated: [{ path: "relative/path.liquid" }],
  conversationId: [saved_id]
)
```

## Step 5: Check for Deprecated APIs

Scan code for known deprecated patterns:

| Pattern | Replacement | Files Found |
|---------|-------------|-------------|
| `inventoryAdjustQuantity` | `inventoryAdjustQuantities` | [list] |
| `productDuplicateAsync` | `productDuplicateAsyncV2` | [list] |
| `Image.originalSrc` | `Image.url` | [list] |
| `totalCount` | `productsCount { count }` | [list] |

## Step 6: Generate Report

```markdown
# Shopify Validation Report

## Summary
| Category | Valid | Invalid | Total |
|----------|-------|---------|-------|
| GraphQL Queries | X | Y | Z |
| Polaris Components | X | Y | Z |
| Liquid Templates | X | Y | Z |
| Deprecated APIs | - | Y | - |

## GraphQL Validation
### Valid ✅
- `GetProducts` in app/graphql/products.js
- `UpdateMetafield` in app/routes/api.wishlist.js

### Invalid ❌
- `GetProductCategory` in app/graphql/products.js
  - Error: Field 'productCategory' is deprecated, use 'category'

## Polaris Validation
### Valid ✅
- DashboardPage in app/routes/app._index.jsx

### Invalid ❌
- SettingsForm in app/routes/app.settings.jsx
  - Error: Unknown component 's-form-field', did you mean 's-text-field'?

## Liquid Validation
### Valid ✅
- wishlist-button.liquid

### Invalid ❌
- [none]

## Deprecated API Usage
### Found ⚠️
- app/graphql/inventory.js:15 - uses `inventoryAdjustQuantity`
  - Fix: Replace with `inventoryAdjustQuantities`

## Recommendations
1. Fix GraphQL errors before deployment
2. Update deprecated API calls
3. Re-run validation after fixes
```
