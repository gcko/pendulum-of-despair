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
- game/scenes/core/exploration.tscn
- game/scripts/core/exploration.gd


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** overworld.tscn has 0 SavePoint nodes (grep -c SavePoint = 0; node list shows only Transitions/Entities/Labels/Markers). Shared Camera2D defines only zoom and position_smoothing in exploration.tscn:22-24. exploration.gd:67-68 '_camera.position = _player.position.round()' — unclamped, no limit_*. Design overworld.md:139 overworld save points; geography.md:523-524 'camera stops at map edges — ocean tiles fill'.
- **Notes:** Confirmed partial-impl. Although effort S, camera limits depend on final continental map bounds (GAP-029) and adding clamping/save-point risks GUT camera/exploration tests; not a safe bounded fix on the placeholder 60x40 map. Not fixable now.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383); write what the file does hold instead. Always verify against current code before acting._
