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
| **GitHub Issue** | _(set during migration)_ |
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

- game/scripts/ui/menu_config.gd:295-301


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** menu_config.gd:294-300 _update_display only sets _preview_rect.color from window_color; nothing propagates window_color to a shared theme. menu_overlay.gd:14 COLOR_WINDOW_BG = Color('#000040') is a static const never driven by config. No StyleBoxFlat bg_color or global window-color singleton is updated from window_color (grep confirms window_color is only read in menu_config.gd). Design ui-design.md:10.3.
- **Notes:** Confirmed: sliders affect preview only. Live tinting across all menu/dialogue chrome + persistence = moderate cross-cutting change; not a bounded safe fix. Not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
