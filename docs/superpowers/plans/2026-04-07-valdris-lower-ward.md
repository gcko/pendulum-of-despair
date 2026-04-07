# Valdris Crown Lower Ward Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a 1-district town (Lower Ward) proving the town gameplay loop: walk around, talk to NPCs, shop, rest at inn, save, transition to/from dungeon.

**Architecture:** TileMapLayer maps with extended placeholder tileset, existing NPC/save point prefabs, new SHOP overlay for buy-only shopping, encounter logic extracted from exploration.gd to free line budget for shop/inn wiring.

**Tech Stack:** Godot 4.6, GDScript, TileMapLayer, existing autoloads (GameManager, DataManager, PartyState, EventFlags)

**Spec:** `docs/superpowers/specs/2026-04-07-valdris-lower-ward-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `game/assets/tilesets/placeholder_dungeon.png` | MODIFY | Extend from 4 to 6 tiles |
| `game/assets/tilesets/placeholder_dungeon.tres` | MODIFY | Add tile 4-5 definitions |
| `game/scenes/maps/towns/valdris_lower_ward.tscn` | CREATE | Exterior map scene (40x35 tiles) |
| `game/scenes/maps/towns/valdris_anchor_oar.tscn` | CREATE | Tavern interior (16x14 tiles) |
| `game/scenes/maps/test_room.tscn` | MODIFY | Add Valdris transition |
| `game/scenes/overlay/shop_overlay.tscn` | CREATE | Shop buy screen |
| `game/scripts/ui/shop_overlay.gd` | CREATE | Shop overlay logic |
| `game/scripts/core/exploration.gd` | MODIFY | Shop/inn NPC detection, extract encounters |
| `game/scripts/core/encounter_handler.gd` | CREATE | Extracted encounter step/trigger logic |
| `game/scripts/autoload/party_state.gd` | MODIFY | Add `rest_at_inn()` |
| `game/scripts/autoload/game_manager.gd` | MODIFY | Add `OverlayState.SHOP` + scene path |
| `game/data/dialogue/npc_valdris_shopkeeper.json` | CREATE | Stub dialogue |
| `game/data/dialogue/npc_valdris_weaponsmith.json` | CREATE | Stub dialogue |
| `docs/analysis/game-dev-gaps.md` | MODIFY | Update gap 4.2 status |

---

## Chunk 1: Infrastructure (Tileset, Encounter Extraction, Shop Overlay)

### Task 1: Extend placeholder tileset

**Files:**
- Modify: `game/assets/tilesets/placeholder_dungeon.png`
- Modify: `game/assets/tilesets/placeholder_dungeon.tres`

- [ ] **Step 1: Extend tileset image from 4 to 6 tiles**

Add 2 new 16x16 tiles to the right of the existing 64x16 strip,
making it 96x16:
- Tile 4 (px 64-79): Building wall `#666666` — `rgb(102, 102, 102)`
- Tile 5 (px 80-95): Town floor `#C4A46E` — `rgb(196, 164, 110)`

```bash
python3 -c "
from PIL import Image
img = Image.open('game/assets/tilesets/placeholder_dungeon.png')
new_img = Image.new('RGBA', (96, 16))
new_img.paste(img, (0, 0))
colors = [(102,102,102,255), (196,164,110,255)]
for t, c in enumerate(colors):
    for y in range(16):
        for x in range(16):
            new_img.putpixel((64 + t*16 + x, y), c)
new_img.save('game/assets/tilesets/placeholder_dungeon.png')
"
```

- [ ] **Step 2: Verify image dimensions**

```bash
file game/assets/tilesets/placeholder_dungeon.png
# Expected: PNG image data, 96 x 16
```

- [ ] **Step 3: Update .tres to include tiles 4-5**

Read `game/assets/tilesets/placeholder_dungeon.tres`. The atlas source
`texture_region_size` is already `Vector2i(16, 16)`. Godot auto-detects
new tile columns from the larger image — no .tres edit needed if the
atlas source covers the full image width. Verify in the existing .tres
that the atlas margin/separation don't clip the new columns.

