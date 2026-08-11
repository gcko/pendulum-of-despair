# GAP-011: Ley Crystal progression uses a flat while-equipped bonus instead of permanent per-level-up accumulation (Esper/Magicite model)

| Field | Value |
|-------|-------|
| **ID** | GAP-011 |
| **Area** | Progression |
| **Severity** | HIGH |
| **Type** | design-divergence |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#161](https://github.com/gcko/pendulum-of-despair/issues/161) |
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
- game/scripts/util/inventory_helpers.gd — `add_xp_to_member()` level-up branch


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** party_state.gd:308-312 folds the crystal bonus into get_equipment_bonus() as a LIVE equipment bonus (`var crystal_id ... total += get_crystal_stat_bonus(crystal_id, stat, char_level)`), and get_crystal_stat_bonus() (party_state.gd:712-729) returns level_bonuses[level-1] each call. unequip_crystal() (party_state.gd:219-228) clears the slot and recalculates, stripping the bonus 100%. The level-up path inventory_helpers.gd:215-220 recomputes base_stats purely from `calculate_stats_at_level(base, growth, level)` with NO crystal accrual. Design progression.md:302-304 requires permanent per-level-up accrual that 'persist after unequipping the crystal'. The UI label 'On Lv Up: %s' at menu_ley_crystal.gd:212 implies an accrual model the code does not implement.
- **Notes:** Real Esper/Magicite-model divergence exactly as described. Fix is a feature: needs a persistent accrued-bonus dict, level-up hook, removal of crystal from get_equipment_bonus, and a save-schema migration plus tests. Not a bounded change; leave for game-designer implementation. Severity HIGH justified — it underpins Grey Remnant / Convergence Shard balance.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
