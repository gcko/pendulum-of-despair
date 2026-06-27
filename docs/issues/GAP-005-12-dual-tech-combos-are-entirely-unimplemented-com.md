# GAP-005: 12 dual-tech combos are entirely unimplemented (combos.json unused)

| Field | Value |
|-------|-------|
| **ID** | GAP-005 |
| **Area** | Combat |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | combat, tracker |

## Summary

combos.json holds all 12 dual techs but no code references combo/dual_tech; there is no Combo command, no full-ATB detection, no MP split, and no story-driven availability.

## Current state (implementation)

The command menu offers only Attack/Magic/Ability/Item/Defend/Flee. grep for combo/dual_tech across scripts/scenes returns nothing.

## Desired state (per design)

When the actor and another ally both have full ATB, a Combo option lists available dual techs; selecting one resolves the combined effect, splits MP, resets both gauges, and honors story availability (Shield Oath/Promise of Dawn loss, Cael's Echo unlock).

## Proposed approach

Add a Combo command querying ATB for full-gauge allies, cross-reference combos.json, dispatch to combo-effect handlers. Depends on ability/buff/device subsystems (GAP-002).

## Acceptance criteria

- [ ] Combo appears only when two contributors have full ATB
- [ ] Selecting a combo resolves combined effect and resets both gauges
- [ ] MP is split per design and story-locked combos are hidden
- [ ] A test triggers a combo from a two-full-gauge state

## Design references

- docs/story/abilities.md §2 (12 dual techs, MP split, 'both gauges full' trigger, Combos Lost to Story)

## Code references

- game/data/abilities/combos.json (unloaded)
- game/scripts/ui/battle_command_menu.gd:45-52 (no Combo option)

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
