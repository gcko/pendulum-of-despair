# Encounter → Battle → Rewards Loop Integration

> **Date:** 2026-04-06
> **Approach:** A — Minimal Exploration-Centric
> **Scope:** Wire the deferred integration items from gaps 3.2, 3.3,
> and 3.4 to create a complete random-encounter gameplay loop.
> **Branch:** `feature/game-designer-tier-3-continued-3`

## Overview

Connect the exploration danger counter, random encounters, battle
entry/exit, and post-battle reward application (XP, gold, drops,
level-ups) into a single end-to-end loop. A player walking through a
dungeon accumulates danger, triggers a random encounter, fights
enemies, and returns to the map with rewards applied.

## Architecture

```
Exploration (owns danger counter)
  ├── EncounterSystem (static helper — roll, check, select)
  ├── DataManager.load_encounters() (encounter table JSON)
  └── GameManager.change_core_state(BATTLE, transition_data)
          │
          ▼
      BattleManager (unchanged)
          │ emits victory/defeat/flee_result
          │ calls _exit_battle() → GameManager.change_core_state(EXPLORATION)
          ▼
Exploration (reads transition_data on return)
  └── PartyState.distribute_battle_rewards() → add_xp, add_gold, add_item
```

No new autoloads. One small BattleManager change (add `_earned_drops`
to transition data). One new static helper, four modified files.

## New File: `game/scripts/combat/encounter_system.gd`

RefCounted static helper — no instance state. Exploration owns the
danger counter value and passes it in.

### Public API

```gdscript
extends RefCounted
## Static helpers for random encounter logic.
## Danger counter, encounter checks, group selection, formation rolls.

## Check if an encounter triggers this step.
## Returns true if random_int(0,255) < floor(danger_counter / 256).
## Source: combat-formulas.md § Danger Counter.
static func check_encounter(danger_counter: int) -> bool

## Calculate the danger increment for one step.
## final = floor(base_increment × act_scale × accessory_mod)
## Source: combat-formulas.md § Danger Counter.
static func roll_increment(
    base_increment: int, act_scale: float, accessory_mod: float
) -> int

## Select an encounter group via weighted random from the groups array.
## Each group has a "weight" field. Returns the selected group Dictionary.
## Source: encounter table JSON files.
static func select_encounter_group(groups: Array) -> Dictionary

## Roll formation type: "normal", "back_attack", or "preemptive".
## Uses formation_rates dict: {normal: float, back_attack: float, preemptive: float}.
## Source: combat-formulas.md § Battle Formations.
static func roll_formation(formation_rates: Dictionary) -> String

## Calculate encounter rate modifier from active party equipment.
## Checks for Ward Talisman (×0.5), Infiltrator's Cloak (×0.5),
## Lure Talisman (×2.0). Ward + Infiltrator don't stack (same slot).
## Modifiers stack multiplicatively.
## Source: combat-formulas.md § Encounter rate modifiers.
static func get_accessory_modifier(party: Array[Dictionary]) -> float
```

### Formulas (from combat-formulas.md)

**Danger check (each step):**
```
if randi_range(0, 255) < int(danger_counter / 256):
    trigger encounter
    danger_counter = 0
```

**Increment:**
```
final_increment = int(float(base_increment) * act_scale * accessory_mod)
```

**Weighted group selection:**
```
roll = randf() * total_weight
cumulative = 0
for group in groups:
    cumulative += group.weight
    if roll < cumulative: return group  # Strict < avoids bias at weight boundaries
```

**Formation roll:**
```
roll = randf() * 100.0
if roll < preemptive: return "preemptive"
if roll < preemptive + back_attack: return "back_attack"
return "normal"
```

**Accessory modifier:**
```
mod = 1.0
has_ward = false, has_cloak = false, has_lure = false
for member in active_party:
    check accessory + crystal slots for modifier items
if has_ward or has_cloak: mod *= 0.5  # don't stack with each other
if has_lure: mod *= 2.0
return mod
```

## Modified: `game/scripts/core/exploration.gd`

### New State

```gdscript
const EncounterSystem = preload("res://scripts/combat/encounter_system.gd")

var _danger_counter: int = 0
var _last_player_tile: Vector2i = Vector2i(-999, -999)
var _encounter_config: Dictionary = {}  # current floor's encounter data
```

### Step Detection

In `_physics_process()` (new method):
```
if _player == null: return
var current_tile: Vector2i = Vector2i(_player.position) / 16
if current_tile == _last_player_tile: return
_last_player_tile = current_tile
_process_step()
```

### Encounter Check (`_process_step()`)

```
if _encounter_config.is_empty(): return
var base: int = _encounter_config.get("danger_increment", 0)
if base <= 0: return
var act_scale: float = 1.0  # TODO: read from current act
var acc_mod: float = EncounterSystem.get_accessory_modifier(
    PartyState.get_active_party()
)
_danger_counter += EncounterSystem.roll_increment(base, act_scale, acc_mod)
if EncounterSystem.check_encounter(_danger_counter):
    _trigger_random_encounter()
```

