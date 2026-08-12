# GAP-027: Formation overrides (Preemptive Charm, Sable's Coin) not implemented

| Field | Value |
|-------|-------|
| **ID** | GAP-027 |
| **Area** | Encounters |
| **Severity** | LOW |
| **Type** | partial-impl |
| **Effort** | S |
| **Epic** | No |
| **Status** | resolved — PR #268 |
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

- docs/story/combat-formulas.md § Battle Formations

## Code references

- game/scripts/combat/encounter_system.gd — `roll_formation()`


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** encounter_system.gd:51-59 — roll_formation(formation_rates: Dictionary) takes only formation_rates and rolls preemptive/back_attack/normal with no modifier path. grep for preemptive_charm/sables_coin across game/ finds no implementation (only unrelated 'sable' NPC dialogue metadata). Design ref docs/story/combat-formulas.md § Battle Formations specifies Preemptive Charm (+25pp to preemptive, deducted from back attack then normal) and Sable's Coin (guarantees preemptive next battle, no bosses).
- **Notes:** Accurate; back-attack/preemptive base roll is implemented but the two override mechanics are absent. Effort is small, but it is still a feature addition needing an optional modifier dict populated from equipped accessories / one-shot item flags plus wiring and tests. Marked not fixNow to avoid risk to the suite; a low-priority enhancement.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Always verify against current code before acting._

## Resolution (PR #268, 2026-07-19)

`apply_preemptive_bonus` (+25pp, back-attack deducted first, non-stacking) and the `sables_coin_active` EventFlag (consumed at the forced roll, random encounters only, never read by the boss path, re-use refused while active) shipped with full test coverage.
