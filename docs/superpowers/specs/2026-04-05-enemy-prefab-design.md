# Gap 2.3: Enemy Prefab (Battle) — Design Spec

> **Date:** 2026-04-05
> **Gap:** 2.3 (Enemy Prefab)
> **Status:** Approved
> **Source docs:** bestiary/README.md (type rules, stat template), combat-formulas.md (damage, elemental), technical-architecture.md Section 4.2 (scene tree)
> **Architecture ref:** technical-architecture.md Section 4.2

## Problem

The battle scene needs an enemy entity that holds runtime state (HP, MP, statuses), exposes elemental profile queries, handles damage/healing, and resolves drops/steals. This is the battle-side counterpart to the PlayerCharacter prefab.

## Scope

- 1 scene file: `game/scenes/entities/enemy.tscn`
- 1 script file: `game/scripts/entities/enemy.gd`
- 1 placeholder sprite (32x32 red rectangle)
- 1 test file: `game/tests/test_enemy.gd`

**Excluded (deferred to gap 3.3 Battle Scene):**
- AI action selection (weighted-random + boss scripted)
- ATB gauge management
- Damage formula calculation (lives in battle_manager)
- Phase transitions and counter-attacks
- Target selection logic

---

## Scene Tree

```
Enemy (Node2D)
├── Sprite2D                    — 32x32 placeholder sprite
├── AnimationPlayer             — idle, hit_reaction, death stubs
└── enemy.gd
```

### Node Configuration

| Node | Property | Value | Notes |
|------|----------|-------|-------|
| Enemy | process_mode | INHERIT | Pauses when battle pauses |
| Sprite2D | texture | placeholder_enemy.png | 32x32 red rectangle |
| Sprite2D | centered | true | |

No collision shapes — enemies don't move, only animate. Instantiated at runtime by the battle scene.

---

## GDScript API

### Signals

```gdscript
signal damage_taken(amount: int)
signal healed(amount: int)
signal status_applied(status_name: String, duration: int)
signal status_removed(status_name: String)
signal died
```

### Constants

```gdscript
## Fixed critical hit rate for all enemies (per combat-formulas.md).
const ENEMY_CRIT_RATE: float = 0.05
```

### Properties

```gdscript
## Enemy ID loaded from DataManager.
var enemy_id: String = ""

## Act the enemy was loaded from (for DataManager lookup).
var enemy_act: String = ""

## Loaded enemy data dictionary (immutable base stats).
var enemy_data: Dictionary = {}

## Runtime mutable state.
var current_hp: int = 0
var current_mp: int = 0

## Active status effects: [{name: String, remaining_turns: int}]
var active_statuses: Array[Dictionary] = []

## Computed from current_hp > 0.
var is_alive: bool = true
```

### Public Methods

```gdscript
## Initialize the enemy with data from DataManager.
func initialize(p_enemy_id: String, p_act: String) -> void

## --- Stat Queries ---

## Get the enemy's base stats dictionary.
func get_stats() -> Dictionary

## Get the enemy's type (beast, undead, construct, etc.).
func get_type() -> String

## Get the enemy's display name.
func get_display_name() -> String

## --- Elemental Profile ---

## Check if the enemy is weak to an element.
func is_weak_to(element: String) -> bool

## Check if the enemy is resistant to an element.
func is_resistant_to(element: String) -> bool

## Check if the enemy is immune to an element.
func is_immune_to(element: String) -> bool

## Check if the enemy absorbs an element.
func absorbs(element: String) -> bool

## Get the damage multiplier for an element.
## Returns: 1.5 (weak), 0.75 (resist), 0.0 (immune), -1.0 (absorb), 1.0 (neutral)
func get_element_multiplier(element: String) -> float

## --- Status Effects ---

## Check if the enemy is immune to a status effect.
func is_immune_to_status(status: String) -> bool

## Apply a status effect. Returns true if applied, false if immune.
func apply_status(status_name: String, duration: int) -> bool

## Remove a status effect by name.
func remove_status(status_name: String) -> void

## Tick all status durations down by 1. Removes expired statuses.
func tick_statuses() -> void

## Check if a status is currently active.
func has_status(status_name: String) -> bool

## --- Damage & Healing ---

## Apply damage. Clamps HP to 0. Emits damage_taken and died signals.
func take_damage(amount: int) -> void

## Apply healing. Clamps HP to max. Emits healed signal.
func heal(amount: int) -> void

## --- Rewards ---

## Roll for a steal attempt. Returns {item_id, success} or {item_id: "", success: false}.
func roll_steal(tier: String) -> Dictionary

## Roll for a drop on death. Returns {item_id, success} or {item_id: "", success: false}.
func roll_drop() -> Dictionary
```

