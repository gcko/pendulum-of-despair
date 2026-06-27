# GAP-047: EPIC: Acts II–IV + Interlude + Epilogue narrative, scene wiring, NPCs, and world-state transitions unimplemented

| Field | Value |
|-------|-------|
| **ID** | GAP-047 |
| **Area** | World/Story |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open — CONFIRMED |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** 140 dialogue JSON exist (ls game/data/dialogue/*.json | wc -l = 140). Critical path ends at pendulum_to_capital (set only in valdris_throne_hall.tscn); no later flag set (cael_betrayal_complete/interlude_begins have 0 setters per GAP-045). Major Act-II+ scenes referenced by 0 code/scene files: cael_betrayal, thornmere_council, scene_19, the_farewell, party_reassembled, scene_23, scene_37 all -> 0 refs. dawn_march and scene_7d_evening ARE wired (overworld.tscn, cutscenes/dawn_march_trail.tscn, throne_hall).
- **Notes:** Confirmed: the single largest content gap (Acts II-IV + Interlude + Epilogue unimplemented). Two sub-claims mildly imprecise: only 28 distinct npc_ids are placed (grep metadata/npc_id), so ~26 of 54 unplaced vs the claimed ~34 (ballpark, some placed ids are cutscene actors); and 'T2/T3 cutscene types unsupported' is partly overstated — cutscene_handler.gd:194/:240 already accepts a `tier`/`cutscene_tier` param and forwards it to start_cutscene. These do not change the verdict. Epic, fixNow FALSE.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
