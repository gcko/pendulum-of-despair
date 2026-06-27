# GAP-002: Six unique character commands (Bulwark/Rally/Forgewright/Spiritcall/Tricks/Arcanum) not implemented in battle

| Field | Value |
|-------|-------|
| **ID** | GAP-002 |
| **Area** | Combat |
| **Severity** | BLOCKER (verified: HIGH) |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#158](https://github.com/gcko/pendulum-of-despair/issues/158) |
| **Source domains** | combat |

## Summary

Each character's unique command is correctly labeled but routes to _do_attack; the resource fields (AP/AC/WG/Favor/stance/rally) are allocated but never read or mutated. No sub-ability, stance, device, steal, or meta-magic logic exists.

## Current state (implementation)

battle_manager routes 'ability' to _do_attack (basic attack). The ability submenu is never populated (same set_submenu_items gap). battle_state's ap/ac/wg/favor/stolen_goods/active_rally/active_stance are written nowhere in combat. menu_abilities.gd is a view-only overlay.

## Desired state (per design)

Each command opens its sub-ability list and executes documented mechanics, tracking per-character resources and applying stances, Rally buffs, Forgewright devices, Spirit Favor, Tricks/Steal, and Weave Gauge meta-magic per abilities.md §1.

## Proposed approach

Build per-command executor modules reading/writing battle_state resource fields, plus a stance/device subsystem on the ATB. Stage incrementally: Edren stances+AP, Cael Rally buffs, then resource-gated systems. Depends on submenu wiring (GAP-001).

## Acceptance criteria

- [ ] Each character's command opens its sub-ability list, not a basic attack
- [ ] Per-character resource (AP/AC/WG/Favor/cooldown) is tracked and spent
- [ ] Edren stance + Riposte and Cael Rally buffs function as a first vertical slice
- [ ] Tests cover at least one ability per command system

## Design references

- docs/story/abilities.md §1 (6 command systems, 44 sub-abilities, AP/AC/WG/Favor/Stance/Rally resources)

## Code references

- game/scripts/combat/battle_manager.gd:151-152 ('ability' -> _do_attack)
- game/scripts/ui/battle_command_menu.gd:182-184
- game/scripts/combat/battle_state.gd:55-63 (resource fields unused)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** battle_manager.gd:154 'ability': ok = _do_attack(actor_id, command) — the unique command routes to basic attack. battle_command_menu.gd:182-183 'ability' branch calls _show_submenu() with an unpopulated list (same set_submenu_items gap). battle_state.gd:55-63 allocates ap/ac(=12)/wg/favor/stolen_goods/active_rally/active_stance; only wg has helpers (gain_weave_gauge 271-280) and no stance/device/steal/rally executor exists.
- **Notes:** XL epic, depends on GAP-001 submenu wiring. Severity refined BLOCKER->HIGH: it degrades to a working basic attack rather than crashing, but six characters' core identity mechanics are absent. Not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
