# Gap 2.4: Interactable Prefabs — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create 3 interactable entity prefabs (TreasureChest, TriggerZone, SavePoint) for exploration scene content.

**Architecture:** All three are Area2D on collision layer 3, detected by PlayerCharacter's InteractionArea. Each has initialize(), emits signals on interaction, checks EventFlags for persistence. Signal-only responses — consumers handle overlays/inventory.

**Tech Stack:** Godot 4.6, GDScript, GUT 9.3.0, gdlint 4.5.0

**Spec:** `docs/superpowers/specs/2026-04-05-interactable-prefabs-design.md`

---

## File Structure

| Action | File | Purpose |
|--------|------|---------|
| Create | `game/scripts/entities/treasure_chest.gd` | Chest entity |
| Create | `game/scripts/entities/trigger_zone.gd` | Trigger entity |
| Create | `game/scripts/entities/save_point.gd` | Save point entity |
| Create | `game/scenes/entities/treasure_chest.tscn` | Chest scene |
| Create | `game/scenes/entities/trigger_zone.tscn` | Trigger scene |
| Create | `game/scenes/entities/save_point.tscn` | Save point scene |
| Create | `game/assets/sprites/interactables/placeholder_chest_closed.png` | 16x16 |
| Create | `game/assets/sprites/interactables/placeholder_chest_open.png` | 16x16 |
| Create | `game/assets/sprites/interactables/placeholder_save_point.png` | 16x16 |
| Create | `game/tests/test_interactables.gd` | Tests for all 3 |
| Modify | `docs/analysis/game-dev-gaps.md` | Update gap 2.4 status |

---

## Chunk 1: Sprites + TreasureChest

### Task 1: Create placeholder sprites

**Files:**
- Create: 3 PNGs in `game/assets/sprites/interactables/`

Generate 16x16 placeholder PNGs using the same pure-Python generator:
- `placeholder_chest_closed.png` — #886644 fill, #664422 border
- `placeholder_chest_open.png` — #886644 fill, #332211 interior (darker center 4x4 area)
- `placeholder_save_point.png` — #44CCCC fill, #228888 border

- [ ] **Step 1:** Create directory and generate 3 PNGs
- [ ] **Step 2:** Verify files exist and are 16x16

---

### Task 2: Create treasure_chest.gd + .tscn

**Files:**
- Create: `game/scripts/entities/treasure_chest.gd`, `game/scenes/entities/treasure_chest.tscn`

**treasure_chest.gd** — Area2D entity:

```gdscript
extends Area2D
## Treasure chest that gives an item on first interaction.
## Tracks opened state via EventFlags. Emits signal — does not
## directly modify inventory (consumer's responsibility).

signal chest_opened(chest_id: String, item_id: String)

var chest_id: String = ""
var item_id: String = ""
var is_opened: bool = false

@onready var _sprite: Sprite2D = $Sprite2D
```

Methods:
- `initialize(p_chest_id, p_item_id)` — stores IDs, checks EventFlags for `chest_{id}_opened`, sets sprite if already opened
- `interact()` — if not opened: sets `is_opened = true`, sets EventFlags flag, swaps sprite texture, emits `chest_opened`
- `_load_sprites()` — loads closed/open placeholder textures

**treasure_chest.tscn:**
- Root: Area2D, collision_layer=4 (layer 3), collision_mask=0, monitorable=true
- Sprite2D: placeholder_chest_closed.png
- CollisionShape2D: RectangleShape2D half-extents 6x6 (12x12)

RULES:
- Must pass gdlint + gdformat
- No direct AudioManager/GameManager calls
- @onready with null guard in _load_sprites
- EventFlags accessed via autoload singleton
- load_steps count must match ext_resource + sub_resource count exactly

- [ ] **Step 1:** Write treasure_chest.gd
- [ ] **Step 2:** Write treasure_chest.tscn
- [ ] **Step 3:** Run gdlint + gdformat — must pass

---

## Chunk 2: TriggerZone + SavePoint

### Task 3: Create trigger_zone.gd + .tscn

**Files:**
- Create: `game/scripts/entities/trigger_zone.gd`, `game/scenes/entities/trigger_zone.tscn`

**trigger_zone.gd** — Area2D that auto-fires on body entry:

```gdscript
extends Area2D
## Invisible trigger zone that fires once when player enters.
## Checks condition flag before firing. Sets fired flag to prevent
## re-trigger. Emits signal — consumer handles the response.

signal triggered(trigger_id: String)

var trigger_id: String = ""
var condition_flag: String = ""
var has_fired: bool = false
```

