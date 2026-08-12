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
| **GitHub Issue** | [#182](https://github.com/gcko/pendulum-of-despair/issues/182) |
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

**Re-verified by behavior search 2026-08-12 (#413): 0 of 4 met, nothing has
moved.** `shop_overlay.gd` is still the only script in `game/scripts/` that
mentions a shop, so no part of Buy mode has been extracted elsewhere.
`_build_list()` still emits one `Label` per row reading `"%s  %dG"` (name and
price, nothing else); `_update_selection()` only re-modulates the row and clears
feedback, so highlighting never populates `DescLabel`; and `_try_buy()` still
transacts a single unit. The nearest live stat-comparison code is
`menu_equip.gd` `_update_stat_comparison()`, which is menu-side and has no shop
caller — implementing this criterion means reusing it, not finding it already
wired.

## Design references

- docs/story/ui-design.md §11.3

## Code references

- game/scripts/ui/shop_overlay.gd — `_build_list()` (name+price labels), `_update_selection()` (highlight only, never fills DescLabel), `_show_feedback()` (the DescLabel reuse), `_try_buy()` (fixed quantity of 1)
- game/scripts/ui/menu_equip.gd — `_update_stat_comparison()`, the existing delta renderer this gap should reuse rather than reimplement
- game/scenes/overlay/shop_overlay.tscn


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** _build_list (shop_overlay.gd:148-151) emits plain labels: lbl.text = '%s  %dG' % [entry['name'], entry['buy_price']]. _show_feedback (193-198) reuses _desc_label ($Panel/VBox/DescLabel) for transient feedback. _try_buy (164-191) always purchases quantity 1. No stat-comparison panel, compat icons, affordability greying, or owned-qty exist.
- **Notes:** All sub-claims confirmed. Refined HIGH->MEDIUM: buying functions correctly; these are UX/polish enhancements, not a blocking defect. L-effort UI work.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
