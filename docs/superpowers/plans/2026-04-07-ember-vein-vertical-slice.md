# Ember Vein Vertical Slice Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a 3-floor playable dungeon (F1, F2, F4) proving the end-to-end gameplay loop: explore → encounters → mini-boss → boss → rewards → exit.

**Architecture:** TileMapLayer maps with placeholder tileset, existing encounter/battle systems, new boss encounter triggers in exploration.gd, hardcoded Vein Guardian AI in battle_manager.gd, dialogue stubs via existing overlay.

**Tech Stack:** Godot 4.6, GDScript, TileMapLayer, existing autoloads (GameManager, DataManager, PartyState, SaveManager, EventFlags)

**Spec:** `docs/superpowers/specs/2026-04-07-ember-vein-vertical-slice-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `game/assets/tilesets/placeholder_dungeon.png` | CREATE | 64x16 tileset image (4 tiles) |
| `game/scenes/maps/dungeons/ember_vein_f1.tscn` | CREATE | Floor 1 map scene |
| `game/scenes/maps/dungeons/ember_vein_f2.tscn` | CREATE | Floor 2 map scene |
| `game/scenes/maps/dungeons/ember_vein_f4.tscn` | CREATE | Floor 4 boss arena scene |
| `game/scripts/core/exploration.gd` | MODIFY | Floor-specific encounters, boss triggers, dungeon_id metadata |
| `game/scripts/combat/battle_manager.gd` | MODIFY | Vein Guardian AI, PartyState fix, boss flee disable |
| `game/data/items/consumables.json` | MODIFY | Verify/add Ember Tonic, Drake Fang |
| `game/data/equipment/accessories.json` | MODIFY | Verify/add Iron Bracelet, Miner's Hardhat, Ember Ring |
| `docs/analysis/game-dev-gaps.md` | MODIFY | Update gap 4.1 status |

**Files NOT created (data already exists):**
- Enemy stat JSON — already in `game/data/enemies/act_i.json` and `bosses.json`
- Potion, Antidote — already in `game/data/items/consumables.json`

---

## Chunk 1: Tilemap Foundation + Map Scenes

### Task 1: Create placeholder tileset image

**Files:**
- Create: `game/assets/tilesets/placeholder_dungeon.png`

- [ ] **Step 1: Generate the tileset image**

Create a 64x16 PNG with 4 solid-color 16x16 tiles:
- Pixel 0-15: Brown floor `#5C3A1E`
- Pixel 16-31: Dark grey wall `#2A2A2A`
- Pixel 32-47: Orange-amber crystal `#D4820A`
- Pixel 48-63: Light grey stairs `#8A8A8A`

Use Python with Pillow or ImageMagick:

```bash
python3 -c "
from PIL import Image
img = Image.new('RGBA', (64, 16))
colors = [(92,58,30,255), (42,42,42,255), (212,130,10,255), (138,138,138,255)]
for t, c in enumerate(colors):
    for y in range(16):
        for x in range(16):
            img.putpixel((t*16+x, y), c)
img.save('game/assets/tilesets/placeholder_dungeon.png')
"
```

If Pillow is not available, use ImageMagick:

```bash
convert -size 16x16 xc:'#5C3A1E' -size 16x16 xc:'#2A2A2A' \
  -size 16x16 xc:'#D4820A' -size 16x16 xc:'#8A8A8A' +append \
  game/assets/tilesets/placeholder_dungeon.png
```

- [ ] **Step 2: Verify the image**

```bash
file game/assets/tilesets/placeholder_dungeon.png
# Should show: PNG image data, 64 x 16
```

- [ ] **Step 3: Commit**

```bash
git add game/assets/tilesets/placeholder_dungeon.png
git commit -m "feat(assets): add placeholder dungeon tileset (4 tiles)"
```

### Task 2: Create Floor 1 map scene (Upper Mine)

**Files:**
- Create: `game/scenes/maps/dungeons/ember_vein_f1.tscn`

The scene is written as a Godot `.tscn` text file. The TileMapLayer
tile data is a PackedInt32Array encoding tile positions. For the
vertical slice, use a simple rectangular room layout.

- [ ] **Step 1: Design the F1 layout**

40x30 tile room. Walls around the perimeter, floor inside, crystal
accents along the east wall, stairs tile at the bottom exit.

