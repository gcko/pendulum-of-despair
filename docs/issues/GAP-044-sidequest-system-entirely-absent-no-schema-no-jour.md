# GAP-044: Sidequest system entirely absent: no schema, no journal, 0 of 26 quests wired (givers already placed)

| Field | Value |
|-------|-------|
| **ID** | GAP-044 |
| **Area** | Story |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
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

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
