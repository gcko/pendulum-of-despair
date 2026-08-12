# GAP-071: Color-Blind Mode config toggle has no runtime effect

| Field | Value |
|-------|-------|
| **ID** | GAP-071 |
| **Area** | Save |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#212](https://github.com/gcko/pendulum-of-despair/issues/212) |
| **Source domains** | save |

## Summary

color_blind_mode (off/deutan_protan/tritan) persists but is referenced nowhere else; no palette swaps for HP bars/status icons/poison/low-HP text and no live preview panel exist.

## Current state (implementation)

Only consumer is the setting definition.

## Desired state (per design)

Selecting a mode applies the palette swaps and the config screen shows the live preview (HP bar + status icons + mini Pallor sample).

## Proposed approach

Centralize palette lookup keyed on color_blind_mode and route HP bar/status icon/text-warning colors through it; add a preview group to the config scene.

## Acceptance criteria

- [ ] Each mode swaps the relevant palettes
- [ ] Config shows a live preview panel
- [ ] Setting persists and applies on load

## Design references

- docs/story/accessibility.md §2

## Code references

- game/scripts/ui/menu_config.gd


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** menu_config.gd:33-38 defines the color_blind_mode setting (off/deutan_protan/tritan). Repo-wide grep for `color_blind_mode` across scripts/ excluding menu_config.gd returns nothing — no palette consumer, no preview panel.
- **Notes:** Confirmed: setting persists, no runtime effect. Palette-swap system + live preview is a feature (effort L). fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383); write what the file does hold instead. Always verify against current code before acting._
