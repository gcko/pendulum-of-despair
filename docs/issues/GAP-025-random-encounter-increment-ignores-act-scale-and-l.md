# GAP-025: Random-encounter increment ignores act_scale and location_mod

| Field | Value |
|-------|-------|
| **ID** | GAP-025 |
| **Area** | Encounters |
| **Severity** | MEDIUM |
| **Type** | design-divergence |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
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

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
