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
| **GitHub Issue** | _(set during migration)_ |
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

- game/scripts/autoload/inventory_helpers.gd:99-114
- game/data/items/consumables.json:487-700


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** inventory_helpers.gd apply_item_effect: 'teleport' (line ~111) and 'preemptive' (~113) are push_warning('...not yet implemented') stubs; 'buff_atk'/'buff_mag' (99-101) push_warning '...battle-only (use BattleManager)' with no battle impl; there is no 'flee' match arm at all. data/items/consumables.json confirms the affected items: waystone(teleport), sables_coin(preemptive), smoke_bomb(flee), whetstone(buff_atk), spirit_incense(buff_mag).
- **Notes:** Confirmed. M-effort needing EventFlags/exploration hooks plus BattleManager integration. Not bounded.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
