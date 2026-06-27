# GAP-043: Act II diplomatic-mission content is reachable/completable during Act I with no story gating

| Field | Value |
|-------|-------|
| **ID** | GAP-043 |
| **Area** | Story |
| **Severity** | HIGH |
| **Type** | design-divergence |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | story |

## Summary

The Fenmother's Hollow entry has no required_flag, so the Act-II diplomatic dungeon is enterable immediately and clearing it sets duskfen_alliance; the canonical prerequisite flag 8 diplomatic_mission_start is never set anywhere.

## Current state (implementation)

Duskfen Spirit Shrine requires caden_binding_complete, but the dungeon that sets it is itself ungated; diplomatic_mission_start set in 0 files.

## Desired state (per design)

Fenmother/Duskfen gated behind diplomatic_mission_start (Act II), OR the out-of-sequence vertical slice is formally documented in events.md/trackers.

## Proposed approach

Add required_flag=diplomatic_mission_start (with its setter when Act II's dispatch scene is built), or record the deviation explicitly.

## Acceptance criteria

- [ ] Fenmother/Duskfen are gated or the deviation is documented
- [ ] diplomatic_mission_start is set by some content or removed as a dependency
- [ ] duskfen_alliance no longer sets without its prerequisite

## Design references

- docs/story/events.md flags 8/9/9a/9b; §1 (Act I->II transition)

## Code references

- game/scenes/maps/overworld.tscn:125,137
- game/scripts/core/exploration_auto_sequence.gd:144-145
- game/scripts/core/cleansing_sequence.gd:80,206

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
