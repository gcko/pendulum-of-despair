# GAP-017: Shop has no Sell mode and no Buy/Sell/Exit entry prompt

| Field | Value |
|-------|-------|
| **ID** | GAP-017 |
| **Area** | Items/Economy |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | items, ui, tracker |

## Summary

shop_overlay is buy-only; there is no entry-mode menu and no sell flow (no 50% sell, no material sell_price, no equipped 'E' indicator/confirm, no quantity selector, no Sea Prince's Signet/Fenn's Seal modifiers).

## Current state (implementation)

Opening a shop jumps straight to a buy list. grep for 'sell' returns only sell_price field reads. Tracker acknowledges buy-only yet marks gap 3.4 'buy/sell interface' COMPLETE (false-completion).

## Desired state (per design)

Shop opens to Buy | Sell | Exit; Sell lists inventory at 50% buy / material sell_price, with E indicator + 'Sell anyway?' confirm, key/quest items hidden, quantity selector, and accessory modifiers applied.

## Proposed approach

Add an entry-mode state machine then a Sell sub-mode reading PartyState consumables/materials/owned_equipment; reuse a quantity widget; gate Sea Prince's Signet/Fenn's Seal off equipped accessories.

## Acceptance criteria

- [ ] Shop opens to a Buy/Sell/Exit prompt
- [ ] Selling yields 50% buy (or material sell_price)
- [ ] Equipped items warn before selling; key items are excluded
- [ ] Sea Prince's Signet/Fenn's Seal modifiers apply

## Design references

- docs/story/economy.md §Currency & Pricing (sell 50% buy; explicit material sell values)
- docs/story/ui-design.md §11.2/§11.4

## Code references

- game/scripts/ui/shop_overlay.gd:1-2,164-187

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
