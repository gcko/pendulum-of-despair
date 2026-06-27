# GAP-071: Color-Blind Mode config toggle has no runtime effect

| Field | Value |
|-------|-------|
| **ID** | GAP-071 |
| **Area** | Save |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | save |

## Summary

color_blind_mode (off/deutan_protan/tritan) persists but is referenced nowhere else; no palette swaps for HP bars/status icons/poison/low-HP text and no live preview panel exist.

## Current state (implementation)

Only consumer is the setting definition.

## Desired state (per design)

Selecting a mode applies the palette swaps and the config screen shows the live preview (HP bar + status icons + mini Pallor sample).

## Proposed approach

Centralize palette lookup keyed on color_blind_mode and route HP bar/status icon/text-warning colors through it; add a preview group to the config scene.

## Acceptance criteria

- [ ] Each mode swaps the relevant palettes
- [ ] Config shows a live preview panel
- [ ] Setting persists and applies on load

## Design references

- docs/story/accessibility.md §2

## Code references

- game/scripts/ui/menu_config.gd:33-38

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
