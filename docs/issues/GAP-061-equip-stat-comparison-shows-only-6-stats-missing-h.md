# GAP-061: Equip stat comparison shows only 6 stats; missing HP/MP rows, EVA/MEVA/CRIT deltas, element/status info line

| Field | Value |
|-------|-------|
| **ID** | GAP-061 |
| **Area** | UI |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#207](https://github.com/gcko/pendulum-of-despair/issues/207) |
| **Source domains** | ui |

## Summary

The equip panel compares only ATK/DEF/MAG/MDEF/SPD/LCK; EVA%/MEVA%/CRIT% deltas, conditional HP/MP rows, and the element/status info line are absent (info label hardcoded empty).

## Current state (implementation)

STAT_NAMES has 6 entries; Stat0-5 only; _info_label.text set to ''.

## Desired state (per design)

Comparison includes the 3 derived percentages and conditional HP/MP rows, plus a populated element/status info line.

## Proposed approach

Extend STAT_NAMES + .tscn rows and populate _info_label from equipment element/status fields (inline icons once GAP-059 lands).

## Acceptance criteria

- [ ] EVA/MEVA/CRIT deltas shown
- [ ] HP/MP rows appear when modified
- [ ] Element/status info line populated

## Design references

- docs/story/ui-design.md §5.6/§5.7

## Code references

- game/scripts/ui/menu_equip.gd — `_update_stat_comparison()`
- game/scenes/overlay/menu.tscn


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** menu_equip.gd:15 STAT_NAMES = ['atk','def','mag','mdef','spd','lck'] (6 entries); menu.tscn:407-422 has Stat0-Stat5 only (ATK/DEF/MAG/MDEF/SPD/LCK). No EVA%/MEVA%/CRIT% rows, no conditional HP/MP rows. menu_equip.gd:222-223 _info_label.text = '' hardcoded empty. Design ui-design.md:5.6 (lines 521-525) specifies '8 core stats + 3 derived... HP, MP, ATK, DEF, MAG, MDEF, SPD, LCK, EVA%, MEVA%, CRIT%' with HP/MP conditional, and 5.7 (536-539) an element/status info line with inline icons.
- **Notes:** Confirmed. Info-line population is partly blocked on GAP-059 inline icons. Not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Always verify against current code before acting._
