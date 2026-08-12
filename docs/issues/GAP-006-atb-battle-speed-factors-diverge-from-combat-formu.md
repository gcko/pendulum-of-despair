# GAP-006: ATB battle-speed factors diverge from combat-formulas.md (~4x slower than documented)

| Field | Value |
|-------|-------|
| **ID** | GAP-006 |
| **Area** | Combat |
| **Severity** | HIGH (verified: MEDIUM) |
| **Type** | design-divergence |
| **Effort** | S |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#177](https://github.com/gcko/pendulum-of-despair/issues/177) |
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

- game/scripts/combat/atb_system.gd (SPEED_FACTORS)
- game/scripts/combat/atb_system.gd — `calculate_fill_rate()` (the formula the divergent constants feed)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** atb_system.gd:14-21 SPEED_FACTORS = {1:1.5,2:1.0,3:0.7,4:0.5,5:0.35,6:0.25}. combat-formulas.md 'Battle Speed Config' table = {1:6,2:5,3:3,4:2,5:1.5,6:1}. Formula shape matches: atb_system.gd:117 (spd+25)*factor*mods vs doc line 644 floor((SPD+25)*factor*mods); GAUGE_MAX=16000 matches doc. At speed 3, Maren SPD 8: doc (8+25)*3=99 -> 2.7s (matches doc table); code (8+25)*0.7=23 -> 16000/23/60=11.6s. Code comment (atb_system.gd:12-13) admits a deliberate retune to ~6-8s.
- **Notes:** Confirmed ~4x divergence. Not fixNow despite being a small constant change: it is a design decision (adopt doc constants vs canonicalize the retune), and changing SPEED_FACTORS would alter ATB pacing assertions in the GUT suite. Severity HIGH->MEDIUM: functionally playable, divergence is from documented pacing milestones, needs owner sign-off.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383); write what the file does hold instead. Always verify against current code before acting._
