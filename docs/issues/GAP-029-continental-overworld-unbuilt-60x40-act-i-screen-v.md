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

- game/scenes/maps/overworld.tscn


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** Parsed overworld.tscn TileMapLayer PackedInt32Array: 2400 cells, x range 0-59, y range 0-39 (exactly 60x40). Design geography.md:472 '128 tiles wide x 96 tiles tall'; geography.md:490 'Key Landmark Positions'. game/scenes/maps/overworld.tscn:41 TileMapLayer holds the only tile data.
- **Notes:** Core claim (60x40 actual vs 128x96 designed) exactly correct. XL multi-act continental epic — must not attempt now.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383); write what the file does hold instead. Always verify against current code before acting._
