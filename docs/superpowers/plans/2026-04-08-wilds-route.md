# Wilds Route Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Roothollow village and Maren's Refuge to the game with overworld transitions, shop, party assembly (Torren + Maren join), and full test coverage.

**Architecture:** Two new town map scenes (.tscn) following the existing Valdris Lower Ward pattern. Overworld.tscn gains 2 new transition triggers. PartyState gets a public add_member() method. Dialogue trigger zones handle story scenes 5-6 via existing dialogue overlay. Tileset extended with 2 forest tiles.

**Tech Stack:** Godot 4.6, GDScript, TileMapLayer, existing exploration.gd + PartyState + DataManager

**Spec:** `docs/superpowers/specs/2026-04-08-wilds-route-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `game/assets/tilesets/placeholder_dungeon.png` | MODIFY | Extend from 8 to 10 tiles (forest floor, bioluminescent) |
| `game/assets/tilesets/placeholder_dungeon.tres` | MODIFY | Register tiles 8-9 |
| `game/data/shops/roothollow_herbalist.json` | CREATE | Herbalist shop inventory |
| `game/data/encounters/overworld.json` | MODIFY | Add thornmere_wilds zone |
| `game/scripts/autoload/party_state.gd` | MODIFY | add_member() public API |
| `game/scripts/core/exploration.gd` | MODIFY | Party joining flag checks |
| `game/scenes/maps/towns/roothollow.tscn` | CREATE | Roothollow village map |
| `game/scenes/maps/towns/marens_refuge.tscn` | CREATE | Maren's Refuge interior |
| `game/scenes/maps/overworld.tscn` | MODIFY | Add 2 transitions + 2 markers |
| `game/tests/test_wilds_route.gd` | CREATE | Integration tests |
| `game/tests/test_party_state.gd` | MODIFY | add_member() tests |
| `game/tests/test_cross_references.gd` | MODIFY | Expand coverage |
| `docs/analysis/game-dev-gaps.md` | MODIFY | Update gap 4.4 |

---

## Chunk 1: Data + PartyState API

### Task 1: Create Roothollow herbalist shop data

**Files:**
- Create: `game/data/shops/roothollow_herbalist.json`

- [ ] **Step 1: Write the shop JSON file**

```json
{
  "shop": {
    "shop_id": "roothollow_herbalist",
    "town": "roothollow",
    "type": "provisioner",
    "markup": 1.0,
    "inventory": [
      { "item_id": "potion", "buy_price": 50, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "hi_potion", "buy_price": 300, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "ether", "buy_price": 200, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "antidote", "buy_price": 50, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "alarm_clock", "buy_price": 75, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "echo_drop", "buy_price": 75, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "eye_drops", "buy_price": 50, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "smelling_salts", "buy_price": 75, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "tent", "buy_price": 500, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "despair_ward", "buy_price": 5000, "available_act": 1, "stock_limit": null, "restock_event": null }
    ]
  }
}
```

All prices from economy.md Thornmere Provisioner table. Despair Ward is
the only Act I source per economy.md.

- [ ] **Step 2: Verify item IDs resolve**

Check that every item_id in the shop exists in `game/data/items/consumables.json`
or `game/data/equipment/accessories.json` (despair_ward is an accessory).

```bash
python3 -c "
import json, sys
shop = json.load(open('game/data/shops/roothollow_herbalist.json'))
cons = json.load(open('game/data/items/consumables.json'))
acc = json.load(open('game/data/equipment/accessories.json'))
con_ids = {i['item_id'] for i in cons.get('consumables', cons.get('items', []))}
acc_ids = {i['equipment_id'] for i in acc.get('accessories', acc.get('equipment', []))}
all_ids = con_ids | acc_ids
missing = [i['item_id'] for i in shop['shop']['inventory'] if i['item_id'] not in all_ids]
if missing:
    print(f'MISSING: {missing}')
    sys.exit(1)
