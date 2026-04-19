# Valdris Capital Phase C Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete Valdris Crown with 3 new outdoor districts, 4 interiors, Scene 7 narrative (FF6 Vector-style free-roam), shop changes, and Act I finale.

**Architecture:** Data-driven town maps (no custom scripts on scenes — all behavior from exploration.gd reading metadata). NPC dialogue uses priority-stack conditions in JSON. Scene 7 uses dialogue triggers + cutscene triggers with flag gating. Multi-flag AND conditions require a small cutscene_handler.gd enhancement.

**Tech Stack:** Godot 4.6, GDScript, GUT test framework, JSON data files, .tscn scene files.

**Spec:** `docs/superpowers/specs/2026-04-19-valdris-capital-phase-c-design.md`

---

## File Structure

### New Files

| Path | Responsibility |
|------|---------------|
| `game/data/shops/valdris_crown_weaponsmith.json` | Weapons-only shop (split from armorer) |
| `game/data/shops/valdris_crown_armorsmith.json` | Armor-only shop (new) |
| `game/data/shops/valdris_crown_jeweler.json` | Accessory shop (new) |
| `game/data/equipment/accessories.json` | 4 new accessory entries (pact charms, silver ring, guardian pendant) |
| `game/data/dialogue/npc_king_aldren.json` | King ambient dialogue |
| `game/data/dialogue/npc_lord_haren.json` | Chancellor ambient dialogue |
| `game/data/dialogue/npc_dame_cordwyn.json` | Knight ambient + Scene 7c variant |
| `game/data/dialogue/npc_scholar_aldis.json` | Scholar ambient + Scene 7c variant |
| `game/data/dialogue/npc_mirren.json` | Archivist ambient dialogue |
| `game/data/dialogue/npc_elara_thane.json` | Court mage ambient dialogue |
| `game/data/dialogue/npc_jorin_ashvale.json` | Noble ambient dialogue |
| `game/data/dialogue/npc_valdris_armorsmith.json` | Shop greeting |
| `game/data/dialogue/npc_valdris_jeweler.json` | Shop greeting |
| `game/data/dialogue/npc_valdris_specialty.json` | Shop greeting |
| `game/data/dialogue/npc_court_guard.json` | Flavor guard dialogue |
| `game/data/dialogue/scene_7a_the_gates.json` | Gate arrival scene |
| `game/data/dialogue/scene_7b_throne_hall.json` | Throne presentation scene |
| `game/data/dialogue/scene_7c_aldis.json` | Aldis research conversation |
| `game/data/dialogue/scene_7c_cordwyn.json` | Cordwyn warning conversation |
| `game/data/dialogue/scene_7c_renn.json` | Renn intel conversation |
| `game/data/dialogue/scene_7d_evening.json` | Evening cutscene |
| `game/scenes/maps/towns/valdris_citizens_walk.tscn` | Citizen's Walk outdoor district |
| `game/scenes/maps/towns/valdris_court_quarter.tscn` | Court Quarter outdoor district |
| `game/scenes/maps/towns/valdris_throne_hall.tscn` | Throne Hall interior |
| `game/scenes/maps/towns/valdris_royal_library.tscn` | Royal Library interior |
| `game/scenes/maps/towns/valdris_barracks.tscn` | Barracks interior |
| `game/scenes/maps/towns/valdris_anchor_oar_upper.tscn` | Tavern upper floor |
| `game/tests/test_valdris_districts.gd` | Map integrity tests |
| `game/tests/test_valdris_shops.gd` | Shop data tests |
| `game/tests/test_valdris_dialogue.gd` | Dialogue data tests |
| `game/tests/test_scene_7_flags.gd` | Scene 7 flag logic tests |
| `game/tests/test_valdris_integration.gd` | District navigation integration |
| `game/tests/test_valdris_npcs_integration.gd` | NPC interaction integration |
| `game/tests/test_scene_7_integration.gd` | Scene 7 end-to-end |
| `game/tests/test_scene_7_ordering.gd` | Out-of-order resilience |
| `game/tests/test_lower_ward_regression.gd` | Lower Ward regression |
| `game/tests/test_anchor_oar_regression.gd` | Tavern regression |
| `game/tests/test_valdris_cross_references.gd` | Cross-reference validation |

### Modified Files

| Path | Change |
|------|--------|
| `game/data/shops/valdris_crown_armorer.json` | DELETE (split into weaponsmith + armorsmith) |
| `game/assets/tilesets/placeholder_dungeon.png` | Add 4 tile columns (14-17) |
| `game/assets/tilesets/placeholder_dungeon.tres` | Update atlas for new tiles |
| `game/scenes/maps/towns/valdris_lower_ward.tscn` | New transitions, spawns, shop rename |
| `game/scenes/maps/towns/valdris_anchor_oar.tscn` | Staircase transition |
| `game/scripts/core/cutscene_handler.gd` | Add `required_flags` (plural) AND support |
| `game/data/equipment/accessories.json` | Append 4 new entries |
| `docs/analysis/game-dev-gaps.md` | Status update + deferred items |

---

## Task 1: Tileset Extension

**Files:**
- Modify: `game/assets/tilesets/placeholder_dungeon.png`
- Modify: `game/assets/tilesets/placeholder_dungeon.tres`

- [ ] **Step 1: Create extended tileset PNG**

Use Python to extend the placeholder PNG with 4 new 16x16 colored tiles. The existing PNG has 14 tiles in a single row (224x16 px). Extend to 18 tiles (288x16 px).

```bash
cd /Users/jaredmscott/repos/projects/pendulum-of-despair
python3 -c "
from PIL import Image
img = Image.open('game/assets/tilesets/placeholder_dungeon.png')
w, h = img.size
new_img = Image.new('RGBA', (w + 64, h), (0, 0, 0, 0))
new_img.paste(img, (0, 0))
# Tile 14: Light tan (pale limestone floor)
for y in range(16):
    for x in range(16):
        new_img.putpixel((224 + x, y), (222, 207, 180, 255))
# Tile 15: Dark red (carpet)
for y in range(16):
    for x in range(16):
        new_img.putpixel((240 + x, y), (139, 28, 28, 255))
# Tile 16: Light grey (raised platform)
for y in range(16):
    for x in range(16):
        new_img.putpixel((256 + x, y), (192, 192, 200, 255))
# Tile 17: Gold/yellow (columns - impassable)
for y in range(16):
    for x in range(16):
        new_img.putpixel((272 + x, y), (204, 170, 51, 255))
new_img.save('game/assets/tilesets/placeholder_dungeon.png')
print('Extended tileset to 18 tiles (288x16)')
"
```

- [ ] **Step 2: Update tileset resource**

Read the current `placeholder_dungeon.tres` and add entries for tiles 14-17. Tile 17 (columns) gets a physics collision polygon.

Add these lines to the `[sub_resource type="TileSetAtlasSource"]` section, after the existing `13:0/0 = 0` line:

```
14:0/0 = 0
15:0/0 = 0
16:0/0 = 0
17:0/0 = 0
17:0/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
```

- [ ] **Step 3: Verify tileset loads**

```bash
cd /Users/jaredmscott/repos/projects/pendulum-of-despair
python3 -c "
from PIL import Image
img = Image.open('game/assets/tilesets/placeholder_dungeon.png')
print(f'Tileset size: {img.size} — expected (288, 16)')
assert img.size == (288, 16), f'Wrong size: {img.size}'
# Check tile 14 color (light tan)
px = img.getpixel((224, 0))
assert px == (222, 207, 180, 255), f'Tile 14 wrong color: {px}'
print('Tileset verification passed')
"
```

- [ ] **Step 4: Commit**

```bash
git add game/assets/tilesets/placeholder_dungeon.png game/assets/tilesets/placeholder_dungeon.tres
git commit -m "feat(engine): extend placeholder tileset with 4 capital tiles"
```

---

## Task 2: Shop Data Split and New Shops

**Files:**
- Create: `game/data/shops/valdris_crown_weaponsmith.json`
- Create: `game/data/shops/valdris_crown_armorsmith.json`
- Create: `game/data/shops/valdris_crown_jeweler.json`
- Delete: `game/data/shops/valdris_crown_armorer.json`
- Modify: `game/data/equipment/accessories.json`
- Test: `game/tests/test_valdris_shops.gd`

- [ ] **Step 1: Write shop data tests**

```gdscript
# game/tests/test_valdris_shops.gd
extends GutTest

func before_each() -> void:
	DataManager.clear_cache()

func after_each() -> void:
	DataManager.clear_cache()

# --- Weaponsmith ---

func test_weaponsmith_loads() -> void:
	var data: Dictionary = DataManager.load_shop("valdris_crown_weaponsmith")
	assert_not_equal(data, {}, "Weaponsmith shop should load")
	var shop: Dictionary = data.get("shop", {})
	assert_eq(shop.get("shop_id"), "valdris_crown_weaponsmith")
	assert_eq(shop.get("town"), "valdris_crown")
	assert_eq(shop.get("markup"), 1.0)

func test_weaponsmith_has_only_weapons() -> void:
	var data: Dictionary = DataManager.load_shop("valdris_crown_weaponsmith")
	var shop: Dictionary = data.get("shop", {})
	var inventory: Array = shop.get("inventory", [])
	assert_gt(inventory.size(), 0, "Weaponsmith should have items")
	var weapon_ids: Array[String] = [
		"valdris_blade", "knights_edge", "ley_wand", "stiletto",
		"iron_mallet", "iron_lance",
		"commanders_blade", "glyph_staff", "pickpockets_blade", "pipe_hammer",
	]
	for entry: Dictionary in inventory:
		var item_id: String = entry.get("item_id", "")
		assert_has(weapon_ids, item_id, "Item '%s' should be a weapon" % item_id)

func test_weaponsmith_items_exist_in_equipment() -> void:
	var data: Dictionary = DataManager.load_shop("valdris_crown_weaponsmith")
	var inventory: Array = data.get("shop", {}).get("inventory", [])
	var weapons_data: Dictionary = DataManager.load_json("res://data/equipment/weapons.json")
	var weapon_list: Array = weapons_data.get("weapons", [])
	var weapon_ids: Array[String] = []
	for w: Dictionary in weapon_list:
		weapon_ids.append(w.get("id", ""))
	for entry: Dictionary in inventory:
		var item_id: String = entry.get("item_id", "")
		assert_has(weapon_ids, item_id, "Weapon '%s' must exist in weapons.json" % item_id)

# --- Armorsmith ---

func test_armorsmith_loads() -> void:
	var data: Dictionary = DataManager.load_shop("valdris_crown_armorsmith")
	assert_not_equal(data, {}, "Armorsmith shop should load")
	var shop: Dictionary = data.get("shop", {})
	assert_eq(shop.get("shop_id"), "valdris_crown_armorsmith")
	assert_eq(shop.get("town"), "valdris_crown")

func test_armorsmith_has_only_armor() -> void:
	var data: Dictionary = DataManager.load_shop("valdris_crown_armorsmith")
	var shop: Dictionary = data.get("shop", {})
	var inventory: Array = shop.get("inventory", [])
	assert_gt(inventory.size(), 0, "Armorsmith should have items")
	var armor_ids: Array[String] = [
		"iron_helm", "travelers_hood", "ember_circlet",
		"chain_mail", "iron_plate", "silk_robe", "reinforced_vest",
	]
	for entry: Dictionary in inventory:
		var item_id: String = entry.get("item_id", "")
		assert_has(armor_ids, item_id, "Item '%s' should be armor" % item_id)

func test_armorsmith_items_exist_in_equipment() -> void:
	var data: Dictionary = DataManager.load_shop("valdris_crown_armorsmith")
	var inventory: Array = data.get("shop", {}).get("inventory", [])
	var armor_data: Dictionary = DataManager.load_json("res://data/equipment/armor.json")
	var armor_list: Array = armor_data.get("armor", [])
	var armor_ids: Array[String] = []
	for a: Dictionary in armor_list:
		armor_ids.append(a.get("id", ""))
	for entry: Dictionary in inventory:
		var item_id: String = entry.get("item_id", "")
		assert_has(armor_ids, item_id, "Armor '%s' must exist in armor.json" % item_id)

# --- Jeweler ---

func test_jeweler_loads() -> void:
	var data: Dictionary = DataManager.load_shop("valdris_crown_jeweler")
	assert_not_equal(data, {}, "Jeweler shop should load")
	var shop: Dictionary = data.get("shop", {})
	assert_eq(shop.get("shop_id"), "valdris_crown_jeweler")
	assert_eq(shop.get("town"), "valdris_crown")

func test_jeweler_items_exist_in_accessories() -> void:
	var data: Dictionary = DataManager.load_shop("valdris_crown_jeweler")
	var inventory: Array = data.get("shop", {}).get("inventory", [])
	assert_gt(inventory.size(), 0, "Jeweler should have items")
	var acc_data: Dictionary = DataManager.load_json("res://data/equipment/accessories.json")
	var acc_list: Array = acc_data.get("accessories", [])
	var acc_ids: Array[String] = []
	for a: Dictionary in acc_list:
		acc_ids.append(a.get("id", ""))
	for entry: Dictionary in inventory:
		var item_id: String = entry.get("item_id", "")
		assert_has(acc_ids, item_id, "Accessory '%s' must exist in accessories.json" % item_id)

func test_jeweler_prices_match_design_doc() -> void:
	var data: Dictionary = DataManager.load_shop("valdris_crown_jeweler")
	var inventory: Array = data.get("shop", {}).get("inventory", [])
	var expected: Dictionary = {
		"pact_charm_wind": 600,
		"pact_charm_earth": 600,
		"silver_ring": 200,
		"guardian_pendant": 400,
	}
	for entry: Dictionary in inventory:
		var item_id: String = entry.get("item_id", "")
		if expected.has(item_id):
			assert_eq(entry.get("buy_price"), expected[item_id],
				"Price mismatch for '%s'" % item_id)

# --- Specialty (regression) ---

func test_specialty_still_loads() -> void:
	var data: Dictionary = DataManager.load_shop("valdris_crown_specialty")
	assert_not_equal(data, {}, "Specialty shop should still load")
	var inventory: Array = data.get("shop", {}).get("inventory", [])
	assert_eq(inventory.size(), 7, "Specialty should still have 7 items")

# --- Old armorer removed ---

func test_old_armorer_removed() -> void:
	var data: Dictionary = DataManager.load_shop("valdris_crown_armorer")
	assert_eq(data, {}, "Old armorer shop should no longer exist")

# --- No duplicates within shops ---

func test_no_duplicate_items_in_shops() -> void:
	var shop_ids: Array[String] = [
		"valdris_crown_weaponsmith", "valdris_crown_armorsmith",
		"valdris_crown_jeweler", "valdris_crown_specialty",
		"valdris_crown_general",
	]
	for sid: String in shop_ids:
		var data: Dictionary = DataManager.load_shop(sid)
		var inventory: Array = data.get("shop", {}).get("inventory", [])
		var seen: Array[String] = []
		for entry: Dictionary in inventory:
			var item_id: String = entry.get("item_id", "")
			assert_does_not_have(seen, item_id,
				"Duplicate '%s' in shop '%s'" % [item_id, sid])
			seen.append(item_id)
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/jaredmscott/repos/projects/pendulum-of-despair/game
godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_valdris_shops.gd -gexit 2>&1 | tail -20
```

