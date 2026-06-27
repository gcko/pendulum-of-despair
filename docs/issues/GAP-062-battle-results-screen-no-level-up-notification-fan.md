# GAP-062: Battle Results screen: no level-up notification/fanfare, no per-section advance, raw item_id shown

| Field | Value |
|-------|-------|
| **ID** | GAP-062 |
| **Area** | UI |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | ui, progression |

## Summary

_show_results dumps a static block (EXP/Gold/'Found: <item_id>' raw id) with no per-section confirm, no drop icon/name resolution, and no level-up notification; distribute_battle_rewards' level_ups return value is discarded by every caller.

## Current state (implementation)

No level-up branch exists; item_id is shown verbatim; level_ups data is computed but ignored.

## Desired state (per design)

Results advance section-by-section, show drops with icon + resolved name, and present a level-up panel (name, new level, stat deltas, newly-learned abilities) with fanfare per design.

## Proposed approach

Consume the distribute_battle_rewards return; resolve item_id->name via DataManager; add a sectioned results state machine and a level-up sub-panel diffing stats and listing abilities learned in (old,new].

## Acceptance criteria

- [ ] Drops show resolved names (and icons when available)
- [ ] Results advance on confirm per section
- [ ] A level-up panel shows new level, stat deltas, and new abilities

## Design references

- docs/story/ui-design.md §2.8
- docs/story/progression.md:240

## Code references

- game/scripts/ui/battle_ui.gd:229-243
- game/scripts/autoload/inventory_helpers.gd:230-265
- game/scripts/core/exploration.gd:225

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
