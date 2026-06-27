# GAP-059: Unified 8x8 status-effect icon system not rendered anywhere

| Field | Value |
|-------|-------|
| **ID** | GAP-059 |
| **Area** | UI |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#205](https://github.com/gcko/pendulum-of-despair/issues/205) |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** No icon atlas exists (assets/sprites/ui/ holds only cursor_hand.png). battle.tscn has no Icon nodes (grep Icon -> none). menu_items.gd:206-207 sets _desc_label.text to raw description string with no BBCode/inline-image substitution. menu_equip.gd:222-223 sets _info_label.text = '' (hardcoded empty). The only match for 'status icon' in scripts is the docstring comment in battle_party_panel.gd:2, which does not implement icons. Design ui-design.md:29,105 specify an 8x8 pixel-art status-icon set used across screens, :437 inline icons in descriptions.
- **Notes:** Confirmed missing system. Large feature (atlas + 22-entry id->icon map + RichTextLabel inline substitution). Not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