---

## Elemental Multiplier Logic

Per combat-formulas.md:

```
func get_element_multiplier(element: String) -> float:
    if element in enemy_data.get("absorb", []):
        return -1.0  # heals enemy
    if element in enemy_data.get("immunities", []):
        return 0.0   # no damage
    if element in enemy_data.get("resistances", []):
        return 0.75
    if element in enemy_data.get("weaknesses", []):
        return 1.5
    return 1.0  # neutral
```

Note: Type-based elemental bonuses (e.g., Construct +1.25x vs Storm) are applied by the battle damage calculator, not the enemy entity. The entity just reports its profile.

---

## Status Immunity

Enemy data includes `status_immunities` array. Additionally, enemy types have default immunities per bestiary/README.md:

| Type | Default Immunities |
|------|--------------------|
| Beast | — |
| Undead | Poison, Death |
| Construct | Poison, Sleep, Confusion, Berserk, Despair |
| Spirit | Poison, Petrify |
| Humanoid | — |
| Pallor | Despair, Death |
| Elemental | Petrify |
| Boss | Death, Petrify, Stop, Sleep, Confusion |

`is_immune_to_status()` checks BOTH the per-enemy `status_immunities` array AND the type default immunities.

Type default immunities are defined as a const dictionary in the script, not loaded from JSON.

---

## Drop/Steal Resolution

```gdscript
func roll_steal(tier: String) -> Dictionary:
    var steal_data: Dictionary = enemy_data.get("steal", {})
    var tier_data: Dictionary = steal_data.get(tier, {})
    if tier_data.is_empty():
        return {"item_id": "", "success": false}
    var rate: int = tier_data.get("rate", 0)
    var success: bool = randi() % 100 < rate
    return {
        "item_id": tier_data.get("item_id", "") if success else "",
        "success": success
    }
```

---

## Placeholder Sprite

1 PNG file, 32x32 pixels, dark red with 1px darker border:
- Color: #993333 fill, #662222 border
- Location: `game/assets/sprites/enemies/placeholder_enemy.png`

---

## Tests

`game/tests/test_enemy.gd`:

1. **test_initialize_loads_data** — Initialize with "ley_vermin" from act_i, verify enemy_data populated
2. **test_current_hp_matches_base** — After init, current_hp == base hp from data
3. **test_take_damage_reduces_hp** — Take 10 damage, verify HP reduced
4. **test_take_damage_clamps_to_zero** — Take massive damage, HP = 0, is_alive = false
5. **test_died_signal_emitted** — Verify died signal fires on lethal damage
6. **test_heal_clamps_to_max** — Heal past max HP, verify clamped
7. **test_elemental_weakness** — Ley Vermin weak to frost, verify multiplier 1.5
8. **test_elemental_neutral** — Non-weak element returns 1.0
9. **test_status_immunity** — Construct immune to Poison, verify is_immune_to_status
10. **test_apply_status_success** — Apply non-immune status, verify active
11. **test_roll_steal** — Verify steal returns dict with item_id and success bool
12. **test_tick_statuses** — Apply status with duration 2, tick twice, verify removed

---

## Verification Checklist

- [ ] Scene loads in Godot editor without errors
- [ ] Node2D scene tree matches spec (Sprite2D, AnimationPlayer)
- [ ] Sprite2D displays 32x32 placeholder
- [ ] initialize() loads from DataManager correctly
- [ ] current_hp/current_mp set from base stats
- [ ] Elemental multiplier returns correct values for all 5 cases
- [ ] Status immunity checks both per-enemy and type defaults
- [ ] take_damage emits signal and clamps to 0
- [ ] died signal emits on lethal damage
- [ ] heal clamps to max HP
- [ ] roll_steal/roll_drop return correct dictionary format
- [ ] All code passes gdlint + gdformat
- [ ] Tests pass