If the atlas has a fixed region, update it to cover 96px width.

- [ ] **Step 4: Commit**

```bash
git add game/assets/tilesets/placeholder_dungeon.png game/assets/tilesets/placeholder_dungeon.tres
git commit -m "feat(assets): extend placeholder tileset with town tiles (building, floor)"
```

### Task 2: Add SHOP overlay state to GameManager

**Files:**
- Modify: `game/scripts/autoload/game_manager.gd` (lines 19-27)

- [ ] **Step 1: Add SHOP to OverlayState enum**

In `game_manager.gd` line 27, the enum is:
```gdscript
enum OverlayState { NONE, MENU, DIALOGUE, SAVE_LOAD, CUTSCENE }
```

Change to:
```gdscript
enum OverlayState { NONE, MENU, DIALOGUE, SAVE_LOAD, CUTSCENE, SHOP }
```

- [ ] **Step 2: Add SHOP scene path to OVERLAY_SCENES dict**

In `game_manager.gd` lines 19-24, the dict maps overlay states to
scene paths. Add:
```gdscript
OverlayState.SHOP: "res://scenes/overlay/shop_overlay.tscn",
```

- [ ] **Step 3: Run gdlint + gdformat**

```bash
gdlint game/scripts/autoload/game_manager.gd
gdformat game/scripts/autoload/game_manager.gd
```

- [ ] **Step 4: Commit**

```bash
git add game/scripts/autoload/game_manager.gd
git commit -m "feat(engine): add SHOP overlay state to GameManager"
```

### Task 3: Add rest_at_inn() to PartyState

**Files:**
- Modify: `game/scripts/autoload/party_state.gd`

- [ ] **Step 1: Add rest_at_inn() method**

Add after the existing `spend_gold()` method (around line 317).
This restores all active party members to max HP/MP/AC and clears
status effects. Per economy.md.

```gdscript
## Restore all party members to full HP/MP/AC and clear status.
## Called when resting at an inn. Per economy.md inn rules.
func rest_at_inn() -> void:
	for i: int in range(_active_party.size()):
		var member: Dictionary = _active_party[i]
		if member.is_empty():
			continue
		var stats: Dictionary = member.get("base_stats", {})
		member["current_hp"] = member.get("max_hp", stats.get("hp", 1))
		member["current_mp"] = member.get("max_mp", stats.get("mp", 0))
		member["current_ac"] = member.get("max_ac", 12)
		member["status_effects"] = []
```

- [ ] **Step 2: Run gdlint + gdformat, verify under 400 lines**

```bash
gdlint game/scripts/autoload/party_state.gd
gdformat game/scripts/autoload/party_state.gd
wc -l game/scripts/autoload/party_state.gd
```

- [ ] **Step 3: Commit**

```bash
git add game/scripts/autoload/party_state.gd
git commit -m "feat(engine): add PartyState.rest_at_inn() for inn healing"
```

### Task 4: Extract encounter logic from exploration.gd

**Files:**
- Create: `game/scripts/core/encounter_handler.gd`
- Modify: `game/scripts/core/exploration.gd`

The goal is to free ~30 lines from exploration.gd by moving encounter
step/trigger logic to a static helper, making room for shop/inn code.

- [ ] **Step 1: Create encounter_handler.gd**