Key positions (in tiles, origin top-left):
- Player spawn: (3, 3) → pixel (48, 48)
- From F2 spawn: (37, 27) → pixel (592, 432) near stairs
- Exit to F2 (stairs): area at tiles (36-38, 28-29) → transition trigger
- Save point: tile (5, 25) → pixel (80, 400)
- Chest 1 (Mining Pick): tile (30, 5) → pixel (480, 80)
- Chest 2 (3x Potion): tile (15, 15) → pixel (240, 240)
- Chest 3 (Iron Bracelet): tile (35, 10) → pixel (560, 160)
- Dialogue trigger (dead miners): tile (10, 8) → pixel (160, 128)

- [ ] **Step 2: Create the .tscn file**

Write the scene file with:
- Root Node2D with metadata: `map_id = "ember_vein_f1"`,
  `floor_id = "1-2"`, `location_name = "Ember Vein - Upper Mine"`,
  `dungeon_id = "ember_vein"`
- TileMapLayer child (tile data encoded — walls on perimeter, floor
  inside, crystals on east wall, stairs at exit)
- Marker2D spawn points as direct children of root:
  `PlayerSpawn` at (48, 48), `from_ember_vein_f2` at (592, 432)
- Entities node with:
  - 3 treasure chest Area2Ds with metadata `item_id` and `quantity`
  - 1 save point Area2D
  - 1 dialogue trigger Area2D with metadata
    `flag = "ember_vein_entry_seen"` and `dialogue_data`
- Transitions node with:
  - Exit stairs Area2D with metadata
    `target_map = "ember_vein_f2"`, `target_spawn = "from_ember_vein_f1"`

**Implementation note:** The TileMapLayer tile_data is a large
PackedInt32Array that encodes (x, y, source_id, atlas_coords, alt_tile)
per cell. For 40x30 = 1,200 cells this is generated programmatically.
Write a helper script or build the data array in code.

Alternatively: create a minimal .tscn with just the structure nodes
and NO tile data, then populate tiles via a GDScript tool script that
runs in-editor. This avoids hand-encoding the PackedInt32Array.

**Recommended approach for vertical slice:** Create the .tscn with
structure (nodes, metadata, spawn points, entities) and use a simple
rectangular wall/floor pattern. The exact tile layout is placeholder —
real dungeon design happens in the content pass.

- [ ] **Step 3: Verify the scene loads**

The scene should load cleanly via `load_map("ember_vein_f1")` in
exploration. Check that:
- Root node metadata is readable
- Spawn points are findable via `get_node_or_null("PlayerSpawn")`
- Entity nodes are present

- [ ] **Step 4: Commit**

```bash
git add game/scenes/maps/dungeons/ember_vein_f1.tscn
git commit -m "feat(engine): add Ember Vein Floor 1 map scene"
```

### Task 3: Create Floor 2 map scene (Lower Mine)

**Files:**
- Create: `game/scenes/maps/dungeons/ember_vein_f2.tscn`

Same structure as F1 but with:
- Metadata: `map_id = "ember_vein_f2"`, `floor_id = "3"`,
  `location_name = "Ember Vein - Lower Mine"`,
  `dungeon_id = "ember_vein"`
- Spawn points: `PlayerSpawn` at default, `from_ember_vein_f1` near
  top entry, `from_ember_vein_f4` near bottom
- Chests: Antidote x2, Miner's Hardhat, Ember Ring (behind boss area)
- Save point before mini-boss area
- Ember Drake boss trigger Area2D with metadata:
  `boss_id = "ember_drake"`,
  `enemy_ids = ["ember_drake"]`,
  `enemy_act = "bosses"`,
  `flag = "ember_drake_defeated"`
- Dialogue trigger for dead miners (flag: `ember_vein_miners_seen`)
- Exit stairs to F4

- [ ] **Step 1: Create the .tscn file**

Follow same pattern as Task 2 but with F2-specific layout, metadata,
and entity placement.

- [ ] **Step 2: Commit**

```bash
git add game/scenes/maps/dungeons/ember_vein_f2.tscn
git commit -m "feat(engine): add Ember Vein Floor 2 map scene"
```

### Task 4: Create Floor 4 map scene (Boss Arena)

**Files:**
- Create: `game/scenes/maps/dungeons/ember_vein_f4.tscn`

Small arena (20x15 tiles). No random encounters.