print(f'All {len(shop[\"shop\"][\"inventory\"])} items resolve')
"
```

- [ ] **Step 3: Commit**

```bash
git add game/data/shops/roothollow_herbalist.json
git commit -m "feat(engine): add Roothollow herbalist shop data (Act I Thornmere)"
```

### Task 2: Add thornmere_wilds zone to overworld encounters

**Files:**
- Modify: `game/data/encounters/overworld.json`

- [ ] **Step 1: Add the zone entry**

Add a new zone object to the `zones` array in overworld.json, after the
existing valdris_highlands zone. Use marsh_serpent and drowned_bones
enemies (these exist in the encounter data for fenmothers_hollow.json
and are Act I enemies):

```json
{
  "zone_id": "thornmere_wilds",
  "name": "Thornmere Wilds",
  "terrain_type": "low_visibility",
  "act": "act_i",
  "danger_tier": 2,
  "danger_increment": 160,
  "formation_rates": {
    "normal": 75.0,
    "back_attack": 15.0,
    "preemptive": 10.0
  },
  "groups": [
    {
      "format": 1,
      "enemies": ["marsh_serpent", "marsh_serpent"],
      "weight": 31.25
    },
    {
      "format": 2,
      "enemies": ["marsh_serpent", "drowned_bones"],
      "weight": 31.25
    },
    {
      "format": 3,
      "enemies": ["drowned_bones", "drowned_bones"],
      "weight": 31.25
    },
    {
      "format": 4,
      "enemies": ["marsh_serpent", "marsh_serpent", "drowned_bones"],
      "weight": 6.25
    }
  ]
}
```

- [ ] **Step 2: Verify enemy IDs exist**

```bash
python3 -c "
import json, glob, sys
ids = set()
for f in glob.glob('game/data/enemies/*.json'):
    data = json.load(open(f))
    for e in data.get('enemies', []):
        ids.add(e.get('enemy_id', ''))
needed = ['marsh_serpent', 'drowned_bones']
missing = [n for n in needed if n not in ids]
if missing:
    print(f'MISSING enemies: {missing}')
    sys.exit(1)
print('All enemy IDs resolve')
"
```

- [ ] **Step 3: Commit**

```bash
git add game/data/encounters/overworld.json
git commit -m "feat(engine): add thornmere_wilds encounter zone to overworld data"
```

### Task 3: Add PartyState.add_member() public API

**Files:**
- Modify: `game/scripts/autoload/party_state.gd` (lines 357-381)
- Test: `game/tests/test_party_state.gd`

- [ ] **Step 1: Add the add_member method**

Insert after line 66 (after `initialize_new_game()`), before `load_from_save()`:

```gdscript
func add_member(character_id: String, level: int = 1) -> void:
	for m: Dictionary in members:
		if m.get("character_id", "") == character_id:
			return
	_add_character(character_id, level)
	var idx: int = members.size() - 1
	if formation.get("active", []).size() < 4:
		formation["active"].append(idx)
	else:
		if not formation.has("reserve"):
			formation["reserve"] = [] as Array[int]
		formation["reserve"].append(idx)
	var char_data: Dictionary = DataManager.load_character(character_id)
	var default_row: String = char_data.get("default_row", "back")
	formation["rows"][character_id] = default_row
```

- [ ] **Step 2: Add has_member helper**

Insert right after add_member:

```gdscript
func has_member(character_id: String) -> bool:
	for m: Dictionary in members:
		if m.get("character_id", "") == character_id:
			return true
	return false
```

- [ ] **Step 3: Add tests to test_party_state.gd**

Append these tests:

```gdscript
func test_add_member_adds_to_party() -> void:
	PartyState.initialize_new_game()
	assert_eq(PartyState.members.size(), 2, "should start with 2 members")
	PartyState.add_member("torren", 3)
	assert_eq(PartyState.members.size(), 3, "should have 3 members after add")
	var m: Dictionary = PartyState.get_member("torren")
	assert_eq(m.get("character_id", ""), "torren", "torren should be in party")
	assert_eq(m.get("level", 0), 3, "torren should be at level 3")


func test_add_member_prevents_duplicates() -> void:
	PartyState.initialize_new_game()
	PartyState.add_member("torren", 3)
	PartyState.add_member("torren", 5)
	var count: int = 0
	for m: Dictionary in PartyState.members:
		if m.get("character_id", "") == "torren":
			count += 1
	assert_eq(count, 1, "should not add duplicate members")


func test_add_member_sets_formation() -> void:
	PartyState.initialize_new_game()
	PartyState.add_member("torren", 1)
	var active: Array = PartyState.formation.get("active", [])
	assert_true(active.has(2), "torren (idx 2) should be in active party")
	PartyState.add_member("maren", 1)
	active = PartyState.formation.get("active", [])
	assert_true(active.has(3), "maren (idx 3) should be in active (4th slot)")


