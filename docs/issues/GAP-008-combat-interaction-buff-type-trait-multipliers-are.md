# GAP-008: Combat interaction/buff/type-trait multipliers are never applied (damage_calculator params always neutral)

| Field | Value |
|-------|-------|
| **ID** | GAP-008 |
| **Area** | Combat |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#178](https://github.com/gcko/pendulum-of-despair/issues/178) |
| **Source domains** | combat, enemies |

## Summary

Every combat caller passes interaction_mult=1.0 and buff/reduction=[], so no Tier 1-3 interactions (Frozen Shatter, Conductive Water, Grounded), no Resonance/Glintmark/Overcharge, no amplification debuffs, and no enemy type traits (Spirit physical -50%, Undead heal-to-damage, Construct/Pallor/Elemental interaction stacking) ever take effect.

## Current state (implementation)

damage_calculator accepts the multiplier params but callers pass neutral values. enemy.gd derives only status immunities from type; heal() heals Undead instead of damaging. Tracker narrows 'type rules' to status immunities (false-completion of gap 2.3).

## Desired state (per design)

Active statuses/buffs/equipment/devices and enemy type contribute interaction/buff/reduction multipliers into damage calls, with type bonuses (1.25x/1.5x) stacking multiplicatively with Weak/Resist per the README stacking rule.

## Proposed approach

Add a buff/status/type aggregation layer that, at attack time, collects modifiers for attacker and target (incl. Spirit pre-DEF 0.5, Undead heal->damage/revive->maxdamage, Elemental absorb-own-element, Pallor regen, Boss overkill-discard) and passes them to damage_calculator. Depends on status/ability subsystems.

## Acceptance criteria

- [ ] Spirit enemies take 50% physical pre-DEF; Undead are damaged by heal magic
- [ ] Type interaction bonus stacks multiplicatively with element weakness (e.g. 2.25x)
- [ ] Resonance/amplification buffs alter spell damage
- [ ] Tests cover at least one interaction per tier

## Design references

- docs/story/combat-formulas.md §Combat Interactions & Hidden Synergies / §Buff & Debuff Interaction
- docs/story/bestiary/README.md:49-135 (Enemy Type Rules; multiplicative stacking)

## Code references

- game/scripts/combat/battle_actions.gd
- game/scripts/combat/damage_calculator.gd
- game/scripts/entities/enemy.gd


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** battle_actions.gd:60 calculate_physical called with interaction_mult=1.0 and reduction_sources=[] (lines 51-64); battle_actions.gd:99 calculate_magic(mag,power,mdef,element_mod,1.0,[],[]) — interaction_mult=1.0, buff_mults=[], reduction=[]. damage_calculator.gd:21-79/90-127 accept these params but callers always pass neutral. enemy.gd type handling derives only status immunities; heal() heals rather than damaging Undead.
- **Notes:** Confirmed neutral-multiplier wiring; no Tier 1-3 interactions, resonance, or enemy type traits applied. Severity MEDIUM appropriate. Depends on status/ability subsystems (GAP-003). Not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Always verify against current code before acting._
