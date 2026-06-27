# GAP-058: 32x32 character portraits and menu walking sprites not implemented in any menu/HUD

| Field | Value |
|-------|-------|
| **ID** | GAP-058 |
| **Area** | UI |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | ui |

## Summary

No screen renders a portrait or walking sprite; menu.tscn references only the cursor texture, Status/Equip/Magic/Crystal have text CharInfo panels, and Formation rows / Save slots are text-only.

## Current state (implementation)

Portraits (32x32) and Formation/Save walking sprites (16x20) are entirely absent.

## Desired state (per design)

Main menu/Status/Equip/Magic/Abilities/Crystal show a 32x32 portrait; Formation rows and Save slots show 16x20 walking sprites, with a Despair desaturation hook per §16.

## Proposed approach

Add portrait/sprite TextureRect placeholders to each screen .tscn and a character_id->texture lookup; coordinate with the art epic (GAP-082).

## Acceptance criteria

- [ ] Portrait nodes appear on the listed screens
- [ ] Formation/Save show walking sprites
- [ ] A character_id->texture lookup drives them

## Design references

- docs/story/ui-design.md §1.1/§3.3/§9.2/§13.3

## Code references

- game/scenes/overlay/menu.tscn
- game/scripts/ui/menu_formation.gd:118-136
- game/scripts/ui/save_load_display.gd:148-170

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
