# GAP-004: Equipment stat bonuses are never applied in battle

| Field | Value |
|-------|-------|
| **ID** | GAP-004 |
| **Area** | Combat |
| **Severity** | HIGH |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | tracker, combat |

## Summary

battle_state builds combatant stats from base character JSON only; equipped weapon/armor/accessory bonus_stats have zero effect on combat math even though the Equipment screen shows stat deltas.

## Current state (implementation)

grep for 'equipment'/'equip' in battle_state.gd returns nothing. Gap 3.4 (Equipment screen) is marked COMPLETE, implying functional equipment, but equipped gear does not flow into battle damage/defense.

## Desired state (per design)

Battle stat resolution sums base stats + equipped bonus_stats (capped per progression.md) before computing damage, so the equipment screen's deltas are real in combat.

## Proposed approach

In battle_state combatant construction, pull PartyState equipped IDs, look up bonus_stats via DataManager, and add to derived combat stats.

## Acceptance criteria

- [ ] Equipping a +ATK weapon raises physical damage output
- [ ] Armor DEF/MDEF reduces incoming damage
- [ ] Stat caps from progression.md are enforced
- [ ] A test asserts an equipped bonus changes a damage result

## Design references

- docs/story/equipment.md (bonus_stats per piece)
- docs/story/combat-formulas.md (ATK/DEF/MAG drive damage)

## Code references

- game/scripts/combat/battle_state.gd (no 'equip' references)

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
