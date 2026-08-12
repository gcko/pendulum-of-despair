# GAP-058: 32x32 character portraits and menu walking sprites not implemented in any menu/HUD

| Field | Value |
|-------|-------|
| **ID** | GAP-058 |
| **Area** | UI |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#204](https://github.com/gcko/pendulum-of-despair/issues/204) |
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
- game/scripts/ui/menu_formation.gd
- game/scripts/ui/save_load_display.gd


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** menu.tscn references only cursor textures (ext_resource cursor_hand.png id 10_cursor; nodes Cursor/CharCursor Sprite2D); grep for Portrait/TextureRect/sprite finds no portrait or walking-sprite nodes. assets/sprites/ui/ contains only cursor_hand.png. menu_formation.gd:_refresh_labels (lines ~118-136) renders text-only rows; save_load_display.gd:_show_populated_slot (148-170) is text-only. Design ui-design.md:37 '32x32 pixel-art face portraits', :369-370 formation rows specify '32x32 pixel-art face portrait'.
- **Notes:** Confirmed absent. Depends on art epic (GAP-082) for actual textures; placeholder nodes alone would be incomplete. Effort L, not a bounded safe fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383); write what the file does hold instead. Always verify against current code before acting._
