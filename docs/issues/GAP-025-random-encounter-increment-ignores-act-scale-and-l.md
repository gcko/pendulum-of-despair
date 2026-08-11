# GAP-025: Random-encounter increment ignores act_scale and location_mod

| Field | Value |
|-------|-------|
| **ID** | GAP-025 |
| **Area** | Encounters |
| **Severity** | MEDIUM |
| **Type** | design-divergence |
| **Effort** | M |
| **Epic** | No |
| **Status** | resolved — PR #268 |
| **GitHub Issue** | [#185](https://github.com/gcko/pendulum-of-despair/issues/185) |
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

- docs/story/combat-formulas.md § Danger Counter

## Code references

- game/scripts/core/encounter_handler.gd
- game/scripts/combat/encounter_system.gd


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** encounter_handler.gd:14 — roll_increment(base, 1.0, acc_mod) hardcodes act_scale=1.0. encounter_system.gd:23-24 — roll_increment(base_increment, act_scale, accessory_mod) has no location_mod parameter. get_accessory_modifier (lines 65-81) only handles ward_talisman/infiltrators_cloak (x0.5) and lure_talisman (x2.0). Design ref docs/story/combat-formulas.md § Danger Counter specifies final_increment = floor(base x act_scale x accessory_mod x location_mod) with Veilstep (x0.25), Tunnel Map (x0.5), Kole patrol (x0.5), and per-act scaling — none present in code.
- **Notes:** Accurate. Code is correct for the Act-I slice (act_scale=1.0) but diverges for later acts and location systems that are not yet in the vertical slice, so current practical impact is low. Fix requires threading act_scale from story state and a new location_mod aggregator (spell/key-item/quest effects) plus tests — new logic, not bounded. Not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Always verify against current code before acting._

## Resolution (PR #268, 2026-07-19)

`roll_increment` implements `floor(base x act_scale x accessory_mod x location_mod)`; the new `StoryAct` helper supplies the act scale from EventFlags, and a flag-gated `location_mods` JSON hook covers Tunnel Map / Kole-style modifiers (entries authored for Bellhaven Tunnels + Corrund Sewers). Veilstep deferred to #262; Tunnel Map item authoring to #263; Ley Stag suppression to #264.
