# GAP-031: Act-based dynamic world transformations not implemented — all locations are single Act-I state

| Field | Value |
|-------|-------|
| **ID** | GAP-031 |
| **Area** | Exploration |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#169](https://github.com/gcko/pendulum-of-despair/issues/169) |
| **Source domains** | exploration |

## Summary

Every map exists in one Act-I state; there is no mechanism to swap tilemaps/palettes/NPCs/blocked areas by act/flag and no staged Pallor corruption overlay, despite 3-5 variants prescribed per location.

## Current state (implementation)

dynamic-world.md (1156 lines) specifies multi-act variants for 35 locations; biomes.md defines a 5-stage corruption overlay; neither is implemented.

## Desired state (per design)

Per-location act-state switching (layout/tile/NPC/blocked-area) and the staged Pallor corruption overlay, driven by act/EventFlags.

## Proposed approach

Build a map-variant resolution layer (map_id + act/flag -> scene/overlay) plus a reusable Pallor corruption shader/overlay node; implement alongside Acts II+ content.

## Acceptance criteria

- [ ] A location renders different states by act flag
- [ ] A Pallor corruption overlay applies stages 0-4
- [ ] Blocked areas/NPC sets change with world state

## Design references

- docs/story/dynamic-world.md
- docs/story/biomes.md §Pallor Corruption Overlay (stages 0-4)

## Code references

- game/scenes/maps/towns/* (single static scenes)
- game/scripts/ (no corruption_stage/biome logic)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** No act-based map-variant or corruption-overlay logic in scripts. grep corruption_stage/corruption/pallor/biome in scripts/ returns only thematic UI strings (ritual_meter.gd:11/14, cleansing_sequence.gd:159) and a combat comment (damage_calculator.gd:45 'Pallor Shimmer'); no world-state switching. dynamic-world.md is 1156 lines; biomes.md:864 'Pallor Corruption Overlay System'. Town scenes are single static .tscn files.
- **Notes:** Confirmed. XL epic spanning Acts II+. fixKind code, not fixable now.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Always verify against current code before acting._
