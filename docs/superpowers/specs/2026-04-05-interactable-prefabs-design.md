# Gap 2.4: Interactable Prefabs — Design Spec

> **Date:** 2026-04-05
> **Gap:** 2.4 (Interactable Prefabs: TreasureChest, TriggerZone, SavePoint)
> **Status:** Approved
> **Source docs:** save-system.md Section 4 (save points), events.md (flags/triggers), items.md (chest contents), overworld.md Section 6 (save point spec), technical-architecture.md Section 4.2 (scene trees)
> **Architecture ref:** technical-architecture.md Section 4.2

## Problem

The exploration scene needs three interactable entity types for dungeon/town content: treasure chests (item rewards), trigger zones (story/boss gates), and save points (rest/save access). TreasureChest and SavePoint are detected by PlayerCharacter's InteractionArea; TriggerZone auto-fires on body_entered without requiring interaction.

## Scope

- 3 scene files + 3 script files
- 3 placeholder sprite PNGs
- 1 shared test file
- Signal-only responses (consumers handle overlays/inventory)

**Excluded (deferred):**
- Save point 3-option menu UI → gap 3.6 (Save/Load Overlay)
- Item inventory management → gap 3.4 (Menu Overlay)
- Auto-save trigger logic → gap 3.2 (Exploration Scene)
- Proximity SFX playback → gap 3.2 (Exploration Scene listens to signals)

---

## Shared Pattern