```gdscript
extends RefCounted
## Static encounter helpers extracted from exploration.gd.

const EncounterSystem = preload("res://scripts/combat/encounter_system.gd")


## Process one movement step for random encounters.
## Returns the updated danger counter. If an encounter triggers,
## returns -1 (caller should start the encounter).
static func process_step(
	config: Dictionary, danger: int, party: Array[Dictionary]
) -> int:
	if config.is_empty():
		return danger
	var base: int = config.get("danger_increment", 0)
	if base <= 0:
		return danger
	var acc_mod: float = EncounterSystem.get_accessory_modifier(party)
	var new_danger: int = danger + EncounterSystem.roll_increment(base, 1.0, acc_mod)
	if EncounterSystem.check_encounter(new_danger):
		return -1
	return new_danger


## Build the transition dictionary for a random encounter.
static func build_random_encounter(
	config: Dictionary, map_id: String, player_pos: Vector2
) -> Dictionary:
	var groups: Array = config.get("groups", [])
	if groups.is_empty():
		return {}
	var group: Dictionary = EncounterSystem.select_encounter_group(groups)
	var rates: Dictionary = config.get("formation_rates", {})
	var formation: String = EncounterSystem.roll_formation(rates)
	return {
		"encounter_group": group.get("enemies", []),
		"formation_type": formation,
		"return_map_id": map_id,
		"return_position": player_pos,
		"enemy_act": "act_i",
		"encounter_source": "random",
	}
```

- [ ] **Step 2: Update exploration.gd to use EncounterHandler**

Add const at top of exploration.gd (after existing const lines):
```gdscript
const EncounterHandler = preload("res://scripts/core/encounter_handler.gd")
```

Replace `_process_encounter_step()` body (lines 64-73) with:
```gdscript
func _process_encounter_step() -> void:
	var result: int = EncounterHandler.process_step(
		_encounter_config, _danger_counter, PartyState.get_active_party()
	)
	if result == -1:
		_trigger_random_encounter()
	else:
		_danger_counter = result
```

Replace `_trigger_random_encounter()` body (lines 76-95) with:
```gdscript
func _trigger_random_encounter() -> void:
	if _transitioning:
		return
	var transition: Dictionary = EncounterHandler.build_random_encounter(
		_encounter_config, _current_map_id, _player.position
	)
	if transition.is_empty():
		return
	_danger_counter = 0
	_transitioning = true
	GameManager.change_core_state(GameManager.CoreState.BATTLE, transition)
```

- [ ] **Step 3: Run gdlint + gdformat on both files**

```bash
gdlint game/scripts/core/encounter_handler.gd game/scripts/core/exploration.gd
gdformat game/scripts/core/encounter_handler.gd game/scripts/core/exploration.gd
wc -l game/scripts/core/exploration.gd
# Must be well under 400 (target: ~375)
```

- [ ] **Step 4: Commit**

```bash
git add game/scripts/core/encounter_handler.gd game/scripts/core/exploration.gd
git commit -m "refactor(engine): extract encounter logic to encounter_handler.gd"
```

### Task 5: Create shop overlay scene and script

**Files:**
- Create: `game/scenes/overlay/shop_overlay.tscn`
- Create: `game/scripts/ui/shop_overlay.gd`

Buy-only shop for the vertical slice. Player sees item list with
prices, selects one, gold deducted, item added to inventory.

- [ ] **Step 1: Create shop_overlay.gd**