### Battle Entry (`_trigger_random_encounter()`)

```
var groups: Array = _encounter_config.get("groups", [])
if groups.is_empty(): return
var group: Dictionary = EncounterSystem.select_encounter_group(groups)
var rates: Dictionary = _encounter_config.get("formation_rates", {})
var formation: String = EncounterSystem.roll_formation(rates)
_danger_counter = 0
var transition: Dictionary = {
    "encounter_group": group.get("enemies", []),
    "formation_type": formation,
    "return_map_id": _current_map_id,
    "return_position": _player.position,
    "enemy_act": "act_i",  # TODO: read from current act when act tracking exists
    "encounter_source": "random",
}
GameManager.change_core_state(GameManager.CoreState.BATTLE, transition)
```

### Battle Return Handling

In `_initialize_from_transition_data()`, add handling for battle
return data:

```
if data.has("result"):
    var result: String = data.get("result", "")
    match result:
        "victory":
            var rewards: Dictionary = {
                "xp": data.get("earned_xp", 0),
                "gold": data.get("earned_gold", 0),
                "drops": data.get("earned_drops", []),
            }
            PartyState.distribute_battle_rewards(rewards)
        "faint":
            SaveManager.faint_and_fast_reload()
            return  # FFR handles its own state transition
        "flee":
            pass  # return to map, no rewards
    _danger_counter = 0
```

### Encounter Config Loading

In `_load_map()`, after loading the map scene, load encounter data:

```
_encounter_config = {}
var encounters: Dictionary = DataManager.load_encounters(_current_map_id)
if not encounters.is_empty():
    # Find floor config matching current floor metadata
    var floor_id: String = _get_current_floor_id()
    for floor_data: Variant in encounters.get("floors", []):
        if floor_data is Dictionary and floor_data.get("floor_id", "") == floor_id:
            _encounter_config = floor_data
            break
    # Fallback: use first floor if no match
    if _encounter_config.is_empty():
        var floors: Array = encounters.get("floors", [])
        if floors.size() > 0 and floors[0] is Dictionary:
            _encounter_config = floors[0]
```

Maps without encounter JSON files (towns, safe zones) get an empty
`_encounter_config` — danger counter stays at 0, no encounters trigger.

## Modified: `game/scripts/combat/battle_manager.gd`

Small change: store drops as instance var and include in exit transition.

### Changes

1. Add `var _earned_drops: Array[Dictionary] = []` instance variable.
2. In `_handle_victory()`, store drops: `_earned_drops = drops`.
3. In `_exit_battle()`, add `"earned_drops": _earned_drops` to transition dict.
4. Reset `_earned_drops = []` at start of `_exit_battle()`.

This ensures exploration can read drops from transition_data on return.

## Modified: `game/scripts/autoload/inventory_helpers.gd`

### New Static Methods

```gdscript
## Add XP to a party member, processing level-ups.
## Returns {leveled_up: bool, old_level: int, new_level: int}.
## Source: progression.md § XP Distribution, § Two-Phase XP Curve.
static func add_xp_to_member(member: Dictionary, amount: int) -> Dictionary

## Distribute battle rewards across active and reserve party.
## Active alive members: full XP. KO'd: 0 XP. Reserve: 50% XP.
## Gold: full amount added. Drops: each item added with qty 1.
## Returns {level_ups: Array, gold_gained: int, items_gained: Array}.
## Source: progression.md § XP Distribution Rules.
static func distribute_rewards(
    rewards: Dictionary,
    active_party: Array[Dictionary],
    reserve_party: Array[Dictionary],
) -> Dictionary
```

### `add_xp_to_member()` Logic

```
var level: int = member.get("level", 1)
var xp: int = member.get("current_xp", 0) + amount
var old_level: int = level
while level < 150:
    var needed: int = xp_to_next_level(level)
    if needed <= 0 or xp < needed: break
    xp -= needed
    level += 1
member["current_xp"] = xp
member["level"] = level
if level > old_level:
    # Recalculate stats using character's base/growth from JSON
    var char_data: Dictionary = DataManager.load_character(member.get("character_id", ""))
    var base: Dictionary = char_data.get("base_stats", {})
    var growth: Dictionary = char_data.get("growth", {})
    var new_stats: Dictionary = calculate_stats_at_level(base, growth, level)
    member["max_hp"] = new_stats.get("hp", member.get("max_hp", 1))
    member["max_mp"] = new_stats.get("mp", member.get("max_mp", 0))
    for stat_key in ["atk", "def", "mag", "mdef", "spd", "lck"]:
        member[stat_key] = new_stats.get(stat_key, member.get(stat_key, 0))
return {leveled_up = level > old_level, old_level = old_level, new_level = level}
```

