# GAP-018: Shop Buy mode missing descriptions, stat comparison, compat icons, affordability greying, owned-qty, quantity selector

| Field | Value |
|-------|-------|
| **ID** | GAP-018 |
| **Area** | Items/Economy |
| **Severity** | HIGH (verified: MEDIUM) |
| **Type** | partial-impl |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | ui |

## Summary

Buy list renders only 'name price' labels; DescLabel is reused for transient feedback, with no item description, no equipment stat-comparison panel, no party compat icons, no unaffordable greying, no owned-quantity, and a fixed quantity of 1.

## Current state (implementation)

_build_list emits plain labels; _show_feedback overwrites the desc; _try_buy always adds quantity 1; no stat panel exists.

## Desired state (per design)

Buy mode shows highlighted item description with inline icons, a green/red stat-delta panel with party cycling, lit/dim compat sprites, grey pricing when unaffordable, owned-qty in parens, and a 1-99 quantity selector with live total.

## Proposed approach

Extend shop_overlay.tscn with a selection-bound description line, an equipment comparison panel (reuse menu_equip projection), a compat icon row, and a quantity sub-state; grey rows when buy_price > gold.

## Acceptance criteria

- [ ] Highlighting an item shows its description
- [ ] Equipment shows stat deltas vs current gear
- [ ] Unaffordable items are greyed; owned quantity shown
- [ ] Consumables support 1-99 quantity with live total

## Design references

- docs/story/ui-design.md §11.3

## Code references

- game/scripts/ui/shop_overlay.gd:138-186
- game/scenes/overlay/shop_overlay.tscn


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** _build_list (shop_overlay.gd:148-151) emits plain labels: lbl.text = '%s  %dG' % [entry['name'], entry['buy_price']]. _show_feedback (193-198) reuses _desc_label ($Panel/VBox/DescLabel) for transient feedback. _try_buy (164-191) always purchases quantity 1. No stat-comparison panel, compat icons, affordability greying, or owned-qty exist.
- **Notes:** All sub-claims confirmed. Refined HIGH->MEDIUM: buying functions correctly; these are UX/polish enhancements, not a blocking defect. L-effort UI work.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
