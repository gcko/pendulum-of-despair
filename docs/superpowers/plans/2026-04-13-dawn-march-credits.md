# Dawn March Opening Credits Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Dawn March T1 Full Cutscene with forward-only walking, title card, character credits, and `opening_credits_seen` flag (39).

**Architecture:** A dedicated trail map scene serves as the cutscene stage. The existing cutscene_player.gd (gap 3.7) drives all choreography via its 10 command types. exploration.gd gains a new cutscene trigger handler that transitions to the trail map, starts the cutscene, and returns to the overworld on completion.

**Tech Stack:** Godot 4.6, GDScript, GUT testing framework

**Spec:** `docs/superpowers/specs/2026-04-13-dawn-march-credits-design.md`

---

## Chunk 1: Cutscene Trigger System in exploration.gd

### Task 1: Add cutscene trigger state variables

**Files:**
- Modify: `game/scripts/core/exploration.gd:31-33`

- [ ] **Step 1: Add new state variables after line 33**

After the existing `_entities` variable (line 33), add:

```gdscript
## Pending cutscene data (set by trigger, consumed after map load).
var _pending_cutscene: Dictionary = {}
## Return destination after a cutscene map finishes.
var _cutscene_return: Dictionary = {}
```

- [ ] **Step 2: Commit**

```bash
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): add cutscene trigger state variables to exploration"
```

---

### Task 2: Wire cutscene trigger detection in _connect_entity_signals

**Files:**
- Modify: `game/scripts/core/exploration.gd:412-418`

- [ ] **Step 1: Add cutscene_scene_id branch before dialogue branch**

In `_connect_entity_signals()`, the Area2D detection block is at lines 412-418. Currently:

```gdscript
			if child is Area2D and child.has_meta("boss_id"):
				child.body_entered.connect(_on_boss_trigger_entered.bind(child))
			elif (
				child is Area2D
				and (child.has_meta("dialogue_data") or child.has_meta("dialogue_scene_id"))
			):
				child.body_entered.connect(_on_dialogue_trigger_entered.bind(child))
```

Insert a new `elif` between the boss branch and the dialogue branch:

```gdscript
			if child is Area2D and child.has_meta("boss_id"):
				child.body_entered.connect(_on_boss_trigger_entered.bind(child))
			elif (
				child is Area2D
				and child.has_meta("cutscene_scene_id")
			):
				child.body_entered.connect(
					_on_cutscene_trigger_entered.bind(child)
				)
			elif (
				child is Area2D
				and (child.has_meta("dialogue_data") or child.has_meta("dialogue_scene_id"))
			):
				child.body_entered.connect(_on_dialogue_trigger_entered.bind(child))
```

The cutscene branch MUST come before the dialogue branch — an Area2D should only wire to one handler.

- [ ] **Step 2: Commit**

```bash
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): wire cutscene trigger detection in entity signals"
```

---

### Task 3: Implement cutscene trigger handler and launch helper

**Files:**
- Modify: `game/scripts/core/exploration.gd` (add after `_on_cutscene_sfx` at ~line 929)

- [ ] **Step 1: Add _start_pending_cutscene helper**

Add after the `_on_cutscene_sfx` function (line 929):

```gdscript


func _start_pending_cutscene(
	cutscene_id: String, entries: Array, tier: int
) -> void:
	if GameManager.push_overlay(GameManager.OverlayState.CUTSCENE):
		GameManager.overlay_node.start_cutscene(cutscene_id, entries, tier)
```

- [ ] **Step 2: Add _on_cutscene_trigger_entered handler**

Add after `_start_pending_cutscene`:

```gdscript


func _on_cutscene_trigger_entered(body: Node2D, area: Area2D) -> void:
	if body != _player or _transitioning or _in_cutscene:
		return
	var flag: String = area.get_meta("flag", "")
	if not flag.is_empty() and EventFlags.get_flag(flag):
		return
	var required: String = area.get_meta("required_flag", "")
	if not required.is_empty() and not EventFlags.get_flag(required):
		return
	# Set one-shot flag immediately (prevents re-trigger)
	if not flag.is_empty():
		EventFlags.set_flag(flag, true)
	var scene_id: String = area.get_meta("cutscene_scene_id", "")
	var map_id: String = area.get_meta("cutscene_map_id", "")
	var return_map: String = area.get_meta("cutscene_return_map", "")
	var return_spawn: String = area.get_meta("cutscene_return_spawn", "")
	# Load cutscene data from dialogue JSON
	var scene_data: Dictionary = DataManager.load_dialogue(scene_id)
	var entries: Array = scene_data.get("entries", [])
	var cutscene_id: String = scene_data.get("cutscene_id", scene_id)
	var tier: int = scene_data.get("cutscene_tier", 1)
	if entries.is_empty():
		return
	# Store return info (survives map swap)
	_cutscene_return = {"map": return_map, "spawn": return_spawn}
	if map_id != "":
		# Transition to cutscene map, then start cutscene after load
		_pending_cutscene = {"id": cutscene_id, "entries": entries, "tier": tier}
		_transition_to_map(map_id, "PlayerSpawn")
	else:
		# Start cutscene on current map
		_start_pending_cutscene(cutscene_id, entries, tier)
```

