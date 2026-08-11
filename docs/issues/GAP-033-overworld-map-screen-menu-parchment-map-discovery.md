# GAP-033: Overworld map screen (menu parchment map + discovery) not implemented

| Field | Value |
|-------|-------|
| **ID** | GAP-033 |
| **Area** | Exploration |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#188](https://github.com/gcko/pendulum-of-despair/issues/188) |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** No map-screen or location-discovery state. grep discover/map_screen/parchment/continent in scripts/+scenes/overlay/ found only inventory_helpers.gd:307 'discovered_synergies' (combat synergies, unrelated). Design overworld.md:77 'Map Screen (Menu-Accessed)'; geography.md:524 map screen overview.
- **Notes:** Confirmed. Effort M feature requiring new save/world state + menu overlay. Not fixable now.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Always verify against current code before acting._