- Metadata: `map_id = "ember_vein_f4"`, `floor_id = ""`,
  `location_name = "Ember Vein - The Pendulum Chamber"`,
  `dungeon_id = "ember_vein"` (empty floor_id = no encounters)
- Spawn points: `PlayerSpawn`, `from_ember_vein_f2` near top entry
- Chests: 3x Potion, Ember Tonic
- Pendulum dialogue trigger (flag: `pendulum_discovered`)
- Vein Guardian boss trigger with metadata:
  `boss_id = "vein_guardian"`,
  `enemy_ids = ["vein_guardian"]`,
  `enemy_act = "bosses"`,
  `flag = "vaelith_ember_vein"`
- Post-boss dialogue trigger (flag: `vaelith_ember_vein`, but only
  fires after boss defeated — gated on `vaelith_ember_vein` flag)
- Exit trigger → `test_room` (placeholder until overworld exists)

- [ ] **Step 1: Create the .tscn file**

- [ ] **Step 2: Commit**

```bash
git add game/scenes/maps/dungeons/ember_vein_f4.tscn
git commit -m "feat(engine): add Ember Vein Floor 4 boss arena scene"
```

---

## Chunk 2: Encounter & Boss Wiring

### Task 5: Add floor-specific encounter config loading

**Files:**
- Modify: `game/scripts/core/exploration.gd` (lines 19-21, 126-135)

Currently exploration always loads `floors[0]`. Fix to match by
`floor_id` from map metadata.

- [ ] **Step 1: Add _current_floor_id variable**

After line 21 (`var _encounter_config: Dictionary = {}`), add:

```gdscript
var _current_floor_id: String = ""
```

- [ ] **Step 2: Read floor_id and dungeon_id from map metadata**

In `load_map()`, after `_current_map_id = map_id` (line 120), replace
the encounter config loading block (lines 126-135) with:

```gdscript
	_current_floor_id = _current_map.get_meta("floor_id", "")
	if _player != null:
		_last_player_tile = Vector2i(_player.position) / 16
	_encounter_config = {}
	_danger_counter = 0
	var dungeon_id: String = _current_map.get_meta("dungeon_id", _current_map_id)
	var encounters: Dictionary = DataManager.load_encounters(dungeon_id)
	if not encounters.is_empty():
		var floors: Array = encounters.get("floors", encounters.get("zones", []))
		# Match by floor_id, fallback to first entry
		for floor_entry: Variant in floors:
			if floor_entry is Dictionary:
				if (floor_entry as Dictionary).get("floor_id", "") == _current_floor_id:
					_encounter_config = floor_entry as Dictionary
					break
		if _encounter_config.is_empty() and floors.size() > 0 and floors[0] is Dictionary:
			_encounter_config = floors[0]
```

This matches floor_id from map metadata against encounter JSON
floor_id. Falls back to first floor if no match (preserves existing
behavior for non-dungeon maps).

- [ ] **Step 3: Commit**

```bash
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): add floor-specific encounter config loading"
```

### Task 6: Add boss encounter trigger to exploration

**Files:**
- Modify: `game/scripts/core/exploration.gd`

Add a new method for boss encounters (triggered by Area2D zones in
map scenes, distinct from random encounters).

- [ ] **Step 1: Add _trigger_boss_encounter method**

Add after `_trigger_random_encounter()`:

```gdscript
func _trigger_boss_encounter(area: Area2D) -> void:
	if _transitioning:
		return
	var boss_id: String = area.get_meta("boss_id", "")
	var enemy_ids_raw: Variant = area.get_meta("enemy_ids", [])
	var enemy_act: String = area.get_meta("enemy_act", "act_i")
	var flag: String = area.get_meta("flag", "")
	if boss_id.is_empty():
		return
	if not flag.is_empty() and EventFlags.is_set(flag):
		return
	var enemy_ids: Array = []
	if enemy_ids_raw is Array:
		enemy_ids = enemy_ids_raw
	_transitioning = true
	var transition: Dictionary = {
		"encounter_group": enemy_ids,
		"formation_type": "normal",
		"return_map_id": _current_map_id,
		"return_position": _player.position,
		"enemy_act": enemy_act,
		"encounter_source": "boss",
		"is_boss": true,
		"boss_flag": flag,
	}
	GameManager.change_core_state(GameManager.CoreState.BATTLE, transition)
```

- [ ] **Step 2: Wire boss trigger in entity signal connection**