func test_add_member_overflow_to_reserve() -> void:
	PartyState.initialize_new_game()
	PartyState.add_member("lira", 1)
	PartyState.add_member("sable", 1)
	# Active should be full at 4 now
	PartyState.add_member("torren", 1)
	var reserve: Array = PartyState.formation.get("reserve", [])
	assert_true(reserve.has(4), "torren (idx 4) should go to reserve when active full")


func test_has_member() -> void:
	PartyState.initialize_new_game()
	assert_true(PartyState.has_member("edren"), "edren should exist")
	assert_false(PartyState.has_member("torren"), "torren should not exist yet")
	PartyState.add_member("torren", 1)
	assert_true(PartyState.has_member("torren"), "torren should exist after add")
```

- [ ] **Step 4: Commit**

```bash
git add game/scripts/autoload/party_state.gd game/tests/test_party_state.gd
git commit -m "feat(engine): add PartyState.add_member() and has_member() public API"
```

### Task 4: Add party joining flag checks to exploration.gd

**Files:**
- Modify: `game/scripts/core/exploration.gd` (currently 401 lines)

- [ ] **Step 1: Add party joining check method**

Insert after `_on_dialogue_trigger_entered()` (after line 360):

```gdscript
func _check_party_joining_flags() -> void:
	if EventFlags.get_flag("torren_joined") and not PartyState.has_member("torren"):
		PartyState.add_member("torren", _get_party_avg_level())
		flash_location_name("Torren joined the party!")
	if EventFlags.get_flag("maren_warning") and not PartyState.has_member("maren"):
		PartyState.add_member("maren", _get_party_avg_level())
		flash_location_name("Maren joined the party!")


func _get_party_avg_level() -> int:
	if PartyState.members.is_empty():
		return 1
	var total: int = 0
	for m: Dictionary in PartyState.members:
		total += m.get("level", 1) as int
	return maxi(1, total / PartyState.members.size())
```

- [ ] **Step 2: Wire the check after dialogue flag is set**

In `_on_dialogue_trigger_entered()`, after `EventFlags.set_flag(flag, true)`
on line 360, add the party joining check. Modify the method:

Change:
```gdscript
	if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		GameManager.overlay_node.show_dialogue(dialogue as Array)
		if not flag.is_empty():
			EventFlags.set_flag(flag, true)
```

To:
```gdscript
	if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		GameManager.overlay_node.show_dialogue(dialogue as Array)
		if not flag.is_empty():
			EventFlags.set_flag(flag, true)
			_check_party_joining_flags()
```

- [ ] **Step 3: Verify line count**

The additions are ~15 lines. exploration.gd was 401 lines, will be ~416.
That's within the 400-line soft limit (acceptable for 2 small methods).

- [ ] **Step 4: Commit**

```bash
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): add party joining flag checks to exploration (Torren, Maren)"
```

---

## Chunk 2: Tileset + Map Scenes

### Task 5: Extend tileset with forest tiles

**Files:**
- Modify: `game/assets/tilesets/placeholder_dungeon.png` (currently 128x16)
- Modify: `game/assets/tilesets/placeholder_dungeon.tres`

- [ ] **Step 1: Extend tileset image from 8 to 10 tiles**

Add 2 new 16x16 tiles to the right, making it 160x16:
- Tile 8 (px 128-143): Forest floor `#5A6B3F` — rgb(90, 107, 63)
- Tile 9 (px 144-159): Bioluminescent `#4A9FBF` — rgb(74, 159, 191)

```bash
python3 -c "
from PIL import Image
img = Image.open('game/assets/tilesets/placeholder_dungeon.png')
new_img = Image.new('RGBA', (160, 16))
new_img.paste(img, (0, 0))
colors = [(90,107,63,255), (74,159,191,255)]
for t, c in enumerate(colors):
    for y in range(16):
        for x in range(16):
            new_img.putpixel((128 + t*16 + x, y), c)
new_img.save('game/assets/tilesets/placeholder_dungeon.png')
"
```

- [ ] **Step 2: Verify image dimensions**

```bash
file game/assets/tilesets/placeholder_dungeon.png
# Expected: PNG image data, 160 x 16
```

- [ ] **Step 3: Update .tres to register tiles 8-9**

