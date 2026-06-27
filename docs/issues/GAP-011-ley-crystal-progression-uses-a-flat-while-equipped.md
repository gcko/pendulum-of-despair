# GAP-011: Ley Crystal progression uses a flat while-equipped bonus instead of permanent per-level-up accumulation (Esper/Magicite model)

| Field | Value |
|-------|-------|
| **ID** | GAP-011 |
| **Area** | Progression |
| **Severity** | HIGH |
| **Type** | design-divergence |
| **Effort** | L |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | progression |

## Summary

Crystal bonuses are applied live while equipped and stripped 100% on unequip; hp/mp grant the full retroactive bonus instantly. The designed FF6 model (permanent gains accrued at each level-up, persisting after unequip) is absent, breaking the Grey Remnant/Convergence Shard balance models built on accumulation.

## Current state (implementation)

get_crystal_stat_bonus returns level_bonuses[level-1] as a live equipment bonus; unequip removes it entirely; add_xp_to_member never accumulates crystal bonuses on level-up. The detail UI even labels 'On Lv Up: ATK +2' implying a model the code doesn't perform.

## Desired state (per design)

Each level-up while a crystal is equipped grants that crystal-level's bonus permanently (added to base_stats), persisting after unequip; equipping grants no retroactive bonus for past levels.

## Proposed approach

On level-up, if a crystal is equipped, add its current-level bonus to a persistent per-character accrued-bonus dict (separate from base_stats); stop applying crystal bonuses via get_equipment_bonus; fold the accrued dict into get_effective_stat/max_hp; migrate save schema.

## Acceptance criteria

- [ ] Leveling up with a crystal equipped permanently raises stats
- [ ] Unequipping retains accrued gains
- [ ] Equipping grants no retroactive past-level bonus
- [ ] Save round-trips accrued crystal gains; tests cover accrual + persistence

## Design references

- docs/story/progression.md:304-306,370,374

## Code references

- game/scripts/autoload/party_state.gd:710-729,295-313,219-229
- game/scripts/autoload/inventory_helpers.gd:193-223

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