- [ ] **Step 3: Commit**

```bash
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): add cutscene trigger handler and launch helper"
```

---

### Task 4: Add pending cutscene hook in load_map()

**Files:**
- Modify: `game/scripts/core/exploration.gd:191-194`

- [ ] **Step 1: Add pending cutscene check after auto_sequence block**

In `load_map()`, after lines 191-194 (the `auto_sequence` block):

```gdscript
	var seq_id: String = _current_map.get_meta("auto_sequence", "")
	var seq_flag: String = _current_map.get_meta("auto_sequence_flag", "")
	if not seq_id.is_empty() and not EventFlags.get_flag(seq_flag):
		call_deferred("_run_auto_sequence", seq_id, seq_flag)
```

Add immediately after:

```gdscript
	if not _pending_cutscene.is_empty():
		var pc: Dictionary = _pending_cutscene
		_pending_cutscene = {}
		call_deferred(
			"_start_pending_cutscene",
			pc.get("id", ""), pc.get("entries", []), pc.get("tier", 1)
		)
```

Uses `call_deferred` so the map is fully loaded and entities are registered before the cutscene starts.

- [ ] **Step 2: Commit**

```bash
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): add pending cutscene hook in load_map"
```

---

### Task 5: Add return transition in _on_cutscene_finished()

**Files:**
- Modify: `game/scripts/core/exploration.gd:897-915`

- [ ] **Step 1: Add return transition at end of _on_cutscene_finished**

At the end of `_on_cutscene_finished()` (after the existing code that re-enables player input around line 915), add:

```gdscript
	if not _cutscene_return.is_empty():
		var ret: Dictionary = _cutscene_return
		_cutscene_return = {}
		var ret_map: String = ret.get("map", "")
		var ret_spawn: String = ret.get("spawn", "PlayerSpawn")
		if ret_map != "":
			_transition_to_map(ret_map, ret_spawn)
```

- [ ] **Step 2: Commit**

```bash
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): add cutscene return transition to exploration"
```

---

### Task 6: Write GUT tests for cutscene trigger system

**Files:**
- Create: `game/tests/test_dawn_march.gd`

- [ ] **Step 1: Write tests for cutscene trigger data loading and state machine**

