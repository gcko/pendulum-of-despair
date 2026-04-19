# Gap 3.2: Exploration Scene (Minimal Viable) — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the exploration core state scene that wires player movement, entity interaction, overlay integration, and map transitions into a walkable, interactive game world.

**Architecture:** Single exploration.tscn as CoreState.EXPLORATION. Loads map .tscn scenes dynamically. Player character instance follows input, Camera2D tracks player. Entity signals wire to overlay pushes. Map transitions use fade-to-black via Tween. Reads GameManager.transition_data on _ready() for New Game vs Continue initialization.

**Tech Stack:** Godot 4.6, GDScript, GUT 9.3.0, gdlint 4.5.0

**Spec:** `docs/superpowers/specs/2026-04-06-exploration-scene-design.md`

---

## File Structure

| Action | File | Purpose |
|--------|------|---------|
| Create | `game/assets/tilesets/tileset_test.png` | 16x16 placeholder tiles (4 colors) |
| Create | `game/scripts/core/exploration.gd` | Exploration scene: map loading, entity wiring, transitions |
| Create | `game/scenes/core/exploration.tscn` | Exploration scene tree |
| Create | `game/scenes/maps/test_room.tscn` | Test map with NPC, chest, save point, exit |
| Create | `game/scenes/maps/test_room_2.tscn` | Second map for transition testing |
| Create | `game/tests/test_exploration.gd` | 10 integration tests |
| Modify | `docs/analysis/game-dev-gaps.md` | Update 3.2 status |

---

## Chunk 1: Placeholder Tileset + Exploration Script

### Task 1: Create placeholder tileset

Generate a 64x16 PNG with 4 colored 16x16 tiles: floor (tan), wall (dark brown), door (blue), grass (green).

- [ ] **Step 1:** Create `game/assets/tilesets/` directory if needed
- [ ] **Step 2:** Generate tileset_test.png (64x16, 4 tiles)
- [ ] **Step 3:** Verify file exists and dimensions are correct

---

### Task 2: Create exploration.gd

**Agent instructions:** This is the integration hub. It loads map scenes, instantiates the player, wires entity signals, handles map transitions with fade, and reads transition_data from GameManager. Apply MANDATORY dual-pass self-review. Trace every state transition: what's visible before, what's visible after, what happens on cancel/failure.

**Files:**
- Create: `game/scripts/core/exploration.gd`

- [ ] **Step 1:** Write exploration.gd:

```gdscript
extends Node2D
## Exploration core state scene. Loads maps, manages player, wires entity signals.
## Reads GameManager.transition_data on _ready() for New Game vs Continue.

const PLAYER_SCENE: PackedScene = preload("res://scenes/entities/player_character.tscn")
const MAP_BASE_PATH: String = "res://scenes/maps/"

## Colors for fade transition.
const FADE_COLOR: Color = Color(0, 0, 0, 1)
const FADE_DURATION: float = 0.3

signal map_changed(map_id: String)

var _current_map_id: String = ""
var _current_map: Node2D = null
var _player: CharacterBody2D = null
var _transitioning: bool = false
var _last_flash_id: String = ""

@onready var _camera: Camera2D = $Camera2D
@onready var _map_container: Node2D = $CurrentMap
@onready var _fade_rect: ColorRect = $FadeOverlay/FadeRect
@onready var _location_label: Label = $LocationFlash/LocationLabel/NameLabel
@onready var _location_panel: PanelContainer = $LocationFlash/LocationLabel


func _ready() -> void:
	_fade_rect.color = FADE_COLOR
	_fade_rect.visible = false
	_location_panel.visible = false
	_spawn_player()
	_initialize_from_transition_data()


func _process(_delta: float) -> void:
	if _player != null and _camera != null:
		_camera.position = _player.position.round()


func _unhandled_input(event: InputEvent) -> void:
	if _transitioning:
		return
	if event.is_action_pressed("ui_accept") and _player != null:
		if _player.has_method("try_interact"):
			_player.try_interact()


## Load a map by ID and place player at spawn or named position.
func load_map(map_id: String, spawn_name: String = "") -> void:
	# Unload current map
	if _current_map != null:
		_disconnect_entity_signals(_current_map)
		_current_map.queue_free()
		_current_map = null

	var map_path: String = MAP_BASE_PATH + map_id + ".tscn"
	if not ResourceLoader.exists(map_path):
		push_error("Exploration: Map not found: %s" % map_path)
		return

	var map_scene: PackedScene = load(map_path)
	_current_map = map_scene.instantiate()
	_map_container.add_child(_current_map)
	_current_map_id = map_id

	# Connect entity signals
	_connect_entity_signals(_current_map)

	# Position player at spawn
	_position_player_at_spawn(spawn_name)

	# Flash location name if different from last
	var location_name: String = _current_map.get_meta("location_name", "")
	if location_name != "" and location_name != _last_flash_id:
		flash_location_name(location_name)
		_last_flash_id = location_name

	map_changed.emit(map_id)


## Flash location name at center-top per ui-design.md 15.2.
func flash_location_name(location_name: String) -> void:
	_location_label.text = location_name
	_location_panel.visible = true
	_location_panel.modulate = Color(1, 1, 1, 0)
	var tween: Tween = create_tween()
	tween.tween_property(_location_panel, "modulate:a", 1.0, 0.5)
	tween.tween_interval(2.0)
	tween.tween_property(_location_panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func() -> void: _location_panel.visible = false)


func _spawn_player() -> void:
	_player = PLAYER_SCENE.instantiate()
	add_child(_player)
	_player.initialize("edren")
	_player.interaction_requested.connect(_on_interaction_requested)


func _initialize_from_transition_data() -> void:
	var data: Dictionary = GameManager.transition_data
	if data.get("new_game", false):
		load_map("test_room")
	elif data.has("save_data"):
		var save_data: Dictionary = data.get("save_data", {})
		var world: Dictionary = save_data.get("world", {})
		var location: String = world.get("current_location", "test_room")
		if location == "":
			location = "test_room"
		load_map(location)
		var pos: Dictionary = world.get("current_position", {})
		if _player != null and pos.has("x") and pos.has("y"):
			_player.position = Vector2(pos["x"], pos["y"])
	else:
		load_map("test_room")


func _connect_entity_signals(map_node: Node2D) -> void:
	var entities_node: Node = map_node.get_node_or_null("Entities")
	if entities_node == null:
		return
	for child: Node in entities_node.get_children():
		if child.has_signal("npc_interacted"):
			child.npc_interacted.connect(_on_npc_interacted)
		if child.has_signal("chest_opened"):
			child.chest_opened.connect(_on_chest_opened)
		if child.has_signal("save_point_activated"):
			child.save_point_activated.connect(_on_save_point_activated)

	var transitions_node: Node = map_node.get_node_or_null("Transitions")
	if transitions_node == null:
		return
	for child: Node in transitions_node.get_children():
		if child.has_signal("triggered"):
			child.triggered.connect(_on_trigger_zone_triggered)


func _disconnect_entity_signals(map_node: Node2D) -> void:
	var entities_node: Node = map_node.get_node_or_null("Entities")
	if entities_node != null:
		for child: Node in entities_node.get_children():
			if child.has_signal("npc_interacted") and child.npc_interacted.is_connected(_on_npc_interacted):
				child.npc_interacted.disconnect(_on_npc_interacted)
			if child.has_signal("chest_opened") and child.chest_opened.is_connected(_on_chest_opened):
				child.chest_opened.disconnect(_on_chest_opened)
			if child.has_signal("save_point_activated") and child.save_point_activated.is_connected(_on_save_point_activated):
				child.save_point_activated.disconnect(_on_save_point_activated)

	var transitions_node: Node = map_node.get_node_or_null("Transitions")
	if transitions_node != null:
		for child: Node in transitions_node.get_children():
			if child.has_signal("triggered") and child.triggered.is_connected(_on_trigger_zone_triggered):
				child.triggered.disconnect(_on_trigger_zone_triggered)


func _position_player_at_spawn(spawn_name: String) -> void:
	if _player == null or _current_map == null:
		return
	var marker_name: String = spawn_name if spawn_name != "" else "PlayerSpawn"
	var spawn: Node2D = _current_map.get_node_or_null(marker_name)
	if spawn != null:
		_player.position = spawn.position.round()
	else:
		_player.position = Vector2(80, 90)


# --- Signal handlers ---


func _on_interaction_requested(interactable: Node2D) -> void:
	if _transitioning:
		return
	if interactable.has_method("interact"):
		interactable.interact()


func _on_npc_interacted(_npc_id: String, dialogue_data: Dictionary) -> void:
	if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		# Wrap single entry in array per dialogue_box.show_dialogue() contract
		if GameManager.overlay_node != null and GameManager.overlay_node.has_method("show_dialogue"):
			GameManager.overlay_node.show_dialogue([dialogue_data])


func _on_chest_opened(chest_id: String, item_id: String) -> void:
	# TODO: Add item to inventory when inventory system exists (gap 3.4)
	flash_location_name("Found %s!" % item_id)
	if OS.is_debug_build():
		print_debug("Chest %s opened: %s" % [chest_id, item_id])


func _on_save_point_activated(_save_point_id: String) -> void:
	if GameManager.push_overlay(GameManager.OverlayState.SAVE_LOAD):
		if GameManager.overlay_node != null and GameManager.overlay_node.has_method("open_save_point"):
			GameManager.overlay_node.open_save_point()


func _on_trigger_zone_triggered(trigger_id: String) -> void:
	if _transitioning:
		return
	# Check if this trigger has map transition metadata
	var transitions_node: Node = _current_map.get_node_or_null("Transitions")
	if transitions_node == null:
		return
	for child: Node in transitions_node.get_children():
		if child.has_signal("triggered") and child.get_meta("trigger_id", "") == trigger_id:
			var target_map: String = child.get_meta("target_map", "")
			var target_spawn: String = child.get_meta("target_spawn", "")
			if target_map != "":
				_transition_to_map(target_map, target_spawn)
			return


func _transition_to_map(target_map: String, target_spawn: String) -> void:
	_transitioning = true
	_fade_rect.visible = true
	_fade_rect.color = Color(0, 0, 0, 0)
	var tween: Tween = create_tween()
	tween.tween_property(_fade_rect, "color:a", 1.0, FADE_DURATION)
	tween.tween_callback(func() -> void:
		load_map(target_map, target_spawn)
	)
	tween.tween_property(_fade_rect, "color:a", 0.0, FADE_DURATION)
	tween.tween_callback(func() -> void:
		_fade_rect.visible = false
		_transitioning = false
	)
```

