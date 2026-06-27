# GAP-033: Overworld map screen (menu parchment map + discovery) not implemented

| Field | Value |
|-------|-------|
| **ID** | GAP-033 |
| **Area** | Exploration |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | exploration |

## Summary

There is no continental map screen and no location-discovery tracking; the menu has no map view.

## Current state (implementation)

No discovered-locations state or map overlay exists.

## Desired state (per design)

A menu-accessible parchment map showing discovered locations and named routes, with a discovery flag set on first visit.

## Proposed approach

Add a discovered-locations set to save/world state set on map entry, and a menu overlay rendering the continent with discovered pins/routes.

## Acceptance criteria

- [ ] Menu opens a parchment continent map
- [ ] Visiting a location marks it discovered
- [ ] Discovered routes/pins render

## Design references

- docs/story/overworld.md §Map Screen
- docs/story/geography.md:524

## Code references

- game/scripts/ (no map-screen logic)
- game/scenes/overlay/menu.tscn

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
