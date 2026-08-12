# GAP-005: 12 dual-tech combos are entirely unimplemented (combos.json unused)

| Field | Value |
|-------|-------|
| **ID** | GAP-005 |
| **Area** | Combat |
| **Severity** | HIGH (verified: MEDIUM) |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#176](https://github.com/gcko/pendulum-of-despair/issues/176) |
| **Source domains** | combat, tracker |

## Summary

combos.json holds all 12 dual techs but no code references combo/dual_tech; there is no Combo command, no full-ATB detection, no MP split, and no story-driven availability.

## Current state (implementation)

The command menu offers only Attack/Magic/Ability/Item/Defend/Flee. grep for combo/dual_tech across scripts/scenes returns nothing.

## Desired state (per design)

When the actor and another ally both have full ATB, a Combo option lists available dual techs; selecting one resolves the combined effect, splits MP, resets both gauges, and honors story availability (Shield Oath/Promise of Dawn loss, Cael's Echo unlock).

## Proposed approach

Add a Combo command querying ATB for full-gauge allies, cross-reference combos.json, dispatch to combo-effect handlers. Depends on ability/buff/device subsystems (GAP-002).

## Acceptance criteria

- [ ] Combo appears only when two contributors have full ATB
- [ ] Selecting a combo resolves combined effect and resets both gauges
- [ ] MP is split per design and story-locked combos are hidden
- [ ] A test triggers a combo from a two-full-gauge state

## Design references

- docs/story/abilities.md §2 (12 dual techs, MP split, 'both gauges full' trigger, Combos Lost to Story)

## Code references

- game/data/abilities/combos.json (unloaded)
- game/scripts/ui/battle_command_menu.gd (no Combo option)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** grep -rni 'combo|dual_tech' over scripts/ and scenes/ returned nothing. combos.json exists (game/data/abilities/combos.json, 6.3K) but is referenced nowhere in code (grep 'combos' in scripts/scenes found no loader). battle_command_menu.gd:45-52 offers only Attack/Magic/<Ability>/Item/Defend/Flee — no Combo option.
- **Notes:** Confirmed unimplemented. Severity refined HIGH->MEDIUM: it is missing content but not blocking the slice's core loop; depends on GAP-002 subsystems. Not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383); write what the file does hold instead. Always verify against current code before acting._
