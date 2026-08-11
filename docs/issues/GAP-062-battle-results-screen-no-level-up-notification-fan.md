# GAP-062: Battle Results screen: no level-up notification/fanfare, no per-section advance, raw item_id shown

| Field | Value |
|-------|-------|
| **ID** | GAP-062 |
| **Area** | UI |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#208](https://github.com/gcko/pendulum-of-despair/issues/208) |
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
- game/scripts/util/inventory_helpers.gd:230-265
- game/scripts/core/exploration.gd:225


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** battle_ui.gd:229-243 _show_results dumps a single static block: 'EXP: %d', 'Gold: %d', and 'Found: %s' % drop.get('item_id') — raw item_id, no name/icon resolution, no per-section advance, no level-up branch (dismissed by single ui_accept at 247-253). inventory_helpers.gd:230-267 distribute_rewards computes and returns level_ups, but the caller chain PartyState.distribute_battle_rewards (party_state.gd:264) -> exploration.gd:225 discards the returned Dictionary (line 'PartyState.distribute_battle_rewards(rewards)' with no assignment). Design ui-design.md:2.8 and progression.md:240.
- **Notes:** Confirmed. Minor naming note: the issue says 'distribute_battle_rewards' (the PartyState wrapper) while the helper is distribute_rewards/apply_battle_rewards — substance is correct, level_ups is genuinely discarded. Sectioned state machine + level-up panel = significant new logic + tests; not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