### `distribute_rewards()` Logic

```
var level_ups: Array = []
var xp_amount: int = rewards.get("xp", 0)
var gold_amount: int = rewards.get("gold", 0)
var drops: Array = rewards.get("drops", [])

# Active party: full XP if alive, 0 if KO'd
for member in active_party:
    if member.get("current_hp", 0) > 0:
        var result: Dictionary = add_xp_to_member(member, xp_amount)
        if result.get("leveled_up", false):
            level_ups.append({
                "character_id": member.get("character_id", ""),
                "old_level": result.old_level,
                "new_level": result.new_level,
            })

# Reserve party: 50% XP
for member in reserve_party:
    var result: Dictionary = add_xp_to_member(member, xp_amount / 2)
    if result.get("leveled_up", false):
        level_ups.append({...same pattern...})

return {level_ups = level_ups, gold_gained = gold_amount, items_gained = drops}
```

PartyState gets a thin wrapper:
```gdscript
func distribute_battle_rewards(rewards: Dictionary) -> Dictionary:
    var active: Array[Dictionary] = get_active_party()
    var reserve: Array[Dictionary] = get_reserve_party()
    var result: Dictionary = Helpers.distribute_rewards(rewards, active, reserve)
    add_gold(rewards.get("gold", 0))
    for drop: Variant in rewards.get("drops", []):
        if drop is Dictionary:
            add_item(drop.get("id", ""), 1)
    return result
```

## Modified: `game/scripts/autoload/data_manager.gd`

One new method following existing patterns:

```gdscript
## Load encounter table for a dungeon/area.
func load_encounters(area_id: String) -> Dictionary:
    var path: String = "res://data/encounters/%s.json" % area_id
    return load_json(path)
```

## Not In Scope

These items are acknowledged deferred and do NOT block the core loop:

| Item | Reason | Future Gap |
|------|--------|------------|
| Veilstep spell modifier | No field spell casting | 3.4 Phase 2 |
| Ley Stag mount (×0 encounters) | No mount system | 4.3 |
| Tunnel Map key item modifier | No key item field effects | 4.1+ |
| Kole's patrol quest modifier | No quest system | 4.4 |
| Sable's Coin preemptive guarantee | Consumable stub exists, not wired | 4.1 |
| Act scaling multiplier | No act tracking in exploration | 4.1 |
| location_mod factor | combat-formulas.md references but never defines; treat as 1.0 | Future |
| Smoke Bomb / Smokeveil 100% flee | Items/spells not wired to flee | 3.4 Phase 2 |
| Victory screen UI (XP bars, level-up fanfare) | UI polish | 4.1 |
| Auto-save on dungeon floor entry | Save system works, trigger not wired | 4.1 |

## File Summary

| File | Action | Est. Lines |
|------|--------|-----------|
| `game/scripts/combat/encounter_system.gd` | NEW | ~80 |
| `game/scripts/core/exploration.gd` | MODIFY | +50 (~340 total) |
| `game/scripts/combat/battle_manager.gd` | MODIFY | +5 (drops in transition) |
| `game/scripts/autoload/inventory_helpers.gd` | MODIFY | +55 (~305 total) |
| `game/scripts/autoload/party_state.gd` | MODIFY | +15 (~413 total) |
| `game/scripts/autoload/data_manager.gd` | MODIFY | +5 |
| `game/tests/test_encounter_system.gd` | NEW | ~80 |
| `game/tests/test_battle_rewards.gd` | NEW | ~60 |

**PartyState concern:** Adding `distribute_battle_rewards()` and
`get_reserve_party()` pushes party_state.gd to ~413 lines (over
400-line gdlint limit). The heavy logic lives in
`inventory_helpers.gd` static methods; PartyState wrappers are thin
(~5 lines each). If still over limit, extract `get_reserve_party()`
body into helpers.

## Design Decisions

1. **No new autoload.** EncounterSystem is a preloaded RefCounted,
   not an autoload. Only exploration uses it.
2. **Step-based, not time-based.** Per combat-formulas.md, danger
   increments per step (16px tile movement), not per frame/second.
3. **Battle manager unchanged.** It already emits the right signals
   and passes the right transition data. We just read what it sends.
4. **Danger counter owned by exploration.** Resets on battle, map
   change, and game load. Not persisted in save data (per
   combat-formulas.md — counter resets each battle).
5. **act_scale hardcoded 1.0.** No act-tracking system exists yet.
   Encounter data already has per-floor danger_increment values that
   implicitly handle difficulty scaling. Act multiplier is future work.
6. **Rewards applied immediately on return.** No victory screen UI
   yet — rewards are silently applied to PartyState. Victory screen
   is UI polish for gap 4.1.
