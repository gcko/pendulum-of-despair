# GAP-044: Sidequest system entirely absent: no schema, no journal, 0 of 26 quests wired (givers already placed)

| Field | Value |
|-------|-------|
| **ID** | GAP-044 |
| **Area** | Story |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#172](https://github.com/gcko/pendulum-of-despair/issues/172) |
| **Source domains** | story |

## Summary

No quest schema, journal UI, or quest state exists; none of the 26 sidequests are implemented even though 5 quest-giver NPCs (Cordwyn, Mirren, Aldis, Vessa, Marek) are already placed and offer only ambient dialogue.

## Current state (implementation)

find game/data -iname '*quest*' is empty; quest reward IDs (Marek's Discipline, Hadley's Bell) don't resolve. Tracker lumps all sidequests into epic 4.5 without noting the missing framework.

## Desired state (per design)

A quest framework: schema (id/giver/steps/flags/rewards), QuestState autoload + save integration, journal/tracking screen, and wiring for at least the placed-giver quests with reward IDs resolving to real items/abilities.

## Proposed approach

Design quest data/runtime as a dedicated gap; build schema in game/data/quests/, QuestState autoload, journal screen, and a vertical-slice quest (Marek's 'The Sword in the Post'); cross-reference reward IDs against existing data.

## Acceptance criteria

- [ ] A quest schema + QuestState autoload exist and persist
- [ ] A journal screen lists active/complete quests
- [ ] At least one placed-giver quest is completable end-to-end with a real reward
- [ ] All quest reward IDs resolve to existing item/ability data

## Design references

- docs/story/sidequests.md (10 major + 16 minor)
- docs/story/events.md (quest NPC threads)

## Code references

- game/data/ (no quest/journal files)
- game/scenes/maps/towns/valdris_barracks.tscn
- game/scenes/maps/towns/valdris_royal_library.tscn
- game/scenes/maps/towns/roothollow.tscn


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** `find game/data -iname '*quest*'` returns 0 files; no quest/journal scripts (find game/scripts -iname '*quest*' empty); no QuestState autoload (absent from project.godot). docs/story/sidequests.md exists (644 lines, 79.2K). Reward IDs only live in the design doc: sidequests.md:343 'Hadley's Bell', sidequests.md:383 "Marek's Discipline" — neither resolves to any game/data item/ability. Quest-giver NPCs ARE placed: valdris_barracks.tscn:26 npc_id=dame_cordwyn, :30 npc_id=sergeant_marek (ambient dialogue only).
- **Notes:** Genuine XL epic / missing-feature. 0 of 26 sidequests wired; no schema, journal, or QuestState. Not fixNow (full subsystem). Severity HIGH appropriate.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383); write what the file does hold instead. Always verify against current code before acting._
