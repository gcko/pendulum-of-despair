# GAP-035: Overworld save points missing; camera edge boundaries not enforced

| Field | Value |
|-------|-------|
| **ID** | GAP-035 |
| **Area** | Exploration |
| **Severity** | LOW |
| **Type** | partial-impl |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | exploration |

## Summary

The overworld has no save point and the shared Camera2D has no limit_* properties, so it scrolls past the map edge instead of stopping with ocean fill.

## Current state (implementation)

overworld.tscn has zero SavePoint nodes; Camera2D defines only zoom; camera tracks player position unclamped.

## Desired state (per design)

Overworld save points and camera limits that stop at map edges with ocean filling the viewport.

## Proposed approach

Add SavePoint entities at designed coords and set Camera2D limit_* from the active tilemap bounds on load.

## Acceptance criteria

- [ ] Overworld has at least one save point
- [ ] Camera stops at map edges
- [ ] Ocean fills beyond the edge

## Design references

- docs/story/overworld.md §6
- docs/story/geography.md §Camera Behavior

## Code references

- game/scenes/maps/overworld.tscn (no SavePoint)
- game/scenes/core/exploration.tscn:22-24
- game/scripts/core/exploration.gd:67-68

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
