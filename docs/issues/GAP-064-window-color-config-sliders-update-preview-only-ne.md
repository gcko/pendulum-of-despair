# GAP-064: Window Color config sliders update preview only — never applied to live UI chrome

| Field | Value |
|-------|-------|
| **ID** | GAP-064 |
| **Area** | UI |
| **Severity** | LOW |
| **Type** | design-divergence |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
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

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
