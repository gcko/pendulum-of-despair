# GAP-022: Caldera Employee Card 25% discount not applied at runtime

| Field | Value |
|-------|-------|
| **ID** | GAP-022 |
| **Area** | Items/Economy |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | items |

## Summary

Caldera shops use markup 1.5 with pre-multiplied prices; the Employee Card key item is never checked, so the 25% discount (net 112.5%) is never granted.

## Current state (implementation)

_try_buy charges the raw buy_price; no employee_card/markup-discount references exist.

## Desired state (per design)

Holding the Caldera Employee Card reduces all Caldera-shop prices 25%.

## Proposed approach

In shop_overlay, when shop.markup>1.0 and PartyState has caldera_employee_card, apply a 0.75 multiplier.

## Acceptance criteria

- [ ] With the card, Caldera prices drop 25%
- [ ] Without it, full inflated prices apply
- [ ] Non-Caldera shops are unaffected

## Design references

- docs/story/economy.md §Caldera Inflation
- docs/story/items.md §Story Items

## Code references

- game/scripts/ui/shop_overlay.gd:164-187
- game/data/shops/caldera_company_store.json:6

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