In `_connect_entity_signals()`, add handling for BossTrigger nodes.
Boss triggers use the same Area2D body_entered pattern as transitions
but call `_trigger_boss_encounter` instead. Add after the transition
signal connections:

```gdscript
	var boss_triggers: Array = _current_map.get_node_or_null("Entities")
	if boss_triggers != null:
		for child: Node in boss_triggers.get_children():
			if child is Area2D and child.has_meta("boss_id"):
				child.body_entered.connect(_on_boss_trigger_entered.bind(child))
```

And add the callback:

```gdscript
func _on_boss_trigger_entered(body: Node2D, area: Area2D) -> void:
	if body != _player:
		return
	_trigger_boss_encounter(area)
```

- [ ] **Step 3: Wire event flag setting on battle return**

In `_initialize_from_transition_data()`, in the `"victory"` match
branch, after `PartyState.distribute_battle_rewards(rewards)`, add:

```gdscript
			var boss_flag: String = data.get("boss_flag", "")
			if not boss_flag.is_empty():
				EventFlags.set_flag(boss_flag)
```

- [ ] **Step 4: Disconnect boss signals in _disconnect_entity_signals**

Add matching disconnect logic for boss triggers.

- [ ] **Step 5: Check line count**

```bash
wc -l game/scripts/core/exploration.gd
```

Must stay under 400 lines. Current is ~367 + ~30 new = ~397.

- [ ] **Step 6: Commit**

```bash
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): add boss encounter triggers and event flag wiring"
```

### Task 7: Add Vein Guardian hardcoded AI to battle_manager

**Files:**
- Modify: `game/scripts/combat/battle_manager.gd`

- [ ] **Step 1: Add Vein Guardian state variables**

After `var _earned_drops: Array[Dictionary] = []` (line 29), add:

```gdscript
var _vg_phase: int = 1
var _vg_last_action: String = ""
var _vg_reconstructed: bool = false
```

- [ ] **Step 2: Add _get_vein_guardian_action method**

Add before `_setup_party()`:

```gdscript
## Hardcoded Vein Guardian boss AI. Tech debt: refactor to data-driven
## boss_ai.gd when second boss is implemented.
func _get_vein_guardian_action(
	turn: int, hp_ratio: float
) -> Dictionary:
	# Phase 2 trigger: reconstruct once at 50% HP
	if hp_ratio <= 0.5 and not _vg_reconstructed:
		_vg_reconstructed = true
		_vg_last_action = "reconstruct"
		return {"type": "heal", "id": "reconstruct", "target": "self", "value": 300}
	# Phase 1 pattern
	var action: String = "crystal_slam"
	if turn % 4 == 0:
		action = "crystal_slam"
	elif turn % 3 == 0:
		action = "ember_pulse"
	elif _vg_last_action == "crystal_slam":
		action = "ember_pulse"
	_vg_last_action = action
	if action == "crystal_slam":
		return {"type": "attack", "id": "crystal_slam", "target": "single"}
	return {"type": "ability", "id": "ember_pulse", "target": "all", "element": "flame"}
```

- [ ] **Step 3: Wire into _execute_enemy_turn**

In `_execute_enemy_turn()` (around line 306), replace the boss action
selection:

```gdscript
	var action: Dictionary
	if _is_boss and enemy.enemy_data.get("id", "") == "vein_guardian":
		var hp_ratio: float = float(enemy.current_hp) / float(enemy.enemy_data.get("hp", 1))
		action = _get_vein_guardian_action(_turn_counter, hp_ratio)
	elif _is_boss:
		action = BattleAI.select_boss_action(enemy.enemy_data, pm, pr)
	else:
		action = BattleAI.select_action(enemy.enemy_data, pm, pr)
```

- [ ] **Step 4: Reset VG state in _setup_enemies**

At the start of `_setup_enemies()`, add:

```gdscript
	_vg_phase = 1
	_vg_last_action = ""
	_vg_reconstructed = false
```

- [ ] **Step 5: Disable flee for boss battles**

In the command handling for flee (in `_on_ui_command`), check
`_is_boss` and reject:

```gdscript
	if _is_boss:
		# Boss battles: flee disabled
		return
```

Find the existing flee handling and add this guard at the top.

- [ ] **Step 6: Check line count**

Must stay under 400 lines.

- [ ] **Step 7: Commit**