```gdscript
extends CanvasLayer
## Buy-only shop overlay for the vertical slice.
##
## Reads shop_id from GameManager.transition_data, loads inventory
## via DataManager, displays item list, handles buy transactions.

signal shop_closed

var _shop_data: Dictionary = {}
var _inventory: Array = []
var _selected_index: int = 0

@onready var _panel: PanelContainer = $Panel
@onready var _title_label: Label = $Panel/VBox/TitleLabel
@onready var _item_list: VBoxContainer = $Panel/VBox/ScrollContainer/ItemList
@onready var _gold_label: Label = $Panel/VBox/GoldLabel
@onready var _desc_label: Label = $Panel/VBox/DescLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var shop_id: String = GameManager.transition_data.get("shop_id", "")
	if shop_id.is_empty():
		push_error("ShopOverlay: No shop_id in transition_data")
		call_deferred("_close")
		return
	_shop_data = DataManager.load_shop(shop_id)
	var shop: Dictionary = _shop_data.get("shop", {})
	_title_label.text = shop.get("type", "Shop").capitalize() + " Shop"
	_inventory = shop.get("inventory", [])
	_build_item_list()
	_update_gold()
	_update_selection()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()
		return
	if event.is_action_pressed("ui_up"):
		get_viewport().set_input_as_handled()
		_selected_index = maxi(0, _selected_index - 1)
		_update_selection()
	elif event.is_action_pressed("ui_down"):
		get_viewport().set_input_as_handled()
		_selected_index = mini(_inventory.size() - 1, _selected_index + 1)
		_update_selection()
	elif event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_buy_selected()


func _build_item_list() -> void:
	for child: Node in _item_list.get_children():
		child.queue_free()
	for entry: Dictionary in _inventory:
		var item_id: String = entry.get("item_id", "")
		var price: int = entry.get("buy_price", 0)
		var item_data: Dictionary = DataManager.load_items("consumables")
		var name: String = _lookup_item_name(item_id)
		var row: Label = Label.new()
		row.text = "%s  %dg" % [name, price]
		_item_list.add_child(row)


func _lookup_item_name(item_id: String) -> String:
	for cat: String in ["consumables", "materials"]:
		var data: Dictionary = DataManager.load_items(cat)
		for item: Dictionary in data.get("items", []):
			if item.get("id", "") == item_id:
				return item.get("name", item_id)
	for etype: String in ["weapons", "armor", "accessories"]:
		var data: Dictionary = DataManager.load_equipment(etype)
		for item: Dictionary in data.get("equipment", data.get(etype, [])):
			if item.get("id", "") == item_id:
				return item.get("name", item_id)
	return item_id


func _buy_selected() -> void:
	if _selected_index < 0 or _selected_index >= _inventory.size():
		return
	var entry: Dictionary = _inventory[_selected_index]
	var price: int = entry.get("buy_price", 0)
	if not PartyState.spend_gold(price):
		_desc_label.text = "Not enough gold."
		return
	PartyState.add_item(entry.get("item_id", ""), 1)
	_desc_label.text = "Purchased!"
	_update_gold()


func _update_gold() -> void:
	_gold_label.text = "Gold: %d" % PartyState.get_gold()


func _update_selection() -> void:
	for i: int in range(_item_list.get_child_count()):
		var label: Label = _item_list.get_child(i) as Label
		if label == null:
			continue
		label.add_theme_color_override(
			"font_color", Color.YELLOW if i == _selected_index else Color.WHITE
		)
	if _selected_index >= 0 and _selected_index < _inventory.size():
		var entry: Dictionary = _inventory[_selected_index]
		_desc_label.text = _lookup_item_name(entry.get("item_id", ""))


func _close() -> void:
	GameManager.pop_overlay()
```

- [ ] **Step 2: Create shop_overlay.tscn**

Write the .tscn text file with the scene tree:
```
ShopOverlay (CanvasLayer)
  Panel (PanelContainer) — anchored center, 280x160
    VBox (VBoxContainer)
      TitleLabel (Label)
      ScrollContainer (ScrollContainer) — 280x100
        ItemList (VBoxContainer)
      GoldLabel (Label)
      DescLabel (Label)
```

Use `StyleBoxFlat` for the panel background (dark blue `#1A1A2E`
with border).

- [ ] **Step 3: Run gdlint + gdformat**

```bash
gdlint game/scripts/ui/shop_overlay.gd
gdformat game/scripts/ui/shop_overlay.gd
wc -l game/scripts/ui/shop_overlay.gd
```

- [ ] **Step 4: Commit**

```bash
git add game/scenes/overlay/shop_overlay.tscn game/scripts/ui/shop_overlay.gd
git commit -m "feat(engine): add buy-only shop overlay for town NPCs"
```

### Task 6: Wire shop and inn interaction in exploration.gd

**Files:**
- Modify: `game/scripts/core/exploration.gd`

- [ ] **Step 1: Update _on_npc_interacted to detect shop/inn NPCs**

Replace the current `_on_npc_interacted` (line 315-320):

