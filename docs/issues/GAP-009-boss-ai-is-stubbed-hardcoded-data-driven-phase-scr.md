# GAP-009: Boss AI is stubbed/hardcoded; data-driven phase scripts, telegraphs, and Ember Drake kit missing

| Field | Value |
|-------|-------|
| **ID** | GAP-009 |
| **Area** | Combat |
| **Severity** | MEDIUM |
| **Type** | design-divergence |
| **Effort** | L |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | combat, enemies, tracker |

## Summary

Only vein_guardian/drowned_sentinel/corrupted_fenmother are hardcoded; all other bosses fall through select_boss_action to a basic attack with the computed phase discarded (TODO). No telegraph/charge mechanic, no highest-threat targeting, no data-driven boss_ai interpreter, and the Ember Drake mini-boss has no kit.

## Current state (implementation)

battle_ai.gd:57 discards _get_boss_phase with a TODO; battle_enemy_turn.gd:69 branches on hardcoded enemy IDs (noted 'tech debt'). Crystal Slam targets randomly; no 'telegraph'/'charge' references exist. Ember Drake routes to generic weighted AI and only basic-attacks.

## Desired state (per design)

A data-driven boss-script interpreter keyed off the JSON phases array, with per-boss ability handlers, 1-turn charge/telegraph state, highest-threat targeting, and corrupted-Rally/amplification application.

## Proposed approach

Build boss_ai.gd interpreting phase triggers + scripted actions from bosses JSON; add a reusable two-phase charge/telegraph state; give Ember Drake a scripted/data kit. Prerequisite for the Acts II-IV epic. Depends on status/buff path (GAP-008).

## Acceptance criteria

- [ ] Boss behavior changes at phase HP thresholds from data, not hardcoded IDs
- [ ] At least one boss telegraphs a charge attack on turn N and resolves N+1
- [ ] Crystal Slam targets highest threat
- [ ] Ember Drake uses Flame Breath/Tail Swipe/Pounce

## Design references

- docs/story/bestiary/bosses.md (29+1 bosses, phase mechanics, 1-turn telegraphs, highest-threat targeting)
- docs/story/abilities.md §Cael (corrupted Rally patterns)

## Code references

- game/scripts/combat/battle_ai.gd:45-59,82-88,103-188
- game/scripts/combat/battle_enemy_turn.gd:69,101

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
