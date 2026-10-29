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

### Slice 158a (Ability submenu, dispatcher, Cael's Rally)

The Ability command now opens a sub-menu of the acting character's known abilities (passives excluded) with their cost, graying out what cannot be paid or is not built yet. `BattleAbilityCommand` is the dispatcher: it checks an ability can be issued, pays its cost by `cost_type`, and hands it to the resolver for its `command`. Cael's Rally and, since slice 158b, Edren's Bulwark have resolvers, and the `mp` and `ap` cost types are paid; Forgewright, Tricks, Spiritcall and Arcanum (slices 158c-f) are listed disabled and refused. Hold the Line, Press Forward, Second Wind and Unbreakable are built to abilities.md § Cael — Rally: every living ally gets the full turns and counts them on its own turns, one Rally is active at a time, and it ends when Cael faints or is Silenced or put to Sleep. A Rally cannot be issued while Cael is Silenced. `BattleRally` holds those in-force rules behind `BattleState`'s ability hooks, which slices b-f extend. Vanguard Strike is a standalone command rather than a Rally and is not built yet.

### Slice 158b (Edren's Bulwark)

Every Bulwark ability is built to abilities.md § Edren — Bulwark, including the rulings paragraph recorded there from #158, with `BattleBulwark` behind the same ability hooks. Ironwall and Rampart redirect their share of an enemy hit to Edren, and a hit on Edren himself in a stance counts as absorbed. He earns AP for each absorbed hit, one more for a heavy one, and loses 1 on a turn that follows no damage. Riposte (armed), Aegis Veil, Shatter Guard, Steadfast Resolve and Oathkeeper spend that AP, and the `ap` cost type is paid. Oathkeeper's second Attack swing is in `BattlePlayerActions.do_attack`.

## Desired state (per design)

Each command opens its sub-ability list and executes documented mechanics, tracking per-character resources and applying stances, Rally buffs, Forgewright devices, Spirit Favor, Tricks/Steal, and Weave Gauge meta-magic per abilities.md §1.

## Proposed approach

Build per-command executor modules reading/writing battle_state resource fields, plus a stance/device subsystem on the ATB. Stage incrementally: Edren stances+AP, Cael Rally buffs, then resource-gated systems. Depends on submenu wiring (GAP-001).

## Acceptance criteria

- [ ] Each character's command opens its sub-ability list, not a basic attack
- [ ] Per-character resource (AP/AC/WG/Favor/cooldown) is tracked and spent
- [x] Edren stance + Riposte and Cael Rally buffs function as a first vertical slice
- [ ] Tests cover at least one ability per command system

## Design references

- docs/story/abilities.md §1 (6 command systems, 44 sub-abilities, AP/AC/WG/Favor/Stance/Rally resources)

## Code references

- game/scripts/combat/battle_ability_command.gd — `do_ability()` (the dispatcher: availability, `pay()` by cost_type, one resolver per command)
- game/scripts/combat/battle_rally.gd — `start()` (Cael's Rally while in force: duration, replacement and end conditions, via BattleState's ability hooks)
- game/scripts/combat/battle_bulwark.gd — `guard_for()` (Edren's Bulwark: stances, absorption, AP, Riposte, Shatter Guard and Oathkeeper, via BattleState's ability hooks and the enemy-hit seam in BattleActions)
- game/scripts/ui/battle_submenu_items.gd — `abilities()` (the Ability sub-menu's entries)
- game/scripts/combat/battle_state.gd — `begin_turn()` (the per-turn hook fan-out; ac/favor/stolen_goods still unused until slices c-f)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** battle_manager.gd:154 'ability': ok = _do_attack(actor_id, command) — the unique command routes to basic attack. battle_command_menu.gd:182-183 'ability' branch calls _show_submenu() with an unpopulated list (same set_submenu_items gap). battle_state.gd:55-63 allocates ap/ac(=12)/wg/favor/stolen_goods/active_rally/active_stance; only wg has helpers (gain_weave_gauge 271-280) and no stance/device/steal/rally executor exists.
- **Notes:** XL epic, depends on GAP-001 submenu wiring. Severity refined BLOCKER->HIGH: it degrades to a working basic attack rather than crashing, but six characters' core identity mechanics are absent. Not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
