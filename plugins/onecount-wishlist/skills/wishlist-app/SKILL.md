# Onecount Wishlist App Skill

Complete technical specification for Onecount Wishlist (App 1).

## App Overview

| Attribute | Value |
|-----------|-------|
| App Name | Onecount Wishlist |
| App Number | 1 |
| Phase | 1 (Foundation) |
| Build Time | 1-2 weeks |
| Complexity | Medium |
| Dependencies | None (foundation app) |

## Core Features

### MVP Features
1. **Multiple Wishlists** - Create named lists (Wishlist, Birthday, Wedding)
2. **Add to Wishlist Button** - Theme extension on product pages
3. **Wishlist Page** - Customer account UI extension
4. **Quick Add** - Add variants without leaving page
5. **Sharing** - Public/private list sharing with links

### Pro Features
6. **Stock Alerts** - Notify integration for back-in-stock
7. **Price Drop Alerts** - Notify integration for price changes
8. **Analytics Dashboard** - Conversion tracking
9. **Export** - CSV/PDF export of wishlists

## Technical Architecture

### Extensions Required

| Extension | Type | Purpose |
|-----------|------|---------|
| `wishlist-button` | Theme App Extension | Add button on product pages |
| `wishlist-account` | Customer Account UI | Wishlist management page |
| `wishlist-admin` | Admin Block | View customer wishlists |

### Metafield Schema

```
Namespace: custom
Key: onec_wishlist
Owner: Customer
Type: json
```

**Structure:**
```json
{
  "lists": [
    {
      "id": "uuid",
      "name": "My Wishlist",
      "isDefault": true,
      "isPublic": false,
      "shareCode": "abc123",
      "items": [
        {
          "productId": "gid://shopify/Product/123",
          "variantId": "gid://shopify/ProductVariant/456",
          "addedAt": "2024-01-15T10:30:00Z",
          "priceAtAdd": "29.99",
          "notifyOnStock": true,
          "notifyOnPriceDrop": true
        }
      ],
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    }
  ],
  "settings": {
    "defaultListId": "uuid",
    "emailNotifications": true
  }
}
```

### Database Schema (Prisma)

```prisma
model Shop {
  id        String   @id @default(uuid())
  shopDomain String  @unique
  accessToken String
  settings   Json     @default("{}")
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  wishlistAnalytics WishlistAnalytics[]
}

model WishlistAnalytics {
  id          String   @id @default(uuid())
  shopId      String
  shop        Shop     @relation(fields: [shopId], references: [id])
  productId   String
  variantId   String?
  customerId  String?
  action      String   // "add", "remove", "purchase"
  metadata    Json?
  createdAt   DateTime @default(now())
  
  @@index([shopId, productId])
  @@index([shopId, action])
}
```

### API Routes

| Route | Method | Purpose |
|-------|--------|---------|
| `/api/wishlist` | GET | Get customer's wishlists |
| `/api/wishlist` | POST | Add item to wishlist |
| `/api/wishlist` | DELETE | Remove item from wishlist |
| `/api/wishlist/list` | POST | Create new list |
| `/api/wishlist/list/:id` | PUT | Update list (rename, privacy) |
| `/api/wishlist/list/:id` | DELETE | Delete list |
| `/api/wishlist/share/:code` | GET | Get shared wishlist (public) |
| `/api/wishlist/analytics` | GET | Get analytics data |

### GraphQL Queries Needed

```graphql
# Get customer metafield
query GetCustomerWishlist($customerId: ID!) {
  customer(id: $customerId) {
    metafield(namespace: "custom", key: "onec_wishlist") {
      id
      value
    }
  }
}

# Get products for wishlist display
query GetWishlistProducts($ids: [ID!]!) {
  nodes(ids: $ids) {
    ... on Product {
      id
      title
      handle
      featuredImage {
        url(transform: { maxWidth: 200 })
      }
      priceRange {
        minVariantPrice {
          amount
          currencyCode
        }
      }
      availableForSale
    }
  }
}

# Save wishlist
mutation SaveWishlist($metafields: [MetafieldsSetInput!]!) {
  metafieldsSet(metafields: $metafields) {
    metafields {
      id
    }
    userErrors {
      field
      message
    }
  }
}
```

