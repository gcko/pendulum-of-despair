# Gap 2.3: Enemy Prefab (Battle) — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a battle enemy entity with runtime state tracking, elemental profile queries, status management, damage/healing, and drop/steal resolution.

**Architecture:** Node2D with Sprite2D and AnimationPlayer. GDScript loads enemy data from DataManager, tracks mutable HP/MP/status state, exposes elemental and type queries. AI and damage formulas deferred to gap 3.3 (Battle Scene). Follows player_character.gd patterns (signals, @onready, initialize).

**Tech Stack:** Godot 4.6, GDScript, GUT 9.3.0 (testing), gdlint 4.5.0 (linting)

**Spec:** `docs/superpowers/specs/2026-04-05-enemy-prefab-design.md`

---

## File Structure

| Action | File | Purpose |
|--------|------|---------|
| Create | `game/scripts/entities/enemy.gd` | Enemy entity script |
| Create | `game/scenes/entities/enemy.tscn` | Scene with Node2D + Sprite2D + AnimationPlayer |
| Create | `game/assets/sprites/enemies/placeholder_enemy.png` | 32x32 red placeholder |
| Create | `game/tests/test_enemy.gd` | Unit tests |
| Modify | `docs/analysis/game-dev-gaps.md` | Update gap 2.3 status |

---

## Chunk 1: Entity Script + Scene

### Task 1: Create placeholder sprite

**Files:**
- Create: `game/assets/sprites/enemies/placeholder_enemy.png`

