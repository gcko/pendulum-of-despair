# GAP-069: Save-screen Copy and Delete operations have no reachable UI path

| Field | Value |
|-------|-------|
| **ID** | GAP-069 |
| **Area** | Save |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
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

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
