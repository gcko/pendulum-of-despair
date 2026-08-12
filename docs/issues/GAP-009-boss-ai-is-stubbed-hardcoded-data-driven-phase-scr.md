# GAP-009: Boss AI is stubbed/hardcoded; data-driven phase scripts, telegraphs, and Ember Drake kit missing

| Field | Value |
|-------|-------|
| **ID** | GAP-009 |
| **Area** | Combat |
| **Severity** | MEDIUM |
| **Type** | design-divergence |
| **Effort** | L |
| **Epic** | No |
| **Status** | resolved — #179 |
| **GitHub Issue** | [#179](https://github.com/gcko/pendulum-of-despair/issues/179) |
| **Source domains** | combat, enemies, tracker |

## Summary

Only vein_guardian/drowned_sentinel/corrupted_fenmother are hardcoded; all other bosses fall through select_boss_action to a basic attack with the computed phase discarded (TODO). No telegraph/charge mechanic, no highest-threat targeting, no data-driven boss_ai interpreter, and the Ember Drake mini-boss has no kit.

## Current state (implementation)

battle_ai.gd:57 discards _get_boss_phase with a TODO; battle_enemy_turn.gd:69 branches on hardcoded enemy IDs (noted 'tech debt'). Crystal Slam targets randomly; no 'telegraph'/'charge' references exist. Ember Drake routes to generic weighted AI and only basic-attacks.

## Desired state (per design)

A data-driven boss-script interpreter keyed off the JSON phases array, with per-boss ability handlers, 1-turn charge/telegraph state, highest-threat targeting, and corrupted-Rally/amplification application.

## Proposed approach

Build boss_ai.gd interpreting phase triggers + scripted actions from bosses JSON; add a reusable two-phase charge/telegraph state; give Ember Drake a scripted/data kit. Prerequisite for the Acts II-IV epic. Depends on status/buff path (GAP-008).

## Acceptance criteria

- [ ] Boss behavior changes at phase HP thresholds from data, not hardcoded IDs
- [ ] At least one boss telegraphs a charge attack on turn N and resolves N+1
- [ ] Crystal Slam targets highest threat
- [ ] Ember Drake uses Flame Breath/Tail Swipe/Pounce

## Design references

- docs/story/bestiary/bosses.md (29+1 bosses, phase mechanics, 1-turn telegraphs, highest-threat targeting)
- docs/story/abilities.md §Cael (corrupted Rally patterns)

## Code references

- game/scripts/combat/boss_ai.gd — `has_script()`, `select_action()` (the data-driven phase interpreter that resolved this; the boss path left battle_ai.gd, which now handles regular enemies only)
- game/scripts/combat/battle_enemy_turn.gd — `_select_action()` (the boss-vs-regular AI dispatch)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** battle_ai.gd:42 'Select boss action (stub — returns basic attack)'; select_boss_action (lines 45-60) calls _get_boss_phase then '_get_boss_phase(...)  # TODO: use for scripted AI' (line ~58) discarding the phase and returns {type:'attack'}. battle_enemy_turn.gd:69-83 hardcodes is_boss && eid=='vein_guardian'/'drowned_sentinel'/'corrupted_fenmother' branches; all other bosses fall to select_boss_action stub. grep 'ember|drake|telegraph|charge' in scripts/combat found no Ember Drake kit, telegraph, or charge mechanic.
- **Notes:** Confirmed. Only 3 bosses hardcoded; data-driven phase interpreter, telegraphs, highest-threat targeting, and Ember Drake kit all missing. Severity MEDIUM (Act-I slice has the 3 implemented bosses working). Not fixNow — large subsystem.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
