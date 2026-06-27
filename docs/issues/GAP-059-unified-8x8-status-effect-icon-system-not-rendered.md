# GAP-059: Unified 8x8 status-effect icon system not rendered anywhere

| Field | Value |
|-------|-------|
| **ID** | GAP-059 |
| **Area** | UI |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | ui |

## Summary

No status icons are drawn: battle rows have no icon container above the name and item/spell/equipment descriptions render plain text with no inline icons; the 22-icon 'learn once, recognize everywhere' system is absent.

## Current state (implementation)

No icon atlas or BBCode-image substitution exists.

## Desired state (per design)

8x8 icons above battle names (up to 4, scrolling) and inline in item/spell/equipment/status descriptions per the 22-entry table.

## Proposed approach

Create an 8x8 icon atlas + status-id->icon map; add an icon HBox above each battle name and a RichTextLabel inline-image substitution pass for descriptions.

## Acceptance criteria

- [ ] Battle rows show status icons above the name
- [ ] Descriptions substitute inline status icons
- [ ] A 22-entry icon map exists

## Design references

- docs/story/ui-design.md §1.6/§2.3/§4.4/§5.7/§6.3/§8.3

## Code references

- game/scenes/core/battle.tscn
- game/scripts/ui/menu_items.gd:202-212
- game/scripts/ui/menu_equip.gd:222-223

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
