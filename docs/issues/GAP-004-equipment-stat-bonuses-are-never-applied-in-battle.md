# GAP-004: Equipment stat bonuses are never applied in battle

| Field | Value |
|-------|-------|
| **ID** | GAP-004 |
| **Area** | Combat |
| **Severity** | HIGH (verified: LOW) |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | RESOLVED — already implemented (verification found no gap) |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** ALREADY_DONE
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** battle_state.gd:35 add_member calls _compute_effective_stats; battle_state.gd:285-291 _compute_effective_stats loops atk/def/mag/mdef/spd/lck and adds PartyState.get_equipment_bonus(character_id, stat) to base. party_state.gd:295-313 get_equipment_bonus sums weapon/head/body/accessory bonus_stats AND crystal bonuses. get_effective_stat (battle_state.gd:206-213) reads effective_stats for all combat math. The issue's premise ("grep for 'equip' in battle_state.gd returns nothing") is FALSE — battle_state.gd has 'equip' references at lines 18-19,205,283-290.
- **Notes:** Stale/wrong issue. Equipment AND crystal bonuses are baked into combat stats at battle start. Only caveat: I did not see an explicit progression.md stat-cap enforcement in this path, but the bonus-application gap claimed is already implemented. Recommend closing as already-done; optionally file a tiny follow-up if stat caps are required.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The durable, maintained anchors are the file-plus-symbol bullets under **Code references**: those must name a file that exists and a symbol that file actually defines, and `scripts/quality-gates/check_stale_counts.py` fails the build if they do not. Always verify against current code before acting._