Methods:
- `initialize(p_trigger_id, p_condition_flag)` — stores config, checks if already fired via EventFlags
- `_on_body_entered(body)` — connected via scene signal. Checks has_fired, checks condition_flag, sets flag, emits triggered.

**trigger_zone.tscn:**
- Root: Area2D, collision_layer=4, collision_mask=2 (detect player body), monitoring=true, monitorable=false
- CollisionShape2D: RectangleShape2D (default 16x16, resized per placement)
- No Sprite2D (invisible)
- Signal: body_entered connected to _on_body_entered

- [ ] **Step 1:** Write trigger_zone.gd
- [ ] **Step 2:** Write trigger_zone.tscn
- [ ] **Step 3:** Run gdlint + gdformat — must pass

---

### Task 4: Create save_point.gd + .tscn

**Files:**
- Create: `game/scripts/entities/save_point.gd`, `game/scenes/entities/save_point.tscn`

**save_point.gd** — Area2D with shimmer animation:

```gdscript
extends Area2D
## Save point (ley crystal) that emits signals for proximity
## and interaction. Does not directly push overlays or play audio
## — exploration scene handles those via signal listeners.

signal save_point_activated(save_point_id: String)
signal save_point_entered(save_point_id: String)

var save_point_id: String = ""

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
```

Methods:
- `initialize(p_save_point_id)` — stores ID, starts shimmer animation
- `interact()` — emits save_point_activated
- `_on_body_entered(body)` — emits save_point_entered (for proximity SFX by exploration scene)

**save_point.tscn:**
- Root: Area2D, collision_layer=4, collision_mask=2, monitorable=true
- Sprite2D: placeholder_save_point.png
- CollisionShape2D: CircleShape2D radius 12
- AnimationPlayer: shimmer animation (1.0s loop)
- Signals: body_entered connected to _on_body_entered

- [ ] **Step 1:** Write save_point.gd
- [ ] **Step 2:** Write save_point.tscn
- [ ] **Step 3:** Run gdlint + gdformat — must pass

---

## Chunk 3: Tests + Completion

### Task 5: Write GUT tests

**Files:**
- Create: `game/tests/test_interactables.gd`

Tests for all 3 prefabs in one file:

**TreasureChest (4 tests):**
- test_chest_initialize — chest_id and item_id stored
- test_chest_interact_opens — interact() sets is_opened, emits signal
- test_chest_already_opened_blocks — second interact() does nothing
- test_chest_signal_carries_ids — signal has correct chest_id and item_id

**TriggerZone (3 tests):**
- test_trigger_initialize — trigger_id and condition_flag stored
- test_trigger_fires_signal — simulate body entered, verify signal
- test_trigger_one_time_fire — has_fired prevents re-fire

**SavePoint (3 tests):**
- test_save_point_initialize — save_point_id stored
- test_save_point_interact_signal — interact() emits save_point_activated
- test_save_point_entered_signal — body_entered emits save_point_entered

- [ ] **Step 1:** Write test_interactables.gd
- [ ] **Step 2:** Run gdlint + gdformat — must pass

---

### Task 6: Update gap tracker and commit

- [ ] **Step 1:** Update gap 2.4 status to COMPLETE in game-dev-gaps.md
- [ ] **Step 2:** Check off all "What's Needed" items
- [ ] **Step 3:** Note downstream gaps unblocked:
  - 2.4 unblocks: 3.2 (Exploration Scene — needs interactables for map content)
- [ ] **Step 4:** Run lint on ALL new .gd files:
  ```bash
  gdlint game/scripts/entities/treasure_chest.gd game/scripts/entities/trigger_zone.gd game/scripts/entities/save_point.gd game/tests/test_interactables.gd
  gdformat --check game/scripts/entities/treasure_chest.gd game/scripts/entities/trigger_zone.gd game/scripts/entities/save_point.gd game/tests/test_interactables.gd
  ```
- [ ] **Step 5:** Verify load_steps in all 3 .tscn files match actual resource count
- [ ] **Step 6:** Stage and commit:
  ```bash
  git add game/scenes/entities/ game/scripts/entities/ game/assets/sprites/interactables/ game/tests/test_interactables.gd docs/analysis/game-dev-gaps.md
  git commit -m "feat(engine): add interactable prefabs - chest, trigger, save point (gap 2.4)"
  ```
- [ ] **Step 7:** Push and hand off to `/create-pr` → `/godot-review-loop`
