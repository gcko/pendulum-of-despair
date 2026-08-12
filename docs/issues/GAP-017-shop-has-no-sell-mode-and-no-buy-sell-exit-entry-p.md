# GAP-017: Shop has no Sell mode and no Buy/Sell/Exit entry prompt

| Field | Value |
|-------|-------|
| **ID** | GAP-017 |
| **Area** | Items/Economy |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#163](https://github.com/gcko/pendulum-of-despair/issues/163) |
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

- game/scripts/ui/shop_overlay.gd


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** shop_overlay.gd is buy-only: _build_list (138-151) opens straight to a buy list, _try_buy (164-191) always calls add_item(iid,1)/add_equipment with no sell path. No 'sell' logic, no Buy/Sell/Exit entry menu, no quantity selector. Tracker game-dev-gaps.md:672 marks '[x] Shop buy/sell interface — buy-only via shop_overlay.gd' (false-completion: checkbox ticked despite buy-only).
- **Notes:** L-effort feature requiring a new entry-mode state machine and sell sub-mode. Not bounded for a safe in-place fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