```gdscript
func _on_npc_interacted(npc_id: String, dialogue_data: Dictionary) -> void:
	var npc_node: Node = _find_entity_npc(npc_id)
	if npc_node != null:
		if npc_node.has_meta("shop_id"):
			GameManager.transition_data = {"shop_id": npc_node.get_meta("shop_id")}
			GameManager.push_overlay(GameManager.OverlayState.SHOP)
			return
		if npc_node.has_meta("inn_id"):
			_handle_inn(npc_node)
			return
	if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		var overlay: Node = GameManager.overlay_node
		if overlay != null and overlay.has_method("show_dialogue"):
			overlay.show_dialogue([dialogue_data])
```

- [ ] **Step 2: Add _find_entity_npc helper**

```gdscript
func _find_entity_npc(npc_id: String) -> Node:
	var entities: Node = _current_map.get_node_or_null("Entities")
	if entities == null:
		return null
	for child: Node in entities.get_children():
		if child.has_signal("npc_interacted") and child.npc_id == npc_id:
			return child
	return null
```

- [ ] **Step 3: Add _handle_inn helper**

```gdscript
func _handle_inn(npc_node: Node) -> void:
	var cost: int = npc_node.get_meta("inn_cost", 150)
	if not PartyState.spend_gold(cost):
		flash_location_name("Not enough gold.")
		return
	PartyState.rest_at_inn()
	flash_location_name("Rested at the inn.")
```

- [ ] **Step 4: Run gdlint + gdformat, verify under 400 lines**

```bash
gdlint game/scripts/core/exploration.gd
gdformat game/scripts/core/exploration.gd
wc -l game/scripts/core/exploration.gd
# Must be <= 400
```

- [ ] **Step 5: Commit**

```bash
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): wire shop and inn NPC interaction in exploration"
```

---

## Chunk 2: Town Maps and Content

### Task 7: Create stub dialogue JSON for shop NPCs

**Files:**
- Create: `game/data/dialogue/npc_valdris_shopkeeper.json`
- Create: `game/data/dialogue/npc_valdris_weaponsmith.json`

- [ ] **Step 1: Create shopkeeper dialogue**

```json
{
  "scene_id": "npc_valdris_shopkeeper",
  "entries": [
    {
      "id": "npc_valdris_shopkeeper_001",
      "speaker": "valdris_shopkeeper",
      "lines": ["Welcome! Take a look around."],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null
    }
  ]
}
```

- [ ] **Step 2: Create weaponsmith dialogue**

```json
{
  "scene_id": "npc_valdris_weaponsmith",
  "entries": [
    {
      "id": "npc_valdris_weaponsmith_001",
      "speaker": "valdris_weaponsmith",
      "lines": ["Good steel keeps you alive. Browse my stock."],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null
    }
  ]
}
```

- [ ] **Step 3: Commit**

```bash
git add game/data/dialogue/npc_valdris_shopkeeper.json game/data/dialogue/npc_valdris_weaponsmith.json
git commit -m "feat(engine): add stub dialogue for Valdris shop NPCs"
```

### Task 8: Create Lower Ward exterior map

**Files:**
- Create: `game/scenes/maps/towns/valdris_lower_ward.tscn`

Write the .tscn as a Godot text scene file. 40x35 tiles with:

- [ ] **Step 1: Design the tile layout**

TileMapLayer with the extended placeholder tileset. Layout:
- Perimeter: wall tiles (tile 1)
- Interior: town floor tiles (tile 5)
- Buildings: building wall tiles (tile 4) in rectangular outlines
- Doors: stairs/door tile (tile 3) at building entrances
- South-west gap in wall: South Gate transition

Building positions (tile coordinates, approximate):
- Chapel (3,3 to 8,10)
- Barracks (15,2 to 22,8)
- Bakery (3,22 to 7,26)
- Item Shop (14,24 to 20,28)
- Arms Shop (22,24 to 28,28)
- Anchor & Oar (30,14 to 37,22)
- Cael's Quarters (32,3 to 36,8)

Central area (16,12 to 24,20): fountain area (floor tiles, no water
tile in placeholder — use crystal tile 2 for fountain accent).

- [ ] **Step 2: Write the .tscn file**

