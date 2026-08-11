# GAP-028: Undocumented Act I enemies in data (Compact Patrol, Compact Scout) absent from bestiary

| Field | Value |
|-------|-------|
| **ID** | GAP-028 |
| **Area** | Enemies |
| **Severity** | LOW |
| **Type** | doc-inconsistency |
| **Effort** | S |
| **Epic** | No |
| **Status** | resolved — #222 |
| **GitHub Issue** | [#222](https://github.com/gcko/pendulum-of-despair/issues/222) |
| **Source domains** | enemies |

## Summary

compact_patrol and compact_scout (ironmouth_docks) appear in act_i.json but in no bestiary row; ironmouth_docks is not an Act I bestiary zone.

## Current state (implementation)

act-i.md declares 25 enemies across Ember Vein/Fenmother/Overworld; these two humanoids are not among them.

## Desired state (per design)

Every enemy traces to a bestiary row; add them (and the Ironmouth Docks zone) to the appropriate bestiary file, or relocate them.

## Proposed approach

Add the two enemies with derived stats/threat/family to the correct bestiary file, or move them out of act_i.json.

## Acceptance criteria

- [ ] Both enemies trace to a bestiary entry
- [ ] Their zone is documented or corrected

## Design references

- docs/story/bestiary/act-i.md:8,91-103

## Code references

- game/data/enemies/act_i.json


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** act_i.json:873-901 (compact_patrol) and 902-930 (compact_scout) both have type 'humanoid' and locations ['ironmouth_docks']. docs/story/bestiary/act-i.md:8 and :93 declare 'Total: 25 enemies (20 regular + 1 unique + 2 mini-bosses + 2 bosses)' across Ember Vein / Fenmother's Hollow / Overworld Act I; grep for 'compact' and 'ironmouth' in act-i.md returns 0 matches — neither enemy nor the Ironmouth Docks zone is documented. A game/scenes/maps/towns/ironmouth_docks.tscn scene does exist, so the enemies are real content, not stray data.
- **Notes:** Genuine doc-inconsistency. Doc-only, zero test risk, but the correct resolution is ambiguous per the issue itself (document the two enemies + add an Ironmouth Docks bestiary zone and bump the total to 27, OR relocate/remove them) and requires design judgment on threat/family classification and whether Ironmouth Docks is an Act I bestiary zone. Because the fix direction is not obvious, not fixNow; recommend filing as a bestiary documentation task. Stats to document already exist in act_i.json (patrol: lv5/180hp/16atk; scout: lv6/140hp/14atk/14spd).

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Always verify against current code before acting._
