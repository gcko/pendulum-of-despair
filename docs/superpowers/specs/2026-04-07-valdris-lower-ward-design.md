# Valdris Crown Lower Ward — Design Spec

> **Gap:** 4.2 (Vertical Slice: Valdris Crown First Town)
> **Approach:** A — Lower Ward only (1 exterior + 1 interior)
> **Goal:** Prove the town gameplay loop: walk around → talk to NPCs →
> shop for gear → rest at inn → save → transition to/from dungeon.

---

## 1. Scope

### In Scope

- 1 exterior map: Lower Ward (~64x56 tiles, placeholder tileset)
- 1 interior map: Anchor & Oar tavern ground floor (16x14 tiles)
- 7 NPCs with flag-gated dialogue (Bren, Wynn, Old Harren, Renn, Thessa, Sgt. Marek, Nella)
- 2 shop NPCs wired to existing shop JSON (general store, armorer)
- 1 inn (Anchor & Oar, 150g rest via Renn)
- 1 save point (Chapel of the Old Pacts)
- Transitions: South Gate ↔ test_room, exterior ↔ tavern interior
- Shop interaction: new SHOP overlay state + standalone shop scene
- Inn interaction wiring in exploration.gd (rest + gold deduction)
- `PartyState.rest_at_inn()` method (new)
- Extract encounter logic from exploration.gd to free line budget
- Placeholder tileset extension (2 new town tiles added to existing strip)

### Not In Scope

