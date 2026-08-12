# GAP-021: Several battle-utility/field item effects are unimplemented stubs

| Field | Value |
|-------|-------|
| **ID** | GAP-021 |
| **Area** | Items/Economy |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#183](https://github.com/gcko/pendulum-of-despair/issues/183) |
| **Source domains** | items |

## Summary

apply_item_effect handles only restore/revive/cure/light/stat_boost; teleport (Waystone) and preemptive (Sable's Coin) are push_warning stubs, buff_atk/buff_mag warn 'battle-only' with no battle impl, and flee (Smoke Bomb) has no case at all.

## Current state (implementation)

Literal 'not yet implemented' warnings for teleport/preemptive; no flee match arm.

## Desired state (per design)

Each item performs its designed effect (Waystone teleport to entrance, Sable's Coin guaranteed preemptive, Whetstone/Spirit Incense one-battle buff, Smoke Bomb guaranteed flee from non-boss).

## Proposed approach

Implement teleport/preemptive via EventFlags + exploration/battle hooks; route buff_atk/buff_mag and flee through BattleManager.

## Acceptance criteria

- [ ] Waystone teleports to the dungeon entrance
- [x] Sable's Coin forces a preemptive next battle (done by GAP-027/PR #268: using the coin sets `sables_coin_active`, `encounter_handler.gd` forces the preemptive formation and clears the flag, and `can_apply_item_effect()` refuses a second coin while one is active; re-measured 2026-08-12)
- [x] Whetstone/Spirit Incense apply a one-battle buff (`battle_item_command.gd` `do_item()` handles `buff_atk` / `buff_mag` by calling `state.set_buff(target_slot, "atk_mult" / "mag_mult", 1.0 + value / 100.0)` — 1.10 for Whetstone's `value: 10` and 1.15 for Spirit Incense's `15`, matching their `+10% ATK` / `+15% MAG` descriptions; `battle_state.gd` `get_effective_stat()` multiplies the base stat by `<stat>_mult` and `battle_actions.gd` reads `atk` and `mag` through it, so the buff reaches damage and expires with the per-battle state; re-measured 2026-08-12)
- [x] Smoke Bomb flees non-boss battles (`_flee_item()` in `battle_item_command.gd` emits "Can't use that here!" and returns false when `is_boss_battle()`, otherwise consumes the item and calls `exit_battle("flee")`; `test_battle_regressions.gd::test_smoke_bomb_blocked_in_boss_fight` covers the boss guard; re-measured 2026-08-12)

The gap stays open on Waystone alone: `teleport` is still a `push_warning`
stub in `apply_item_effect()`. Waystone is also the one affected item that is
field-only (`usable_in_battle: false`), so the battle path that carries the
other four cannot reach it.

The Summary, Current state and Verification sections are the frozen 2026-06-27
record of the gap as first filed, and are left as written. They read
`inventory_helpers.gd` alone, which no longer tells the whole story: the
battle-side effects live in `battle_item_command.gd` (split out of
`battle_manager.gd` by the GAP-087 extraction), reached from
`battle_manager.gd` via `_get_items().do_item(command)`. The `buff_atk` /
`buff_mag` "battle-only" warnings still in `apply_item_effect()` are
unreachable in production — `party_inventory.gd` `use_item()` refuses any item
without `usable_in_field` before the effect runs, and both items are
`usable_in_field: false` — so they mark the field refusal, not a missing
implementation. Smoke Bomb needs no arm there for the same reason.

## Design references

- docs/story/items.md §Battle Utility (Waystone, Sable's Coin, Spirit Incense, Whetstone, Smoke Bomb)

## Code references

- game/scripts/util/inventory_helpers.gd — `apply_item_effect()`, `can_apply_item_effect()` (the coin's set-flag path and its refuse-while-active guard; the field side, where `teleport` is still a stub)
- game/scripts/combat/battle_item_command.gd — `do_item()` (`buff_atk` / `buff_mag`) and `_flee_item()` (Smoke Bomb): the battle side, dispatched from `battle_manager.gd`
- game/scripts/combat/battle_state.gd — `set_buff()` / `get_effective_stat()`, which is how a buff reaches damage and how it expires
- game/scripts/core/encounter_handler.gd — the `sables_coin_active` consumer that forces the preemptive formation
- game/data/items/consumables.json


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** inventory_helpers.gd apply_item_effect: 'teleport' (line ~111) and 'preemptive' (~113) are push_warning('...not yet implemented') stubs; 'buff_atk'/'buff_mag' (99-101) push_warning '...battle-only (use BattleManager)' with no battle impl; there is no 'flee' match arm at all. data/items/consumables.json confirms the affected items: waystone(teleport), sables_coin(preemptive), smoke_bomb(flee), whetstone(buff_atk), spirit_incense(buff_mag).
- **Notes:** Confirmed. M-effort needing EventFlags/exploration hooks plus BattleManager integration. Not bounded.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
