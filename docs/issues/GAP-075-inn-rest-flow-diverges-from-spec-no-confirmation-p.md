# GAP-075: Inn rest flow diverges from spec (no confirmation prompt, no Rest & Save; save-point device reconfiguration missing)

| Field | Value |
|-------|-------|
| **ID** | GAP-075 |
| **Area** | Save |
| **Severity** | LOW |
| **Type** | design-divergence |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | save |

## Summary

Inn interaction spends gold and rests immediately with no 'Rest for Xg?' confirm and no Rest & Save option; the save-point menu offers only Rest/Rest & Save/Save with no Lira device-reconfiguration entry.

## Current state (implementation)

_handle_inn rests unconditionally; SavePointOption has only REST/REST_SAVE/SAVE.

## Desired state (per design)

Inn shows a confirm then Rest or Rest & Save (latter opens the save screen); save points expose device reconfiguration when Lira is present.

## Proposed approach

Route inn interaction through a confirm prompt and Rest & Save; add a conditional 'Configure Devices' save-point option (defer if crafting is out of slice, see GAP-016).

## Acceptance criteria

- [ ] Inn shows 'Rest for Xg?' confirm
- [ ] Rest & Save opens the save screen after resting
- [ ] Device reconfiguration available at save points when Lira is recruited

## Design references

- docs/story/save-system.md §4

## Code references

- game/scripts/core/exploration.gd:284-289
- game/scripts/ui/save_load.gd:7-9,230-243

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