- [ ] **Step 2:** Run gdformat + gdlint — must pass
- [ ] **Step 3:** Dual-pass self-review (mechanical + narrative)
- [ ] **Step 4:** Behavioral trace: what if load_map called during transition? (_transitioning blocks triggers but not direct load_map calls — acceptable since only _transition_to_map calls it during gameplay)

---

### Task 3: Create exploration.tscn

**Files:**
- Create: `game/scenes/core/exploration.tscn`

**Resource counts:**
- ext_resource: 1 (script)
- sub_resource: 2 (StyleBoxFlat for location flash + StyleBoxFlat for fade)
- load_steps = 1 + 2 = 3

- [ ] **Step 1:** Write exploration.tscn
- [ ] **Step 2:** Verify load_steps = ext_resource + sub_resource count

---

## Chunk 2: Test Maps + Tests + Gap Tracker

### Task 4: Create test_room.tscn

A 20x11 tile room with walls, a floor, an NPC, a chest, a save point, and an exit trigger.

**Files:**
- Create: `game/scenes/maps/test_room.tscn`

- [ ] **Step 1:** Write test_room.tscn with:
  - TileMapLayer with 20x11 floor tiles + wall border
  - Entities/TestNPC: NPC instance, meta npc_id="bren", position (64, 48)
  - Entities/TestChest: TreasureChest instance, meta chest_id="test_chest_01", item_id="potion", position (128, 48)
  - Entities/TestSavePoint: SavePoint instance, meta save_point_id="test_save", position (192, 48)
  - Transitions/ExitTrigger: TriggerZone instance, meta trigger_id="exit_east", target_map="test_room_2", target_spawn="EntryWest", position (304, 96)
  - PlayerSpawn (Marker2D), position (80, 96)
  - Metadata: location_name = "Test Room"

- [ ] **Step 2:** Verify all entity positions are integer pixels

---

### Task 5: Create test_room_2.tscn

Minimal second room for transition testing.

**Files:**
- Create: `game/scenes/maps/test_room_2.tscn`

- [ ] **Step 1:** Write test_room_2.tscn with:
  - TileMapLayer with 20x11 floor
  - Transitions/ReturnTrigger: meta trigger_id="exit_west", target_map="test_room", target_spawn="PlayerSpawn"
  - PlayerSpawn named "EntryWest" at (16, 96)
  - Metadata: location_name = "Test Room 2"

---

### Task 6: Write exploration tests

**Files:**
- Create: `game/tests/test_exploration.gd`

- [ ] **Step 1:** Write test_exploration.gd with 10 tests
- [ ] **Step 2:** Run gdformat + gdlint

---

### Task 7: Update gap tracker and commit

- [ ] **Step 1:** Update gap 3.2 status in game-dev-gaps.md
- [ ] **Step 2:** Note deferred items (encounters, auto-save, audio, menu button)
- [ ] **Step 3:** Run all quality gates
- [ ] **Step 4:** Commit and push

**Hand off:**
1. `/create-pr` — open PR targeting main
2. `/godot-review-loop <PR#> 3` — hardening
3. Copilot gap analysis (autonomous)