Scene tree:
```
Node2D (root)
  metadata/map_id = "towns/valdris_lower_ward"
  metadata/location_name = "Valdris Crown - Lower Ward"
  metadata/dungeon_id = ""
  metadata/floor_id = ""
  TileMapLayer (terrain + collision)
  Entities (Node2D)
    Bren (npc instance, metadata/npc_id = "bren")
    Wynn (npc instance, metadata/npc_id = "wynn")
    OldHarren (npc instance, metadata/npc_id = "old_harren")
    Thessa (npc instance, metadata/npc_id = "thessa")
    SergeantMarek (npc instance, metadata/npc_id = "sergeant_marek")
    Nella (npc instance, metadata/npc_id = "nella")
    Shopkeeper (npc instance, metadata/npc_id = "valdris_shopkeeper",
      metadata/shop_id = "valdris_crown_general")
    Weaponsmith (npc instance, metadata/npc_id = "valdris_weaponsmith",
      metadata/shop_id = "valdris_crown_armorer")
    SavePoint1 (save_point instance,
      metadata/save_point_id = "valdris_chapel_save")
  Transitions (Node2D)
    SouthGate (Area2D, target_map = "test_room",
      target_spawn = "from_valdris")
    TavernDoor (Area2D, target_map = "towns/valdris_anchor_oar",
      target_spawn = "from_exterior")
  PlayerSpawn (Marker2D)
  from_tavern (Marker2D, near tavern door)
  from_test_room (Marker2D, near south gate)
```

NPC positions must be on integer pixel coordinates within the
640x560 map bounds. Save point near the Chapel building.

- [ ] **Step 3: Verify entity count**

9 NPCs + 1 save point + 2 transitions + 2 markers = 14 entities.
Well under 64 budget.

- [ ] **Step 4: Commit**

```bash
git add game/scenes/maps/towns/valdris_lower_ward.tscn
git commit -m "feat(engine): add Valdris Crown Lower Ward exterior map"
```

### Task 9: Create Anchor & Oar tavern interior map

**Files:**
- Create: `game/scenes/maps/towns/valdris_anchor_oar.tscn`

16x14 tile tavern ground floor from interiors.md canonical layout.

- [ ] **Step 1: Write the .tscn file**

Scene tree:
```
Node2D (root)
  metadata/map_id = "towns/valdris_anchor_oar"
  metadata/location_name = "The Anchor & Oar"
  TileMapLayer (terrain — floor/walls/counter using placeholder tiles)
  Entities (Node2D)
    Renn (npc instance, metadata/npc_id = "renn",
      metadata/inn_id = "valdris_anchor_oar",
      metadata/inn_cost = 150)
    SavePoint (save_point instance,
      metadata/save_point_id = "valdris_anchor_oar_save")
  Transitions (Node2D)
    FrontDoor (Area2D, target_map = "towns/valdris_lower_ward",
      target_spawn = "from_tavern")
  PlayerSpawn (Marker2D, near front door)
  from_exterior (Marker2D, near front door)
```

Layout: walls around perimeter, floor inside, building wall tiles
for counter and fireplace areas.

Renn positioned behind the counter. Save point near the east wall
(staircase area per interiors.md).

- [ ] **Step 2: Commit**

```bash
git add game/scenes/maps/towns/valdris_anchor_oar.tscn
git commit -m "feat(engine): add Anchor & Oar tavern interior map"
```

### Task 10: Add Valdris transition to test_room

**Files:**
- Modify: `game/scenes/maps/test_room.tscn`

- [ ] **Step 1: Add transition and spawn marker**

Add to test_room.tscn Transitions node:
```
ExitNorthValdris (Area2D)
  position = Vector2(160, 16)
  collision_layer = 0, collision_mask = 2
  metadata/target_map = "towns/valdris_lower_ward"
  metadata/target_spawn = "from_test_room"
  CollisionShape2D (RectangleShape2D, 32x16)
```

Add spawn marker:
```
from_valdris (Marker2D)
  position = Vector2(160, 32)
```