Read `placeholder_dungeon.tres` and update the atlas texture region to
cover the wider image. Tiles 8-9 are walkable (no physics body). Follow
the same pattern as existing grass tile (6) which is also walkable.

The `.tres` file should have its `region` updated from
`Rect2i(0, 0, 128, 16)` to `Rect2i(0, 0, 160, 16)`.

- [ ] **Step 4: Commit**

```bash
git add game/assets/tilesets/placeholder_dungeon.png game/assets/tilesets/placeholder_dungeon.tres
git commit -m "feat(assets): extend tileset with forest tiles (forest floor, bioluminescent)"
```

### Task 6: Create Roothollow map scene

**Files:**
- Create: `game/scenes/maps/towns/roothollow.tscn`

- [ ] **Step 1: Write the .tscn file**

Follow the same pattern as `valdris_lower_ward.tscn`. Scene tree:

```
Node2D "Roothollow"
  metadata/map_id = "roothollow"
  metadata/dungeon_id = ""
  metadata/floor_id = ""
  metadata/location_name = "Roothollow"

  TileMapLayer (placeholder_dungeon.tres, 30x25)
    - Border: wall tiles (1) — impassable
    - Interior walkable: forest floor (8) for most areas
    - Accent: bioluminescent (9) along paths
    - Central area: town floor (5) for main chamber

  Entities (Node2D)
    Vessa (NPC instance, npc_id="vessa", position ~(240, 200))
    Herbalist (NPC instance, npc_id="roothollow_herbalist",
      shop_id="roothollow_herbalist", position ~(380, 180))
    RootholowSave (SavePoint instance, save_point_id="roothollow_shrine",
      position ~(240, 300))

  Transitions (Node2D)
    ExitToOverworld (Area2D)
      position = Vector2(240, 32)
      collision_layer = 0, collision_mask = 2
      monitoring = true, monitorable = false
      metadata/target_map = "overworld"
      metadata/target_spawn = "from_roothollow"
      CollisionShape2D (RectangleShape2D size 48x32)

  Scene5Trigger (Area2D)
    position = Vector2(240, 80)
    collision_layer = 0, collision_mask = 2
    monitoring = true, monitorable = false
    metadata/flag = "torren_joined"
    metadata/dialogue_data = <loaded from torren_encounter.json>
    CollisionShape2D (RectangleShape2D size 96x32)

  PlayerSpawn (Marker2D) position = Vector2(240, 64)
  from_overworld (Marker2D) position = Vector2(240, 64)
```

The Scene5Trigger is a dialogue trigger zone (same pattern as
ember_vein boss/dialogue triggers). It fires when the player enters
and `torren_joined` flag is NOT set. After dialogue completes, the
flag is set by `_on_dialogue_trigger_entered`.

**Important:** The dialogue_data metadata needs to reference the
dialogue entries. Since the dialogue trigger in exploration.gd reads
`area.get_meta("dialogue_data", [])` and passes it to
`show_dialogue()`, the metadata should contain the dialogue entries
array directly. However, for large dialogue scenes, embedding JSON
in .tscn metadata is impractical.

**Alternative approach:** Use a dialogue_scene_id metadata that
exploration.gd resolves via DataManager:

```
metadata/dialogue_scene_id = "torren_encounter"
metadata/flag = "torren_joined"
```

This requires a small change to `_on_dialogue_trigger_entered` to
load dialogue from DataManager when `dialogue_scene_id` is set
instead of `dialogue_data`.

- [ ] **Step 2: Update exploration.gd to support dialogue_scene_id**

In `_on_dialogue_trigger_entered`, before the dialogue_data check:

```gdscript
func _on_dialogue_trigger_entered(body: Node2D, area: Area2D) -> void:
	if body != _player or _transitioning:
		return
	var flag: String = area.get_meta("flag", "")
	if not flag.is_empty() and EventFlags.get_flag(flag):
		return
	var dialogue: Variant = area.get_meta("dialogue_data", [])
	var scene_id: String = area.get_meta("dialogue_scene_id", "")
	if scene_id != "":
		var scene_data: Dictionary = DataManager.load_dialogue(scene_id)
		dialogue = scene_data.get("entries", [])
	if not (dialogue is Array) or (dialogue as Array).is_empty():
		return
	if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		GameManager.overlay_node.show_dialogue(dialogue as Array)
		if not flag.is_empty():
			EventFlags.set_flag(flag, true)
			_check_party_joining_flags()
```

