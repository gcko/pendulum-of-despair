# GAP-006: ATB battle-speed factors diverge from combat-formulas.md (~4x slower than documented)

| Field | Value |
|-------|-------|
| **ID** | GAP-006 |
| **Area** | Combat |
| **Severity** | HIGH |
| **Type** | design-divergence |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | combat |

## Summary

Doc battle_speed_factor {1:6,2:5,3:3,4:2,5:1.5,6:1}; code SPEED_FACTORS {1:1.5,2:1.0,3:0.7,4:0.5,5:0.35,6:0.25}. Formula shape and GAUGE_MAX match but constants differ ~4x, contradicting every value in the doc's pacing tables.

## Current state (implementation)

At default speed 3 the doc yields fill_rate ~99 (~2.7s/turn); the code yields ~23 (~11.6s/turn). The code comment deliberately retunes to '~6-8s at speed 3'. Tracker marks the ATB formula COMPLETE (false-completion on constants).

## Desired state (per design)

SPEED_FACTORS match combat-formulas.md so the documented fill-rate and seconds-per-turn milestones hold, OR the design doc is formally revised with updated milestone tables.

## Proposed approach

Decide with design owner: adopt doc constants and verify pacing in-engine, or update combat-formulas.md Battle Speed/Pacing tables to canonicalize the retune.

## Acceptance criteria

- [ ] Code constants and doc tables agree (one is changed to match the other)
- [ ] In-engine seconds-per-turn at speed 3 matches the chosen spec
- [ ] Decision is recorded in the doc or a changelog

## Design references

- docs/story/combat-formulas.md §ATB Gauge System (Battle Speed Config table; ATB Pacing milestones)

## Code references

- game/scripts/combat/atb_system.gd:14-21 (SPEED_FACTORS)
- game/scripts/combat/atb_system.gd:112-117

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
