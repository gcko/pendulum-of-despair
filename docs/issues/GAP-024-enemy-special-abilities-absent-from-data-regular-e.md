# GAP-024: Enemy special abilities absent from data; regular-enemy AI can only basic-attack or defend

| Field | Value |
|-------|-------|
| **ID** | GAP-024 |
| **Area** | Enemies |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | No |
| **Status** | resolved — #166 |
| **GitHub Issue** | [#166](https://github.com/gcko/pendulum-of-despair/issues/166) |
| **Source domains** | enemies |

## Summary

No enemy has an abilities array, so the AI's 20% ability roll always falls through to defend (effective 70% attack / 30% defend); no designed kits (Poison, Frenzy, Flame Breath AoE, Pack Howl, swarm-on-death) exist and enemy actions never inflict status.

## Current state (implementation)

grep '"abilities"' in enemy data returns nothing; battle_actions never calls enemy.apply_status. Tracker admits the apply path is unwired but doesn't track the missing ability data.

## Desired state (per design)

Each enemy carries its designed ability list (id, target, element, power, status, rate); the AI selects and resolves them, inflicting status (via roll_status), handling multi-hit, AoE-on-death, and pack buffs.

## Proposed approach

Add an abilities schema to enemy JSON (Act I families first), populate from palette-families.md/act-i.md, wire battle_actions to resolve effects + call apply_status, and handle AoE-on-death and group buffs. Depends on GAP-003.

## Acceptance criteria

- [ ] Act-I enemies have populated ability lists
- [ ] Enemies inflict status and use multi-hit attacks
- [ ] Unstable Crystal's Shard Burst fires on death
- [ ] Pack/group buffs function

## Design references

- docs/story/bestiary/palette-families.md (per-family 'New Abilities')
- docs/story/bestiary/act-i.md:104-107

## Code references

- game/data/enemies/act_i.json — 19 of its 27 entries carry a populated `abilities` array (#166). Of the 8 without, 4 carry a `boss_ai` phase script instead (ember_drake, vein_guardian, drowned_sentinel, corrupted_fenmother) and 4 carry neither (the_flickering, bog_leech, compact_patrol, compact_scout)
- game/scripts/combat/battle_ai.gd — `select_action()` (the 20% ability roll, which now reads those arrays instead of falling through to defend)
- game/scripts/combat/battle_actions.gd — `apply_status_to_enemy()` (the status path enemy abilities resolve through)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** grep '"abilities"' game/data/enemies/act_i.json returns 0 matches across all 27 entries. battle_ai.gd:30-36 — the 20% ability branch reads enemy_data.get('abilities', []) and, when empty, falls through to the 10% defend branch (line 38-39), so regular enemies are effectively 70% attack / 30% defend. battle_actions.gd has 0 matches for apply_status/roll_status, so enemy actions never inflict status. Scripted boss AI (Vein Guardian, Drowned Sentinel, Corrupted Fenmother) is hardcoded in battle_ai.gd:103-188 and does not use a data-driven ability schema. Design ref docs/story/bestiary/palette-families.md confirms per-family ability kits are designed.
- **Notes:** Real and significant. Large feature: requires a new JSON ability schema, data population from the bestiary, and wiring apply_status/roll_status + AoE-on-death + pack buffs into battle_actions — clear new logic and new tests, would meaningfully touch the GUT suite. Not safe to fix now. Issue notes a dependency on GAP-003.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