This adds 3 lines. The `dialogue_scene_id` metadata on the Area2D
triggers DataManager to load the dialogue JSON file.

- [ ] **Step 3: Commit**

```bash
git add game/scenes/maps/towns/roothollow.tscn game/scripts/core/exploration.gd
git commit -m "feat(engine): add Roothollow village map with NPCs, shop, and Scene 5 trigger"
```

### Task 7: Create Maren's Refuge map scene

**Files:**
- Create: `game/scenes/maps/towns/marens_refuge.tscn`

- [ ] **Step 1: Write the .tscn file**

Small cottage interior (same scale as valdris_anchor_oar.tscn at 16x14):

```
Node2D "MarensRefuge"
  metadata/map_id = "marens_refuge"
  metadata/dungeon_id = ""
  metadata/floor_id = ""
  metadata/location_name = "Maren's Refuge"

  TileMapLayer (placeholder_dungeon.tres, 16x14)
    - Border: wall tiles (1)
    - Floor: town floor (5)
    - Decorative: crystal tiles (2) for bookshelves/ley crystals

  Entities (Node2D)
    Maren (NPC instance, npc_id="maren_refuge", position ~(128, 48))

  Transitions (Node2D)
    ExitToOverworld (Area2D)
      position = Vector2(128, 200)
      collision_layer = 0, collision_mask = 2
      metadata/target_map = "overworld"
      metadata/target_spawn = "from_marens_refuge"
      CollisionShape2D (RectangleShape2D size 32x16)

  Scene6Trigger (Area2D)
    position = Vector2(128, 112)
    collision_layer = 0, collision_mask = 2
    metadata/dialogue_scene_id = "scene_6_marens_warning"
    metadata/flag = "maren_warning"
    CollisionShape2D (RectangleShape2D size 96x32)

  PlayerSpawn (Marker2D) position = Vector2(128, 192)
  from_overworld (Marker2D) position = Vector2(128, 192)
```

Scene 6 trigger requires `torren_joined` to be set. However, the
current dialogue trigger system only checks the `flag` metadata for
"already fired" gating. We need a `required_flag` metadata check.

- [ ] **Step 2: Add required_flag support to dialogue trigger**

In `_on_dialogue_trigger_entered`, add a required_flag check:

```gdscript
	var required: String = area.get_meta("required_flag", "")
	if not required.is_empty() and not EventFlags.get_flag(required):
		return
```

Insert this right after the existing flag check (after the
`if not flag.is_empty() and EventFlags.get_flag(flag): return` line).

Then add to Scene6Trigger metadata:
```
metadata/required_flag = "torren_joined"
```

This ensures Scene 6 only fires after Scene 5 (Torren joined).

- [ ] **Step 3: Commit**

```bash
git add game/scenes/maps/towns/marens_refuge.tscn game/scripts/core/exploration.gd
git commit -m "feat(engine): add Maren's Refuge map with Scene 6 trigger and required_flag support"
```

### Task 8: Add overworld transitions for Roothollow and Maren's Refuge

**Files:**
- Modify: `game/scenes/maps/overworld.tscn`

- [ ] **Step 1: Add sub_resources for collision shapes**

Add after existing Shape_ember sub_resource:

```
[sub_resource type="RectangleShape2D" id="Shape_roothollow"]
size = Vector2(48, 48)

[sub_resource type="RectangleShape2D" id="Shape_marens"]
size = Vector2(48, 48)
```

- [ ] **Step 2: Add transition nodes**

Add after EmberVeinEntrance node block:

```
[node name="Roothollow" type="Area2D" parent="Transitions"]
position = Vector2(480, 480)
collision_layer = 0
collision_mask = 2
monitoring = true
monitorable = false
metadata/target_map = "towns/roothollow"
metadata/target_spawn = "from_overworld"

[node name="CollisionShape2D" type="CollisionShape2D" parent="Transitions/Roothollow"]
shape = SubResource("Shape_roothollow")

[node name="MarensRefuge" type="Area2D" parent="Transitions"]
position = Vector2(200, 500)
collision_layer = 0
collision_mask = 2
monitoring = true
monitorable = false
metadata/target_map = "towns/marens_refuge"
metadata/target_spawn = "from_overworld"

[node name="CollisionShape2D" type="CollisionShape2D" parent="Transitions/MarensRefuge"]
shape = SubResource("Shape_marens")
```