Generate a 32x32 dark red PNG (fill #993333, border #662222) using the same pure-Python PNG generator used for player character placeholders.

- [ ] **Step 1:** Create `game/assets/sprites/enemies/` directory
- [ ] **Step 2:** Generate placeholder_enemy.png (32x32)
- [ ] **Step 3:** Verify file exists and is 32x32

---

### Task 2: Create enemy.gd

**Files:**
- Create: `game/scripts/entities/enemy.gd`
- Read: `docs/superpowers/specs/2026-04-05-enemy-prefab-design.md`
- Read: `game/scripts/entities/player_character.gd` (pattern reference)
- Read: `game/data/enemies/act_i.json` (understand data schema)
- Read: `docs/story/bestiary/README.md` (type default immunities)

**Agent instructions:** Write the full enemy entity GDScript. Follow the player_character.gd patterns exactly: @onready vars, initialize() method, signals, defensive coding.

The script must include:

**Signals:** `damage_taken(amount)`, `healed(amount)`, `status_applied(status_name, duration)`, `status_removed(status_name)`, `died`

**Constants:**
- `ENEMY_CRIT_RATE: float = 0.05`
- `TYPE_IMMUNITIES: Dictionary` — maps enemy type to default status immunities per bestiary/README.md

**Properties:** `enemy_id`, `enemy_act`, `enemy_data`, `current_hp`, `current_mp`, `active_statuses`, `is_alive`

**Methods (in order per style guide):**

Virtual methods first:
- (none needed for this entity — no _process or _physics_process)

Public methods:
- `initialize(p_enemy_id, p_act)` — load from DataManager, set current_hp/mp
- `get_stats()`, `get_type()`, `get_display_name()`
- `is_weak_to(element)`, `is_resistant_to(element)`, `is_immune_to(element)`, `absorbs(element)`, `get_element_multiplier(element)`
- `is_immune_to_status(status)`, `apply_status(status_name, duration)`, `remove_status(status_name)`, `tick_statuses()`, `has_status(status_name)`
- `take_damage(amount)`, `heal(amount)`
- `roll_steal(tier)`, `roll_drop()`

**TYPE_IMMUNITIES dict:**
```gdscript
const TYPE_IMMUNITIES: Dictionary = {
    "beast": [],
    "undead": ["poison", "death"],
    "construct": ["poison", "sleep", "confusion", "berserk", "despair"],
    "spirit": ["poison", "petrify"],
    "humanoid": [],
    "pallor": ["despair", "death"],
    "elemental": ["petrify"],
    "boss": ["death", "petrify", "stop", "sleep", "confusion"],
}
```

**Data loading pattern:**
```gdscript
func initialize(p_enemy_id: String, p_act: String) -> void:
    enemy_id = p_enemy_id
    enemy_act = p_act
    var enemies: Array = DataManager.load_enemies(p_act)
    for entry: Dictionary in enemies:
        if entry.get("id", "") == enemy_id:
            enemy_data = entry
            break
    if enemy_data.is_empty():
        push_error("Enemy: Failed to load '%s' from act '%s'" % [enemy_id, p_act])
        return
    current_hp = enemy_data.get("hp", 0)
    current_mp = enemy_data.get("mp", 0)
    is_alive = current_hp > 0
    _load_placeholder_sprite()
```

**Elemental multiplier (must match combat-formulas.md exactly):**
```gdscript
func get_element_multiplier(element: String) -> float:
    if element in enemy_data.get("absorb", []):
        return -1.0
    if element in enemy_data.get("immunities", []):
        return 0.0
    if element in enemy_data.get("resistances", []):
        return 0.75
    if element in enemy_data.get("weaknesses", []):
        return 1.5
    return 1.0
```

RULES:
- Must pass `gdlint` and `gdformat --check`
- All parameters and returns typed
- No `class_name`
- `push_error()` not `print()`
- @onready for child node refs with null guards
- Private methods prefixed with `_`
- Signals typed

- [ ] **Step 1:** Create `game/scripts/entities/enemy.gd`
- [ ] **Step 2:** Run `gdlint game/scripts/entities/enemy.gd` — must pass
- [ ] **Step 3:** Run `gdformat --check game/scripts/entities/enemy.gd` — must pass

---

### Task 3: Create enemy.tscn

**Files:**
- Create: `game/scenes/entities/enemy.tscn`

Write the .tscn scene file in Godot text format:
- Root: Node2D named "Enemy"
- Child: Sprite2D with placeholder_enemy.png texture
- Child: AnimationPlayer with stub animations (idle, hit_reaction, death)
- Script: res://scripts/entities/enemy.gd
- No collision shapes needed

AnimationPlayer must have all 3 animations in the AnimationLibrary:
- `idle` — 2.0s loop
- `hit_reaction` — 0.3s, no loop
- `death` — 0.5s, no loop

- [ ] **Step 1:** Write `enemy.tscn` in Godot text scene format
- [ ] **Step 2:** Verify load_steps count matches sub_resource + ext_resource count

---

## Chunk 2: Tests + Completion

### Task 4: Write GUT tests

**Files:**
- Create: `game/tests/test_enemy.gd`

Write tests following the player_character test patterns (untyped vars from instantiate, add_child_autofree).

Tests to write:
1. `test_initialize_loads_data` — init with "ley_vermin"/"act_i", verify enemy_data populated
2. `test_current_hp_matches_base` — after init, current_hp == enemy_data.hp
3. `test_take_damage_reduces_hp` — take 10 damage, verify HP reduced by 10
4. `test_take_damage_clamps_to_zero` — take 99999 damage, HP = 0, is_alive = false
5. `test_died_signal_emitted` — watch for died signal on lethal damage
6. `test_heal_clamps_to_max` — heal past max, verify clamped to base hp
7. `test_element_weakness` — ley_vermin data should have weaknesses, verify multiplier
8. `test_element_neutral` — non-weak element returns 1.0
9. `test_status_immunity_by_type` — construct type immune to poison
10. `test_apply_status_success` — apply non-immune status, verify has_status
11. `test_tick_statuses_removes_expired` — apply duration 1, tick, verify removed
12. `test_roll_steal_returns_dict` — verify return format {item_id, success}

- [ ] **Step 1:** Write `test_enemy.gd`
- [ ] **Step 2:** Run `gdlint game/tests/test_enemy.gd` — must pass
- [ ] **Step 3:** Run `gdformat --check game/tests/test_enemy.gd` — must pass

---

### Task 5: Update gap tracker and commit

- [ ] **Step 1:** Update gap 2.3 status to COMPLETE in game-dev-gaps.md
- [ ] **Step 2:** Check off all "What's Needed" items (noting AI deferred to 3.3)
- [ ] **Step 3:** Note downstream gaps unblocked:
  - 2.3 unblocks: 3.3 (Battle Scene)
- [ ] **Step 4:** Run lint on ALL new .gd files:
  ```bash
  gdlint game/scripts/entities/enemy.gd game/tests/test_enemy.gd
  gdformat --check game/scripts/entities/enemy.gd game/tests/test_enemy.gd
  ```
- [ ] **Step 5:** Stage and commit:
  ```bash
  git add game/scenes/entities/enemy.tscn game/scripts/entities/enemy.gd game/assets/sprites/enemies/ game/tests/test_enemy.gd docs/analysis/game-dev-gaps.md docs/superpowers/specs/2026-04-05-enemy-prefab-design.md docs/superpowers/plans/2026-04-05-enemy-prefab.md
  git commit -m "feat(engine): add Enemy prefab with state tracking and elemental system (gap 2.3)"
  ```
- [ ] **Step 6:** Push and hand off to `/create-pr` → `/godot-review-loop`
