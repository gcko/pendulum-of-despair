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
- [ ] Sable's Coin forces a preemptive next battle
- [ ] Whetstone/Spirit Incense apply a one-battle buff
- [ ] Smoke Bomb flees non-boss battles

## Design references

- docs/story/items.md §Battle Utility (Waystone, Sable's Coin, Spirit Incense, Whetstone, Smoke Bomb)

## Code references

- game/scripts/util/inventory_helpers.gd — `apply_item_effect()`
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
