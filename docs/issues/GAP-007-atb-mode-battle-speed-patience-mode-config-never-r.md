# GAP-007: ATB Mode / Battle Speed / Patience Mode config never reaches the battle system

| Field | Value |
|-------|-------|
| **ID** | GAP-007 |
| **Area** | Combat |
| **Severity** | HIGH |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | save, combat |

## Summary

atb_system exposes set_atb_mode/set_battle_speed and _should_pause handles wait/patience, but battle_manager never calls them with player config; _atb_mode stays 'active' and _battle_speed stays 3 every battle.

## Current state (implementation)

battle_manager only forwards command/submenu open state; grep for get_config|atb_mode|battle_speed|patience returns nothing. The Patience cascade in menu_config only rewrites the config dict.

## Desired state (per design)

Battle init reads PartyState.get_config() and calls set_atb_mode (patience?'patience':config.atb_mode) and set_battle_speed (patience?6:config.battle_speed); wait/patience actually pause gauges at decision points.

## Proposed approach

In battle_manager._ready/init, read config and configure the ATB node; also pause real-time status timers via should_pause_timers() during command/submenu selection.

## Acceptance criteria

- [ ] Wait mode pauses all gauges during submenu selection
- [ ] Patience mode pauses gauges on the top-level command menu
- [ ] Battle Speed config changes observed turn pacing
- [ ] A test asserts config values reach the ATB node

## Design references

- docs/story/accessibility.md §3 (Patience Mode), §7
- docs/story/save-system.md §2 (Battle Speed 1-6, ATB Active/Wait)

## Code references

- game/scripts/combat/atb_system.gd:94-99,182-187
- game/scripts/combat/battle_manager.gd:37,53,111,133,154
- game/scripts/ui/menu_config.gd:203-254

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
