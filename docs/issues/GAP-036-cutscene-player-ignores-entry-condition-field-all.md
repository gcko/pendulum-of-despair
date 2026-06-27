# GAP-036: Cutscene player ignores entry condition field — all scripted entries play unconditionally

| Field | Value |
|-------|-------|
| **ID** | GAP-036 |
| **Area** | Dialogue |
| **Severity** | HIGH |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | dialogue |

## Summary

CutscenePlayer._process_entries never reads the condition field; the condition evaluator lives only in npc.gd and is not shared, so 135 conditioned entries (party_has, reunion_order, betrayal flags) play regardless.

## Current state (implementation)

grep for 'condition' in cutscene_player.gd returns 0. Party-aware Tier-1 scenes (cael_betrayal, scene_24, thornmere_council, Maren reunion) cannot vary.

## Desired state (per design)

Cutscene entries with a condition are filtered with the same priority-stack/first-match semantics used for NPCs.

## Proposed approach

Extract the condition evaluator + priority-stack logic into a shared helper and have cutscene_player skip false-condition entries; add tests for party_has and reunion_order comparisons.

## Acceptance criteria

- [ ] Conditioned cutscene entries are evaluated
- [ ] party_has and reunion_order comparisons work in cutscenes
- [ ] A test asserts a false-condition entry is skipped

## Design references

- docs/story/dialogue-system.md §3.2/§3.5/§4.5

## Code references

- game/scripts/core/cutscene_player.gd:178-214
- game/scripts/entities/npc.gd:81-148

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
