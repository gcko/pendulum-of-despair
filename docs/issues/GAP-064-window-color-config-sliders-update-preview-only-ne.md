# GAP-064: Window Color config sliders update preview only — never applied to live UI chrome

| Field | Value |
|-------|-------|
| **ID** | GAP-064 |
| **Area** | UI |
| **Severity** | LOW |
| **Type** | design-divergence |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#228](https://github.com/gcko/pendulum-of-despair/issues/228) |
| **Source domains** | ui |

## Summary

Adjusting Window R/G/B updates only the small PreviewRect; actual menu/dialogue window backgrounds stay the static #000040.

## Current state (implementation)

_update_display sets preview color but nothing propagates window_color to the shared window theme.

## Desired state (per design)

The chosen window color tints all menu/dialogue window backgrounds in real time, persisted.

## Proposed approach

Drive a shared theme StyleBoxFlat bg_color (or a global window-color singleton) from the persisted window_color.

## Acceptance criteria

- [ ] Window color tints all windows live
- [ ] Setting persists across sessions
- [ ] Preview matches actual chrome

## Design references

- docs/story/ui-design.md §10.3

## Code references

- game/scripts/ui/menu_config.gd


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** menu_config.gd:294-300 _update_display only sets _preview_rect.color from window_color; nothing propagates window_color to a shared theme. menu_overlay.gd:14 COLOR_WINDOW_BG = Color('#000040') is a static const never driven by config. No StyleBoxFlat bg_color or global window-color singleton is updated from window_color (grep confirms window_color is only read in menu_config.gd). Design ui-design.md:10.3.
- **Notes:** Confirmed: sliders affect preview only. Live tinting across all menu/dialogue chrome + persistence = moderate cross-cutting change; not a bounded safe fix. Not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
