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

- game/scripts/ui/menu_config.gd:33-38


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** menu_config.gd:33-38 defines the color_blind_mode setting (off/deutan_protan/tritan). Repo-wide grep for `color_blind_mode` across scripts/ excluding menu_config.gd returns nothing — no palette consumer, no preview panel.
- **Notes:** Confirmed: setting persists, no runtime effect. Palette-swap system + live preview is a feature (effort L). fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The durable, maintained anchors are the file-plus-symbol bullets under **Code references**: those must name a file that exists and a symbol that file actually defines, and `scripts/quality-gates/check_stale_counts.py` fails the build if they do not. Always verify against current code before acting._
