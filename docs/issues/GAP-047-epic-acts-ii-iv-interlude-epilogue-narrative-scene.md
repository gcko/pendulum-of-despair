# GAP-047: EPIC: Acts II–IV + Interlude + Epilogue narrative, scene wiring, NPCs, and world-state transitions unimplemented

| Field | Value |
|-------|-------|
| **ID** | GAP-047 |
| **Area** | World/Story |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | story, dialogue, tracker |

## Summary

The implemented critical path ends at pendulum_to_capital. 140 dialogue JSON exist but only 2 (dawn_march, scene_7d_evening) plus caden_binding/fenmother_cleansing are wired; ~34 of 54 NPCs are never placed; no flag past pendulum_to_capital is set; T2/T3 cutscene types are unsupported.

## Current state (implementation)

Major scenes (cael_betrayal, thornmere_council, scene_19 siege, scene_23-37 reunions/finale, the_farewell, party_reassembled) are referenced by 0 code/scene files. The single largest content gap.

## Desired state (per design)

Acts II-IV, Interlude, and Epilogue built: maps, NPC placements with act-state dialogue, ~50 flags, boss/cutscene wiring, and per-act world-state transitions per events.md §1.

## Proposed approach

Track per-act as sub-epics. Reuse the proven pipeline (dialogue JSON -> map triggers -> cutscene/flag wiring). Prerequisites: GAP-036/037/038 engine fixes and T2/T3 support. Sequence after Act-I completeness.

## Acceptance criteria

- [ ] Each act's scenes are triggered at their story beats
- [ ] Act-state flags through flag 58 are set by content
- [ ] Designed NPCs are placed with act-state dialogue
- [ ] World-state transitions per events.md §1 occur

## Design references

- docs/story/outline.md
- docs/story/events.md §1/§2 (flags 7-58)
- docs/story/npcs.md (54 NPCs)
- docs/story/script/*

## Code references

- game/scenes/maps/ (all Act-I)
- game/data/dialogue/ (Act II-IV scene JSON unwired)
- docs/analysis/game-dev-gaps.md:1089-1119

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