```gdscript
extends GutTest
## Tests for Dawn March cutscene trigger system and data validation.


func before_each() -> void:
	EventFlags.clear_all()
	GameManager.transition_data = {}


# --- 1. dawn_march.json loads with cutscene metadata ---
func test_dawn_march_json_has_cutscene_id() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	assert_eq(data.get("cutscene_id", ""), "dawn_march", "cutscene_id should be dawn_march")


func test_dawn_march_json_has_cutscene_tier() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	assert_eq(data.get("cutscene_tier", 0), 1, "cutscene_tier should be 1 (T1 Full)")


# --- 2. dawn_march.json has 16 entries ---
func test_dawn_march_has_16_entries() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	var entries: Array = data.get("entries", [])
	assert_eq(entries.size(), 16, "Should have 16 entries (12 dialogue + 4 credits)")


# --- 3. Entry 012 has flag_set ---
func test_entry_012_has_flag_set() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	var entries: Array = data.get("entries", [])
	var entry_12: Dictionary = entries[11]
	assert_eq(
		entry_12.get("flag_set", ""),
		"opening_credits_seen",
		"Entry 012 should set opening_credits_seen flag"
	)


# --- 4. Entry 013 has title command ---
func test_entry_013_has_title_command() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	var entries: Array = data.get("entries", [])
	var entry_13: Dictionary = entries[12]
	var commands: Array = entry_13.get("commands", [])
	assert_gt(commands.size(), 0, "Entry 013 should have commands")
	var title_cmd: Dictionary = commands[0]
	assert_eq(title_cmd.get("type", ""), "title", "First command should be title")
	assert_eq(
		title_cmd.get("text", ""),
		"PENDULUM OF DESPAIR",
		"Title text should be PENDULUM OF DESPAIR"
	)


# --- 5. Entry 001 has move commands with correct field name ---
func test_entry_001_move_commands_use_to_field() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	var entries: Array = data.get("entries", [])
	var entry_1: Dictionary = entries[0]
	var commands: Array = entry_1.get("commands", [])
	var move_cmds: Array = []
	for cmd: Variant in commands:
		if cmd is Dictionary and (cmd as Dictionary).get("type", "") == "move":
			move_cmds.append(cmd)
	assert_gt(move_cmds.size(), 0, "Entry 001 should have move commands")
	for cmd: Variant in move_cmds:
		var d: Dictionary = cmd as Dictionary
		assert_true(d.has("to"), "Move command must use 'to' field (not 'target')")
		assert_false(d.has("target"), "Move command must NOT have 'target' field")


# --- 6. All entries have required fields ---
func test_all_entries_have_required_fields() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	var entries: Array = data.get("entries", [])
	for i in range(entries.size()):
		var entry: Dictionary = entries[i]
		assert_true(entry.has("id"), "Entry %d missing 'id'" % i)
		assert_true(entry.has("speaker"), "Entry %d missing 'speaker'" % i)
		assert_true(entry.has("lines"), "Entry %d missing 'lines'" % i)


# --- 7. Trail map scene file exists ---
func test_trail_map_scene_exists() -> void:
	assert_true(
		ResourceLoader.exists("res://scenes/maps/cutscenes/dawn_march_trail.tscn"),
		"dawn_march_trail.tscn should exist"
	)


# --- 8. Entry 012 has fade-out command ---
func test_entry_012_has_fade_out_command() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	var entries: Array = data.get("entries", [])
	var entry_12: Dictionary = entries[11]
	var commands: Array = entry_12.get("commands", [])
	var has_fade_out: bool = false
	for cmd: Variant in commands:
		if cmd is Dictionary:
			var d: Dictionary = cmd as Dictionary
			if d.get("type", "") == "fade" and d.get("direction", "") == "out":
				has_fade_out = true
	assert_true(has_fade_out, "Entry 012 should have fade-out command")


# --- 9. Entry 016 has fade-in command (return from black) ---
func test_entry_016_has_fade_in_command() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	var entries: Array = data.get("entries", [])
	var entry_16: Dictionary = entries[15]
	var commands: Array = entry_16.get("commands", [])
	var has_fade_in: bool = false
	for cmd: Variant in commands:
		if cmd is Dictionary:
			var d: Dictionary = cmd as Dictionary
			if d.get("type", "") == "fade" and d.get("direction", "") == "in":
				has_fade_in = true
	assert_true(has_fade_in, "Entry 016 should have fade-in command")
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd game && godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_dawn_march.gd -gexit`

Expected: FAIL — dawn_march.json doesn't have cutscene_id yet, trail map doesn't exist yet.

- [ ] **Step 3: Commit test file**

```bash
git add game/tests/test_dawn_march.gd
git commit -m "test(engine): add GUT tests for Dawn March cutscene trigger and data"
```

---

## Chunk 2: Dawn March Dialogue JSON and Trail Map

### Task 7: Update dawn_march.json with cutscene commands

**Files:**
- Modify: `game/data/dialogue/dawn_march.json`

- [ ] **Step 1: Replace dawn_march.json with full cutscene-enhanced version**

The file currently has 12 entries with no commands. Replace the entire file with the enhanced version that adds:
- Top-level `cutscene_id` and `cutscene_tier` fields
- `commands` arrays on entries 001, 005, 006, 012
- `flag_set` on entry 012
- New entries 013-016 (title card + credits + fade back)

Write the complete file:

```json
{
  "scene_id": "dawn_march",
  "cutscene_id": "dawn_march",
  "cutscene_tier": 1,
  "entries": [
    {
      "id": "dawn_march_001",
      "speaker": "cael",
      "lines": [
        "Those miners. They just stopped. No fight, no wounds.",
        "They gave up."
      ],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null,
      "commands": [
        {"type": "move", "who": "edren", "to": [400, 120], "speed": 60, "when": "before"},
        {"type": "move", "who": "cael", "to": [384, 136], "speed": 60, "when": "before"},
        {"type": "move", "who": "lira", "to": [352, 120], "speed": 60, "when": "before"},
        {"type": "move", "who": "sable", "to": [336, 136], "speed": 60, "when": "before"},
        {"type": "camera", "target": [240, 120], "duration": 5.0, "when": "before"},
        {"type": "wait", "duration": 2.0, "when": "before"}
      ]
    },
    {
      "id": "dawn_march_002",
      "speaker": "edren",
      "lines": [
        "We'll let the court decide what it is."
      ],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null
    },
    {
      "id": "dawn_march_003",
      "speaker": "cael",
      "lines": [
        "And the stranger? You're not concerned?"
      ],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null
    },
    {
      "id": "dawn_march_004",
      "speaker": "edren",
      "lines": [
        "I'm concerned about all of it."
      ],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null
    },
    {
      "id": "dawn_march_005",
      "speaker": "cael",
      "lines": [
        "I keep thinking about their faces."
      ],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null,
      "commands": [
        {"type": "wait", "duration": 1.5, "when": "after"}
      ]
    },
    {
      "id": "dawn_march_006",
      "speaker": "sable",
      "lines": [
        "So. That thing in the satchel."
      ],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null,
      "commands": [
        {"type": "move", "who": "edren", "to": [700, 120], "speed": 60, "when": "before"},
        {"type": "move", "who": "cael", "to": [684, 136], "speed": 60, "when": "before"},
        {"type": "move", "who": "lira", "to": [652, 120], "speed": 60, "when": "before"},
        {"type": "move", "who": "sable", "to": [636, 136], "speed": 60, "when": "before"},
        {"type": "camera", "target": [620, 128], "duration": 1.5, "when": "before"},
        {"type": "wait", "duration": 1.0, "when": "before"}
      ]
    },
    {
      "id": "dawn_march_007",
      "speaker": "lira",
      "lines": [
        "Don't ask."
      ],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null
    },
    {
      "id": "dawn_march_008",
      "speaker": "sable",
      "lines": [
        "I wasn't asking. I was observing. The commander's",
        "carrying it like it's made of glass, and your boyfriend hasn't",
        "stopped staring at it since we left."
      ],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null
    },
    {
      "id": "dawn_march_009",
      "speaker": "lira",
      "lines": [
        "He's not my \u2014 we just met."
      ],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null
    },
    {
      "id": "dawn_march_010",
      "speaker": "sable",
      "lines": [
        "Mhm. And I'm just a tourist."
      ],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null
    },
    {
      "id": "dawn_march_011",
      "speaker": "sable",
      "lines": [
        "For what it's worth \u2014 whatever that thing is, the",
        "Compact sent fifty soldiers to guard it. Fifty. They don't do",
        "that for mining equipment."
      ],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null
    },
    {
      "id": "dawn_march_012",
      "speaker": "lira",
      "lines": [
        "I know. That's why I came."
      ],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null,
      "commands": [
        {"type": "fade", "direction": "out", "duration": 1.5, "when": "after"},
        {"type": "wait", "duration": 0.5, "when": "after"}
      ],
      "flag_set": "opening_credits_seen"
    },
    {
      "id": "dawn_march_013",
      "speaker": "",
      "lines": [],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": "title_reveal",
      "commands": [
        {"type": "title", "text": "PENDULUM OF DESPAIR", "fade_in": 1.0, "duration": 3.0, "fade_out": 1.0, "when": "before"},
        {"type": "wait", "duration": 5.0, "when": "before"}
      ]
    },
    {
      "id": "dawn_march_014",
      "speaker": "",
      "lines": [],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null,
      "commands": [
        {"type": "title", "text": "Edren  -  Cael  -  Maren", "fade_in": 0.5, "duration": 2.0, "fade_out": 0.5, "when": "before"},
        {"type": "wait", "duration": 3.0, "when": "before"}
      ]
    },
    {
      "id": "dawn_march_015",
      "speaker": "",
      "lines": [],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null,
      "commands": [
        {"type": "title", "text": "Sable  -  Lira  -  Torren", "fade_in": 0.5, "duration": 2.0, "fade_out": 0.5, "when": "before"},
        {"type": "wait", "duration": 3.0, "when": "before"}
      ]
    },
    {
      "id": "dawn_march_016",
      "speaker": "",
      "lines": [],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null,
      "commands": [
        {"type": "fade", "direction": "in", "duration": 1.0, "when": "before"}
      ]
    }
  ]
}
```

