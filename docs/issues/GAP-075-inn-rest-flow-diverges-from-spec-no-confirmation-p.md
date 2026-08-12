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
| **GitHub Issue** | [#231](https://github.com/gcko/pendulum-of-despair/issues/231) |
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

- game/scripts/core/exploration_interactions.gd — `_handle_inn()` (spends gold and rests with no confirm and no Rest & Save; moved out of exploration.gd by PR #357)
- game/scripts/ui/save_load.gd


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** exploration.gd:284-289 _handle_inn spends gold and calls PartyState.rest_at_inn() unconditionally — no confirm, no Rest & Save. save-system.md §4 specifies inns show a single 'Rest for Xg?' confirmation prompt and offer Rest or Rest & Save, and §4 Device Reconfiguration lets Lira reconfigure at any save point. save_load.gd:9 SavePointOption has only REST/REST_SAVE/SAVE — no device-reconfiguration entry.
- **Notes:** Confirmed design-divergence. Note save points DO offer Rest & Save (REST_SAVE); the divergence is specifically the Inn flow (no confirm / no Rest & Save) plus missing Lira device reconfiguration. Needs UI prompt wiring + tests. fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383); write what the file does hold instead. Always verify against current code before acting._