| Item | Reason | Deferred To |
|------|--------|-------------|
| Districts B-E (Citizen's Walk, Court Quarter, Royal Keep, Eastern Wall) | Full city is Act I-Interlude content | 4.4 |
| Scene 7 story sequence (King Aldren, throne hall) | Needs 6-person party + cutscene system (3.7) | 4.4 |
| Specialty/Accessory shop (Citizen's Walk) | Different district | 4.4 |
| Armor Shop (Citizen's Walk) | Different district | 4.4 |
| Tavern upper floor (guest rooms) | Minimal gameplay value for slice | 4.4 |
| Barracks interior | No unique gameplay mechanic | 4.4 |
| Cael's Quarters interior | Cutscene-only location | 4.4 + 3.7 |
| Chapel interior | Save point is exterior, sufficient for slice | 4.4 |
| Training post interaction | Combat tutorial not designed | 4.4 |
| Act II shop restocking (diplomatic_mission_start) | Act II content | 4.4 |
| Refugee Quarter (Osric NPC) | Act II content | 4.4 |
| Dame Cordwyn NPC | Barracks interior, story-heavy dialogue | 4.4 |
| Music/ambient audio | Gap 3.8 NOT STARTED | 3.8 |
| Pixel art tileset | Gap 4.8 | 4.8 |
| North ramp to Citizen's Walk | District B not in scope | 4.4 |
| SE Postern to Thornwatch | No Thornwatch map exists | 4.4 |

### Tech Debt (track in beads)

1. **Inn wiring is hardcoded** — Rest logic lives in exploration.gd.
   Should move to a dedicated InnKeeper entity or service when more
   inns are added.
2. **Placeholder tileset** — 6-color tiles. Replace with pixel art
   in gap 4.8.
3. **Shop NPCs have minimal dialogue** — They have stub dialogue JSON
   but primarily open the shop overlay. Add personality dialogue in 4.4.
4. **Shop overlay is minimal** — Buy-only for vertical slice. Sell
   mode, quantity selection, and equipment comparison deferred to 3.4.

---

## 2. Tilemap Pipeline

### Tileset Extension

Extend `game/assets/tilesets/placeholder_dungeon.png` from 64x16 (4 tiles)
to 96x16 (6 tiles):

- Tile 0: Floor — brown `#5C3A1E` (existing)
- Tile 1: Wall — dark grey `#2A2A2A` (existing, reused for city walls)
- Tile 2: Crystal — orange-amber `#D4820A` (existing, unused in town)
- Tile 3: Stairs — light grey `#8A8A8A` (existing, reused for ramps/doors)
- Tile 4: Building wall — medium grey `#666666` (NEW)
- Tile 5: Town floor — warm tan `#C4A46E` (NEW)

Update `placeholder_dungeon.tres` to include tiles 4-5 with no physics
(buildings are solid via wall tiles around them, not via building tile
collision).

Alternatively, create a separate `placeholder_town.png` / `.tres` to
keep dungeon and town tilesets independent. **Decision: extend the
existing tileset** — simpler, one TileSet resource to manage.

### Exterior Map: Lower Ward

`game/scenes/maps/towns/valdris_lower_ward.tscn`

**Dimensions:** 40x35 tiles (640x560 pixels) — simplified from the
canonical 64x56 to fit the vertical slice. The canonical ASCII layout
has extensive empty space; the simplified version preserves all
building positions and NPC placements but reduces corridor widths.

**Layout (simplified for vertical slice):**

```
North edge: wall with gap (future ramp to Citizen's Walk, blocked)
West: city wall
East: city wall
South-west: South Gate transition (to test_room)
South-east: SE Postern (blocked for vertical slice)

Buildings (clockwise from NW):
- Chapel of the Old Pacts (NW area, save point outside)
- Barracks (N-center, Sgt. Marek outside)
- Cael's Quarters (NE, door locked — flavor only)
- Anchor & Oar Tavern (E-center, transition to interior)
- Arms Shop (S-center-right, shop NPC inside doorway)
- Item Shop (S-center-left, shop NPC inside doorway)
- Bakery (SW, Bren outside)

Central: fountain + market stalls
Wynn: near South Gate
Old Harren: near Anchor & Oar entrance
Thessa: near Chapel
```

### Interior Map: Anchor & Oar Ground Floor

`game/scenes/maps/towns/valdris_anchor_oar.tscn`

**Dimensions:** 16x14 tiles (256x224 pixels)

From `interiors.md` canonical layout:
- Fireplace (north wall)
- Bar counter (center-south)
- Renn behind counter (inn + shop NPC)
- Save point near staircase
- Tables and chairs (decoration, non-interactive)
- Front door (south, transition back to exterior)
- Staircase (east, blocked — upper floor not in scope)

---

## 3. NPC Data

All 7 NPCs use existing `npc.tscn` prefab. Dialogue JSON already
exists in `game/data/dialogue/`.

| NPC | ID | Location | Dialogue JSON | Notes |
|-----|----|----------|---------------|-------|
| Bren | `bren` | Market Square (exterior) | `npc_bren.json` | Baker, flavor |
| Wynn | `wynn` | South Gate (exterior) | `npc_wynn.json` | Guard, flavor |
| Old Harren | `old_harren` | Near tavern (exterior) | `npc_old_harren.json` | Innkeeper, Vaelith breadcrumb |
| Renn | `renn` | Behind counter (interior) | `npc_renn.json` | Tavern keeper, inn service |
| Thessa | `thessa` | Chapel area (exterior) | `npc_thessa.json` | Temple keeper, flavor |
| Sgt. Marek | `sergeant_marek` | Barracks area (exterior) | `npc_sergeant_marek.json` | Training sergeant, flavor |
| Nella | `nella` | Fountain area (exterior) | `npc_nella.json` | Flower seller, flavor |

**Shop NPCs (unnamed, no dialogue JSON):**

| NPC | ID | Location | Metadata |
|-----|----|----------|----------|
| Shopkeeper | `valdris_shopkeeper` | Item Shop doorway | `shop_id: valdris_crown_general` |
| Weaponsmith | `valdris_weaponsmith` | Arms Shop doorway | `shop_id: valdris_crown_armorer` |

Shop NPCs use `npc.tscn` with `metadata/shop_id` set. They also need
stub dialogue JSON files so `npc.gd.initialize()` doesn't push_error
on missing dialogue. Create `npc_valdris_shopkeeper.json` and
`npc_valdris_weaponsmith.json` with a single default entry each
(e.g., "Welcome! Take a look around.").

When interacted, exploration.gd detects the `shop_id` metadata and
opens the shop overlay instead of dialogue.

---

## 4. Shop System

### New Overlay: SHOP

The menu overlay (gap 3.4) does NOT have a shop screen. A new
standalone SHOP overlay is needed.

**New GameManager overlay state:** `OverlayState.SHOP`

**New scene:** `game/scenes/overlay/shop_overlay.tscn`

**New script:** `game/scripts/ui/shop_overlay.gd`

**Scope for vertical slice:** Buy-only. No sell mode, no quantity
picker, no equipment comparison. Player sees a list of items with
prices, selects one, gold is deducted, item is added to inventory.

**Shop overlay scene tree:**
```
ShopOverlay (CanvasLayer)
  +-- Panel (PanelContainer, 280x160, centered)
      +-- VBox
          +-- Title (Label: "General Store" / "Armorer")
          +-- ItemList (ScrollContainer + VBox of item rows)
          +-- GoldLabel (Label: "Gold: 500")
          +-- HintLabel (Label: "A: Buy  B: Cancel")
```

**Shop overlay flow:**
1. `exploration.gd` detects `shop_id` on interacted NPC
2. Sets `GameManager.transition_data = {"shop_id": shop_id}`
3. Calls `GameManager.push_overlay(GameManager.OverlayState.SHOP)`
4. `shop_overlay.gd._ready()` reads `shop_id` from transition_data
5. Loads shop inventory via `DataManager.load_shop(shop_id)`
6. Displays item list with prices
7. On confirm: deducts gold via `PartyState.spend_gold()`, adds item
8. On cancel: `GameManager.pop_overlay()`

**Implementation in exploration.gd (`_on_npc_interacted`):**

```gdscript
# Check if NPC is a shopkeeper (by instance var after initialize)
var entities: Node = _current_map.get_node_or_null("Entities")
if entities != null:
    for child: Node in entities.get_children():
        if child.has_method("get_npc_id") and child.get_npc_id() == npc_id:
            if child.has_meta("shop_id"):
                var sid: String = child.get_meta("shop_id")
                GameManager.transition_data = {"shop_id": sid}
                GameManager.push_overlay(GameManager.OverlayState.SHOP)
                return
            if child.has_meta("inn_id"):
                _handle_inn_interaction(child)
                return
            break
# Fall through to normal dialogue
```

**Note:** NPC lookup uses `get_npc_id()` method (instance var accessor)
rather than metadata, since `npc_id` is set via `initialize()` and
stored as an instance variable, not metadata.

### Existing Shop Data

Shop JSON files already exist and are loaded by DataManager:
- `game/data/shops/valdris_crown_general.json`
- `game/data/shops/valdris_crown_armorer.json`

---

## 5. Inn Wiring

### New Feature: Inn Rest Interaction

**Trigger:** Player interacts with NPC that has `metadata/inn_id`.

**Flow:**
1. NPC emits `npc_interacted`
2. `exploration.gd` checks `metadata/inn_id` on the NPC node
3. If inn_id exists: check if PartyState has enough gold (150g)
4. If enough gold: deduct gold, call `PartyState.rest_at_inn()`,
   flash "Rested at the inn." location text
5. If not enough gold: flash "Not enough gold." and return

**Inn data:**

| Field | Value | Source |
|-------|-------|--------|
| Cost | 150g | economy.md line 146 |
| Effect | Restore all HP, MP, AC; clear all status | economy.md |
| NPC | Renn | city-valdris.md |
| Location | Anchor & Oar tavern interior | city-valdris.md |

**Implementation in exploration.gd:**

```gdscript
func _handle_inn_interaction(npc_node: Node) -> void:
    var cost: int = npc_node.get_meta("inn_cost", 150)
    if not PartyState.spend_gold(cost):
        flash_location_name("Not enough gold.")
        return
    PartyState.rest_at_inn()
    flash_location_name("Rested at the inn.")
```

Uses existing `PartyState.spend_gold(amount)` which validates and
returns bool.

**New method: `PartyState.rest_at_inn()`** (MUST be added to
`game/scripts/autoload/party_state.gd`):

```gdscript
func rest_at_inn() -> void:
    for member: Dictionary in _active_party:
        if member.is_empty():
            continue
        member["current_hp"] = member.get("max_hp", member.get("base_stats", {}).get("hp", 1))
        member["current_mp"] = member.get("max_mp", member.get("base_stats", {}).get("mp", 0))
        member["current_ac"] = member.get("max_ac", 12)
        member["status_effects"] = []
```

Restores all active party members to max HP, MP, AC and clears
all status ailments. Per economy.md.

---

## 6. Save Point

One save point in the exterior map near the Chapel of the Old Pacts.
Uses existing `save_point.tscn` prefab with `metadata/save_point_id`
set to `"valdris_chapel_save"`.

One save point in the tavern interior near the staircase.
`metadata/save_point_id = "valdris_anchor_oar_save"`.

---

## 7. Transitions

| From | To | Trigger | Spawn Point |
|------|----|---------|-------------|
| Lower Ward exterior | test_room | South Gate Area2D | `from_valdris` in test_room |
| test_room | Lower Ward exterior | New transition Area2D | `PlayerSpawn` in lower ward |
| Lower Ward exterior | Anchor & Oar interior | Tavern door Area2D | `from_exterior` in tavern |
| Anchor & Oar interior | Lower Ward exterior | Front door Area2D | `from_tavern` in exterior |

**test_room updates:**
- Add transition Area2D for Valdris (east side, mirroring the dungeon
  entrance on the west side)
- Add `from_valdris` Marker2D spawn point

---

## 8. Event Flags

No new event flags are needed for the vertical slice. The NPCs'
flag-gated dialogue uses existing flags from events.md. For the
vertical slice (Act I, early game), most NPCs will show their
default (no-flag) dialogue.

Flags that affect NPC dialogue in the existing JSON:
- `vaelith_tavern_encounter` — Old Harren's Vaelith breadcrumb
- `cael_betrayal_complete` — Post-betrayal dialogue variants
- `interlude_begins` — Interlude dialogue variants
- `party_has(torren)` — Thessa's Torren-specific line

None of these need to be set for the vertical slice to work. The
default dialogue entries (condition: null) will display.

---

## 9. exploration.gd Line Budget

exploration.gd is at 400 lines (the gdlint max). This spec adds
~15 net new lines (shop/inn NPC detection in `_on_npc_interacted`,
`_handle_inn_interaction` helper). To stay under 400 lines:

**Extract encounter logic to `encounter_handler.gd`** (~45 lines freed):

Move these functions to `game/scripts/core/encounter_handler.gd`:
- `_process_encounter_step()` (~10 lines)
- `_trigger_random_encounter()` (~20 lines)

`encounter_handler.gd` is a static helper (like BattleActions). The
encounter config and danger counter stay on exploration.gd as state,
but the step/trigger logic moves out. Exploration.gd calls:
```gdscript
EncounterHandler.process_step(_encounter_config, _danger_counter, ...)
EncounterHandler.trigger_random(_encounter_config, _current_map_id, ...)
```

This frees ~30 lines after removing the function bodies and
replacing with static calls, giving comfortable headroom for the
new shop/inn code.

---

## 10. File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `game/assets/tilesets/placeholder_dungeon.png` | MODIFY | Extend from 4 to 6 tiles |
| `game/assets/tilesets/placeholder_dungeon.tres` | MODIFY | Add tile 4-5 definitions |
| `game/scenes/maps/towns/valdris_lower_ward.tscn` | CREATE | Exterior map scene |
| `game/scenes/maps/towns/valdris_anchor_oar.tscn` | CREATE | Tavern interior scene |
| `game/scenes/maps/test_room.tscn` | MODIFY | Add Valdris transition |
| `game/scenes/overlay/shop_overlay.tscn` | CREATE | Shop buy screen |
| `game/scripts/ui/shop_overlay.gd` | CREATE | Shop overlay logic |
| `game/scripts/core/exploration.gd` | MODIFY | Shop + inn NPC detection |
| `game/scripts/core/encounter_handler.gd` | CREATE | Extracted encounter logic |
| `game/scripts/autoload/party_state.gd` | MODIFY | Add `rest_at_inn()` |
| `game/scripts/autoload/game_manager.gd` | MODIFY | Add `OverlayState.SHOP` |
| `game/data/dialogue/npc_valdris_shopkeeper.json` | CREATE | Stub dialogue for shop NPC |
| `game/data/dialogue/npc_valdris_weaponsmith.json` | CREATE | Stub dialogue for arms NPC |
| `docs/analysis/game-dev-gaps.md` | MODIFY | Update gap 4.2 status |

**Files NOT created (data already exists):**
- Shop JSON — `game/data/shops/valdris_crown_general.json` exists
- Shop JSON — `game/data/shops/valdris_crown_armorer.json` exists
- Dialogue JSON — all 7 named NPC dialogue files exist in `game/data/dialogue/`

---

## 11. Verification Checklist

- [ ] All 7 NPCs display their default dialogue when interacted
- [ ] Item Shop opens shop overlay with correct inventory
- [ ] Arms Shop opens shop overlay with correct inventory
- [ ] Inn deducts 150g and restores party (or shows "Not enough gold.")
- [ ] Save point at Chapel opens save/load overlay
- [ ] Save point at tavern opens save/load overlay
- [ ] South Gate transition takes player to test_room
- [ ] test_room transition takes player to Lower Ward
- [ ] Tavern door transitions work bidirectionally
- [ ] No entity positions are outside map bounds
- [ ] All NPC positions are on integer pixel coordinates
- [ ] Placeholder tileset has 6 tiles at 16x16 each
- [ ] exploration.gd stays under 400 lines
- [ ] All new code has static type hints
