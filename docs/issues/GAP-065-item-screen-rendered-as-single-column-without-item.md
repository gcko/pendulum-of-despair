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

- game/scenes/overlay/menu.tscn:280-300
- game/scripts/ui/menu_items.gd:202-237


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** menu.tscn:280 ItemContainer is a VBoxContainer holding single-column Label nodes Item0,Item1,... (text=''). menu_items.gd:217-220 renders '%s %s' % [name, ':qty'] text with no icons. Design ui-design.md:4.5 (lines 446-451) 'Two-column scrollable grid. Each entry: 8x8 pixel-art item icon + name + quantity (right-aligned)'.
- **Notes:** Confirmed single-column text list vs specified two-column icon grid. Depends on item icon atlas (relates to GAP-059). Not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The durable, maintained anchors are the file-plus-symbol bullets under **Code references**: those must name a file that exists and a symbol that file actually defines, and `scripts/quality-gates/check_stale_counts.py` fails the build if they do not. Always verify against current code before acting._
