# GAP-003: Status-effect infliction is never wired into combat actions

| Field | Value |
|-------|-------|
| **ID** | GAP-003 |
| **Area** | Combat |
| **Severity** | HIGH |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | resolved — #159 |
| **GitHub Issue** | [#159](https://github.com/gcko/pendulum-of-despair/issues/159) |
| **Source domains** | combat, tracker |

## Summary

roll_status() and apply_status() are implemented but have zero callers; no spell, ability, item, or enemy action ever inflicts Poison/Sleep/Silence/Petrify/Slow/Confusion/Despair, and the ATB never receives status-driven Stop/Sleep/Haste/Slow modifiers.

## Current state (implementation)

The two-stage status accuracy roll and party status container exist but are dead-ended. ATB frozen/status_mods plumbing exists with nothing feeding it. Boss debuffs (e.g. Marked for Sorrow) cannot be applied. Tracker flags this at game-dev-gaps.md:616.

## Desired state (per design)

Damaging/status spells, Tricks debuffs, and enemy abilities call roll_status then apply_status, set ATB frozen/status_mods for Stop/Sleep/Haste/Slow/Despair, and apply poison ticks, honoring boss immunity lists.

## Proposed approach

Add a status-application step to spell/ability/enemy resolution; map status names to ATB modifiers (set_status_mods/set_frozen) and to per-turn ticks in battle_state.tick_statuses.

## Acceptance criteria

- [ ] A poison spell inflicts poison and ticks damage each turn
- [ ] Stop/Sleep freeze the target's ATB gauge
- [ ] Boss immunity lists are respected
- [ ] Tests assert infliction success/failure across the two-stage roll

## Design references

- docs/story/combat-formulas.md §Status Effect Accuracy / §Status Spell Resolution
- docs/story/magic.md (status spells)

## Code references

- game/scripts/combat/damage_calculator.gd — `roll_status()` (the two-stage accuracy roll; called from both status paths in battle_actions.gd since #159)
- game/scripts/combat/battle_state.gd — `apply_status()` (the party-side application; called by execute_enemy_status)
- game/scripts/combat/battle_actions.gd — `apply_status_to_enemy()`, `execute_enemy_status()` (the party->enemy and enemy->party status paths that closed this gap)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** damage_calculator.gd:160 roll_status() has zero callers (grep found only the definition). battle_state.gd:136 apply_status() and enemy.gd:196 apply_status() both have zero call sites (grep for '.apply_status(' excluding defs returned nothing). battle_actions.gd magic/physical paths never invoke a status step. ATB frozen/status_mods setters exist (atb_system.gd:77,89) but nothing in combat feeds them.
- **Notes:** Confirmed dead-ended status pipeline. Not fixNow: needs status-application step across spell/ability/enemy resolution plus ATB modifier mapping and ticks — feature work with new tests.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
