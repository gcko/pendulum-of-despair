# GAP-042: NPC dialogue resolver silently drops all default lines except the last

| Field | Value |
|-------|-------|
| **ID** | GAP-042 |
| **Area** | Story |
| **Severity** | HIGH (verified: MEDIUM) |
| **Type** | bug |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#192](https://github.com/gcko/pendulum-of-despair/issues/192) |
| **Source domains** | story |

## Summary

get_current_dialogue overwrites fallback on each null-condition entry and returns only the last; multi-default NPCs lose authored content (Bren 3->1 reachable, Seyth 5->1, and similar in renn/jace_renn/mira_thenn/fiara/etc).

## Current state (implementation)

In the normal Act-I case (act flags unset) only the final default line is reachable. Tracker marks the NPC priority stack COMPLETE without noting multi-default collapse.

## Desired state (per design)

NPCs with multiple unconditioned lines surface all of them — a sequential/cycling set or topic list — preserving every authored default.

## Proposed approach

Decide semantics (group consecutive same-condition entries as a sequence, or cycle defaults across interactions via a per-NPC index); add a regression test feeding a 3-default NPC.

## Acceptance criteria

- [ ] All default lines of a multi-default NPC are reachable
- [ ] Behavior matches dialogue-system.md semantics
- [ ] A test asserts three defaults are all reachable

## Design references

- docs/story/dialogue-system.md (NPC ambient model)
- docs/story/npcs.md
- docs/story/events.md §3

## Code references

- game/scripts/entities/npc.gd:66-75
- game/data/dialogue/npc_bren.json
- game/data/dialogue/npc_grandmother_seyth.json


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/scripts/entities/npc.gd:66-75 get_current_dialogue() reassigns `fallback = entry` and `continue`s on every null/empty-condition entry, so only the LAST default survives. game/data/dialogue/npc_bren.json has 3 null-condition entries (npc_bren_001/002/003 — distinct topics) plus conditioned ones; npc_grandmother_seyth.json has 5 null-condition entries (001-005). In the Act-I case (act flags unset) only npc_bren_003 and seyth_005 are reachable. Confirmed: Bren 3->1, Seyth 5->1.
- **Notes:** Real content loss across many ambient NPCs. Not fixNow: dialogue-system.md §3.2 (docs/story/dialogue-system.md:135-170) only models a SINGLE [default] entry ('the [default] entry fires'), so multi-default semantics (sequential vs per-NPC cycling index) is an UNSPECIFIED design decision the issue itself flags. Implementing cycling/sequencing plus a regression test is a non-trivial change against the 916-test suite. Severity refined HIGH->MEDIUM: ambient flavor, non-progression-blocking, but genuinely widespread.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
