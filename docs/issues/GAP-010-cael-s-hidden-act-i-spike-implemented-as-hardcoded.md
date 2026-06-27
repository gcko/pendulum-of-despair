# GAP-010: Cael's hidden Act I spike implemented as hardcoded +10% physical damage instead of ATK+2/MAG+2/SPD+1

| Field | Value |
|-------|-------|
| **ID** | GAP-010 |
| **Area** | Combat |
| **Severity** | LOW |
| **Type** | design-divergence |
| **Effort** | S |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | combat, progression |

## Summary

calculate_physical contains `if attacker_id=='cael': raw*=1.1`, a hardcoded character special-case that ignores MAG/SPD and violates the data-driven principle; design specifies +2 ATK / +2 MAG / +1 SPD to base stats.

## Current state (implementation)

The +10% physical multiplier is the only 'spike' present and diverges from design. Tracker records the divergent definition as complete.

## Desired state (per design)

Apply ATK+2/MAG+2/SPD+1 to Cael's base_stats on the appropriate Ember Vein flag (silently), and remove the 1.1x special case from damage_calculator.

## Proposed approach

Fold into the narrative-spike framework (GAP-013); drive from passive/trait data, delete the string-equality branch.

## Acceptance criteria

- [ ] damage_calculator has no character-name special case
- [ ] Cael gains +2 ATK/+2 MAG/+1 SPD via the spike system on the right flag
- [ ] No visible notification fires for the hidden spike

## Design references

- docs/story/progression.md:388
- docs/story/characters.md:49-50
- docs/story/combat-formulas.md:542 ('interactions are data-driven, not special-cased')

## Code references

- game/scripts/combat/damage_calculator.gd:45-47


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** damage_calculator.gd:45-47: '# Cael's Pallor Shimmer: +10% physical damage (permanent, hidden)' / 'if attacker_id == "cael":' / 'raw *= 1.1'. This is a hardcoded character-name special case; combat-formulas.md:542 states interactions should be data-driven not special-cased, and progression.md:388/characters.md:49-50 specify the spike as +2 ATK/+2 MAG/+1 SPD (not a flat 10% physical multiplier, and ignores MAG/SPD).
- **Notes:** Confirmed divergence. Not fixNow despite small footprint: a correct fix means removing the branch AND applying ATK+2/MAG+2/SPD+1 on the Ember Vein flag via the spike framework (GAP-013); a bare deletion would change combat output and very likely break a GUT test asserting the 1.1x behavior. Safer to do with the spike system and test updates.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
