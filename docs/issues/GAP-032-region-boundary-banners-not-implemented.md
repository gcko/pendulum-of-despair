# GAP-032: Region boundary banners not implemented

| Field | Value |
|-------|-------|
| **ID** | GAP-032 |
| **Area** | Exploration |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | S |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#187](https://github.com/gcko/pendulum-of-despair/issues/187) |
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

- game/scripts/core/exploration.gd


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** Only flash_location_name exists (exploration.gd:176-187, a per-map-load fade panel). No region-detection or banner/crossfade code. Design overworld.md:235 'Region Boundary Banners — Plus Enhancement', overworld.md:248 '3-second' music crossfade; geography.md:524-528 region banners on boundary crossing.
- **Notes:** Confirmed. Effort S but hard-blocked by GAP-029 (no continental regions exist to cross). Not fixable now.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Always verify against current code before acting._
