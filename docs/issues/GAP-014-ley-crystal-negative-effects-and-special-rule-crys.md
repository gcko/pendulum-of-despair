# GAP-014: Ley Crystal negative effects and special-rule crystals have data but no mechanics

| Field | Value |
|-------|-------|
| **ID** | GAP-014 |
| **Area** | Progression |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | L |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | progression |

## Summary

Negative-effect crystals carry descriptive JSON and a UI warning but no mechanics: Frost Veil SPD-15%, Grey Remnant HP-40/level-up + 25% Pallor damage, Flame Heart self-flame, Storm Eye random-target are no-ops; Null Crystal Despair immunity and Cael's Echo character-specific bonuses are absent from data and code.

## Current state (implementation)

negative_effect blocks are description-only; the menu shows a warning string; combat references none of these crystals. Cael's Echo level_bonuses lack the Lira/Edren conditional bonuses.

## Desired state (per design)

Each negative/special effect is mechanically enforced (SPD penalty and Pallor-damage in combat, HP-loss-per-level in progression, Despair immunity in status, Cael's Echo conditional bonuses in data + get_equipment_bonus).

## Proposed approach

Add a negative_effect/special_rule handler keyed off the equipped crystal; hook SPD/Pallor multipliers into battle_state/damage_calculator, HP-loss into level-up, immunity into status; backfill Cael's Echo data. Mostly Act III/post-game scope.

## Acceptance criteria

- [ ] Frost Veil applies SPD-15% in battle
- [ ] Grey Remnant reduces HP on level-up and amplifies Pallor damage
- [ ] Null Crystal grants Despair immunity
- [ ] Cael's Echo grants Lira/Edren conditional bonuses

## Design references

- docs/story/progression.md:336-343,349-352

## Code references

- game/data/ley_crystals.json:352-462,567-573
- game/scripts/ui/menu_ley_crystal.gd:215-223
- game/scripts/combat/ (no negative_effect refs)

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
