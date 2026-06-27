# GAP-061: Equip stat comparison shows only 6 stats; missing HP/MP rows, EVA/MEVA/CRIT deltas, element/status info line

| Field | Value |
|-------|-------|
| **ID** | GAP-061 |
| **Area** | UI |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | ui |

## Summary

The equip panel compares only ATK/DEF/MAG/MDEF/SPD/LCK; EVA%/MEVA%/CRIT% deltas, conditional HP/MP rows, and the element/status info line are absent (info label hardcoded empty).

## Current state (implementation)

STAT_NAMES has 6 entries; Stat0-5 only; _info_label.text set to ''.

## Desired state (per design)

Comparison includes the 3 derived percentages and conditional HP/MP rows, plus a populated element/status info line.

## Proposed approach

Extend STAT_NAMES + .tscn rows and populate _info_label from equipment element/status fields (inline icons once GAP-059 lands).

## Acceptance criteria

- [ ] EVA/MEVA/CRIT deltas shown
- [ ] HP/MP rows appear when modified
- [ ] Element/status info line populated

## Design references

- docs/story/ui-design.md §5.6/§5.7

## Code references

- game/scripts/ui/menu_equip.gd:15-16,222-223
- game/scenes/overlay/menu.tscn:407-422

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
