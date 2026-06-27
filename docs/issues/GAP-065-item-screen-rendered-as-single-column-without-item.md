# GAP-065: Item screen rendered as single column without item icons (design specifies two-column grid)

| Field | Value |
|-------|-------|
| **ID** | GAP-065 |
| **Area** | UI |
| **Severity** | LOW |
| **Type** | design-divergence |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
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

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
