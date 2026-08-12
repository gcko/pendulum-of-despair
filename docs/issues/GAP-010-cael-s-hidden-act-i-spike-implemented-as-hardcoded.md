# GAP-010: Cael's hidden Act I spike implemented as hardcoded +10% physical damage instead of ATK+2/MAG+2/SPD+1

| Field | Value |
|-------|-------|
| **ID** | GAP-010 |
| **Area** | Combat |
| **Severity** | LOW |
| **Type** | design-divergence |
| **Effort** | S |
| **Epic** | No |
| **Status** | resolved — #219 |
| **GitHub Issue** | [#219](https://github.com/gcko/pendulum-of-despair/issues/219) |
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
- docs/story/combat-formulas.md § Implementation Architecture ('interactions are data-driven, not special-cased')

## Code references

- game/scripts/combat/damage_calculator.gd — `calculate_physical()` (where the hardcoded character special-case sat)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** damage_calculator.gd:45-47: '# Cael's Pallor Shimmer: +10% physical damage (permanent, hidden)' / 'if attacker_id == "cael":' / 'raw *= 1.1'. This is a hardcoded character-name special case; combat-formulas.md § Implementation Architecture states interactions should be data-driven not special-cased, and progression.md:388/characters.md:49-50 specify the spike as +2 ATK/+2 MAG/+1 SPD (not a flat 10% physical multiplier, and ignores MAG/SPD).
- **Notes:** Confirmed divergence. Not fixNow despite small footprint: a correct fix means removing the branch AND applying ATK+2/MAG+2/SPD+1 on the Ember Vein flag via the spike framework (GAP-013); a bare deletion would change combat output and very likely break a GUT test asserting the 1.1x behavior. Safer to do with the spike system and test updates.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
