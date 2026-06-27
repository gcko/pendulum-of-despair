# GAP-025: Random-encounter increment ignores act_scale and location_mod

| Field | Value |
|-------|-------|
| **ID** | GAP-025 |
| **Area** | Encounters |
| **Severity** | MEDIUM |
| **Type** | design-divergence |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | enemies |

## Summary

process_step hardcodes act_scale=1.0 and roll_increment has no location_mod term; only Ward/Infiltrator/Lure accessories are handled, so Act scaling and Veilstep/Tunnel Map/Kole/Ley Stag location modifiers are absent.

## Current state (implementation)

Correct for the Act I slice (act_scale=1.0) but diverges silently for later acts and the specified location systems.

## Desired state (per design)

final_increment = base x act_scale x accessory_mod x location_mod, with act_scale from story act and location_mod from active spell/key-item/quest effects.

## Proposed approach

Thread act_scale from GameManager/story state and a location_mod aggregator into roll_increment; extend the accessory-modifier path for spell/key-item modifiers.

## Acceptance criteria

- [ ] Increment includes act_scale and location_mod
- [ ] Veilstep/Tunnel Map reduce encounters
- [ ] Act II/Interlude scaling applies

## Design references

- docs/story/combat-formulas.md:807-833

## Code references

- game/scripts/core/encounter_handler.gd:14
- game/scripts/combat/encounter_system.gd:22-24,65-81


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** encounter_handler.gd:14 — roll_increment(base, 1.0, acc_mod) hardcodes act_scale=1.0. encounter_system.gd:23-24 — roll_increment(base_increment, act_scale, accessory_mod) has no location_mod parameter. get_accessory_modifier (lines 65-81) only handles ward_talisman/infiltrators_cloak (x0.5) and lure_talisman (x2.0). Design ref docs/story/combat-formulas.md:807-833 specifies final_increment = floor(base x act_scale x accessory_mod x location_mod) with Veilstep (x0.25), Tunnel Map (x0.5), Kole patrol (x0.5), and per-act scaling — none present in code.
- **Notes:** Accurate. Code is correct for the Act-I slice (act_scale=1.0) but diverges for later acts and location systems that are not yet in the vertical slice, so current practical impact is low. Fix requires threading act_scale from story state and a new location_mod aggregator (spell/key-item/quest effects) plus tests — new logic, not bounded. Not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
