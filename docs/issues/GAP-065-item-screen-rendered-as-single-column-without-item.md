# GAP-065: Item screen rendered as single column without item icons (design specifies two-column grid)

| Field | Value |
|-------|-------|
| **ID** | GAP-065 |
| **Area** | UI |
| **Severity** | LOW |
| **Type** | design-divergence |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#229](https://github.com/gcko/pendulum-of-despair/issues/229) |
| **Source domains** | ui |

## Summary

The item list is a single VBoxContainer of 12 labels rendering 'name :qty' with no icons; the design specifies a two-column grid with 8x8 icon + name + right-aligned quantity.

## Current state (implementation)

ItemContainer is a one-column VBox; menu_items renders text only.

## Desired state (per design)

Two-column item grid with 8x8 icons and right-aligned quantities.

## Proposed approach

Convert ItemContainer to a 2-column GridContainer with icon TextureRects per cell (depends on item icon atlas).

## Acceptance criteria

- [ ] Items render in a two-column grid
- [ ] Each cell shows an icon, name, and quantity
- [ ] Quantity is right-aligned

## Design references

- docs/story/ui-design.md §4.2/§4.5

## Code references

- game/scenes/overlay/menu.tscn
- game/scripts/ui/menu_items.gd


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** menu.tscn:280 ItemContainer is a VBoxContainer holding single-column Label nodes Item0,Item1,... (text=''). menu_items.gd:217-220 renders '%s %s' % [name, ':qty'] text with no icons. Design ui-design.md:4.5 (lines 446-451) 'Two-column scrollable grid. Each entry: 8x8 pixel-art item icon + name + quantity (right-aligned)'.
- **Notes:** Confirmed single-column text list vs specified two-column icon grid. Depends on item icon atlas (relates to GAP-059). Not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383); write what the file does hold instead. Always verify against current code before acting._