```bash
git add game/scripts/combat/battle_manager.gd
git commit -m "feat(engine): add Vein Guardian scripted AI and boss flee disable"
```

### Task 8: Fix _setup_party to use PartyState

**Files:**
- Modify: `game/scripts/combat/battle_manager.gd`

- [ ] **Step 1: Replace _setup_party implementation**

Replace the current `_setup_party()` method:

```gdscript
func _setup_party() -> void:
	var active: Array[Dictionary] = PartyState.get_active_party()
	for i: int in range(active.size()):
		if not active[i].is_empty():
			_state.add_member(i, active[i])
```

- [ ] **Step 2: Verify battle_state.add_member handles PartyState format**

Read `game/scripts/combat/battle_state.gd` `add_member()` method.
It currently reads `data.get("base_stats", {}).get("hp", 1)` for max HP.
PartyState members have `base_stats` dict AND top-level `max_hp`.
Verify `add_member` works with PartyState member dicts — it may need
to read `data.get("max_hp", ...)` instead of `data.get("base_stats", {}).get("hp", ...)`.

If `add_member` needs changes, update it to check both formats:

```gdscript
var max_hp: int = data.get("max_hp", data.get("base_stats", {}).get("hp", 1))
```

- [ ] **Step 3: Commit**

```bash
git add game/scripts/combat/battle_manager.gd game/scripts/combat/battle_state.gd
git commit -m "fix(engine): use PartyState live data in battle setup"
```

---

## Chunk 3: Content & Integration

### Task 9: Verify and add treasure items to JSON data

