# GAP-001: Magic command is non-functional in battle — spell submenu never populated

| Field | Value |
|-------|-------|
| **ID** | GAP-001 |
| **Area** | Combat |
| **Severity** | BLOCKER |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | combat |

## Summary

Selecting Magic in battle opens an empty submenu; set_submenu_items() has zero callers so no spell can ever be chosen and _do_magic is dead code.

## Current state (implementation)

_show_submenu() is invoked but _submenu_items is never filled; set_submenu_items() is defined and never called. _handle_submenu_input guards on is_empty() so only cancel works. battle_manager._do_magic exists but is unreachable via the UI.

## Desired state (per design)

Opening Magic lists the caster's known spells (spell_helpers.get_known_spells / DataManager.load_spells), lets the player pick spell and target, and routes the chosen spell dict into _do_magic for resolution per magic.md.

## Proposed approach

On Magic confirm in battle_ui/battle_command_menu, build the active character's spell list and call set_submenu_items with {type:'magic', spell:{...}} command dicts and target_type, mirroring menu_magic's grid construction.

## Acceptance criteria

- [ ] Magic submenu lists the active character's known spells with MP costs
- [ ] Selecting a spell prompts target selection and resolves via _do_magic
- [ ] Insufficient-MP spells are greyed/blocked
- [ ] A battle test casts a damage spell and asserts MP spent + damage dealt

## Design references

- docs/story/magic.md (89-spell catalog)
- docs/story/combat-formulas.md §Magic Damage Resolution

## Code references

- game/scripts/ui/battle_command_menu.gd:181,203-209,233
- game/scripts/combat/battle_manager.gd:208 (_do_magic unreachable)

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
