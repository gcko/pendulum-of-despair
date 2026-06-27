# GAP-026: Overworld per-tile encounter zones not implemented; 12 of 13 zones are unreachable dead data

| Field | Value |
|-------|-------|
| **ID** | GAP-026 |
| **Area** | Encounters |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | exploration |

## Summary

Encounter zone is chosen once per map from a single floor_id meta (valdris_highlands), so the other 12 authored overworld zones can never be selected; no per-tile terrain->zone lookup exists.

## Current state (implementation)

exploration.gd:131 reads one floor_id; the zone-match loop only matches valdris_highlands. Tracker marks 'overworld encounter tables per terrain type' DONE (false-completion: data unreachable).

## Desired state (per design)

A per-tile/per-region terrain classifier selects the matching encounter zone as the party moves, activating all 13 zones.

## Proposed approach

Add a TileMapLayer terrain-tag -> zone_id map and update the current zone on tile change in the encounter step, replacing the static floor_id for the overworld.

## Acceptance criteria

- [ ] Crossing terrain changes the active encounter zone
- [ ] All 13 zones become reachable
- [ ] A test asserts zone selection by terrain tag

## Design references

- docs/story/geography.md §5 (per-tile terrain encounter zones)
- docs/story/geography.md §2

## Code references

- game/data/encounters/overworld.json (13 zones)
- game/scripts/core/exploration.gd:131,136-149
- game/scenes/maps/overworld.tscn:38

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
