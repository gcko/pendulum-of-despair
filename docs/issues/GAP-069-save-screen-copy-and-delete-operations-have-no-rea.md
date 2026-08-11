# GAP-069: Save-screen Copy and Delete operations have no reachable UI path

| Field | Value |
|-------|-------|
| **ID** | GAP-069 |
| **Area** | Save |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#210](https://github.com/gcko/pendulum-of-despair/issues/210) |
| **Source domains** | ui, save |

## Summary

_do_copy/_do_delete and the 'copy_dest'/'delete' confirm branches exist (backend too) but are never reachable: slot input only triggers overwrite/save/load, so the player can never copy or delete a slot.

## Current state (implementation)

_copy_source_slot is only read, never set; _show_confirm is called only for overwrite.

## Desired state (per design)

The save screen exposes Save/Copy/Delete operations driving the existing handlers.

## Proposed approach

Add a per-slot operations sub-menu (Save/Copy/Delete) wiring Copy to a source->dest pick and Delete to a confirm.

## Acceptance criteria

- [ ] Player can copy a slot to another
- [ ] Player can delete a slot with confirm
- [ ] Existing _do_copy/_do_delete are reached

## Design references

- docs/story/save-system.md §5
- docs/story/ui-design.md §13.5

## Code references

- game/scripts/ui/save_load.gd:263,283-289,323-331
- game/scripts/autoload/save_manager.gd:243-266


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** save_load.gd: _do_copy (309) and _do_delete (303) exist and call SaveManager.copy_slot/delete_slot (backend at save_manager.gd:243-266). _execute_confirm has "delete" (286) and "copy_dest" (288-289) branches, but _show_confirm is only invoked with "overwrite" (263). _copy_source_slot declared at line 21 and only ever READ at 289, never assigned. SavePointOption enum (line 9) has only REST/REST_SAVE/SAVE. So no UI path reaches copy/delete.
- **Notes:** Confirmed dead/unreachable backend. Requires a new per-slot operations sub-menu (UI scene + input wiring + tests). Not bounded. fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The durable, maintained anchors are the file-plus-symbol bullets under **Code references**: those must name a file that exists and a symbol that file actually defines, and `scripts/quality-gates/check_stale_counts.py` fails the build if they do not. Always verify against current code before acting._