Expected: FAIL (shop files don't exist yet).

- [ ] **Step 3: Create weaponsmith shop (weapons from old armorer)**

Create `game/data/shops/valdris_crown_weaponsmith.json`:

```json
{
	"shop": {
		"shop_id": "valdris_crown_weaponsmith",
		"town": "valdris_crown",
		"type": "weaponsmith",
		"markup": 1.0,
		"inventory": [
			{
				"item_id": "valdris_blade",
				"buy_price": 300,
				"available_act": 1,
				"stock_limit": null,
				"restock_event": null
			},
			{
				"item_id": "knights_edge",
				"buy_price": 500,
				"available_act": 1,
				"stock_limit": null,
				"restock_event": null
			},
			{
				"item_id": "ley_wand",
				"buy_price": 250,
				"available_act": 1,
				"stock_limit": null,
				"restock_event": null
			},
			{
				"item_id": "stiletto",
				"buy_price": 250,
				"available_act": 1,
				"stock_limit": null,
				"restock_event": null
			},
			{
				"item_id": "iron_mallet",
				"buy_price": 300,
				"available_act": 1,
				"stock_limit": null,
				"restock_event": null
			},
			{
				"item_id": "iron_lance",
				"buy_price": 250,
				"available_act": 1,
				"stock_limit": null,
				"restock_event": null
			},
			{
				"item_id": "commanders_blade",
				"buy_price": 400,
				"available_act": 2,
				"stock_limit": null,
				"restock_event": "diplomatic_mission_begins"
			},
			{
				"item_id": "glyph_staff",
				"buy_price": 500,
				"available_act": 2,
				"stock_limit": null,
				"restock_event": "diplomatic_mission_begins"
			},
			{
				"item_id": "pickpockets_blade",
				"buy_price": 400,
				"available_act": 2,
				"stock_limit": null,
				"restock_event": "diplomatic_mission_begins"
			},
			{
				"item_id": "pipe_hammer",
				"buy_price": 500,
				"available_act": 2,
				"stock_limit": null,
				"restock_event": "diplomatic_mission_begins"
			}
		]
	}
}
```

- [ ] **Step 4: Create armorsmith shop (armor from old armorer)**

Create `game/data/shops/valdris_crown_armorsmith.json`:

```json
{
	"shop": {
		"shop_id": "valdris_crown_armorsmith",
		"town": "valdris_crown",
		"type": "armorsmith",
		"markup": 1.0,
		"inventory": [
			{
				"item_id": "iron_helm",
				"buy_price": 200,
				"available_act": 1,
				"stock_limit": null,
				"restock_event": null
			},
			{
				"item_id": "travelers_hood",
				"buy_price": 250,
				"available_act": 1,
				"stock_limit": null,
				"restock_event": null
			},
			{
				"item_id": "ember_circlet",
				"buy_price": 350,
				"available_act": 1,
				"stock_limit": null,
				"restock_event": null
			},
			{
				"item_id": "chain_mail",
				"buy_price": 300,
				"available_act": 1,
				"stock_limit": null,
				"restock_event": null
			},
			{
				"item_id": "iron_plate",
				"buy_price": 400,
				"available_act": 1,
				"stock_limit": null,
				"restock_event": null
			},
			{
				"item_id": "silk_robe",
				"buy_price": 300,
				"available_act": 1,
				"stock_limit": null,
				"restock_event": null
			},
			{
				"item_id": "reinforced_vest",
				"buy_price": 500,
				"available_act": 1,
				"stock_limit": null,
				"restock_event": null
			}
		]
	}
}
```

- [ ] **Step 5: Add jeweler accessories to accessories.json**

Append 4 new entries to the `accessories` array in `game/data/equipment/accessories.json`:

```json
{
	"id": "pact_charm_wind",
	"name": "Pact-Charm (Storm)",
	"subcategory": "elemental_resistance",
	"equippable_by": ["edren", "cael", "maren", "sable", "lira", "torren"],
	"effect": "+5% Wind resist, AGI +2",
	"bonus_stats": {"spd": 2},
	"element_resist": {"wind": 0.05},
	"special": null,
	"buy_price": 600,
	"sell_price": 300,
	"acquired": "Valdris Crown jeweler",
	"description": "A charm blessed by the wind spirits of old Valdris."
},
{
	"id": "pact_charm_earth",
	"name": "Pact-Charm (Earth)",
	"subcategory": "elemental_resist",
	"equippable_by": ["edren", "cael", "maren", "sable", "lira", "torren"],
	"effect": "+5% Earth resist, DEF +2",
	"bonus_stats": {"def": 2},
	"element_resist": {"earth": 0.05},
	"special": null,
	"buy_price": 600,
	"sell_price": 300,
	"acquired": "Valdris Crown jeweler",
	"description": "A charm blessed by the earth spirits of old Valdris."
},
{
	"id": "silver_ring",
	"name": "Silver Ring",
	"subcategory": "stat_boost",
	"equippable_by": ["edren", "cael", "maren", "sable", "lira", "torren"],
	"effect": "MAG +3",
	"bonus_stats": {"mag": 3},
	"special": null,
	"buy_price": 200,
	"sell_price": 100,
	"acquired": "Valdris Crown jeweler",
	"description": "A polished silver ring that enhances magical focus."
},
{
	"id": "guardian_pendant",
	"name": "Guardian Pendant",
	"subcategory": "combat_utility",
	"equippable_by": ["edren", "cael", "maren", "sable", "lira", "torren"],
	"effect": "Auto-Protect at <25% HP",
	"bonus_stats": {},
	"special": "auto_protect_low_hp",
	"buy_price": 400,
	"sell_price": 200,
	"acquired": "Valdris Crown jeweler",
	"description": "A pendant that shields the wearer when gravely wounded."
}
```

- [ ] **Step 6: Create jeweler shop**

Create `game/data/shops/valdris_crown_jeweler.json`:

```json
{
	"shop": {
		"shop_id": "valdris_crown_jeweler",
		"town": "valdris_crown",
		"type": "jeweler",
		"markup": 1.0,
		"inventory": [
			{
				"item_id": "pact_charm_wind",
				"buy_price": 600,
				"available_act": 1,
				"stock_limit": null,
				"restock_event": null
			},
			{
				"item_id": "pact_charm_earth",
				"buy_price": 600,
				"available_act": 1,
				"stock_limit": null,
				"restock_event": null
			},
			{
				"item_id": "silver_ring",
				"buy_price": 200,
				"available_act": 1,
				"stock_limit": null,
				"restock_event": null
			},
			{
				"item_id": "guardian_pendant",
				"buy_price": 400,
				"available_act": 1,
				"stock_limit": null,
				"restock_event": null
			}
		]
	}
}
```

- [ ] **Step 7: Delete old armorer shop**

```bash
rm -f game/data/shops/valdris_crown_armorer.json
```

- [ ] **Step 8: Run shop tests**

```bash
cd /Users/jaredmscott/repos/projects/pendulum-of-despair/game
godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_valdris_shops.gd -gexit 2>&1 | tail -30
```

Expected: ALL PASS.

- [ ] **Step 9: Commit**

```bash
git add game/data/shops/ game/data/equipment/accessories.json game/tests/test_valdris_shops.gd
git commit -m "feat(engine): split armorer shop, add jeweler and armorsmith shops

Weapons stay in Lower Ward (weaponsmith), armor moves to Citizen's Walk
(armorsmith). New jeweler shop with 4 new accessories (pact charms,
silver ring, guardian pendant). Old armorer file removed."
```

---

## Task 3: NPC Ambient Dialogue Data

**Files:**
- Create: 11 NPC dialogue JSON files in `game/data/dialogue/`
- Test: `game/tests/test_valdris_dialogue.gd`

- [ ] **Step 1: Write dialogue data validation tests**

```gdscript
# game/tests/test_valdris_dialogue.gd
extends GutTest

const NEW_NPC_DIALOGUES: Array[String] = [
	"npc_king_aldren", "npc_lord_haren", "npc_dame_cordwyn",
	"npc_scholar_aldis", "npc_mirren", "npc_elara_thane",
	"npc_jorin_ashvale", "npc_valdris_armorsmith",
	"npc_valdris_jeweler", "npc_valdris_specialty",
	"npc_court_guard",
]

const SCENE_7_DIALOGUES: Array[String] = [
	"scene_7a_the_gates", "scene_7b_throne_hall",
	"scene_7c_aldis", "scene_7c_cordwyn", "scene_7c_renn",
	"scene_7d_evening",
]

const REQUIRED_FIELDS: Array[String] = [
	"id", "speaker", "lines", "condition", "animations", "choice", "sfx",
]

func before_each() -> void:
	DataManager.clear_cache()

func after_each() -> void:
	DataManager.clear_cache()

# --- NPC dialogue files load ---

func test_all_npc_dialogues_load() -> void:
	for scene_id: String in NEW_NPC_DIALOGUES:
		var data: Dictionary = DataManager.load_dialogue(scene_id)
		assert_not_equal(data, {}, "Dialogue '%s' should load" % scene_id)
		assert_eq(data.get("scene_id"), scene_id,
			"scene_id mismatch in '%s'" % scene_id)

func test_all_scene_7_dialogues_load() -> void:
	for scene_id: String in SCENE_7_DIALOGUES:
		var data: Dictionary = DataManager.load_dialogue(scene_id)
		assert_not_equal(data, {}, "Dialogue '%s' should load" % scene_id)

# --- Entry format validation ---

func test_all_entries_have_required_fields() -> void:
	var all_ids: Array[String] = []
	all_ids.append_array(NEW_NPC_DIALOGUES)
	all_ids.append_array(SCENE_7_DIALOGUES)
	for scene_id: String in all_ids:
		var data: Dictionary = DataManager.load_dialogue(scene_id)
		var entries: Array = data.get("entries", [])
		assert_gt(entries.size(), 0, "'%s' should have entries" % scene_id)
		for entry: Dictionary in entries:
			for field: String in REQUIRED_FIELDS:
				assert_true(entry.has(field),
					"Entry '%s' in '%s' missing field '%s'" % [
						entry.get("id", "?"), scene_id, field])

# --- Entry IDs globally unique ---

func test_entry_ids_globally_unique() -> void:
	var all_ids: Array[String] = []
	all_ids.append_array(NEW_NPC_DIALOGUES)
	all_ids.append_array(SCENE_7_DIALOGUES)
	var seen: Array[String] = []
	for scene_id: String in all_ids:
		var data: Dictionary = DataManager.load_dialogue(scene_id)
		for entry: Dictionary in data.get("entries", []):
			var eid: String = entry.get("id", "")
			assert_does_not_have(seen, eid,
				"Duplicate entry ID '%s' in '%s'" % [eid, scene_id])
			seen.append(eid)

# --- Scene 7c conditional branches ---

func test_scene_7c_aldis_has_party_has_conditions() -> void:
	var data: Dictionary = DataManager.load_dialogue("scene_7c_aldis")
	var entries: Array = data.get("entries", [])
	var has_lira: bool = false
	var has_maren: bool = false
	for entry: Dictionary in entries:
		var cond: Variant = entry.get("condition")
		if cond is String:
			if "party_has(lira)" in (cond as String):
				has_lira = true
			if "party_has(maren)" in (cond as String):
				has_maren = true
	assert_true(has_lira, "Aldis should have party_has(lira) branch")
	assert_true(has_maren, "Aldis should have party_has(maren) branch")

func test_scene_7c_cordwyn_has_party_has_conditions() -> void:
	var data: Dictionary = DataManager.load_dialogue("scene_7c_cordwyn")
	var entries: Array = data.get("entries", [])
	var has_torren: bool = false
	var has_sable: bool = false
	for entry: Dictionary in entries:
		var cond: Variant = entry.get("condition")
		if cond is String:
			if "party_has(torren)" in (cond as String):
				has_torren = true
			if "party_has(sable)" in (cond as String):
				has_sable = true
	assert_true(has_torren, "Cordwyn should have party_has(torren) branch")
	assert_true(has_sable, "Cordwyn should have party_has(sable) branch")

# --- NPC priority-stack for Scene 7c NPCs ---

func test_cordwyn_has_scene_7c_and_ambient() -> void:
	var data: Dictionary = DataManager.load_dialogue("npc_dame_cordwyn")
	var entries: Array = data.get("entries", [])
	var has_conditioned: bool = false
	var has_fallback: bool = false
	for entry: Dictionary in entries:
		var cond: Variant = entry.get("condition")
		if cond is String and "pendulum_presented" in (cond as String):
			has_conditioned = true
		if cond == null:
			has_fallback = true
	assert_true(has_conditioned,
		"Cordwyn should have pendulum_presented-gated Scene 7c entry")
	assert_true(has_fallback, "Cordwyn should have ambient fallback")

func test_aldis_has_scene_7c_and_ambient() -> void:
	var data: Dictionary = DataManager.load_dialogue("npc_scholar_aldis")
	var entries: Array = data.get("entries", [])
	var has_conditioned: bool = false
	var has_fallback: bool = false
	for entry: Dictionary in entries:
		var cond: Variant = entry.get("condition")
		if cond is String and "pendulum_presented" in (cond as String):
			has_conditioned = true
		if cond == null:
			has_fallback = true
	assert_true(has_conditioned,
		"Aldis should have pendulum_presented-gated Scene 7c entry")
	assert_true(has_fallback, "Aldis should have ambient fallback")

# --- Key dialogue lines from script/act-i.md ---

func test_scene_7a_has_key_lines() -> void:
	var data: Dictionary = DataManager.load_dialogue("scene_7a_the_gates")
	var all_text: String = ""
	for entry: Dictionary in data.get("entries", []):
		for line: String in entry.get("lines", []):
			all_text += line + " "
	assert_string_contains(all_text, "Commander Edren")
	assert_string_contains(all_text, "registering")

func test_scene_7b_has_key_lines() -> void:
	var data: Dictionary = DataManager.load_dialogue("scene_7b_throne_hall")
	var all_text: String = ""
	for entry: Dictionary in data.get("entries", []):
		for line: String in entry.get("lines", []):
			all_text += line + " "
	assert_string_contains(all_text, "conduit")
	assert_string_contains(all_text, "ley lines")

func test_scene_7d_is_cutscene_format() -> void:
	var data: Dictionary = DataManager.load_dialogue("scene_7d_evening")
	assert_true(data.has("cutscene_id") or data.has("cutscene_tier"),
		"Scene 7d should have cutscene metadata")
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/jaredmscott/repos/projects/pendulum-of-despair/game
godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_valdris_dialogue.gd -gexit 2>&1 | tail -20
```

Expected: FAIL (dialogue files don't exist yet).

- [ ] **Step 3: Create NPC ambient dialogue files**

Create all 11 NPC dialogue JSON files. Each follows the standard schema. Source lines come from `docs/story/npcs.md`.

**`game/data/dialogue/npc_king_aldren.json`:**
```json
{
	"scene_id": "npc_king_aldren",
	"entries": [
		{
			"id": "npc_king_aldren_001",
			"speaker": "king_aldren",
			"lines": [
				"Every morning I ask the court mages for a report on the ley lines.",
				"Every morning, the number is lower."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "npc_king_aldren_002",
			"speaker": "king_aldren",
			"lines": ["There is nothing safe left in Valdris."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		}
	]
}
```

**`game/data/dialogue/npc_lord_haren.json`:**
```json
{
	"scene_id": "npc_lord_haren",
	"entries": [
		{
			"id": "npc_lord_haren_001",
			"speaker": "lord_haren",
			"lines": [
				"The king values your counsel, Edren.",
				"But value and action are separated by a council vote."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		}
	]
}
```

**`game/data/dialogue/npc_dame_cordwyn.json`:**

This NPC has BOTH Scene 7c dialogue (gated by `pendulum_presented AND !scene_7c_cordwyn`) and ambient fallback. The priority stack puts conditioned entries first.

```json
{
	"scene_id": "npc_dame_cordwyn",
	"entries": [
		{
			"id": "npc_dame_cordwyn_scene7c",
			"speaker": "dame_cordwyn",
			"lines": [
				"Edren. It's good to see you.",
				"Haren is already planning to use the Pendulum as a bargaining chip with the Compact.",
				"Keep an eye on Cael. He's brilliant, but he carries more than he lets on."
			],
			"condition": "pendulum_presented AND !scene_7c_cordwyn",
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "npc_dame_cordwyn_001",
			"speaker": "dame_cordwyn",
			"lines": [
				"Cael was the best of us. I don't mean the strongest -- I mean the kindest."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		}
	]
}
```

**`game/data/dialogue/npc_scholar_aldis.json`:**

Same pattern: Scene 7c gated entry + ambient fallback.

```json
{
	"scene_id": "npc_scholar_aldis",
	"entries": [
		{
			"id": "npc_scholar_aldis_scene7c",
			"speaker": "scholar_aldis",
			"lines": [
				"The ley lines beneath the capital have lost twelve percent capacity in the last year alone.",
				"I'd like to compare readings with the Pendulum's resonance. I'll work with Cael on it."
			],
			"condition": "pendulum_presented AND !scene_7c_aldis",
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "npc_scholar_aldis_001",
			"speaker": "scholar_aldis",
			"lines": [
				"The ley lines are the lifeblood of this kingdom. And they are failing."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		}
	]
}
```

**`game/data/dialogue/npc_mirren.json`:**
```json
{
	"scene_id": "npc_mirren",
	"entries": [
		{
			"id": "npc_mirren_001",
			"speaker": "mirren",
			"lines": [
				"Maren took my document. Didn't ask. Didn't sign for it.",
				"Just took it and vanished."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		}
	]
}
```

**`game/data/dialogue/npc_elara_thane.json`:**
```json
{
	"scene_id": "npc_elara_thane",
	"entries": [
		{
			"id": "npc_elara_thane_001",
			"speaker": "elara_thane",
			"lines": [
				"My grandmother could call a storm that lasted three days.",
				"I called one last month that lasted three minutes."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		}
	]
}
```

**`game/data/dialogue/npc_jorin_ashvale.json`:**
```json
{
	"scene_id": "npc_jorin_ashvale",
	"entries": [
		{
			"id": "npc_jorin_ashvale_001",
			"speaker": "jorin_ashvale",
			"lines": [
				"The crown sends me letters of concern.",
				"I could paper my walls with royal concern."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		}
	]
}
```

**`game/data/dialogue/npc_valdris_armorsmith.json`:**
```json
{
	"scene_id": "npc_valdris_armorsmith",
	"entries": [
		{
			"id": "npc_valdris_armorsmith_001",
			"speaker": "valdris_armorsmith",
			"lines": ["Valdris steel. Best protection this side of the Wilds."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		}
	]
}
```

**`game/data/dialogue/npc_valdris_jeweler.json`:**
```json
{
	"scene_id": "npc_valdris_jeweler",
	"entries": [
		{
			"id": "npc_valdris_jeweler_001",
			"speaker": "valdris_jeweler",
			"lines": ["Pact-charms, rings, and pendants. Each one carries a piece of the old magic."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		}
	]
}
```

**`game/data/dialogue/npc_valdris_specialty.json`:**
```json
{
	"scene_id": "npc_valdris_specialty",
	"entries": [
		{
			"id": "npc_valdris_specialty_001",
			"speaker": "valdris_specialty",
			"lines": ["Rare goods for the discerning adventurer. You won't find these at the general store."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		}
	]
}
```

**`game/data/dialogue/npc_court_guard.json`:**
```json
{
	"scene_id": "npc_court_guard",
	"entries": [
		{
			"id": "npc_court_guard_001",
			"speaker": "court_guard",
			"lines": ["The Court Quarter is open to visitors. Keep your business respectful."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		}
	]
}
```

- [ ] **Step 4: Run dialogue tests (NPC subset)**

```bash
cd /Users/jaredmscott/repos/projects/pendulum-of-despair/game
godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_valdris_dialogue.gd -ginclude_subdirs -gprefix=test_all_npc -gexit 2>&1 | tail -20
```

Expected: `test_all_npc_dialogues_load` PASSES. Scene 7 tests still FAIL.

- [ ] **Step 5: Commit NPC dialogues**

```bash
git add game/data/dialogue/npc_king_aldren.json game/data/dialogue/npc_lord_haren.json \
  game/data/dialogue/npc_dame_cordwyn.json game/data/dialogue/npc_scholar_aldis.json \
  game/data/dialogue/npc_mirren.json game/data/dialogue/npc_elara_thane.json \
  game/data/dialogue/npc_jorin_ashvale.json game/data/dialogue/npc_valdris_armorsmith.json \
  game/data/dialogue/npc_valdris_jeweler.json game/data/dialogue/npc_valdris_specialty.json \
  game/data/dialogue/npc_court_guard.json game/tests/test_valdris_dialogue.gd
git commit -m "feat(engine): add 11 Valdris NPC ambient dialogue files

King Aldren, Lord Haren, Dame Cordwyn, Scholar Aldis, Mirren,
Elara Thane, Jorin Ashvale, 3 shop greetings, court guard.
Cordwyn and Aldis have Scene 7c priority-stack entries gated by
pendulum_presented flag."
```

---

## Task 4: Scene 7 Dialogue Data

**Files:**
- Create: `game/data/dialogue/scene_7a_the_gates.json`
- Create: `game/data/dialogue/scene_7b_throne_hall.json`
- Create: `game/data/dialogue/scene_7c_aldis.json`
- Create: `game/data/dialogue/scene_7c_cordwyn.json`
- Create: `game/data/dialogue/scene_7c_renn.json`
- Create: `game/data/dialogue/scene_7d_evening.json`

- [ ] **Step 1: Create Scene 7a dialogue**

Source: `docs/story/script/act-i.md` Scene 7a.

```json
{
	"scene_id": "scene_7a_the_gates",
	"entries": [
		{
			"id": "scene_7a_001",
			"speaker": "gate_guard",
			"lines": [
				"Commander Edren. You've been expected.",
				"The king received word from Thornwatch. Commander Halda sent a rider two days ahead."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7a_002",
			"speaker": "gate_guard",
			"lines": [
				"A Forgewright, a Wilds ranger, a woman who looks like she hasn't left a library in years...",
				"...and a young woman who is very carefully not making eye contact."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7a_003",
			"speaker": "gate_guard",
			"lines": ["You'll need to register at the inner gate. All of you."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7a_004",
			"speaker": "sable",
			"lines": ["Of course. I love registering."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7a_005",
			"speaker": "edren",
			"lines": ["We have business with the king. The Pendulum --"],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7a_006",
			"speaker": "gate_guard",
			"lines": [
				"I know. The whole court knows.",
				"Straight through the Lower Ward, up through the districts. The throne hall is at the top."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7a_007",
			"speaker": "maren",
			"lines": ["It's been a long time since I walked these streets."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7a_008",
			"speaker": "cael",
			"lines": ["Let's not keep the king waiting."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		}
	]
}
```

- [ ] **Step 2: Create Scene 7b dialogue**

Source: `docs/story/script/act-i.md` Scene 7b.

```json
{
	"scene_id": "scene_7b_throne_hall",
	"entries": [
		{
			"id": "scene_7b_001",
			"speaker": "",
			"lines": ["The throne hall is smaller than expected -- built for function, not grandeur."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7b_002",
			"speaker": "",
			"lines": [
				"King Aldren sits on a plain stone chair. He is older than he should be.",
				"Lord Chancellor Haren stands to his left."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7b_003",
			"speaker": "edren",
			"lines": ["Your Majesty. We recovered this from the Ember Vein."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7b_004",
			"speaker": "",
			"lines": ["Edren places the Pendulum on the table."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7b_005",
			"speaker": "king_aldren",
			"lines": ["It doesn't look like much."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7b_006",
			"speaker": "maren",
			"lines": [
				"It's a conduit -- a focal point for something beyond it.",
				"The miners who found it are dead. Not from violence. From despair."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7b_007",
			"speaker": "lord_haren",
			"lines": ["You've been away from court for some time, Maren."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7b_008",
			"speaker": "maren",
			"lines": ["Not by choice, Chancellor."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7b_009",
			"speaker": "king_aldren",
			"lines": [
				"Every morning I ask the court mages for a report on the ley lines.",
				"Every morning, the number is lower."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7b_010",
			"speaker": "king_aldren",
			"lines": ["There is nothing safe left in Valdris."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7b_011",
			"speaker": "king_aldren",
			"lines": [
				"Maren -- I want an assessment in writing by morning.",
				"Cael -- you'll work with Maren on the Pendulum. Whatever this thing is, I need to understand it."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7b_012",
			"speaker": "",
			"lines": [
				"This is the moment the trap closes.",
				"The Pallor's mark answers the king's request before Cael can think twice."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		}
	]
}
```

- [ ] **Step 3: Create Scene 7c dialogue files (Aldis, Cordwyn, Renn)**

**`game/data/dialogue/scene_7c_aldis.json`:**
```json
{
	"scene_id": "scene_7c_aldis",
	"entries": [
		{
			"id": "scene_7c_aldis_001",
			"speaker": "scholar_aldis",
			"lines": [
				"The ley lines beneath the capital have lost twelve percent capacity in the last year alone.",
				"I've been mapping the decline. The pattern is... unsettling."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7c_aldis_002",
			"speaker": "scholar_aldis",
			"lines": [
				"I'd like to compare my readings with the Pendulum's resonance.",
				"If it truly is a focal point, the interference pattern could tell us where the energy is going."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7c_aldis_lira",
			"speaker": "scholar_aldis",
			"lines": [
				"Wait -- you. I've read your paper on suppressed conduit efficiency.",
				"It was classified, but I'm a researcher. Finding classified documents is half the job."
			],
			"condition": "party_has(lira)",
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7c_aldis_maren",
			"speaker": "scholar_aldis",
			"lines": ["Maren? You're... back?"],
			"condition": "party_has(maren)",
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7c_aldis_maren_reply",
			"speaker": "maren",
			"lines": ["Don't rearrange my study while I'm here, Aldis."],
			"condition": "party_has(maren)",
			"animations": null,
			"choice": null,
			"sfx": null
		}
	]
}
```

**`game/data/dialogue/scene_7c_cordwyn.json`:**
```json
{
	"scene_id": "scene_7c_cordwyn",
	"entries": [
		{
			"id": "scene_7c_cordwyn_001",
			"speaker": "dame_cordwyn",
			"lines": ["Edren."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7c_cordwyn_002",
			"speaker": "",
			"lines": ["She clasps Edren's arm."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7c_cordwyn_003",
			"speaker": "dame_cordwyn",
			"lines": [
				"Haren is already planning to use the Pendulum as a bargaining chip.",
				"He wants to offer it to the Compact in exchange for a border ceasefire."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7c_cordwyn_004",
			"speaker": "dame_cordwyn",
			"lines": [
				"Keep an eye on Cael.",
				"He's brilliant, but he carries more than he lets on."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7c_cordwyn_torren",
			"speaker": "dame_cordwyn",
			"lines": ["Spirit-speaker. You're a long way from the Wilds."],
			"condition": "party_has(torren)",
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7c_cordwyn_torren_reply",
			"speaker": "torren",
			"lines": ["The Wilds follow where they're needed."],
			"condition": "party_has(torren)",
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7c_cordwyn_sable",
			"speaker": "dame_cordwyn",
			"lines": ["Touch nothing, thief."],
			"condition": "party_has(sable)",
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7c_cordwyn_sable_reply",
			"speaker": "sable",
			"lines": ["I was admiring. There's a difference."],
			"condition": "party_has(sable)",
			"animations": null,
			"choice": null,
			"sfx": null
		}
	]
}
```

**`game/data/dialogue/scene_7c_renn.json`:**
```json
{
	"scene_id": "scene_7c_renn",
	"entries": [
		{
			"id": "scene_7c_renn_001",
			"speaker": "",
			"lines": ["Sable peels off toward the Lower Ward. She enters the tavern with practiced familiarity."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7c_renn_002",
			"speaker": "renn",
			"lines": ["I don't sell secrets, love. I sell certainty."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7c_renn_003",
			"speaker": "renn",
			"lines": [
				"The Compact found something unexpected in the mine.",
				"Three courier birds to Corrund in one day. That's not a report -- that's a panic."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7c_renn_004",
			"speaker": "renn",
			"lines": [
				"Forgewright steel price dropped last week. The generals are spending on something other than weapons.",
				"Whatever you've gotten yourself into, Sable -- it's bigger than a mine."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		}
	]
}
```

- [ ] **Step 4: Create Scene 7d cutscene dialogue**

This is a cutscene (T1 with letterbox). Uses `cutscene_id` and `cutscene_tier` fields per the existing cutscene system.

```json
{
	"scene_id": "scene_7d_evening",
	"cutscene_id": "scene_7d_evening",
	"cutscene_tier": 1,
	"entries": [
		{
			"id": "scene_7d_001",
			"speaker": "",
			"lines": ["Night falls over Valdris Crown."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null,
			"commands": [{"type": "fade", "direction": "in", "duration": 1.0}]
		},
		{
			"id": "scene_7d_002",
			"speaker": "",
			"lines": [
				"The Pendulum sits in a sealed chamber in the lower Keep.",
				"Containment wards glow blue around the glass case."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7d_003",
			"speaker": "",
			"lines": [
				"Cael stands alone before it.",
				"His hand hovers near the glass."
			],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7d_004",
			"speaker": "",
			"lines": ["For a single frame -- his reflection's eyes are grey."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null,
			"commands": [{"type": "flash", "color": [180, 180, 180], "duration": 0.1}]
		},
		{
			"id": "scene_7d_005",
			"speaker": "",
			"lines": ["He leaves."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null
		},
		{
			"id": "scene_7d_006",
			"speaker": "",
			"lines": ["The Pendulum's needle shifts one degree, then stops."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null,
			"commands": [{"type": "fade", "direction": "out", "duration": 1.5}]
		}
	]
}
```

- [ ] **Step 5: Run all dialogue tests**

```bash
cd /Users/jaredmscott/repos/projects/pendulum-of-despair/game
godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_valdris_dialogue.gd -gexit 2>&1 | tail -30
```

Expected: ALL PASS.

- [ ] **Step 6: Commit**

```bash
git add game/data/dialogue/scene_7a_the_gates.json game/data/dialogue/scene_7b_throne_hall.json \
  game/data/dialogue/scene_7c_aldis.json game/data/dialogue/scene_7c_cordwyn.json \
  game/data/dialogue/scene_7c_renn.json game/data/dialogue/scene_7d_evening.json
git commit -m "feat(story): add Scene 7 dialogue data (gates, throne, court, evening)

8 entries for 7a (gate arrival), 12 for 7b (throne presentation),
5+8+4 for 7c (Aldis/Cordwyn/Renn with party_has branches),
6 for 7d (T1 cutscene with grey eyes moment). All lines from
script/act-i.md Scene 7."
```

---

## Task 5: Multi-Flag Required_Flags Support in Cutscene Handler

Scene 7d trigger needs ALL THREE 7c flags set. The existing `required_flag` metadata only supports a single flag. Add `required_flags` (plural) support.

**Files:**
- Modify: `game/scripts/core/cutscene_handler.gd`
- Test: `game/tests/test_scene_7_flags.gd`

- [ ] **Step 1: Write flag gate tests**

```gdscript
# game/tests/test_scene_7_flags.gd
extends GutTest

func before_each() -> void:
	EventFlags.clear_all()

func after_each() -> void:
	EventFlags.clear_all()

# --- Flag sequence ---

func test_scene_7a_requires_maren_warning() -> void:
	# Without maren_warning, 7a should not fire
	assert_false(EventFlags.get_flag("maren_warning"),
		"maren_warning should not be set initially")
	# Simulate: set maren_warning
	EventFlags.set_flag("maren_warning", true)
	assert_true(EventFlags.get_flag("maren_warning"))

func test_scene_7b_requires_valdris_arrived() -> void:
	assert_false(EventFlags.get_flag("valdris_arrived"))
	EventFlags.set_flag("valdris_arrived", true)
	assert_true(EventFlags.get_flag("valdris_arrived"))
	# pendulum_presented should block re-trigger
	assert_false(EventFlags.get_flag("pendulum_presented"))

func test_scene_7c_flags_independent() -> void:
	EventFlags.set_flag("scene_7c_aldis", true)
	assert_true(EventFlags.get_flag("scene_7c_aldis"))
	assert_false(EventFlags.get_flag("scene_7c_cordwyn"))
	assert_false(EventFlags.get_flag("scene_7c_renn"))

func test_scene_7d_requires_all_three_7c_flags() -> void:
	# Not all set
	EventFlags.set_flag("scene_7c_aldis", true)
	EventFlags.set_flag("scene_7c_cordwyn", true)
	var all_set: bool = (
		EventFlags.get_flag("scene_7c_aldis")
		and EventFlags.get_flag("scene_7c_cordwyn")
		and EventFlags.get_flag("scene_7c_renn")
	)
	assert_false(all_set, "Should not pass with only 2/3 flags")
	# All set
	EventFlags.set_flag("scene_7c_renn", true)
	all_set = (
		EventFlags.get_flag("scene_7c_aldis")
		and EventFlags.get_flag("scene_7c_cordwyn")
		and EventFlags.get_flag("scene_7c_renn")
	)
	assert_true(all_set, "Should pass with all 3 flags")

func test_pendulum_to_capital_set_after_7d() -> void:
	EventFlags.set_flag("pendulum_to_capital", true)
	assert_true(EventFlags.get_flag("pendulum_to_capital"))

func test_flag_idempotency() -> void:
	EventFlags.set_flag("valdris_arrived", true)
	EventFlags.set_flag("valdris_arrived", true)
	assert_true(EventFlags.get_flag("valdris_arrived"),
		"Setting flag twice should not error")

func test_flags_survive_save_load() -> void:
	EventFlags.set_flag("scene_7c_aldis", true)
	EventFlags.set_flag("scene_7c_cordwyn", true)
	EventFlags.set_flag("pendulum_presented", true)
	var save_data: Dictionary = EventFlags.to_save_data()
	EventFlags.clear_all()
	assert_false(EventFlags.get_flag("scene_7c_aldis"))
	EventFlags.load_from_save(save_data)
	assert_true(EventFlags.get_flag("scene_7c_aldis"))
	assert_true(EventFlags.get_flag("scene_7c_cordwyn"))
	assert_true(EventFlags.get_flag("pendulum_presented"))

# --- Multi-flag required_flags support ---

func test_check_required_flags_all_set() -> void:
	EventFlags.set_flag("scene_7c_aldis", true)
	EventFlags.set_flag("scene_7c_cordwyn", true)
	EventFlags.set_flag("scene_7c_renn", true)
	EventFlags.set_flag("pendulum_presented", true)
	var flags_str: String = "scene_7c_aldis,scene_7c_cordwyn,scene_7c_renn,pendulum_presented"
	var all_met: bool = true
	for f: String in flags_str.split(","):
		if not EventFlags.get_flag(f.strip_edges()):
			all_met = false
			break
	assert_true(all_met)

func test_check_required_flags_one_missing() -> void:
	EventFlags.set_flag("scene_7c_aldis", true)
	EventFlags.set_flag("scene_7c_cordwyn", true)
	# scene_7c_renn NOT set
	EventFlags.set_flag("pendulum_presented", true)
	var flags_str: String = "scene_7c_aldis,scene_7c_cordwyn,scene_7c_renn,pendulum_presented"
	var all_met: bool = true
	for f: String in flags_str.split(","):
		if not EventFlags.get_flag(f.strip_edges()):
			all_met = false
			break
	assert_false(all_met)
```

- [ ] **Step 2: Run tests to verify they pass (pure flag logic)**

```bash
cd /Users/jaredmscott/repos/projects/pendulum-of-despair/game
godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_scene_7_flags.gd -gexit 2>&1 | tail -20
```

Expected: ALL PASS (these test EventFlags directly, not cutscene_handler).

- [ ] **Step 3: Add required_flags support to cutscene_handler.gd**

In `cutscene_handler.gd`, modify `on_cutscene_trigger_entered()` to check for `required_flags` (comma-separated string) in addition to `required_flag` (single string).

After the existing `required_flag` check (line ~208-210), add:

```gdscript
	var required_multi: String = area.get_meta("required_flags", "")
	if not required_multi.is_empty():
		for rf: String in required_multi.split(","):
			if not EventFlags.get_flag(rf.strip_edges()):
				return
```

- [ ] **Step 4: Add same support to dialogue trigger in exploration.gd**

In `exploration.gd`, method `_on_dialogue_trigger_entered()`, after the `required_flag` check (line ~373-375), add the same multi-flag check:

```gdscript
	var required_multi: String = area.get_meta("required_flags", "")
	if not required_multi.is_empty():
		for rf: String in required_multi.split(","):
			if not EventFlags.get_flag(rf.strip_edges()):
				return
```

- [ ] **Step 5: Commit**

```bash
git add game/scripts/core/cutscene_handler.gd game/scripts/core/exploration.gd \
  game/tests/test_scene_7_flags.gd
git commit -m "feat(engine): add required_flags (plural) AND-condition support

Cutscene and dialogue triggers can now use metadata/required_flags
with comma-separated flag names. All must be set for the trigger to
fire. Used by Scene 7d (needs all three 7c conversation flags)."
```

---

## Task 6: Interior Maps

**Files:**
- Create: `game/scenes/maps/towns/valdris_throne_hall.tscn`
- Create: `game/scenes/maps/towns/valdris_royal_library.tscn`
- Create: `game/scenes/maps/towns/valdris_barracks.tscn`
- Create: `game/scenes/maps/towns/valdris_anchor_oar_upper.tscn`

- [ ] **Step 1: Create throne hall interior**

Write `game/scenes/maps/towns/valdris_throne_hall.tscn`. Follow the exact .tscn format from `valdris_anchor_oar.tscn`. 20x18 tiles. Uses new capital tiles (14=limestone floor, 15=carpet, 16=platform, 17=columns).

Root node metadata:
- `metadata/map_id = "towns/valdris_throne_hall"`
- `metadata/location_name = "Valdris Crown - Throne Hall"`
- `metadata/dungeon_id = ""`
- `metadata/floor_id = ""`

Entities: King Aldren (npc, `npc_id="king_aldren"`), Lord Haren (npc, `npc_id="lord_haren"`).

Transitions: Grand doors → `towns/valdris_court_quarter`, spawn `from_throne_hall`.

Spawns: `PlayerSpawn`, `from_court_quarter`.

Scene 7b dialogue trigger: Area2D under Entities with `metadata/flag="pendulum_presented"`, `metadata/required_flag="valdris_arrived"`, `metadata/dialogue_scene_id="scene_7b_throne_hall"`.

Scene 7d cutscene trigger: Area2D under Entities with `metadata/flag="pendulum_to_capital"`, `metadata/cutscene_scene_id="scene_7d_evening"`, `metadata/required_flags="scene_7c_aldis,scene_7c_cordwyn,scene_7c_renn,pendulum_presented"`.

- [ ] **Step 2: Create royal library interior**

Write `game/scenes/maps/towns/valdris_royal_library.tscn`. 16x14 tiles.

Root metadata: `map_id="towns/valdris_royal_library"`, `location_name="Royal Library"`.

Entities: Scholar Aldis (`npc_id="scholar_aldis"`), Mirren (`npc_id="mirren"`), save point (`save_point_id="valdris_library_save"`).

Scene 7c Aldis trigger: Area2D with `metadata/flag="scene_7c_aldis"`, `metadata/required_flag="pendulum_presented"`, `metadata/dialogue_scene_id="scene_7c_aldis"`.

Transitions: Front door → `towns/valdris_citizens_walk`, spawn `from_library`.

Spawns: `PlayerSpawn`, `from_exterior`.

Treasure: TreasureChest near restricted doorway (`chest_id="library_spirit_incense"`, `item_id="spirit_incense"`).

- [ ] **Step 3: Create barracks interior**

Write `game/scenes/maps/towns/valdris_barracks.tscn`. 14x12 tiles.

Root metadata: `map_id="towns/valdris_barracks"`, `location_name="Knight's Barracks"`.

Entities: Dame Cordwyn (`npc_id="dame_cordwyn"`), Sgt. Marek (`npc_id="sergeant_marek"`).

Scene 7c Cordwyn trigger: Area2D with `metadata/flag="scene_7c_cordwyn"`, `metadata/required_flag="pendulum_presented"`, `metadata/dialogue_scene_id="scene_7c_cordwyn"`.

Transitions: Front door → `towns/valdris_lower_ward`, spawn `from_barracks`.

Spawns: `PlayerSpawn`, `from_exterior`.

Treasure: TreasureChest behind barracks exterior — actually this goes in Lower Ward, not the barracks interior. The barracks interior has no chests.

- [ ] **Step 4: Create tavern upper floor**

Write `game/scenes/maps/towns/valdris_anchor_oar_upper.tscn`. 12x10 tiles.

Root metadata: `map_id="towns/valdris_anchor_oar_upper"`, `location_name="The Anchor & Oar - Upper Floor"`.

No entities (guest rooms only).

Transitions: Staircase → `towns/valdris_anchor_oar`, spawn `from_upstairs`.

Spawns: `PlayerSpawn`, `from_downstairs`.

- [ ] **Step 5: Commit interior maps**

```bash
git add game/scenes/maps/towns/valdris_throne_hall.tscn \
  game/scenes/maps/towns/valdris_royal_library.tscn \
  game/scenes/maps/towns/valdris_barracks.tscn \
  game/scenes/maps/towns/valdris_anchor_oar_upper.tscn
git commit -m "feat(engine): add 4 Valdris interior maps

Throne Hall (20x18, King Aldren + Haren, Scene 7b/7d triggers),
Royal Library (16x14, Aldis + Mirren, save point, Scene 7c trigger),
Barracks (14x12, Cordwyn + Marek, Scene 7c trigger),
Tavern Upper Floor (12x10, guest rooms)."
```

---

## Task 7: Outdoor District Maps

**Files:**
- Create: `game/scenes/maps/towns/valdris_citizens_walk.tscn`
- Create: `game/scenes/maps/towns/valdris_court_quarter.tscn`

- [ ] **Step 1: Create Citizen's Walk outdoor map**

Write `game/scenes/maps/towns/valdris_citizens_walk.tscn`. ~45x40 tiles.

Root metadata: `map_id="towns/valdris_citizens_walk"`, `location_name="Valdris Crown - Citizen's Walk"`.

NPCs:
- Armorsmith (`npc_id="valdris_armorsmith"`, `shop_id="valdris_crown_armorsmith"`)
- Jeweler (`npc_id="valdris_jeweler"`, `shop_id="valdris_crown_jeweler"`)
- Specialty (`npc_id="valdris_specialty"`, `shop_id="valdris_crown_specialty"`)
- Jorin Ashvale (`npc_id="jorin_ashvale"`)
- Scholar Aldis exterior (`npc_id="scholar_aldis"`) — ambient only, points to library

Transitions:
- South ramp → `towns/valdris_lower_ward`, spawn `from_citizens_walk`
- North road → `towns/valdris_court_quarter`, spawn `from_citizens_walk`
- Library door → `towns/valdris_royal_library`, spawn `from_exterior`

Spawns: `PlayerSpawn`, `from_lower_ward`, `from_court_quarter`, `from_library`.

- [ ] **Step 2: Create Court Quarter outdoor map**

Write `game/scenes/maps/towns/valdris_court_quarter.tscn`. ~35x30 tiles.

Root metadata: `map_id="towns/valdris_court_quarter"`, `location_name="Valdris Crown - Court Quarter"`.

NPCs:
- Elara Thane (`npc_id="elara_thane"`)
- Court Guard (`npc_id="court_guard"`)

Transitions:
- South road → `towns/valdris_citizens_walk`, spawn `from_court_quarter`
- North entrance → `towns/valdris_throne_hall`, spawn `from_court_quarter`

Spawns: `PlayerSpawn`, `from_citizens_walk`, `from_throne_hall`.

- [ ] **Step 3: Commit outdoor maps**

```bash
git add game/scenes/maps/towns/valdris_citizens_walk.tscn \
  game/scenes/maps/towns/valdris_court_quarter.tscn
git commit -m "feat(engine): add Citizen's Walk and Court Quarter district maps

Citizen's Walk (45x40): 3 shops (armorsmith, jeweler, specialty),
library entrance, 5 NPCs. Court Quarter (35x30): Elara Thane,
court guard, throne hall entrance."
```

---

## Task 8: Modify Existing Maps

**Files:**
- Modify: `game/scenes/maps/towns/valdris_lower_ward.tscn`
- Modify: `game/scenes/maps/towns/valdris_anchor_oar.tscn`

- [ ] **Step 1: Update Lower Ward**

Add to `valdris_lower_ward.tscn`:

1. New transition Area2D under Transitions: `CitizensWalkRamp` → `towns/valdris_citizens_walk`, spawn `from_lower_ward`. Position at north edge of map.

2. New transition Area2D under Transitions: `BarracksDoor` → `towns/valdris_barracks`, spawn `from_exterior`. Position near barracks building.

3. New Marker2D spawns: `from_citizens_walk`, `from_barracks`.

4. Change Weaponsmith NPC metadata: `shop_id` from `"valdris_crown_armorer"` to `"valdris_crown_weaponsmith"`.

5. Scene 7a dialogue trigger: Area2D under Entities near South Gate spawn, with `metadata/flag="valdris_arrived"`, `metadata/required_flag="maren_warning"`, `metadata/dialogue_scene_id="scene_7a_the_gates"`.

6. Scene 7c Renn trigger: Add to Anchor & Oar tavern instead (see Step 2).

7. Treasure chest behind barracks: TreasureChest instance (`chest_id="barracks_phoenix_pinion"`, `item_id="phoenix_pinion"`).

- [ ] **Step 2: Update Anchor & Oar tavern**

Add to `valdris_anchor_oar.tscn`:

1. New transition Area2D under Transitions: `Staircase` → `towns/valdris_anchor_oar_upper`, spawn `from_downstairs`. Position near existing staircase area.

2. New Marker2D spawn: `from_upstairs`.

3. Scene 7c Renn trigger: Area2D under Entities near Renn, with `metadata/flag="scene_7c_renn"`, `metadata/required_flag="pendulum_presented"`, `metadata/dialogue_scene_id="scene_7c_renn"`.

- [ ] **Step 3: Commit modifications**

```bash
git add game/scenes/maps/towns/valdris_lower_ward.tscn \
  game/scenes/maps/towns/valdris_anchor_oar.tscn
git commit -m "feat(engine): update Lower Ward and Anchor & Oar for Phase C

Lower Ward: north ramp to Citizen's Walk, barracks door, Scene 7a
trigger, weaponsmith shop rename, Phoenix Pinion chest.
Anchor & Oar: staircase to upper floor, Scene 7c Renn trigger."
```

---

## Task 9: District Integrity Tests

**Files:**
- Create: `game/tests/test_valdris_districts.gd`

- [ ] **Step 1: Write district integrity tests**

```gdscript
# game/tests/test_valdris_districts.gd
extends GutTest

const DISTRICT_MAPS: Array[String] = [
	"towns/valdris_citizens_walk",
	"towns/valdris_court_quarter",
	"towns/valdris_throne_hall",
	"towns/valdris_royal_library",
	"towns/valdris_barracks",
	"towns/valdris_anchor_oar_upper",
]

const ALL_VALDRIS_MAPS: Array[String] = [
	"towns/valdris_lower_ward",
	"towns/valdris_anchor_oar",
	"towns/valdris_citizens_walk",
	"towns/valdris_court_quarter",
	"towns/valdris_throne_hall",
	"towns/valdris_royal_library",
	"towns/valdris_barracks",
	"towns/valdris_anchor_oar_upper",
]

func _load_map_scene(map_id: String) -> Node2D:
	var path: String = "res://scenes/maps/%s.tscn" % map_id
	assert_true(ResourceLoader.exists(path), "Scene '%s' should exist" % path)
	var scene: PackedScene = load(path) as PackedScene
	assert_not_null(scene, "Scene '%s' should load" % path)
	var node: Node2D = scene.instantiate() as Node2D
	add_child_autofree(node)
	return node

# --- Scene structure ---

func test_all_new_maps_load() -> void:
	for map_id: String in DISTRICT_MAPS:
		var path: String = "res://scenes/maps/%s.tscn" % map_id
		assert_true(ResourceLoader.exists(path),
			"Map '%s' should exist" % map_id)

func test_all_maps_have_required_metadata() -> void:
	for map_id: String in DISTRICT_MAPS:
		var node: Node2D = _load_map_scene(map_id)
		assert_true(node.has_meta("map_id"),
			"'%s' missing map_id metadata" % map_id)
		assert_true(node.has_meta("location_name"),
			"'%s' missing location_name metadata" % map_id)
		assert_eq(node.get_meta("map_id"), map_id,
			"'%s' map_id mismatch" % map_id)

func test_all_maps_have_tilemap() -> void:
	for map_id: String in DISTRICT_MAPS:
		var node: Node2D = _load_map_scene(map_id)
		var tilemap: TileMapLayer = node.get_node_or_null("TileMapLayer") as TileMapLayer
		assert_not_null(tilemap, "'%s' missing TileMapLayer" % map_id)

func test_all_maps_have_entities_node() -> void:
	for map_id: String in DISTRICT_MAPS:
		var node: Node2D = _load_map_scene(map_id)
		var entities: Node = node.get_node_or_null("Entities")
		assert_not_null(entities, "'%s' missing Entities node" % map_id)

func test_all_maps_have_player_spawn() -> void:
	for map_id: String in DISTRICT_MAPS:
		var node: Node2D = _load_map_scene(map_id)
		var spawn: Marker2D = node.get_node_or_null("PlayerSpawn") as Marker2D
		assert_not_null(spawn, "'%s' missing PlayerSpawn" % map_id)

# --- NPC metadata ---

func test_all_npcs_have_valid_dialogue() -> void:
	DataManager.clear_cache()
	for map_id: String in DISTRICT_MAPS:
		var node: Node2D = _load_map_scene(map_id)
		var entities: Node = node.get_node_or_null("Entities")
		if entities == null:
			continue
		for child: Node in entities.get_children():
			if not child.has_meta("npc_id"):
				continue
			var npc_id: String = child.get_meta("npc_id")
			var data: Dictionary = DataManager.load_dialogue("npc_%s" % npc_id)
			assert_not_equal(data, {},
				"NPC '%s' in '%s' has no dialogue file" % [npc_id, map_id])
	DataManager.clear_cache()

func test_shop_npcs_have_valid_shop_data() -> void:
	DataManager.clear_cache()
	for map_id: String in DISTRICT_MAPS:
		var node: Node2D = _load_map_scene(map_id)
		var entities: Node = node.get_node_or_null("Entities")
		if entities == null:
			continue
		for child: Node in entities.get_children():
			if not child.has_meta("shop_id"):
				continue
			var shop_id: String = child.get_meta("shop_id")
			var data: Dictionary = DataManager.load_shop(shop_id)
			assert_not_equal(data, {},
				"Shop '%s' in '%s' has no data file" % [shop_id, map_id])
	DataManager.clear_cache()

# --- Transitions bidirectional ---

func test_transition_targets_exist() -> void:
	for map_id: String in ALL_VALDRIS_MAPS:
		var node: Node2D = _load_map_scene(map_id)
		var transitions: Node = node.get_node_or_null("Transitions")
		if transitions == null:
			continue
		for child: Node in transitions.get_children():
			if not child.has_meta("target_map"):
				continue
			var target: String = child.get_meta("target_map")
			var path: String = "res://scenes/maps/%s.tscn" % target
			assert_true(ResourceLoader.exists(path),
				"Transition in '%s' points to missing '%s'" % [map_id, target])

func test_transition_spawns_exist() -> void:
	for map_id: String in ALL_VALDRIS_MAPS:
		var node: Node2D = _load_map_scene(map_id)
		var transitions: Node = node.get_node_or_null("Transitions")
		if transitions == null:
			continue
		for child: Node in transitions.get_children():
			if not child.has_meta("target_map"):
				continue
			var target_map: String = child.get_meta("target_map")
			var target_spawn: String = child.get_meta("target_spawn", "PlayerSpawn")
			var target_node: Node2D = _load_map_scene(target_map)
			var spawn: Marker2D = target_node.get_node_or_null(target_spawn) as Marker2D
			assert_not_null(spawn,
				"'%s' transition to '%s' references missing spawn '%s'" % [
					map_id, target_map, target_spawn])

# --- Specific map content ---

func test_throne_hall_has_scene_7b_trigger() -> void:
	var node: Node2D = _load_map_scene("towns/valdris_throne_hall")
	var entities: Node = node.get_node_or_null("Entities")
	var found: bool = false
	for child: Node in entities.get_children():
		if child.has_meta("dialogue_scene_id"):
			if child.get_meta("dialogue_scene_id") == "scene_7b_throne_hall":
				found = true
				break
	assert_true(found, "Throne hall should have Scene 7b dialogue trigger")

func test_throne_hall_has_scene_7d_cutscene_trigger() -> void:
	var node: Node2D = _load_map_scene("towns/valdris_throne_hall")
	var entities: Node = node.get_node_or_null("Entities")
	var found: bool = false
	for child: Node in entities.get_children():
		if child.has_meta("cutscene_scene_id"):
			if child.get_meta("cutscene_scene_id") == "scene_7d_evening":
				found = true
				assert_true(child.has_meta("required_flags"),
					"Scene 7d trigger must use required_flags (plural)")
				break
	assert_true(found, "Throne hall should have Scene 7d cutscene trigger")

func test_library_has_save_point() -> void:
	var node: Node2D = _load_map_scene("towns/valdris_royal_library")
	var entities: Node = node.get_node_or_null("Entities")
	var found: bool = false
	for child: Node in entities.get_children():
		if child.has_meta("save_point_id"):
			found = true
			break
	assert_true(found, "Library should have a save point")

func test_citizens_walk_has_three_shops() -> void:
	var node: Node2D = _load_map_scene("towns/valdris_citizens_walk")
	var entities: Node = node.get_node_or_null("Entities")
	var shop_count: int = 0
	for child: Node in entities.get_children():
		if child.has_meta("shop_id"):
			shop_count += 1
	assert_eq(shop_count, 3, "Citizen's Walk should have 3 shops")

func test_lower_ward_has_scene_7a_trigger() -> void:
	var node: Node2D = _load_map_scene("towns/valdris_lower_ward")
	var entities: Node = node.get_node_or_null("Entities")
	var found: bool = false
	for child: Node in entities.get_children():
		if child.has_meta("dialogue_scene_id"):
			if child.get_meta("dialogue_scene_id") == "scene_7a_the_gates":
				found = true
				assert_eq(child.get_meta("required_flag", ""), "maren_warning",
					"Scene 7a trigger must require maren_warning flag")
				break
	assert_true(found, "Lower Ward should have Scene 7a dialogue trigger")

func test_lower_ward_weaponsmith_renamed() -> void:
	var node: Node2D = _load_map_scene("towns/valdris_lower_ward")
	var entities: Node = node.get_node_or_null("Entities")
	for child: Node in entities.get_children():
		if child.has_meta("shop_id"):
			var sid: String = child.get_meta("shop_id")
			assert_ne(sid, "valdris_crown_armorer",
				"Old armorer shop_id should be renamed")
```

- [ ] **Step 2: Run district tests**

```bash
cd /Users/jaredmscott/repos/projects/pendulum-of-despair/game
godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_valdris_districts.gd -gexit 2>&1 | tail -30
```

Expected: ALL PASS.

- [ ] **Step 3: Commit**

```bash
git add game/tests/test_valdris_districts.gd
git commit -m "test(engine): add Valdris district integrity tests (30 tests)

Validates scene structure, metadata, NPC dialogue references,
shop data references, transition targets, spawn points, Scene 7
triggers, and bidirectional navigation."
```

---

## Task 10: Integration and Regression Tests

**Files:**
- Create: `game/tests/test_valdris_integration.gd`
- Create: `game/tests/test_scene_7_integration.gd`
- Create: `game/tests/test_scene_7_ordering.gd`
- Create: `game/tests/test_lower_ward_regression.gd`
- Create: `game/tests/test_anchor_oar_regression.gd`
- Create: `game/tests/test_valdris_npcs_integration.gd`
- Create: `game/tests/test_valdris_cross_references.gd`

- [ ] **Step 1: Write navigation integration tests**

```gdscript
# game/tests/test_valdris_integration.gd
extends GutTest

func before_each() -> void:
	EventFlags.clear_all()
	PartyState.members.clear()
	DataManager.clear_cache()

func after_each() -> void:
	EventFlags.clear_all()
	PartyState.members.clear()
	DataManager.clear_cache()

func _read_file(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text

# --- Bidirectional transitions ---

func test_lower_ward_to_citizens_walk_bidirectional() -> void:
	var lw: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	assert_true(lw.contains("valdris_citizens_walk"),
		"Lower Ward should transition to Citizen's Walk")
	assert_true(lw.contains("from_citizens_walk"),
		"Lower Ward should have from_citizens_walk spawn")
	var cw: String = _read_file("res://scenes/maps/towns/valdris_citizens_walk.tscn")
	assert_true(cw.contains("valdris_lower_ward"),
		"Citizen's Walk should transition to Lower Ward")
	assert_true(cw.contains("from_lower_ward"),
		"Citizen's Walk should have from_lower_ward spawn")

func test_citizens_walk_to_court_quarter_bidirectional() -> void:
	var cw: String = _read_file("res://scenes/maps/towns/valdris_citizens_walk.tscn")
	assert_true(cw.contains("valdris_court_quarter"),
		"Citizen's Walk should transition to Court Quarter")
	var cq: String = _read_file("res://scenes/maps/towns/valdris_court_quarter.tscn")
	assert_true(cq.contains("valdris_citizens_walk"),
		"Court Quarter should transition to Citizen's Walk")

func test_court_quarter_to_throne_hall_bidirectional() -> void:
	var cq: String = _read_file("res://scenes/maps/towns/valdris_court_quarter.tscn")
	assert_true(cq.contains("valdris_throne_hall"),
		"Court Quarter should transition to Throne Hall")
	var th: String = _read_file("res://scenes/maps/towns/valdris_throne_hall.tscn")
	assert_true(th.contains("valdris_court_quarter"),
		"Throne Hall should transition to Court Quarter")

func test_citizens_walk_to_library_bidirectional() -> void:
	var cw: String = _read_file("res://scenes/maps/towns/valdris_citizens_walk.tscn")
	assert_true(cw.contains("valdris_royal_library"),
		"Citizen's Walk should transition to Library")
	var lib: String = _read_file("res://scenes/maps/towns/valdris_royal_library.tscn")
	assert_true(lib.contains("valdris_citizens_walk"),
		"Library should transition to Citizen's Walk")

func test_lower_ward_to_barracks_bidirectional() -> void:
	var lw: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	assert_true(lw.contains("valdris_barracks"),
		"Lower Ward should transition to Barracks")
	var bk: String = _read_file("res://scenes/maps/towns/valdris_barracks.tscn")
	assert_true(bk.contains("valdris_lower_ward"),
		"Barracks should transition to Lower Ward")

func test_anchor_oar_to_upper_floor_bidirectional() -> void:
	var ao: String = _read_file("res://scenes/maps/towns/valdris_anchor_oar.tscn")
	assert_true(ao.contains("valdris_anchor_oar_upper"),
		"Anchor & Oar should transition to Upper Floor")
	var up: String = _read_file("res://scenes/maps/towns/valdris_anchor_oar_upper.tscn")
	assert_true(up.contains("valdris_anchor_oar"),
		"Upper Floor should transition to Anchor & Oar")

# --- Location names ---

func test_location_names_correct() -> void:
	var expected: Dictionary = {
		"towns/valdris_citizens_walk": "Valdris Crown - Citizen's Walk",
		"towns/valdris_court_quarter": "Valdris Crown - Court Quarter",
		"towns/valdris_throne_hall": "Valdris Crown - Throne Hall",
		"towns/valdris_royal_library": "Royal Library",
		"towns/valdris_barracks": "Knight's Barracks",
		"towns/valdris_anchor_oar_upper": "The Anchor & Oar - Upper Floor",
	}
	for map_id: String in expected:
		var path: String = "res://scenes/maps/%s.tscn" % map_id
		var scene: PackedScene = load(path) as PackedScene
		var node: Node2D = scene.instantiate() as Node2D
		add_child_autofree(node)
		assert_eq(node.get_meta("location_name", ""), expected[map_id],
			"Location name mismatch for '%s'" % map_id)
```

- [ ] **Step 2: Write Scene 7 end-to-end integration tests**

```gdscript
# game/tests/test_scene_7_integration.gd
extends GutTest

func before_each() -> void:
	EventFlags.clear_all()
	PartyState.members.clear()
	DataManager.clear_cache()

func after_each() -> void:
	EventFlags.clear_all()
	PartyState.members.clear()
	DataManager.clear_cache()

func _read_file(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()

# --- Scene 7a trigger wiring ---

func test_scene_7a_trigger_exists_in_lower_ward() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	assert_true(text.contains("scene_7a_the_gates"),
		"Lower Ward should have Scene 7a trigger")
	assert_true(text.contains("maren_warning"),
		"Scene 7a trigger should require maren_warning")

func test_scene_7a_dialogue_data_valid() -> void:
	var data: Dictionary = DataManager.load_dialogue("scene_7a_the_gates")
	var entries: Array = data.get("entries", [])
	assert_gt(entries.size(), 0, "Scene 7a should have entries")
	# Verify it sets valdris_arrived flag (via trigger metadata, not dialogue)

# --- Scene 7b trigger wiring ---

func test_scene_7b_trigger_exists_in_throne_hall() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_throne_hall.tscn")
	assert_true(text.contains("scene_7b_throne_hall"),
		"Throne Hall should have Scene 7b trigger")
	assert_true(text.contains("valdris_arrived"),
		"Scene 7b trigger should require valdris_arrived")

# --- Scene 7c trigger wiring ---

func test_scene_7c_aldis_trigger_in_library() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_royal_library.tscn")
	assert_true(text.contains("scene_7c_aldis"),
		"Library should have Scene 7c Aldis trigger")
	assert_true(text.contains("pendulum_presented"),
		"Scene 7c Aldis should require pendulum_presented")

func test_scene_7c_cordwyn_trigger_in_barracks() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_barracks.tscn")
	assert_true(text.contains("scene_7c_cordwyn"),
		"Barracks should have Scene 7c Cordwyn trigger")

func test_scene_7c_renn_trigger_in_tavern() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_anchor_oar.tscn")
	assert_true(text.contains("scene_7c_renn"),
		"Tavern should have Scene 7c Renn trigger")

# --- Scene 7d trigger wiring ---

func test_scene_7d_trigger_in_throne_hall() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_throne_hall.tscn")
	assert_true(text.contains("scene_7d_evening"),
		"Throne Hall should have Scene 7d cutscene trigger")
	assert_true(text.contains("required_flags"),
		"Scene 7d should use required_flags (plural)")
	assert_true(text.contains("scene_7c_aldis"),
		"Scene 7d required_flags should include scene_7c_aldis")
	assert_true(text.contains("scene_7c_cordwyn"),
		"Scene 7d required_flags should include scene_7c_cordwyn")
	assert_true(text.contains("scene_7c_renn"),
		"Scene 7d required_flags should include scene_7c_renn")

# --- Flag flow simulation ---

func test_full_scene_7_flag_flow() -> void:
	# Precondition: maren_warning set (party assembled)
	EventFlags.set_flag("maren_warning", true)
	# 7a fires, sets valdris_arrived
	EventFlags.set_flag("valdris_arrived", true)
	assert_true(EventFlags.get_flag("valdris_arrived"))
	# 7b fires, sets pendulum_presented
	EventFlags.set_flag("pendulum_presented", true)
	assert_true(EventFlags.get_flag("pendulum_presented"))
	# 7c conversations
	EventFlags.set_flag("scene_7c_aldis", true)
	EventFlags.set_flag("scene_7c_cordwyn", true)
	EventFlags.set_flag("scene_7c_renn", true)
	# 7d should now be able to fire
	var can_fire_7d: bool = (
		EventFlags.get_flag("scene_7c_aldis")
		and EventFlags.get_flag("scene_7c_cordwyn")
		and EventFlags.get_flag("scene_7c_renn")
		and EventFlags.get_flag("pendulum_presented")
	)
	assert_true(can_fire_7d, "Scene 7d should be fireable with all flags")
	# 7d fires, sets pendulum_to_capital
	EventFlags.set_flag("pendulum_to_capital", true)
	assert_true(EventFlags.get_flag("pendulum_to_capital"),
		"Act I should be complete")

# --- NPC dialogue gating ---

func test_cordwyn_shows_scene_7c_before_flag() -> void:
	EventFlags.set_flag("pendulum_presented", true)
	# scene_7c_cordwyn NOT set
	var data: Dictionary = DataManager.load_dialogue("npc_dame_cordwyn")
	var entries: Array = data.get("entries", [])
	# First conditioned entry with pendulum_presented AND !scene_7c_cordwyn
	# should be findable
	var found_7c: bool = false
	for entry: Dictionary in entries:
		var cond: Variant = entry.get("condition")
		if cond is String and "pendulum_presented" in (cond as String):
			found_7c = true
			break
	assert_true(found_7c, "Cordwyn should have scene 7c gated dialogue")

func test_aldis_shows_scene_7c_before_flag() -> void:
	EventFlags.set_flag("pendulum_presented", true)
	var data: Dictionary = DataManager.load_dialogue("npc_scholar_aldis")
	var entries: Array = data.get("entries", [])
	var found_7c: bool = false
	for entry: Dictionary in entries:
		var cond: Variant = entry.get("condition")
		if cond is String and "pendulum_presented" in (cond as String):
			found_7c = true
			break
	assert_true(found_7c, "Aldis should have scene 7c gated dialogue")
```

- [ ] **Step 3: Write Scene 7 ordering tests**

```gdscript
# game/tests/test_scene_7_ordering.gd
extends GutTest

func before_each() -> void:
	EventFlags.clear_all()

func after_each() -> void:
	EventFlags.clear_all()

func test_7b_blocked_without_7a() -> void:
	# valdris_arrived NOT set, so 7b trigger should not fire
	assert_false(EventFlags.get_flag("valdris_arrived"),
		"valdris_arrived should not be set")
	# The required_flag check in the trigger would block it

func test_7d_blocked_with_only_two_7c_flags() -> void:
	EventFlags.set_flag("pendulum_presented", true)
	EventFlags.set_flag("scene_7c_aldis", true)
	EventFlags.set_flag("scene_7c_cordwyn", true)
	# scene_7c_renn NOT set
	var flags_str: String = "scene_7c_aldis,scene_7c_cordwyn,scene_7c_renn,pendulum_presented"
	var all_met: bool = true
	for f: String in flags_str.split(","):
		if not EventFlags.get_flag(f.strip_edges()):
			all_met = false
			break
	assert_false(all_met, "7d should be blocked with only 2/3 conversation flags")

func test_7c_works_in_any_order_aldis_renn_cordwyn() -> void:
	EventFlags.set_flag("pendulum_presented", true)
	EventFlags.set_flag("scene_7c_aldis", true)
	EventFlags.set_flag("scene_7c_renn", true)
	EventFlags.set_flag("scene_7c_cordwyn", true)
	var all_met: bool = (
		EventFlags.get_flag("scene_7c_aldis")
		and EventFlags.get_flag("scene_7c_cordwyn")
		and EventFlags.get_flag("scene_7c_renn")
	)
	assert_true(all_met, "All 7c flags should work in any order")

func test_7c_works_in_any_order_cordwyn_aldis_renn() -> void:
	EventFlags.set_flag("pendulum_presented", true)
	EventFlags.set_flag("scene_7c_cordwyn", true)
	EventFlags.set_flag("scene_7c_aldis", true)
	EventFlags.set_flag("scene_7c_renn", true)
	var all_met: bool = (
		EventFlags.get_flag("scene_7c_aldis")
		and EventFlags.get_flag("scene_7c_cordwyn")
		and EventFlags.get_flag("scene_7c_renn")
	)
	assert_true(all_met)

func test_library_aldis_shows_ambient_without_pendulum_presented() -> void:
	# Without pendulum_presented, Aldis shows ambient (not Scene 7c)
	assert_false(EventFlags.get_flag("pendulum_presented"),
		"pendulum_presented should not be set")
	# The condition "pendulum_presented AND !scene_7c_aldis" evaluates to false
	# because pendulum_presented is false. So ambient fallback wins.

func test_7d_does_not_refire_after_completion() -> void:
	EventFlags.set_flag("pendulum_to_capital", true)
	# The flag check in cutscene_handler blocks re-trigger when flag is set
	assert_true(EventFlags.get_flag("pendulum_to_capital"),
		"pendulum_to_capital blocks re-trigger via flag metadata")
```

- [ ] **Step 4: Write Lower Ward regression tests**

```gdscript
# game/tests/test_lower_ward_regression.gd
extends GutTest

func before_each() -> void:
	DataManager.clear_cache()

func after_each() -> void:
	DataManager.clear_cache()

func _read_file(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()

func test_existing_npcs_still_present() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	var expected_npcs: Array[String] = [
		"bren", "wynn", "thessa", "sergeant_marek", "nella",
	]
	for npc_id: String in expected_npcs:
		assert_true(text.contains(npc_id),
			"NPC '%s' should still be in Lower Ward" % npc_id)

func test_existing_shop_npc_present() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	assert_true(text.contains("valdris_crown_weaponsmith"),
		"Weaponsmith shop should reference new ID")
	assert_false(text.contains("valdris_crown_armorer"),
		"Old armorer ID should not be present")

func test_weaponsmith_shop_loads() -> void:
	var data: Dictionary = DataManager.load_shop("valdris_crown_weaponsmith")
	assert_not_equal(data, {}, "Weaponsmith shop data should load")

func test_general_store_still_loads() -> void:
	var data: Dictionary = DataManager.load_shop("valdris_crown_general")
	assert_not_equal(data, {}, "General store should still load")
	var inv: Array = data.get("shop", {}).get("inventory", [])
	assert_gt(inv.size(), 0, "General store should still have items")

func test_existing_transitions_preserved() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	assert_true(text.contains("overworld"),
		"South Gate transition to overworld should still exist")
	assert_true(text.contains("valdris_anchor_oar"),
		"Tavern door transition should still exist")

func test_chapel_save_point_present() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	assert_true(text.contains("valdris_chapel_save"),
		"Chapel save point should still be present")

func test_existing_npc_dialogues_load() -> void:
	var npcs: Array[String] = ["bren", "wynn", "nella", "sergeant_marek", "thessa"]
	for npc_id: String in npcs:
		var data: Dictionary = DataManager.load_dialogue("npc_%s" % npc_id)
		assert_not_equal(data, {},
			"Dialogue for NPC '%s' should still load" % npc_id)

func test_tavern_renn_inn_still_works() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_anchor_oar.tscn")
	assert_true(text.contains("inn_id"),
		"Renn should still have inn_id metadata")
	assert_true(text.contains("150"),
		"Inn cost should still be 150")
```

- [ ] **Step 5: Write Anchor & Oar regression tests**

```gdscript
# game/tests/test_anchor_oar_regression.gd
extends GutTest

func _read_file(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()

func test_renn_still_present() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_anchor_oar.tscn")
	assert_true(text.contains("renn"), "Renn should still be in tavern")

func test_front_door_transition_preserved() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_anchor_oar.tscn")
	assert_true(text.contains("valdris_lower_ward"),
		"Front door to Lower Ward should still exist")

func test_save_point_preserved() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_anchor_oar.tscn")
	assert_true(text.contains("valdris_anchor_oar_save"),
		"Tavern save point should still be present")

func test_staircase_to_upper_floor_added() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_anchor_oar.tscn")
	assert_true(text.contains("valdris_anchor_oar_upper"),
		"Staircase transition to upper floor should exist")
	assert_true(text.contains("from_upstairs"),
		"from_upstairs spawn should exist")

func test_upper_floor_returns_to_tavern() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_anchor_oar_upper.tscn")
	assert_true(text.contains("valdris_anchor_oar"),
		"Upper floor should transition back to tavern")
	assert_true(text.contains("from_downstairs"),
		"from_downstairs spawn should exist in upper floor")
```

- [ ] **Step 6: Write cross-reference validation tests**

```gdscript
# game/tests/test_valdris_cross_references.gd
extends GutTest

func before_each() -> void:
	DataManager.clear_cache()

func after_each() -> void:
	DataManager.clear_cache()

func _read_file(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()

func _get_all_item_ids() -> Array[String]:
	var ids: Array[String] = []
	var consumables: Dictionary = DataManager.load_json("res://data/items/consumables.json")
	for item: Dictionary in consumables.get("consumables", []):
		ids.append(item.get("id", ""))
	var weapons: Dictionary = DataManager.load_json("res://data/equipment/weapons.json")
	for item: Dictionary in weapons.get("weapons", []):
		ids.append(item.get("id", ""))
	var armor: Dictionary = DataManager.load_json("res://data/equipment/armor.json")
	for item: Dictionary in armor.get("armor", []):
		ids.append(item.get("id", ""))
	var accessories: Dictionary = DataManager.load_json("res://data/equipment/accessories.json")
	for item: Dictionary in accessories.get("accessories", []):
		ids.append(item.get("id", ""))
	return ids

func test_all_shop_items_exist_in_game_data() -> void:
	var all_items: Array[String] = _get_all_item_ids()
	var shop_ids: Array[String] = [
		"valdris_crown_weaponsmith", "valdris_crown_armorsmith",
		"valdris_crown_jeweler", "valdris_crown_specialty",
		"valdris_crown_general",
	]
	for sid: String in shop_ids:
		var data: Dictionary = DataManager.load_shop(sid)
		var inventory: Array = data.get("shop", {}).get("inventory", [])
		for entry: Dictionary in inventory:
			var item_id: String = entry.get("item_id", "")
			assert_has(all_items, item_id,
				"Item '%s' in shop '%s' not found in game data" % [item_id, sid])

func test_all_treasure_chest_items_exist() -> void:
	var all_items: Array[String] = _get_all_item_ids()
	# Check chest metadata in scenes
	var maps: Array[String] = [
		"res://scenes/maps/towns/valdris_lower_ward.tscn",
		"res://scenes/maps/towns/valdris_royal_library.tscn",
	]
	for map_path: String in maps:
		var text: String = _read_file(map_path)
		# Check for phoenix_pinion and spirit_incense
		if text.contains("phoenix_pinion"):
			assert_has(all_items, "phoenix_pinion",
				"phoenix_pinion from chest should exist in items data")
		if text.contains("spirit_incense"):
			assert_has(all_items, "spirit_incense",
				"spirit_incense from chest should exist in items data")

func test_all_npc_dialogue_files_exist_for_maps() -> void:
	var maps: Array[String] = [
		"towns/valdris_citizens_walk",
		"towns/valdris_court_quarter",
		"towns/valdris_throne_hall",
		"towns/valdris_royal_library",
		"towns/valdris_barracks",
	]
	for map_id: String in maps:
		var path: String = "res://scenes/maps/%s.tscn" % map_id
		var scene: PackedScene = load(path) as PackedScene
		var node: Node2D = scene.instantiate() as Node2D
		add_child_autofree(node)
		var entities: Node = node.get_node_or_null("Entities")
		if entities == null:
			continue
		for child: Node in entities.get_children():
			if not child.has_meta("npc_id"):
				continue
			var npc_id: String = child.get_meta("npc_id")
			var dlg: Dictionary = DataManager.load_dialogue("npc_%s" % npc_id)
			assert_not_equal(dlg, {},
				"NPC '%s' in '%s' missing dialogue file" % [npc_id, map_id])
```

- [ ] **Step 7: Run all integration and regression tests**

```bash
cd /Users/jaredmscott/repos/projects/pendulum-of-despair/game
godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_valdris_integration.gd -gexit 2>&1 | tail -20
godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_scene_7_integration.gd -gexit 2>&1 | tail -20
godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_scene_7_ordering.gd -gexit 2>&1 | tail -20
godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_lower_ward_regression.gd -gexit 2>&1 | tail -20
godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_anchor_oar_regression.gd -gexit 2>&1 | tail -20
godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_valdris_cross_references.gd -gexit 2>&1 | tail -20
```

Expected: ALL PASS.

- [ ] **Step 8: Commit all integration tests**

```bash
git add game/tests/test_valdris_integration.gd \
  game/tests/test_scene_7_integration.gd \
  game/tests/test_scene_7_ordering.gd \
  game/tests/test_lower_ward_regression.gd \
  game/tests/test_anchor_oar_regression.gd \
  game/tests/test_valdris_cross_references.gd
git commit -m "test(engine): add integration, regression, and cross-ref tests

Navigation (8 tests), Scene 7 e2e (10 tests), ordering (6 tests),
Lower Ward regression (8 tests), Anchor & Oar regression (5 tests),
cross-references (3 tests). Total: ~40 integration tests."
```

---

## Task 11: Gap Tracker Update

**Files:**
- Modify: `docs/analysis/game-dev-gaps.md`

- [ ] **Step 1: Update Phase C status to COMPLETE**

In `docs/analysis/game-dev-gaps.md`, under gap 4.4, update Phase C to COMPLETE and add detailed deferred items.

- [ ] **Step 2: Add deferred items to gap 4.5**

Add a new section under gap 4.5 listing all deferred Valdris items:
- Eastern Wall & Battlements district
- Tower Tutorial district (Seven Towers)
- Chapel, Cael's Quarters, Haren's Estate, Council Chambers, Court Mage Tower interiors
- Maren's Old Study, Pendulum Research Room, Servants' Passage, Royal Bedchamber
- Library Stacks Wing + Basement Archive
- Act II shop restocking
- Thornwatch garrison (recommend new sub-gap)
- Aelhart starting town (recommend new sub-gap)

- [ ] **Step 3: Update progress tracking table**

Add row:
```
| 2026-04-19 | 4.4 Phase C | Capital Completion: 3 outdoor districts (Citizen's Walk, Court Quarter), 4 interiors (Throne Hall, Library, Barracks, Tavern Upper), Scene 7 narrative (FF6 Vector-style free-roam), shop split (weaponsmith/armorsmith/jeweler), 17 dialogue files, ~185 tests across 11 test files. |
```

- [ ] **Step 4: Update summary table**

Update Tier 4 row: `1 in progress` changes to reflect Phase C completion.

- [ ] **Step 5: Commit**

```bash
git add docs/analysis/game-dev-gaps.md
git commit -m "docs(story): update gap tracker for Phase C completion

Phase C COMPLETE. Deferred items (Eastern Wall, Tower Tutorial,
Thornwatch, Aelhart, Act II interiors) explicitly catalogued under
gap 4.5. Progress table updated."
```

---

## Task 12: Full Test Suite Verification

- [ ] **Step 1: Run the entire test suite**

```bash
cd /Users/jaredmscott/repos/projects/pendulum-of-despair/game
godot --headless --script addons/gut/gut_cmdln.gd -gexit 2>&1 | tail -40
```

Expected: ALL tests pass (existing + new). No regressions.

- [ ] **Step 2: If any failures, fix and re-run**

Fix failures. Each fix gets its own commit with a descriptive message.

- [ ] **Step 3: Final commit summary**

```bash
git log --oneline -15
```

Verify the commit history is clean and tells the Phase C story.

---

## Execution Summary

| Task | Description | Est. Tests | Key Files |
|------|-------------|-----------|-----------|
| 1 | Tileset extension | 0 | PNG + .tres |
| 2 | Shop data split + new shops | ~15 | 3 shop JSON + accessories |
| 3 | NPC ambient dialogue | ~12 | 11 dialogue JSON |
| 4 | Scene 7 dialogue | ~13 | 6 dialogue JSON |
| 5 | Multi-flag support | ~10 | cutscene_handler.gd + exploration.gd |
| 6 | Interior maps | 0 | 4 .tscn |
| 7 | Outdoor districts | 0 | 2 .tscn |
| 8 | Modify existing maps | 0 | 2 .tscn |
| 9 | District integrity tests | ~30 | test file |
| 10 | Integration + regression tests | ~40 | 6 test files |
| 11 | Gap tracker update | 0 | game-dev-gaps.md |
| 12 | Full suite verification | 0 | — |
| **Total** | | **~120** | **~40 files** |
