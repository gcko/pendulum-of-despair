# GAP-001: Magic command is non-functional in battle — spell submenu never populated

| Field | Value |
|-------|-------|
| **ID** | GAP-001 |
| **Area** | Combat |
| **Severity** | BLOCKER |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | resolved — #157 |
| **GitHub Issue** | [#157](https://github.com/gcko/pendulum-of-despair/issues/157) |
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

- game/scripts/ui/battle_command_menu.gd — `set_submenu_items()` (the spell-list setter the finding recorded as having zero callers)
- game/scripts/combat/battle_magic_command.gd — `do_magic()` (was battle_manager._do_magic, unreachable at the time of the finding)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** BLOCKER
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** battle_command_menu.gd:233 set_submenu_items() is the ONLY occurrence in scripts/ (grep across scripts/ + scenes/ found no callers). _confirm_command 'magic' branch (line 181) calls _show_submenu() which renders _submenu_items, but that array is never populated, and _handle_submenu_input (line 103) guards is_empty() so only cancel works. _do_magic IS wired in _on_ui_command (battle_manager.gd:140), so the issue's 'dead code' phrasing is slightly off, but in practice it is unreachable because no magic command dict with a spell is ever emitted. Net: Magic is unusable in battle.
- **Notes:** Core claim TRUE (submenu never populated, magic unusable). Minor overstatement: _do_magic is wired into the command router, not literally dead. Not fixNow: requires building per-character spell list (spell_helpers/DataManager.load_spells), MP gating, and a battle test — feature work.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Always verify against current code before acting._