- [ ] **Step 2: Commit**

```bash
git add game/data/dialogue/dawn_march.json
git commit -m "feat(story): add cutscene commands and credits to dawn_march.json"
```

---

### Task 8: Create dawn_march_trail.tscn map scene

**Files:**
- Create: `game/scenes/maps/cutscenes/dawn_march_trail.tscn`

- [ ] **Step 1: Create the cutscenes directory**

```bash
ls game/scenes/maps/cutscenes/ 2>/dev/null || mkdir -p game/scenes/maps/cutscenes/
```

- [ ] **Step 2: Write the trail map .tscn file**

This is a minimal linear trail map. It uses:
- The shared `placeholder_dungeon.tres` tileset
- 4 NPC instances as character actors (edren, cael, lira, sable)
- PlayerSpawn off-screen at (-100, -100) to hide the auto-spawned player
- No encounter_floor_id (no random encounters)
- 80x15 tile corridor using forest floor (index 8) with wall borders (index 1)

The tile_map_data encodes an 80x15 grid:
- Row 0 and row 14: all wall tiles (index 1)
- Rows 1-4 and 10-13: wall on columns 0 and 79, forest elsewhere (index 1 border, index 8 fill)
- Rows 5-9 (y=80 to y=144): walkable forest floor (index 8) — the corridor characters walk through
- A few bioluminescent tiles (index 9) scattered for visual interest

Write the .tscn file with the complete tile_map_data. The tile encoding uses Godot's PackedInt32Array format where each tile is 3 ints: `(col | (row << 16)), source_id, atlas_coords_packed`. For the placeholder tileset (single atlas, one column), the third int equals the tile index.

Given the complexity of encoding 80x15=1200 tiles by hand, generate the tile data programmatically:

```bash
cd /Users/jaredmscott/repos/projects/pendulum-of-despair
python3 -c "
tiles = []
for row in range(15):
    for col in range(80):
        packed_pos = col | (row << 16)
        if row <= 1 or row >= 13 or col == 0 or col == 79:
            tile_id = 1  # wall
        elif row <= 3 or row >= 11:
            tile_id = 9  # bioluminescent border
        else:
            tile_id = 8  # forest floor
        tiles.extend([packed_pos, 0, tile_id])
print(', '.join(str(t) for t in tiles))
" > /tmp/dawn_trail_tiles.txt
```

Then construct the .tscn:

```
[gd_scene load_steps=3 format=3]

[ext_resource type="TileSet" path="res://assets/tilesets/placeholder_dungeon.tres" id="1_tileset"]
[ext_resource type="PackedScene" path="res://scenes/entities/npc.tscn" id="2_npc"]

[node name="DawnMarchTrail" type="Node2D"]
metadata/map_id = "cutscenes/dawn_march_trail"
metadata/dungeon_id = ""
metadata/floor_id = ""
metadata/location_name = ""

[node name="TileMapLayer" type="TileMapLayer" parent="."]
tile_set = ExtResource("1_tileset")
tile_map_data = {"format": 3, "tile_data": PackedInt32Array(<GENERATED_TILE_DATA>)}

[node name="Entities" type="Node2D" parent="."]

[node name="Edren" parent="Entities" instance=ExtResource("2_npc")]
position = Vector2(80, 120)
metadata/npc_id = "edren"

[node name="Cael" parent="Entities" instance=ExtResource("2_npc")]
position = Vector2(64, 136)
metadata/npc_id = "cael"

[node name="Lira" parent="Entities" instance=ExtResource("2_npc")]
position = Vector2(32, 120)
metadata/npc_id = "lira"

[node name="Sable" parent="Entities" instance=ExtResource("2_npc")]
position = Vector2(16, 136)
metadata/npc_id = "sable"

[node name="PlayerSpawn" type="Marker2D" parent="."]
position = Vector2(-100, -100)
```

Replace `<GENERATED_TILE_DATA>` with the output from the Python script.

**Note on NPC sprites:** The NPC entities will use the default NPC sprite. To set character-specific colors, each NPC node needs its Sprite2D modulate set. Add these properties to the .tscn NPC nodes:

For Edren (blue): no extra property needed — default NPC sprite is fine for placeholder
For Cael (red): likewise
For Lira (orange): likewise
For Sable (grey): likewise

The character-specific colored sprites are defined in the PlayerCharacter prefab assets, not NPC assets. For this cutscene, the default NPC placeholder sprite is acceptable — all characters will look the same but be at different positions. Character-specific art is deferred to gap 4.8.

