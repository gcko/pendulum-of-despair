# GAP-035: Overworld save points missing; camera edge boundaries not enforced

| Field | Value |
|-------|-------|
| **ID** | GAP-035 |
| **Area** | Exploration |
| **Severity** | LOW |
| **Type** | partial-impl |
| **Effort** | S |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#223](https://github.com/gcko/pendulum-of-despair/issues/223) |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** overworld.tscn has 0 SavePoint nodes (grep -c SavePoint = 0; node list shows only Transitions/Entities/Labels/Markers). Shared Camera2D defines only zoom and position_smoothing in exploration.tscn:22-24. exploration.gd:67-68 '_camera.position = _player.position.round()' — unclamped, no limit_*. Design overworld.md:139 overworld save points; geography.md:523-524 'camera stops at map edges — ocean tiles fill'.
- **Notes:** Confirmed partial-impl. Although effort S, camera limits depend on final continental map bounds (GAP-029) and adding clamping/save-point risks GUT camera/exploration tests; not a safe bounded fix on the placeholder 60x40 map. Not fixable now.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
