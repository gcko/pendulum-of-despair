# GAP-031: Act-based dynamic world transformations not implemented — all locations are single Act-I state

| Field | Value |
|-------|-------|
| **ID** | GAP-031 |
| **Area** | Exploration |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | exploration |

## Summary

Every map exists in one Act-I state; there is no mechanism to swap tilemaps/palettes/NPCs/blocked areas by act/flag and no staged Pallor corruption overlay, despite 3-5 variants prescribed per location.

## Current state (implementation)

dynamic-world.md (1156 lines) specifies multi-act variants for 35 locations; biomes.md defines a 5-stage corruption overlay; neither is implemented.

## Desired state (per design)

Per-location act-state switching (layout/tile/NPC/blocked-area) and the staged Pallor corruption overlay, driven by act/EventFlags.

## Proposed approach

Build a map-variant resolution layer (map_id + act/flag -> scene/overlay) plus a reusable Pallor corruption shader/overlay node; implement alongside Acts II+ content.

## Acceptance criteria

- [ ] A location renders different states by act flag
- [ ] A Pallor corruption overlay applies stages 0-4
- [ ] Blocked areas/NPC sets change with world state

## Design references

- docs/story/dynamic-world.md
- docs/story/biomes.md §Pallor Corruption Overlay (stages 0-4)

## Code references

- game/scenes/maps/towns/* (single static scenes)
- game/scripts/ (no corruption_stage/biome logic)

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