All three interactables:
- Root node: `Area2D`
- `collision_layer = 4` (layer 3 in Godot's 1-indexed UI, bitmask value 4)
- `process_mode = INHERIT` (pause when overlays active)
- `initialize()` method called after instantiation
- Emit signals — don't directly trigger overlays or modify inventory

### Per-Prefab Collision Config

| Prefab | collision_mask | monitorable | monitoring | Notes |
|--------|---------------|-------------|------------|-------|
| TreasureChest | `0` | `true` | `false` | Detected by InteractionArea |
| TriggerZone | `2` (player body layer) | `false` | `true` | Auto-fires on body_entered |
| SavePoint | `2` (player body layer) | `true` | `true` | Detected by InteractionArea + emits proximity signal on body_entered |

---

## TreasureChest

### Scene Tree

```
TreasureChest (Area2D)
├── Sprite2D              — 16x16 placeholder (closed frame)
├── CollisionShape2D      — RectangleShape2D 12x12
└── treasure_chest.gd
```

### Properties

```gdscript
var chest_id: String = ""
var item_id: String = ""
var is_opened: bool = false
```

### Signals

```gdscript
signal chest_opened(chest_id: String, item_id: String)
```

### Methods

```gdscript
func initialize(p_chest_id: String, p_item_id: String) -> void
```

Stores chest_id and item_id. Checks `EventFlags.get_flag("chest_%s_opened" % chest_id)` — if true, sets `is_opened = true` and swaps sprite to open frame.

```gdscript
func interact() -> void
```

Called by exploration scene when player interacts. If `is_opened`, returns immediately. Otherwise: sets `is_opened = true`, sets EventFlags flag, swaps sprite frame, emits `chest_opened`.

### Sprite Frames

- Frame 0: closed (default)
- Frame 1: open

For placeholder: two 16x16 PNGs loaded as separate textures. When real art exists, use a spritesheet.

---

## TriggerZone

### Scene Tree

```
TriggerZone (Area2D)
├── CollisionShape2D      — RectangleShape2D (variable size)
└── trigger_zone.gd
```

No sprite — invisible trigger area.

### Properties

```gdscript
var trigger_id: String = ""
var condition_flag: String = ""
var has_fired: bool = false
```

### Signals

```gdscript
signal triggered(trigger_id: String)
```

### Methods

```gdscript
func initialize(p_trigger_id: String, p_condition_flag: String = "") -> void
```

Stores config. Checks if already fired via EventFlags.

### Body Detection

Unlike chest/save point (which wait for explicit interaction), TriggerZone fires automatically on body_entered:

```gdscript
func _on_body_entered(body: Node2D) -> void:
    if has_fired:
        return
    if condition_flag != "" and not EventFlags.get_flag(condition_flag):
        return
    has_fired = true
    EventFlags.set_flag("trigger_%s_fired" % trigger_id, true)
    triggered.emit(trigger_id)
```

### Collision Config

- `collision_layer = 4` (layer 3)
- `collision_mask = 2` (detect player body on layer 2)
- `monitoring = true` (listens for body_entered)
- `monitorable = false` (player doesn't need to detect it via InteractionArea)

Note: TriggerZone uses `collision_mask = 2` because it auto-fires on body entry, unlike chest/save point which require explicit interaction.

---

## SavePoint

### Scene Tree

```
SavePoint (Area2D)
├── Sprite2D              — 16x16 placeholder (shimmer)
├── CollisionShape2D      — CircleShape2D radius 12
├── AnimationPlayer       — shimmer loop
└── save_point.gd
```

### Properties

```gdscript
var save_point_id: String = ""
```

### Signals

```gdscript
signal save_point_activated(save_point_id: String)
signal save_point_entered(save_point_id: String)
```

### Methods

```gdscript
func initialize(p_save_point_id: String) -> void
```

Stores ID, starts shimmer animation.

```gdscript
func interact() -> void
```

Called by exploration scene. Emits `save_point_activated`. Exploration scene handles the overlay push.

### Body Detection (Proximity)

```gdscript
func _on_body_entered(body: Node2D) -> void:
    save_point_entered.emit(save_point_id)
```

Exploration scene listens to this for proximity SFX. The save point itself doesn't play audio (AudioManager is the exploration scene's responsibility per "call down, signal up").

### Animation

- `shimmer`: 2-frame loop, 1.0s total (0.5s per frame)
- Started by `initialize()` when called (not autoplay)
- Shimmer animation is a stub — real tracks added when art assets exist.

---

## Placeholder Sprites

| File | Size | Color | Notes |
|------|------|-------|-------|
| `placeholder_chest_closed.png` | 16x16 | #886644 fill, #664422 border | Brown box |
| `placeholder_chest_open.png` | 16x16 | #886644 fill, #332211 interior | Brown box with dark center |
| `placeholder_save_point.png` | 16x16 | #44CCCC fill, #228888 border | Cyan/teal crystal |

Location: `game/assets/sprites/interactables/`

---

## Tests

`game/tests/test_interactables.gd`:

**TreasureChest:**
1. test_chest_initialize — verify chest_id and item_id set
2. test_chest_interact_opens — verify is_opened, signal emitted
3. test_chest_already_opened_blocks — interact on opened chest does nothing
4. test_chest_signal_carries_ids — verify signal carries chest_id and item_id

**TriggerZone:**
5. test_trigger_initialize — verify trigger_id and condition_flag set
6. test_trigger_fires_signal — simulate body enter, verify signal
7. test_trigger_one_time_fire — second entry doesn't re-fire
8. test_trigger_condition_blocks — unmet condition prevents firing

**SavePoint:**
9. test_save_point_initialize — verify save_point_id set
10. test_save_point_interact_signal — verify save_point_activated emitted
11. test_save_point_entered_signal — verify save_point_entered on body proximity

---

## Verification Checklist

- [ ] All 3 scenes load in Godot editor without errors
- [ ] TreasureChest on collision layer 3 (bitmask 4)
- [ ] TriggerZone detects player body (mask layer 2)
- [ ] SavePoint on collision layer 3 with shimmer animation
- [ ] Chest interact() emits chest_opened with correct IDs
- [ ] Chest re-interaction blocked when is_opened
- [ ] TriggerZone fires once and sets flag
- [ ] TriggerZone condition check works (blocks when flag not set)
- [ ] SavePoint interact() emits save_point_activated
- [ ] SavePoint body_entered emits save_point_entered
- [ ] All sprites 16x16, snapped to pixel grid
- [ ] All code passes gdlint + gdformat
- [ ] Tests pass
- [ ] No direct overlay pushes or AudioManager calls (signals only)