- [ ] **Step 3: Add spawn markers**

Add after existing from_ember_vein marker:

```
[node name="from_roothollow" type="Marker2D" parent="."]
position = Vector2(448, 448)

[node name="from_marens_refuge" type="Marker2D" parent="."]
position = Vector2(232, 468)
```

- [ ] **Step 4: Verify positions are within bounds**

Overworld is 60x40 tiles = 960x640 pixels. Check all new positions:
- Roothollow transition: (480, 480) — within bounds ✓
- Maren's Refuge transition: (200, 500) — within bounds ✓
- from_roothollow marker: (448, 448) — within bounds ✓
- from_marens_refuge marker: (232, 468) — within bounds ✓

All positions are on grass/walkable tiles (not on water/mountain border).

- [ ] **Step 5: Commit**

```bash
git add game/scenes/maps/overworld.tscn
git commit -m "feat(engine): add Roothollow and Maren's Refuge transitions to overworld"
```

---

## Chunk 3: Tests + Gap Tracker

### Task 9: Write Wilds Route integration tests

**Files:**
- Create: `game/tests/test_wilds_route.gd`

- [ ] **Step 1: Write the test file**

```gdscript
extends GutTest
## Integration tests for the Wilds Route — Roothollow, Maren's Refuge,
## overworld transitions, shop data, encounter zones, and party assembly.


func before_each() -> void:
	DataManager.clear_cache()
	EventFlags.clear_all()


# --- Scene Existence ---


func test_roothollow_scene_exists() -> void:
	assert_true(FileAccess.file_exists("res://scenes/maps/towns/roothollow.tscn"))


func test_marens_refuge_scene_exists() -> void:
	assert_true(FileAccess.file_exists("res://scenes/maps/towns/marens_refuge.tscn"))


# --- Overworld Transitions ---


func test_overworld_has_roothollow_transition() -> void:
	var text: String = _read_file("res://scenes/maps/overworld.tscn")
	assert_true(text.contains("towns/roothollow"), "overworld should target roothollow")


func test_overworld_has_marens_refuge_transition() -> void:
	var text: String = _read_file("res://scenes/maps/overworld.tscn")
	assert_true(text.contains("towns/marens_refuge"), "overworld should target marens_refuge")


func test_overworld_wilds_spawn_markers() -> void:
	var text: String = _read_file("res://scenes/maps/overworld.tscn")
	assert_true(text.contains("from_roothollow"), "should have from_roothollow marker")
	assert_true(text.contains("from_marens_refuge"), "should have from_marens_refuge marker")


func test_roothollow_exit_targets_overworld() -> void:
	var text: String = _read_file("res://scenes/maps/towns/roothollow.tscn")
	assert_true(
		text.contains('target_map = "overworld"'),
		"roothollow exit should target overworld"
	)


func test_marens_refuge_exit_targets_overworld() -> void:
	var text: String = _read_file("res://scenes/maps/towns/marens_refuge.tscn")
	assert_true(
		text.contains('target_map = "overworld"'),
		"marens_refuge exit should target overworld"
	)


# --- Round-Trip Validation ---


func test_overworld_to_roothollow_round_trip() -> void:
	var ow: String = _read_file("res://scenes/maps/overworld.tscn")
	var rh: String = _read_file("res://scenes/maps/towns/roothollow.tscn")
	assert_true(ow.contains("towns/roothollow"), "overworld targets roothollow")
	assert_true(rh.contains('"overworld"'), "roothollow targets overworld")
	assert_true(ow.contains("from_roothollow"), "overworld has from_roothollow spawn")
	assert_true(rh.contains("from_overworld"), "roothollow has from_overworld spawn")


func test_overworld_to_marens_refuge_round_trip() -> void:
	var ow: String = _read_file("res://scenes/maps/overworld.tscn")
	var mr: String = _read_file("res://scenes/maps/towns/marens_refuge.tscn")
	assert_true(ow.contains("towns/marens_refuge"), "overworld targets marens_refuge")
	assert_true(mr.contains('"overworld"'), "marens_refuge targets overworld")
	assert_true(ow.contains("from_marens_refuge"), "overworld has from_marens_refuge spawn")
	assert_true(mr.contains("from_overworld"), "marens_refuge has from_overworld spawn")


# --- Shop Data ---


func test_roothollow_herbalist_shop_exists() -> void:
	var data: Dictionary = DataManager.load_shop("roothollow_herbalist")
	assert_false(data.is_empty(), "roothollow herbalist shop should load")


func test_roothollow_herbalist_has_despair_ward() -> void:
	var data: Dictionary = DataManager.load_shop("roothollow_herbalist")
	var inv: Array = data.get("inventory", [])
	var found: bool = false
	for item: Variant in inv:
		if item is Dictionary and (item as Dictionary).get("item_id", "") == "despair_ward":
			found = true
			break
	assert_true(found, "roothollow herbalist should stock despair_ward")


# --- Dialogue Data ---


func test_torren_encounter_dialogue_exists() -> void:
	var data: Dictionary = DataManager.load_dialogue("torren_encounter")
	assert_false(data.is_empty(), "torren_encounter dialogue should load")
	var entries: Array = data.get("entries", [])
	assert_gt(entries.size(), 0, "torren_encounter should have entries")


func test_marens_warning_dialogue_exists() -> void:
	var data: Dictionary = DataManager.load_dialogue("scene_6_marens_warning")
	assert_false(data.is_empty(), "scene_6_marens_warning dialogue should load")
	var entries: Array = data.get("entries", [])
	assert_gt(entries.size(), 0, "scene_6_marens_warning should have entries")


# --- Encounter Zone ---


func test_thornmere_wilds_zone_exists() -> void:
	var data: Dictionary = DataManager.load_encounters("overworld")
	var zones: Array = data.get("zones", [])
	var found: bool = false
	for z: Variant in zones:
		if z is Dictionary and (z as Dictionary).get("zone_id", "") == "thornmere_wilds":
			found = true
			var groups: Array = (z as Dictionary).get("groups", [])
			assert_gt(groups.size(), 0, "thornmere_wilds should have encounter groups")
			break
	assert_true(found, "overworld should have thornmere_wilds zone")


# --- Scene 5/6 Trigger Wiring ---


func test_roothollow_has_scene5_trigger() -> void:
	var text: String = _read_file("res://scenes/maps/towns/roothollow.tscn")
	assert_true(text.contains("torren_joined"), "roothollow should have torren_joined flag trigger")
	assert_true(
		text.contains("torren_encounter"),
		"roothollow should reference torren_encounter dialogue"
	)


func test_marens_refuge_has_scene6_trigger() -> void:
	var text: String = _read_file("res://scenes/maps/towns/marens_refuge.tscn")
	assert_true(text.contains("maren_warning"), "marens_refuge should have maren_warning flag")
	assert_true(
		text.contains("scene_6_marens_warning"),
		"marens_refuge should reference scene_6 dialogue"
	)


func test_marens_refuge_requires_torren_joined() -> void:
	var text: String = _read_file("res://scenes/maps/towns/marens_refuge.tscn")
	assert_true(
		text.contains("required_flag") and text.contains("torren_joined"),
		"scene 6 trigger should require torren_joined flag"
	)


# --- NPC Metadata ---


func test_roothollow_has_shop_npc() -> void:
	var text: String = _read_file("res://scenes/maps/towns/roothollow.tscn")
	assert_true(
		text.contains("roothollow_herbalist"),
		"roothollow should have herbalist shop NPC"
	)


func test_roothollow_has_vessa_npc() -> void:
	var text: String = _read_file("res://scenes/maps/towns/roothollow.tscn")
	assert_true(text.contains('"vessa"'), "roothollow should have Vessa NPC")


func test_roothollow_has_save_point() -> void:
	var text: String = _read_file("res://scenes/maps/towns/roothollow.tscn")
	assert_true(
		text.contains("roothollow_shrine"),
		"roothollow should have save point"
	)


# --- Helper ---


func _read_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text
```