## Ecosystem Connections

### Provides to Other Apps

| Consumer App | Data Provided | How |
|--------------|---------------|-----|
| Notify | Wishlisted product IDs | Read customer.metafield.custom.onec_wishlist |
| Analytics | Wishlist activity | Read metafield + webhook events |
| Upsell | Items not in cart | Read metafield at checkout |

### Consumes from Other Apps

| Provider App | Data Consumed | How |
|--------------|---------------|-----|
| Loyalty | VIP status for badges | Read customer.metafield.custom.onec_loyalty |
| Inventory | Stock status display | GraphQL inventory query |

## Webhooks

### Subscribe To
```toml
[[webhooks.subscriptions]]
topics = [
  "customers/data_request",
  "customers/redact",
  "shop/redact",
  "products/update",    # Price change detection
  "products/delete"     # Remove from wishlists
]
uri = "/webhooks"
```

### Webhook Handlers

```javascript
// products/update - Check for price drops
if (oldPrice > newPrice) {
  // Find customers who wishlisted this product
  // Trigger Notify app (if installed)
}

// products/delete - Clean up wishlists
// Remove product from all customer wishlists
```

## Theme Extension

### Block: Wishlist Button

**File:** `extensions/wishlist-button/blocks/wishlist-button.liquid`

```liquid
<div class="onec-wishlist-btn"
     data-product-id="{{ product.id }}"
     data-variant-id="{{ product.selected_or_first_available_variant.id }}"
     {{ block.shopify_attributes }}>
  <button class="onec-wishlist-btn__button" 
          aria-label="{{ 'wishlist.add' | t }}">
    <span class="onec-wishlist-btn__icon">
      {% render 'icon-heart' %}
    </span>
    {% if block.settings.show_text %}
      <span class="onec-wishlist-btn__text">
        {{ 'wishlist.add' | t }}
      </span>
    {% endif %}
  </button>
</div>

{% schema %}
{
  "name": "Wishlist Button",
  "target": "section",
  "settings": [
    {
      "type": "checkbox",
      "id": "show_text",
      "label": "Show text",
      "default": false
    },
    {
      "type": "color",
      "id": "icon_color",
      "label": "Icon color",
      "default": "#000000"
    },
    {
      "type": "color",
      "id": "active_color",
      "label": "Active color",
      "default": "#ff0000"
    }
  ]
}
{% endschema %}
```

## CLI Prerequisites

```bash
# Step 1: Initialize app
shopify app init
# Name: onecount-wishlist
# Template: Remix
# Language: JavaScript

# Step 2: Generate extensions
cd onecount-wishlist

# Theme App Extension
shopify app generate extension
# Type: Theme app extension
# Name: wishlist-button

# Customer Account UI
shopify app generate extension
# Type: Customer account UI extension
# Name: wishlist-account

# Admin Block (optional)
shopify app generate extension
# Type: Admin block
# Name: wishlist-admin

# Step 3: Start development
shopify app dev
```

## Pricing Tiers

| Tier | Price | Features |
|------|-------|----------|
| Free | $0 | 1 wishlist, 50 items max, basic button |
| Basic | $6.99/mo | 5 wishlists, unlimited items, sharing |
| Pro | $14.99/mo | Unlimited lists, analytics, Notify integration |
| Plus | $29.99/mo | All features, priority support, custom styling |

## Access Scopes Required

```toml
[access_scopes]
scopes = "read_products,read_customers,write_customers"
```

## App Store Checklist

- [ ] OAuth flow working
- [ ] GDPR webhooks implemented
- [ ] Privacy policy URL
- [ ] Support URL/email
- [ ] App icon (96x96px)
- [ ] Screenshots (3+)
- [ ] Demo video
- [ ] Proper error handling
- [ ] Rate limiting respected