- [ ] **Step 2: Commit**

```bash
git add game/scenes/maps/test_room.tscn
git commit -m "feat(engine): add Valdris Crown transition to test room"
```

---

## Chunk 3: Verification and Gap Tracker

### Task 11: Verify all wiring works

- [ ] **Step 1: Run gdlint on all changed/created .gd files**

```bash
gdlint game/scripts/core/exploration.gd \
  game/scripts/core/encounter_handler.gd \
  game/scripts/ui/shop_overlay.gd \
  game/scripts/autoload/party_state.gd \
  game/scripts/autoload/game_manager.gd
```

- [ ] **Step 2: Run gdformat on all changed/created .gd files**

```bash
gdformat game/scripts/core/exploration.gd \
  game/scripts/core/encounter_handler.gd \
  game/scripts/ui/shop_overlay.gd \
  game/scripts/autoload/party_state.gd \
  game/scripts/autoload/game_manager.gd
```

- [ ] **Step 3: Verify line counts**

```bash
wc -l game/scripts/core/exploration.gd
# Must be <= 400
wc -l game/scripts/ui/shop_overlay.gd
# Should be ~110
wc -l game/scripts/core/encounter_handler.gd
# Should be ~45
```

- [ ] **Step 4: Verify all referenced files exist**

```bash
ls game/scenes/maps/towns/valdris_lower_ward.tscn
ls game/scenes/maps/towns/valdris_anchor_oar.tscn
ls game/scenes/overlay/shop_overlay.tscn
ls game/scripts/ui/shop_overlay.gd
ls game/scripts/core/encounter_handler.gd
ls game/data/dialogue/npc_valdris_shopkeeper.json
ls game/data/dialogue/npc_valdris_weaponsmith.json
```

- [ ] **Step 5: Verify JSON validity**

```bash
python3 -c "import json; json.load(open('game/data/dialogue/npc_valdris_shopkeeper.json'))"
python3 -c "import json; json.load(open('game/data/dialogue/npc_valdris_weaponsmith.json'))"
```

- [ ] **Step 6: Cross-reference entity metadata**

Verify every NPC `metadata/npc_id` in the .tscn files has a
corresponding dialogue JSON file in `game/data/dialogue/`:
```bash
grep 'metadata/npc_id' game/scenes/maps/towns/valdris_lower_ward.tscn
grep 'metadata/npc_id' game/scenes/maps/towns/valdris_anchor_oar.tscn
# Each npc_id should map to game/data/dialogue/npc_{id}.json
```

Verify shop_id metadata maps to existing shop JSON:
```bash
grep 'metadata/shop_id' game/scenes/maps/towns/valdris_lower_ward.tscn
# valdris_crown_general -> game/data/shops/valdris_crown_general.json
# valdris_crown_armorer -> game/data/shops/valdris_crown_armorer.json
```

### Task 12: Update gap tracker

**Files:**
- Modify: `docs/analysis/game-dev-gaps.md`

- [ ] **Step 1: Update gap 4.2 status**

Change status from NOT STARTED to MOSTLY COMPLETE. Add notes:
- Lower Ward exterior + Anchor & Oar interior built
- 7 NPCs + 2 shop NPCs wired
- Shop overlay (buy-only) functional
- Inn rest functional
- 2 save points placed
- Remaining: Districts B-E, Scene 7 story, full shop system

- [ ] **Step 2: Commit**

```bash
git add docs/analysis/game-dev-gaps.md
git commit -m "docs(engine): update gap tracker — 4.2 Valdris Crown MOSTLY COMPLETE"
```

### Task 13: Final commit and handoff

- [ ] **Step 1: Verify clean working tree**

```bash
git status
# Should show clean
```

- [ ] **Step 2: Push**

```bash
git push -u origin feature/game-designer-tier-3-continued-5
```

**Next steps:**
1. `/create-pr` — open PR targeting main
2. `/godot-review-loop <PR#> 2` — multi-round hardening
3. Address Copilot comments + gap analysis (autonomous)