- [ ] **Step 2: Run gdformat**

```bash
gdformat game/tests/test_wilds_route.gd
```

- [ ] **Step 3: Commit**

```bash
git add game/tests/test_wilds_route.gd
git commit -m "test(engine): add Wilds Route integration tests — transitions, shops, triggers, round trips"
```

### Task 10: Expand cross-reference tests

**Files:**
- Modify: `game/tests/test_cross_references.gd`

- [ ] **Step 1: Add roothollow shop to shop validation**

Find the existing shop validation test and ensure the roothollow_herbalist
shop is covered by the scan. If the test already scans all shop files
in `game/data/shops/`, no change is needed (verify this).

If the test hardcodes shop IDs, add `"roothollow_herbalist"` to the list.

- [ ] **Step 2: Verify transition coverage**

The existing `test_all_transition_targets_exist` test should already
catch roothollow and marens_refuge transitions since it scans all .tscn
files. Verify by reading the test logic.

- [ ] **Step 3: Commit if changes made**

```bash
git add game/tests/test_cross_references.gd
git commit -m "test(engine): expand cross-reference tests for Wilds Route coverage"
```

### Task 11: Update gap tracker

**Files:**
- Modify: `docs/analysis/game-dev-gaps.md`

- [ ] **Step 1: Update gap 4.4 status**

