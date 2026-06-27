# GAP-075: Inn rest flow diverges from spec (no confirmation prompt, no Rest & Save; save-point device reconfiguration missing)

| Field | Value |
|-------|-------|
| **ID** | GAP-075 |
| **Area** | Save |
| **Severity** | LOW |
| **Type** | design-divergence |
| **Effort** | S |
| **Epic** | No |
| **Status** | open — CONFIRMED |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** exploration.gd:284-289 _handle_inn spends gold and calls PartyState.rest_at_inn() unconditionally — no confirm, no Rest & Save. save-system.md §4 specifies inns show a single 'Rest for Xg?' confirmation prompt and offer Rest or Rest & Save, and §4 Device Reconfiguration lets Lira reconfigure at any save point. save_load.gd:9 SavePointOption has only REST/REST_SAVE/SAVE — no device-reconfiguration entry.
- **Notes:** Confirmed design-divergence. Note save points DO offer Rest & Save (REST_SAVE); the divergence is specifically the Inn flow (no confirm / no Rest & Save) plus missing Lira device reconfiguration. Needs UI prompt wiring + tests. fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
