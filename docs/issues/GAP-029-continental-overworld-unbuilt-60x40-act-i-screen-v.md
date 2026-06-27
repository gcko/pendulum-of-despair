# GAP-029: Continental overworld unbuilt — 60x40 Act-I screen vs designed 128x96 free-scroll continent

| Field | Value |
|-------|-------|
| **ID** | GAP-029 |
| **Area** | Exploration |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#167](https://github.com/gcko/pendulum-of-despair/issues/167) |
| **Source domains** | exploration |

## Summary

The overworld is a single ~60x40 valdris_highlands screen with 7 Act-I transitions; no continental geography exists and ~35 designed locations have no overworld presence.

## Current state (implementation)

Measured extent x0-59,y0-39 (~20% of 128x96). No canonical landmark coords honored. Tracker labels gap 4.3 'MOSTLY COMPLETE' (overstates).

## Desired state (per design)

A 128x96 free-scroll continental tilemap honoring the 25 landmark coordinates, with region boundaries and entry triggers to the designed locations.

## Proposed approach

Multi-phase epic: build the full tilemap to canonical coords, then add location maps act-by-act per the Location Progression tables.

## Acceptance criteria

- [ ] Tilemap spans 128x96 with landmarks at canonical coords
- [ ] Region boundaries and entry triggers exist
- [ ] Camera/free-scroll works across the continent

## Design references

- docs/story/geography.md §5 (128x96 grid; 25 landmark coords)
- docs/story/locations.md

## Code references

- game/scenes/maps/overworld.tscn:35-39,49-156


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** Parsed overworld.tscn TileMapLayer PackedInt32Array: 2400 cells, x range 0-59, y range 0-39 (exactly 60x40). Design geography.md:472 '128 tiles wide x 96 tiles tall'; geography.md:490 'Key Landmark Positions'. game/scenes/maps/overworld.tscn:41 TileMapLayer holds the only tile data.
- **Notes:** Core claim (60x40 actual vs 128x96 designed) exactly correct. XL multi-act continental epic — must not attempt now.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
