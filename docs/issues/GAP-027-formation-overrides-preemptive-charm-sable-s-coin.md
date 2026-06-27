# GAP-027: Formation overrides (Preemptive Charm, Sable's Coin) not implemented

| Field | Value |
|-------|-------|
| **ID** | GAP-027 |
| **Area** | Encounters |
| **Severity** | LOW |
| **Type** | partial-impl |
| **Effort** | S |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#221](https://github.com/gcko/pendulum-of-despair/issues/221) |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** encounter_system.gd:51-59 — roll_formation(formation_rates: Dictionary) takes only formation_rates and rolls preemptive/back_attack/normal with no modifier path. grep for preemptive_charm/sables_coin across game/ finds no implementation (only unrelated 'sable' NPC dialogue metadata). Design ref docs/story/combat-formulas.md:859-863 specifies Preemptive Charm (+25pp to preemptive, deducted from back attack then normal) and Sable's Coin (guarantees preemptive next battle, no bosses).
- **Notes:** Accurate; back-attack/preemptive base roll is implemented but the two override mechanics are absent. Effort is small, but it is still a feature addition needing an optional modifier dict populated from equipped accessories / one-shot item flags plus wiring and tests. Marked not fixNow to avoid risk to the suite; a low-priority enhancement.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
