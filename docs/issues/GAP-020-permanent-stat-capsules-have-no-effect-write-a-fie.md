# GAP-020: Permanent stat capsules have no effect (write a field nothing reads; wiped on level-up)

| Field | Value |
|-------|-------|
| **ID** | GAP-020 |
| **Area** | Items/Economy |
| **Severity** | HIGH |
| **Type** | bug |
| **Effort** | S |
| **Epic** | No |
| **Status** | resolved — #165 |
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

- game/scripts/util/inventory_helpers.gd — `apply_item_effect()` stat_boost arm
- game/scripts/util/progression_helpers.gd — `add_xp_to_member()` level-up overwrite
- game/scripts/autoload/party_state.gd — `get_effective_stat()` (the reader that ignored the capsule field)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** the `stat_boost` arm of `inventory_helpers.gd` `apply_item_effect()` writes target[stat_key]=current+boost (a top-level member field). `party_state.gd` `get_effective_stat()` reads m.get('base_stats',{}).get(stat,0)+equipment_bonus — never the top-level field. The level-up path `add_xp_to_member()` calls calculate_stats_at_level then sets member['base_stats']=new_stats and member[stat_key]=new_stats.get(...), overwriting any capsule gain. Capsules are therefore inert and wiped on level-up.
- **Notes:** Confirmed bug. Although S-effort, the fix introduces a new persistent stat_capsules field that must be added into get_effective_stat, re-applied after level-up recalculation, and round-tripped through save — new logic with real risk to the stat/level/save test paths. fixNow FALSE.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
