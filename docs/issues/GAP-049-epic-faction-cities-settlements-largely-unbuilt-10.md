# GAP-049: EPIC: Faction cities/settlements largely unbuilt (10 Carradan, Highcairn, Greyvale, 5 Thornmere settlements, full Duskfen)

| Field | Value |
|-------|-------|
| **ID** | GAP-049 |
| **Area** | World |
| **Severity** | HIGH (verified: MEDIUM) |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#196](https://github.com/gcko/pendulum-of-despair/issues/196) |
| **Source domains** | world |

## Summary

Built towns cover only Valdris Crown districts plus partial Roothollow/Maren's Refuge and the Ironmouth escape stub; all other faction settlements (~24) are unbuilt.

## Current state (implementation)

Tracker's 4.5 '4+ towns' phrasing severely undercounts the remaining settlements across Carradan/Valdris/Thornmere.

## Desired state (per design)

All designed settlements built per the three city docs (10 Carradan, Highcairn/Thornwatch/Greyvale/Aelhart, Ashgrove/Canopy Reach/Greywood Camp/Stillwater Hollow/Sunstone Ridge, full Duskfen).

## Proposed approach

Single cities epic; enumerate settlements by faction in the tracker so the ~24 remaining are visible.

## Acceptance criteria

- [ ] Tracker enumerates remaining settlements by faction
- [ ] Settlements build act-by-act with shops/NPCs
- [ ] Each has the designed building directory

## Design references

- docs/story/city-carradan.md
- docs/story/city-valdris.md:660,877,1061
- docs/story/city-thornmere.md

## Code references

- game/scenes/maps/towns/ (only Valdris Crown districts + roothollow + marens_refuge + ironmouth stub)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/scenes/maps/towns/ contains only Valdris Crown districts (valdris_lower_ward, citizens_walk, court_quarter, throne_hall, royal_library, barracks, anchor_oar, anchor_oar_upper), roothollow.tscn, marens_refuge.tscn, ironmouth_docks.tscn. No Carradan/Highcairn/Greyvale/Aelhart/Thornwatch or Thornmere settlement scenes exist (grep for aelhart/thornwatch in game/scenes returns nothing). Design docs city-carradan.md, city-valdris.md, city-thornmere.md define ~24 additional settlements. Tracker game-dev-gaps.md:1103 uses generic '4+ towns' phrasing.
- **Notes:** Real epic-scale missing-feature gap, accurately framed. All Act-II+ gated content; MEDIUM for the Act-I slice. Not a bounded fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Always verify against current code before acting._