Change gap 4.4 from NOT STARTED to IN PROGRESS. Add Phase A completion
details under the "What's Needed" section:

```markdown
### 4.4 Remaining Act I Content

**Status:** IN PROGRESS
**Priority:** P1 — completes Act I
**Estimated Size:** XL (multiple phases)
**Output:** Additional dungeon/town maps, story scenes
**Source Docs:** `dungeons-world.md`, `script/act-i.md`, `events.md`, `economy.md`, `npcs.md`
**Depends On:** 4.1, 4.2, 4.3 (all MOSTLY COMPLETE)

**Phase A: Wilds Route (COMPLETE — 2026-04-08)**
- [x] Roothollow village map (30x25 tiles, Vessa NPC, herbalist shop, save point)
- [x] Maren's Refuge interior map (16x14 tiles, Maren NPC)
- [x] Overworld transitions to both locations
- [x] Scene 5 dialogue trigger (Torren joins party via torren_encounter.json)
- [x] Scene 6 dialogue trigger (Maren joins party via scene_6_marens_warning.json)
- [x] PartyState.add_member() public API
- [x] Roothollow herbalist shop (roothollow_herbalist.json, 10 items)
- [x] Thornmere Wilds overworld encounter zone
- [x] Tileset extended to 10 tiles (forest floor, bioluminescent)
- [x] Integration tests (test_wilds_route.gd)

**Phase A2: Fenmother's Hollow (NOT STARTED)**
- [ ] Second Act I dungeon (forest/swamp biome, 3 floors)
- [ ] Drowned Sentinel mini-boss + Corrupted Fenmother boss
- [ ] Encounter data exists (fenmothers_hollow.json)
- [ ] New enemy types (marsh_serpent, drowned_bones, ley_jellyfish, polluted_elemental)

**Phase B: Opening Sequence (NOT STARTED)**
- [ ] Ironmouth outpost map
- [ ] Ember Vein F3 (Ancient Ruin, puzzles)
- [ ] Scenes 1-4 (tutorial, Vaelith, Lira+Sable join, Dawn March credits)
- [ ] Party starts with Edren+Cael only, others join during Act I

**Phase C: Capital Completion (NOT STARTED)**
- [ ] Remaining Valdris districts (Citizen's Walk, Court Quarter, etc.)
- [ ] Scene 7 (throne hall, court, Cael's grey eyes)
- [ ] Thornwatch garrison rest stop
- [ ] Act I finale flag: pendulum_to_capital

**Blocking:** Act II content (needs Act I complete for flag state)
```

- [ ] **Step 2: Commit**

```bash
git add docs/analysis/game-dev-gaps.md
git commit -m "docs(engine): update gap 4.4 — Phase A Wilds Route complete, Phases A2/B/C documented"
```

### Task 12: Verify all tests pass

- [ ] **Step 1: Run GUT tests**

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game/ -s addons/gut/gut_cmdln.gd
```

All tests must pass (366 existing + ~25 new = ~391).

- [ ] **Step 2: Fix any failures**

If any tests fail, investigate and fix before proceeding.

---

## Remaining Work After This Plan

Explicitly documented in gap 4.4 tracker update (Task 11):

**Phase A2:** Fenmother's Hollow dungeon — 3 floors, 2 bosses, forest biome encounters. Encounter data already exists.

**Phase B:** Opening Sequence — Ironmouth, Ember Vein F3, Scenes 1-4, party starts with Edren+Cael only.

**Phase C:** Capital Completion — remaining Valdris districts, Scene 7 (throne hall), Thornwatch, Act I finale.

**Deferred Systems:** Cutscene overlay (3.7), Audio (3.8), Full overworld expansion, Deeproot Shrine optional content.
