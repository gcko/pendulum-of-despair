# GAP-032: Region boundary banners not implemented

| Field | Value |
|-------|-------|
| **ID** | GAP-032 |
| **Area** | Exploration |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | exploration |

## Summary

Only flash_location_name (per-map-load) exists; there are no region-crossing banners or banner/location-name precedence handling because the overworld is a single region.

## Current state (implementation)

No region-detection or banner code; no music crossfade on crossing.

## Desired state (per design)

Region banners trigger on boundary crossings with precedence rules and a music crossfade per overworld.md.

## Proposed approach

Once continental region boundaries exist, detect crossings in the move step and reuse the location flash panel with precedence logic.

## Acceptance criteria

- [ ] Crossing a region boundary shows an ~2s banner
- [ ] Banner vs location-name precedence is honored
- [ ] Music crossfades on region change

## Design references

- docs/story/overworld.md §Region Boundary Banners
- docs/story/geography.md:526

## Code references

- game/scripts/core/exploration.gd:176-187

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
