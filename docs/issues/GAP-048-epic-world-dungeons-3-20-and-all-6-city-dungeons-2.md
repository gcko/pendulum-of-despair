# GAP-048: EPIC: World dungeons 3-20 and all 6 city dungeons + ~20 secret passages unbuilt

| Field | Value |
|-------|-------|
| **ID** | GAP-048 |
| **Area** | World |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | world |

## Summary

Only Ember Vein and Fenmother's Hollow exist; the other 18 world dungeons, all 6 city dungeons, and the ~20 designed secret passages have no scenes (encounter JSON exists but maps do not).

## Current state (implementation)

Tracker folds these into 4.5 with a generic '6 dungeons' bullet that undercounts the 18 world + 6 city dungeons and omits the secret-passage scope entirely.

## Desired state (per design)

All 20 world dungeons and 6 city dungeons built as tilemapped scenes with floor counts/puzzles/encounters/bosses, plus the ~20 secret passages, per the dungeon docs.

## Proposed approach

Single dungeon build-out epic; add an enumerated checklist (18 world + 6 city + ~20 passages by name/floor count) to the tracker so completion is measurable. Most are Act-II+ gated.

## Acceptance criteria

- [ ] Tracker enumerates the 18 world + 6 city dungeons + ~20 passages by name
- [ ] Dungeons build act-by-act with their bosses
- [ ] Secret passages are reachable interactables

## Design references

- docs/story/dungeons-world.md (20 dungeons)
- docs/story/dungeons-city.md (6 city dungeons + ~20 secret passages)

## Code references

- game/scenes/maps/dungeons/ (only ember_vein, fenmothers_hollow, duskfen_spirit_shrine)

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