**Files:**
- Modify: `game/data/items/consumables.json` (if Ember Tonic, Drake Fang missing)
- Modify: `game/data/equipment/accessories.json` (if Iron Bracelet, Miner's Hardhat, Ember Ring missing)
- Modify: `game/data/equipment/weapons.json` (if Carradan Mining Pick missing)
- Modify: `game/data/items/materials.json` (if Vein Guardian's Core missing)

- [ ] **Step 1: Check which items already exist**

```bash
grep -l "ember_tonic\|drake_fang\|iron_bracelet\|miners_hardhat\|ember_ring\|carradan_mining_pick\|vein_guardians_core" game/data/items/*.json game/data/equipment/*.json
```

- [ ] **Step 2: Add missing items**

For each missing item, append to the appropriate JSON file following
the existing schema. Values MUST come from the design docs:
- `docs/story/items.md` for consumables
- `docs/story/equipment.md` for weapons/accessories
- `docs/story/economy.md` for prices

Do NOT invent values. If a value is not in the design docs, leave it
as a placeholder with a TODO comment and flag it.

- [ ] **Step 3: Validate JSON syntax**

```bash
python3 -m json.tool game/data/items/consumables.json > /dev/null
python3 -m json.tool game/data/equipment/accessories.json > /dev/null
python3 -m json.tool game/data/equipment/weapons.json > /dev/null
python3 -m json.tool game/data/items/materials.json > /dev/null
```

- [ ] **Step 4: Commit**

```bash
git add game/data/
git commit -m "feat(engine): add Ember Vein treasure items to data files"
```

### Task 10: Add dialogue triggers and wiring

**Files:**
- Modify: `game/scripts/core/exploration.gd`

Dialogue triggers are Area2D nodes in the map with metadata:
- `dialogue_data`: Array of dialogue line dicts
- `flag`: EventFlags key (one-shot trigger)

- [ ] **Step 1: Add dialogue trigger handling**

In `_connect_entity_signals()`, add handling for dialogue triggers
(Area2D nodes with `dialogue_data` metadata):

```gdscript
		if child is Area2D and child.has_meta("dialogue_data"):
			child.body_entered.connect(
				_on_dialogue_trigger_entered.bind(child)
			)
```

Add the callback:

```gdscript
func _on_dialogue_trigger_entered(body: Node2D, area: Area2D) -> void:
	if body != _player or _transitioning:
		return
	var flag: String = area.get_meta("flag", "")
	if not flag.is_empty() and EventFlags.is_set(flag):
		return
	var dialogue: Variant = area.get_meta("dialogue_data", [])
	if dialogue is Array and not (dialogue as Array).is_empty():
		if not flag.is_empty():
			EventFlags.set_flag(flag)
		GameManager.push_overlay(GameManager.OverlayState.DIALOGUE, {
			"dialogue": dialogue,
		})
```

- [ ] **Step 2: Add disconnect for dialogue triggers**

In `_disconnect_entity_signals()`, add matching disconnect.

- [ ] **Step 3: Check line count**

Must stay under 400 lines. If over, extract dialogue trigger handling
to a static helper.

- [ ] **Step 4: Commit**

```bash
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): add dialogue trigger zones in exploration"
```

### Task 11: Add dialogue data to map scenes

**Files:**
- Modify: `game/scenes/maps/dungeons/ember_vein_f1.tscn`
- Modify: `game/scenes/maps/dungeons/ember_vein_f2.tscn`
- Modify: `game/scenes/maps/dungeons/ember_vein_f4.tscn`

- [ ] **Step 1: Add dialogue metadata to trigger nodes**

Each dialogue trigger Area2D needs `dialogue_data` metadata set as
an Array of Dictionaries. The format matches the existing dialogue
overlay contract:

```
[
  {"speaker": "Edren", "text": "Hold."},
  {"speaker": "Edren", "text": "No marks. No signs of a fight. They just... stopped."},
  {"speaker": "Cael", "text": "They didn't die fighting. They died feeling something."},
  {"speaker": "Edren", "text": "There'll be more."}
]
```

Set this as metadata on each dialogue trigger node in the .tscn files.
Lines must come from `docs/story/script/act-i.md` — see spec Section 9.

- [ ] **Step 2: Commit**

```bash
git add game/scenes/maps/dungeons/
git commit -m "feat(engine): add dialogue data to Ember Vein map triggers"
```

### Task 12: Wire map transitions between floors

**Files:**
- Already handled in Tasks 2-4 (transition Area2Ds with metadata)

- [ ] **Step 1: Verify transition chain**

Confirm the transition metadata chain is correct:
- F1 exit → `target_map = "ember_vein_f2"`, `target_spawn = "from_ember_vein_f1"`
- F2 exit → `target_map = "ember_vein_f4"`, `target_spawn = "from_ember_vein_f2"`
- F4 exit → `target_map = "test_room"`, `target_spawn = "PlayerSpawn"`

- [ ] **Step 2: Add test_room entry point for Ember Vein**

In `game/scenes/maps/test_room.tscn`, add a transition Area2D that
leads to `ember_vein_f1`:

```
target_map = "ember_vein_f1"
target_spawn = "PlayerSpawn"
```

This gives the player a way to enter the dungeon from the existing
test room.

- [ ] **Step 3: Commit**

```bash
git add game/scenes/maps/
git commit -m "feat(engine): wire Ember Vein floor transitions and test room entry"
```

### Task 13: Update gap tracker

**Files:**
- Modify: `docs/analysis/game-dev-gaps.md`

- [ ] **Step 1: Update gap 4.1 status**

Change status to IN PROGRESS or MOSTLY COMPLETE. Check off completed
items:
- [x] 3-floor dungeon tilemap (placeholder)
- [x] Placeholder tilesets
- [x] Enemy encounters wired to encounter tables
- [x] Treasure chests placed
- [x] Save point placement
- [ ] Corrupted Fenmother → replaced by Vein Guardian (name difference)
- [ ] Intro cutscene → stub via dialogue overlay
- [x] Event flags set on completion
- [x] Full loop test possible

Add progress tracking entry with date and commit reference.

- [ ] **Step 2: Add tech debt notes**

Note in gap 4.1 that:
- Vein Guardian AI is hardcoded (refactor when second boss exists)
- Placeholder tileset (replace in gap 4.8)
- Post-boss exit goes to test_room (replace in gap 4.3)
- Ember Drake uses weighted-random AI (canonical AI is conditional)

- [ ] **Step 3: Commit**

```bash
git add docs/analysis/game-dev-gaps.md
git commit -m "docs(engine): update gap tracker — Ember Vein vertical slice"
```

---

## Execution Order

Tasks 1-4 are sequential (tileset → F1 → F2 → F4).
Tasks 5-8 are sequential (encounter config → boss trigger → VG AI → PartyState fix).
Tasks 9-11 depend on Tasks 2-4 (need map scenes to exist).
Task 12 depends on Tasks 2-4.
Task 13 is last.

**Chunks 1 and 2 can be parallelized** — map scene creation (Tasks 1-4)
and encounter/boss wiring (Tasks 5-8) touch different files.

Task 9 (item data) is independent and can run in parallel with
either chunk.
