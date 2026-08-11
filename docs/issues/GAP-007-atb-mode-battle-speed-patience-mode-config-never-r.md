# GAP-007: ATB Mode / Battle Speed / Patience Mode config never reaches the battle system

| Field | Value |
|-------|-------|
| **ID** | GAP-007 |
| **Area** | Combat |
| **Severity** | HIGH |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | resolved — #160 |
| **GitHub Issue** | [#160](https://github.com/gcko/pendulum-of-despair/issues/160) |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** battle_manager.gd _ready (lines 42-89) wires submenu_open (line 53 set_submenu_open) but never calls set_atb_mode or set_battle_speed and never reads PartyState config (grep 'set_atb_mode|set_battle_speed|get_config' in battle_manager.gd found only should_pause_timers at line 98). atb_system defaults stay _atb_mode='active' (line 30) and _battle_speed=3 (line 27). Because mode is 'active', _should_pause (atb_system.gd:181-187) always returns false, so wait/patience never pause and the player's Battle Speed setting never changes pacing.
- **Notes:** Confirmed: config never reaches ATB. Not fixNow: requires reading PartyState.get_config in battle init plus verifying pause behavior with tests — bounded but feature-shaped, touching battle init that the GUT suite exercises.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The durable, maintained anchors are the file-plus-symbol bullets under **Code references**: those must name a file that exists and a symbol that file actually defines, and `scripts/quality-gates/check_stale_counts.py` fails the build if they do not. Always verify against current code before acting._
