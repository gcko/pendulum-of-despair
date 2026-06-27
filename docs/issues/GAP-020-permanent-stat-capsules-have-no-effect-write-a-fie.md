# GAP-020: Permanent stat capsules have no effect (write a field nothing reads; wiped on level-up)

| Field | Value |
|-------|-------|
| **ID** | GAP-020 |
| **Area** | Items/Economy |
| **Severity** | HIGH |
| **Type** | bug |
| **Effort** | S |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#165](https://github.com/gcko/pendulum-of-despair/issues/165) |
| **Source domains** | items |

## Summary

stat_boost writes a top-level member field that get_effective_stat (base_stats + equipment) never reads, and the next level-up recalculation overwrites it; all 82 capsules are inert.

## Current state (implementation)

apply_item_effect sets member[stat_key]; get_effective_stat reads base_stats[stat]; the two never intersect, and calculate_stats_at_level replaces base_stats wholesale.

## Desired state (per design)

Capsules apply a persistent +1 surviving level-ups and reflected in effective stats.

## Proposed approach

Store gains in member['stat_capsules']; add into get_effective_stat and re-apply after level-up recalculation.

## Acceptance criteria

- [ ] Using a capsule raises the effective stat
- [ ] The boost survives a level-up
- [ ] Save round-trips capsule gains

## Design references

- docs/story/items.md §Stat Capsules (~82 permanent +1 boosts)

## Code references

- game/scripts/autoload/inventory_helpers.gd:105-110,217-220
- game/scripts/autoload/party_state.gd:287


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** inventory_helpers.gd stat_boost (104-110) writes target[stat_key]=current+boost (a top-level member field). party_state.gd get_effective_stat (283-292) reads m.get('base_stats',{}).get(stat,0)+equipment_bonus — never the top-level field. add_xp_to_member level-up (inventory_helpers.gd) calls calculate_stats_at_level then sets member['base_stats']=new_stats and member[stat_key]=new_stats.get(...), overwriting any capsule gain. Capsules are therefore inert and wiped on level-up.
- **Notes:** Confirmed bug. Although S-effort, the fix introduces a new persistent stat_capsules field that must be added into get_effective_stat, re-applied after level-up recalculation, and round-tripped through save — new logic with real risk to the stat/level/save test paths. fixNow FALSE.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