- [ ] **Step 3: Commit**

```bash
git add game/scenes/maps/cutscenes/dawn_march_trail.tscn
git commit -m "feat(story): add dawn march trail map scene for cutscene stage"
```

---

### Task 9: Update overworld.tscn trigger metadata

**Files:**
- Modify: `game/scenes/maps/overworld.tscn:185-196`

- [ ] **Step 1: Replace Scene4Trigger metadata**

In `overworld.tscn`, find the Scene4Trigger block (lines 185-196):

```
[node name="Scene4Trigger" type="Area2D" parent="Entities"]
position = Vector2(576, 480)
collision_layer = 0
collision_mask = 2
monitoring = true
monitorable = false
metadata/flag = "opening_credits_seen"
metadata/required_flag = "ironmouth_escape_seen"
metadata/dialogue_scene_id = "dawn_march"
```

Replace `metadata/dialogue_scene_id` with the cutscene metadata:

```
[node name="Scene4Trigger" type="Area2D" parent="Entities"]
position = Vector2(576, 480)
collision_layer = 0
collision_mask = 2
monitoring = true
monitorable = false
metadata/flag = "opening_credits_seen"
metadata/required_flag = "ironmouth_escape_seen"
metadata/cutscene_scene_id = "dawn_march"
metadata/cutscene_map_id = "cutscenes/dawn_march_trail"
metadata/cutscene_return_map = "overworld"
metadata/cutscene_return_spawn = "Scene4Return"
```

- [ ] **Step 2: Add Scene4Return spawn marker**

After the Scene4Trigger's CollisionShape2D (line 196), add a return spawn Marker2D:

```
[node name="Scene4Return" type="Marker2D" parent="."]
position = Vector2(576, 496)
```

Position it 16px south of the trigger so the player doesn't immediately re-enter the trigger zone on return (though the flag gate prevents re-trigger anyway).

- [ ] **Step 3: Commit**

```bash
git add game/scenes/maps/overworld.tscn
git commit -m "feat(story): convert Scene4Trigger to cutscene trigger on overworld"
```

---

### Task 10: Run tests and verify

**Files:**
- Test: `game/tests/test_dawn_march.gd`

- [ ] **Step 1: Run the Dawn March tests**

```bash
cd game && godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_dawn_march.gd -gexit
```

Expected: All 9 tests PASS.

- [ ] **Step 2: Run the full test suite to check for regressions**

```bash
cd game && godot --headless -s addons/gut/gut_cmdln.gd -gexit
```

Expected: All existing tests pass (620+ tests from gap 3.7 plus 9 new).

- [ ] **Step 3: Commit any fixes if tests failed**

If any test failed, fix the issue and commit with:

```bash
git add <fixed-files>
git commit -m "fix(engine): resolve test failure in dawn march implementation"
```

---

### Task 11: Update gap tracker

**Files:**
- Modify: `docs/analysis/game-dev-gaps.md`

- [ ] **Step 1: Update 4.4 Phase B2 checklist items**

In the Phase B2 section, check off the three remaining items:

```markdown
- [x] Opening credits visual sequence (title card, character names) — **unblocked by gap 3.7 (COMPLETE)**
- [x] Dawn March forward-only walk mechanics — **unblocked by gap 3.7 (COMPLETE)**
- [x] `opening_credits_seen` flag (39) — **unblocked by gap 3.7 (COMPLETE)**
```

Update Phase B2 status from MOSTLY COMPLETE to COMPLETE.

- [ ] **Step 2: Add progress tracking row**

Add to the Progress Tracking table:

```
| 2026-04-13 | 4.4 Phase B2F | Dawn March T1 cutscene (trail map, 16-entry choreographed dialogue, title card + credits, cutscene trigger system in exploration.gd, opening_credits_seen flag). Phase B2 now COMPLETE. | — |
```

- [ ] **Step 3: Update summary table**

In the summary, update the Tier 4 line to reflect Phase B2 completion.

- [ ] **Step 4: Commit**

```bash
git add docs/analysis/game-dev-gaps.md
git commit -m "docs(story): mark Phase B2 Dawn March items as COMPLETE"
```

---

## Handoff

After all tasks complete:

1. `/create-pr` — open a PR targeting main
2. `/godot-review-loop <PR#> 2` — multi-round hardening on the PR
3. Address Copilot comments + gap analysis (autonomous — no reminder needed)
