# GAP-027: Formation overrides (Preemptive Charm, Sable's Coin) not implemented

| Field | Value |
|-------|-------|
| **ID** | GAP-027 |
| **Area** | Encounters |
| **Severity** | LOW |
| **Type** | partial-impl |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | enemies |

## Summary

roll_formation takes only formation_rates; there is no Preemptive Charm (+25pp) or Sable's Coin (guaranteed preemptive) override.

## Current state (implementation)

No references to preemptive_charm or sables_coin anywhere; back-attack row swap is otherwise implemented.

## Desired state (per design)

roll_formation accepts modifier state so the charm shifts rates and the coin forces a preemptive next encounter.

## Proposed approach

Add an optional modifier dict (charm_bonus, force_preemptive) populated from equipped accessories / one-shot item flags.

## Acceptance criteria

- [ ] Preemptive Charm raises preemptive odds by 25pp
- [ ] Sable's Coin guarantees a preemptive next battle

## Design references

- docs/story/combat-formulas.md:859-863

## Code references

- game/scripts/combat/encounter_system.gd:51-59

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
