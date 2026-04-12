# Fenmother's Hollow Puzzles — Phase A2b Design Spec

> **Gap:** 4.4 Phase A2b (Fenmother's Hollow Puzzles)
> **Date:** 2026-04-11
> **Status:** Approved
> **Builds on:** docs/superpowers/specs/2026-04-09-fenmothers-hollow-design.md

## Overview

Phase A2b adds the interactive puzzle systems to Fenmother's Hollow,
transforming it from a linear dungeon into a multi-state exploration
puzzle. The player manipulates three water wheels to open/close paths,
carries a Spirit Vessel across floors to restore a dying spirit-plant,
navigates poison damage zones, survives a ritual meter during the
cleansing wave sequence, and walks through a cinematic spirit-path
tunnel to reach the Duskfen Spirit Shrine where Caden performs the
binding ritual.

**Source docs:**
- `docs/story/dungeons-world.md` — Fenmother's Hollow section
- `docs/story/items.md` — Spirit Vessel, Fenmother's Blessing
- `docs/story/events.md` — Fenmother-related flags
- `docs/story/script/act-i.md` — Caden binding dialogue

## Player Flow (Complete Puzzle Chain)

```
F1: Enter → Wheel 1 (HIGH) → alcove opens → chest: Spirit Vessel
    → fill at Pure Spring → Wheel 2 (HIGH) → more paths open
    → descend to F2

F2: Pour vessel on spirit-plant → passage opens (cinematic)
    → fight Drowned Sentinel → Wheel 3 (HIGH) → secret room
    → descend to F3

F3: Navigate poison pools → fight Corrupted Fenmother
    → cleansing waves (4 battles, ritual meter between)
    → poison pools spawn between waves

Post-boss: Auto-walk spirit-path tunnel → Duskfen Spirit Shrine
    → Caden arrives, binding ritual, Fenmother's Blessing
    → permanent overworld shortcut
```

---

## Section 1: Puzzle State System (PartyState)

### New `puzzle_state` Dictionary

```gdscript
var puzzle_state: Dictionary = {}
```

Persisted in save data at the top level (alongside `ley_crystals`).
Keyed by dungeon_id, each value is a Dictionary of key-value pairs.

Example runtime state:
```gdscript
{
    "fenmothers_hollow": {
        "wheel_1_high": false,
        "wheel_2_high": false,
        "wheel_3_high": false,
        "spirit_plant_1_restored": false
    }
}
```

### API

```gdscript
## Set a puzzle state value for a dungeon.
func set_puzzle_state(dungeon_id: String, key: String, value: Variant) -> void

## Get a puzzle state value. Returns default if not set.
func get_puzzle_state(dungeon_id: String, key: String, default_value: Variant = false) -> Variant

## Clear all puzzle state for a dungeon (new game reset).
func clear_puzzle_state(dungeon_id: String) -> void
```

### Save/Load Integration

`build_save_data()` includes `"puzzle_state": puzzle_state.duplicate(true)`.
`load_from_save()` restores with type guard:
```gdscript
var ps_data: Variant = data.get("puzzle_state", {})
puzzle_state = ps_data as Dictionary if ps_data is Dictionary else {}
```

`initialize_new_game()` clears: `puzzle_state.clear()`

`save_manager.gd` `_validate()` adds `"puzzle_state"` to the required
keys array.

### Tests (~8)

- set/get round-trip
- get with default (key not set)
- clear removes dungeon state
- other dungeon state unaffected by clear
- save includes puzzle_state
- load restores puzzle_state
- load handles missing key (empty dict)
- load handles wrong type (Array instead of Dict)

---

## Section 2: Water Wheel Interactable

### Prefab

**Files:** `game/scenes/entities/water_wheel.tscn`,
`game/scripts/entities/water_wheel.gd`

**Scene tree:**
```
WaterWheel (Area2D, collision layer 3)
├── Sprite2D (16x16 placeholder, 2 frames: LOW=grey, HIGH=blue)
├── CollisionShape2D (12x12 RectangleShape2D)
└── AnimationPlayer (toggle stub)
```

### Metadata (.tscn)

```
wheel_id: "wheel_1"
dungeon_id: "fenmothers_hollow"
```

### GDScript

```gdscript
signal wheel_toggled(wheel_id: String, is_high: bool)

func initialize(wheel_id: String, dungeon_id: String) -> void
    ## Reads current state from PartyState.get_puzzle_state()
    ## Sets sprite frame accordingly

func interact() -> void
    ## Toggles state, writes to PartyState.set_puzzle_state()
    ## Updates sprite, emits wheel_toggled
```

Guards: empty wheel_id, empty dungeon_id → push_error + return.

### Placement

| Floor | Position | wheel_id |
|-------|----------|----------|
| F1 | (192, 256) | wheel_1 |
| F1 | (640, 400) | wheel_2 |
| F2 | (752, 160) | wheel_3 |

F1 Wheel 1 replaces the existing "WaterWheel" dialogue trigger.

### Tests (~6)

- initialize sets correct visual from puzzle_state
- interact toggles state
- interact persists to puzzle_state
- signal emitted with correct args
- re-initialize after toggle preserves state
- empty wheel_id guard

---

## Section 3: Water Level Zone System

### Prefab

**Files:** `game/scenes/entities/water_zone.tscn`,
`game/scripts/entities/water_zone.gd`

**Scene tree:**
```
WaterZone (Area2D, collision layer 1 for block type)
├── Sprite2D (semi-transparent blue rectangle)
└── CollisionShape2D (sized per instance)
```

### Metadata (.tscn)

```
dungeon_id: "fenmothers_hollow"
active_when: "wheel_1_low"              # comma-separated conditions
zone_type: "block"                       # or "reveal"
```

### Condition Format

Each condition is `{wheel_id}_{state}` where state is `high` or `low`.
Multiple conditions separated by commas = ALL must be true.

Examples:
- `"wheel_1_low"` — active when Wheel 1 is LOW
- `"wheel_1_high,wheel_2_high,wheel_3_high"` — active when all HIGH

### GDScript

```gdscript
func initialize(dungeon_id: String, conditions: String, zone_type: String) -> void
    ## Parses conditions string, stores dungeon_id and type

func refresh() -> void
    ## Reads wheel states from puzzle_state
    ## Evaluates all conditions
    ## block type: visible + collision enabled when conditions MET (water blocks)
    ## reveal type: visible + collision disabled when conditions MET (path opens)
    ## Inverted when conditions NOT met
```

### Zone Placement

**F1 zones (~4):**

| Position | Size | active_when | zone_type | Purpose |
|----------|------|-------------|-----------|---------|
| (320, 64) | 64x32 | wheel_1_low | block | Deep water barrier, clears when W1 HIGH |
| (224, 240) | 48x48 | wheel_1_low | block | Alcove entrance, opens when W1 HIGH |
| (480, 320) | 96x32 | wheel_1_high,wheel_2_low | block | Mid-passage floods in partial state |
| (608, 288) | 48x64 | wheel_1_low | block | East wing stairs, opens when W1 HIGH |

**F2 zones (~3):**

| Position | Size | active_when | zone_type | Purpose |
|----------|------|-------------|-----------|---------|
| (320, 192) | 128x64 | wheel_1_low | block | Submerged mosaic, drains when W1+W2 HIGH |
| (320, 192) | 128x64 | wheel_2_low | block | Second condition for mosaic (both needed) |
| (80, 48) | 48x48 | wheel_1_high,wheel_2_high,wheel_3_high | reveal | Secret room, accessible when all HIGH |

### Exploration.gd Integration

When `_on_wheel_toggled` fires, call `refresh()` on all water_zone
entities in the current map. Also call `refresh()` on all zones during
`_initialize_entities()` on map load.

### Tests (~5)

- condition parsing (single, multiple)
- refresh with matching state → active
- refresh with non-matching state → inactive
- block type: collision enabled when active
- reveal type: collision disabled when active

---

## Section 4: Spirit Vessel, Pure Spring, Spirit-Plant

### 4a. Key Items

Two new entries in `game/data/items/key_items.json`:

```json
{
    "id": "spirit_vessel",
    "name": "Spirit Vessel",
    "category": "key_item",
    "subcategory": "dungeon_access",
    "description": "An empty fenwood bowl lined with thin ley-crystal. It could hold sacred water.",
    "auto_use": false,
    "acquired_from": "Fenmother's Hollow F1 hidden alcove",
    "quest_link": "fenmothers_hollow_spirit_plant"
},
{
    "id": "spirit_vessel_filled",
    "name": "Spirit Vessel (Filled)",
    "category": "key_item",
    "subcategory": "dungeon_access",
    "description": "A fenwood bowl brimming with pure spring water. It glows faintly with spiritual energy.",
    "auto_use": false,
    "acquired_from": "Pure Spring in Fenmother's Hollow F1",
    "quest_link": "fenmothers_hollow_spirit_plant"
}
```

### 4b. Pure Spring

**Files:** `game/scenes/entities/pure_spring.tscn`,
`game/scripts/entities/pure_spring.gd`

**Scene tree:**
```
PureSpring (Area2D, collision layer 3)
├── Sprite2D (16x16 blue-white shimmer placeholder)
└── CollisionShape2D (12x12)
```

**GDScript:**
```gdscript
signal spring_filled

func interact() -> void
    ## Check inventory for spirit_vessel or spirit_vessel_filled
    ## If spirit_vessel: remove it, add spirit_vessel_filled, emit spring_filled
    ## If spirit_vessel_filled: flash "The vessel is already full."
    ## If neither: flash "You have nothing to hold the water in."
```

**F1 placement:** (256, 256) inside hidden alcove. A TreasureChest at
(224, 256) contains `spirit_vessel`. Both gated behind Wheel 1 water
zone (inaccessible until Wheel 1 HIGH).

### 4c. Spirit-Plant

**Files:** `game/scenes/entities/spirit_plant.tscn`,
`game/scripts/entities/spirit_plant.gd`

**Scene tree:**
```
SpiritPlant (StaticBody2D — blocks passage when unrestored)
├── Sprite2D (two states: wilted grey, restored blue-white)
├── CollisionShape2D (passage-blocking, disabled when restored)
└── InteractionArea (Area2D, collision layer 3)
    └── CollisionShape2D (12x12)
```

**Metadata:**
```
plant_id: "spirit_plant_1"
dungeon_id: "fenmothers_hollow"
```

**GDScript:**
```gdscript
signal plant_restored(plant_id: String)

func initialize(plant_id: String, dungeon_id: String) -> void
    ## Read {plant_id}_restored from puzzle_state
    ## Set visual + collision accordingly

func interact() -> void
    ## If already restored: dialogue "The spirit-plant glows..."
    ## If spirit_vessel_filled in key_items:
    ##   remove spirit_vessel_filled, add spirit_vessel (empty)
    ##   set puzzle_state {plant_id}_restored = true
    ##   tween sprite modulate grey → blue-white over 1.5s
    ##   disable StaticBody2D collision (passage opens)
    ##   emit plant_restored(plant_id)
    ## If no filled vessel: dialogue "The tendrils block the passage..."
```

**F2 placement:** (544, 160), replaces existing "SpiritPlant" dialogue
trigger. Blocks path to Drowned Sentinel until restored.

**Exploration.gd integration:**
- `_on_plant_restored(plant_id)`: push dialogue overlay with Torren/
  Maren/Lira restoration dialogue from `water_of_life.json`, flash
  location name "Passage Opened"

### Tests (~10)

- spring with vessel → swap to filled
- spring with filled vessel → no-op message
- spring without vessel → no-op message
- plant interact without vessel → blocked message
- plant interact with filled vessel → restores, swaps items
- plant collision disabled after restore
- plant visual changes on restore
- puzzle_state persists {plant_id}_restored
- re-initialize plant after restore → stays open
- signal emitted on restore

---

## Section 5: Poison Damage Zones

### Prefab

**Files:** `game/scenes/entities/damage_zone.tscn`,
`game/scripts/entities/damage_zone.gd`

**Scene tree:**
```
DamageZone (Area2D, collision layer 0 — overlaps, no blocking)
├── Sprite2D (dark purple rectangle, semi-transparent, pulse animation)
└── CollisionShape2D (sized per instance)
```

### Metadata

```
zone_id: "f2_corrupted_pool_1"
damage_per_tick: 8
tick_interval: 1.0
status_effect: "poison"
```

### GDScript

```gdscript
signal zone_damage_dealt(zone_id: String, total_damage: int)

func initialize(zone_id: String, damage_per_tick: int, tick_interval: float, status_effect: String) -> void

## body_entered → start Timer (tick_interval repeat)
## body_exited → stop Timer
## Each tick: damage active party members, clamp to min 1 HP
## First tick only: apply status_effect (if non-empty)
```

**HP clamp:** Environmental damage never kills. `current_hp` clamped
to minimum 1. Per difficulty-balance.md, environmental hazards create
pressure, not death.

### Placement

**F2 (3 static zones):**

| Position | Size | zone_id |
|----------|------|---------|
| (608, 192) | 96x48 | f2_corrupted_pool_east |
| (320, 480) | 160x32 | f2_polluted_channel_south |
| (64, 80) | 64x64 | f2_stagnant_corner |

**F3 (2 static zones):**

| Position | Size | zone_id |
|----------|------|---------|
| (176, 160) | 48x96 | f3_seepage_left |
| (368, 160) | 48x96 | f3_seepage_right |

**Boss phase spawning:** Between cleansing waves, `exploration.gd`
instantiates 1-2 additional DamageZone scenes at random positions in
the F3 arena. Maximum 4 spawned pools (capped). Spawned pools use
`damage_per_tick: 10`, `status_effect: ""` (no status, just damage).

**Boss arena bounds for random pool spawning:** F3 boss arena is
centered at (272, 208) with a radius of ~80 pixels. Valid spawn area:
x in [192, 352], y in [144, 272]. Exclude a 32px radius around the
player's last known position to prevent unavoidable damage.

### Tests (~6)

- damage on enter (tick fires)
- damage stops on exit
- HP clamped to minimum 1
- status applied on first tick only
- no damage after exit
- tick interval respected

---

## Section 6: Ritual Meter (Between-Battle)

### UI Overlay

**Files:** `game/scenes/ui/ritual_meter.tscn`,
`game/scripts/ui/ritual_meter.gd`

**Scene tree:**
```
RitualMeter (CanvasLayer, layer 11)
└── PanelContainer (FF6-style, top-center)
    └── VBoxContainer
        ├── Label ("Cleansing Ritual")
        ├── HBoxContainer
        │   └── ColorRect (meter bg, 200x12)
        │       └── ColorRect (meter fill, green→yellow→red)
        └── Label (status text)
```

### GDScript

```gdscript
var meter_value: float = 100.0

func show_meter() -> void
func hide_meter() -> void
func set_value(new_value: float) -> void  ## clamps 0-100, updates bar
func drain(amount: float) -> void
func recover(amount: float) -> void
func is_failed() -> bool  ## meter_value <= 0.0
```

### Drain Calculation (between waves)

**Simplification note:** The canonical design in dungeons-world.md
describes Torren as a targetable entity in the battle arena with
enemies draining the meter by attacking him in real-time. This is a
significant battle system change that is deferred. Instead, the meter
drains between waves based on post-battle performance metrics. This
preserves the ritual pressure feel without modifying the battle system.

```
base_drain     = 15 (constant per wave)
ko_penalty     = 10 x count of KO'd party members at wave end
turn_penalty   = 2 x max(0, turn_count - turn_threshold)
recovery       = 10 during wave 2 only (Fenmother cooperation)

total_drain = base_drain + ko_penalty + turn_penalty - recovery
```

**Turn thresholds per wave:** wave 1: 6, wave 2: 8, wave 3: 8, wave 4: 5

**Note:** Recovery can exceed drain in wave 2 if the player performs
well (few KOs, fast clear). In that case the meter increases between
waves 2 and 3. This is intentional — the Fenmother's cooperation
rewards skilled play.

### Failure Behavior

- Meter ≤ 0 between waves → failure dialogue
- Restart CURRENT wave only (not entire sequence)
- Meter resets to 25.0 on retry (not full — failure has cost)

### Battle Manager Changes

Add `_turn_counter: int = 0` to `battle_manager.gd`. Increment on
each combatant action. Add `get_turn_count() -> int`. Include
`"turn_count": _turn_counter` in victory transition data.

### Exploration.gd Integration

In cleansing sequence:
- `_start_cleansing_sequence()`: instantiate + show meter
- `_continue_cleansing_sequence()`: calculate drain, update meter.
  If `is_failed()`, show failure dialogue, re-launch same wave
  (don't increment wave_num). Spawn poison pools.
- `_complete_cleansing()`: hide + free meter

### Status Text

| meter_value | Text | Fill Color |
|-------------|------|------------|
| 75-100 | "The Fenmother's light holds steady..." | Green #44cc44 |
| 50-74 | "The ritual strains against the corruption..." | Yellow #cccc44 |
| 25-49 | "The ritual weakens... hold the line!" | Orange #cc8844 |
| 1-24 | "The Fenmother's light flickers dangerously!" | Red #cc4444 |
| 0 | "The corruption surges back!" | Red #cc4444 |

### Tests (~8)

- meter value clamping (0-100)
- drain reduces value
- recover increases value
- is_failed at 0
- not failed at 1
- drain calculation with KO penalty
- drain calculation with turn penalty
- retry resets to 25

---

## Section 7: Spirit-Path Walk Scene

### Map

**File:** `game/scenes/maps/dungeons/fenmothers_hollow_spirit_path.tscn`

**Dimensions:** 20x5 tiles (320x80 pixels)

**Tileset additions** (indices 14-17 on existing placeholder tileset):
- 14: Spirit water floor (translucent blue-white, walkable)
- 15: Luminous root wall (glowing root tendrils, top/bottom border)
- 16: Spirit water deep (darker blue, decorative, non-walkable)
- 17: Shrine stone (warm grey, exit-end transition tile)

### Scene Tree

```
SpiritPath (Node2D)
  metadata: location_name="Spirit Path", is_auto_walk=true
├── TileMapLayer (20x5)
├── Entities
│   ├── SpiritParticles1 (GPUParticles2D)
│   ├── SpiritParticles2 (GPUParticles2D)
│   └── SpiritParticles3 (GPUParticles2D)
├── Transitions
│   └── ShrineExit (Area2D → dungeons/duskfen_spirit_shrine)
└── PlayerSpawn (Marker2D at x=32, y=40)
```

### Auto-Walk Mechanic

`exploration.gd` detects `is_auto_walk` metadata on map load:
1. Disable player input: `_player.set_input_enabled(false)`
2. Set walk_east animation on player
3. Tween player position from spawn to ShrineExit over ~4 seconds
   (80 px/sec, matching normal walk speed)
4. When player reaches transition zone, normal fade + map load fires
5. Player input re-enabled after transition to next map

### Player Character Changes

```gdscript
var _input_enabled: bool = true

func set_input_enabled(enabled: bool) -> void:
    _input_enabled = enabled

## In _unhandled_input: early return if not _input_enabled
```

### Particle Effects

3x GPUParticles2D instances:
- 2x2 white pixel circular texture
- Emitting rightward with slight vertical wobble
- Lifetime 3.0s, 8-10 particles each
- Spread across tunnel length at y=20, y=40, y=60

### Tests (~4)

- auto-walk metadata detected
- input disabled during auto-walk
- transition fires at tunnel end
- input re-enabled after transition

---

## Section 8: Duskfen Spirit Shrine & Caden Sequence

### Map

**File:** `game/scenes/maps/dungeons/duskfen_spirit_shrine.tscn`

**Dimensions:** 16x12 tiles (256x192 pixels)

**Layout:**
```
████████████████
██    ████    ██
██  S       C ██
██            ██
██     ☆      ██
██            ██
██            ██
██████  ████████
██████ v ███████
████████████████
```

- S = Save point
- ☆ = Caden destination (center)
- C = Caden spawn (off-screen right, walks to center)
- v = Overworld exit (permanent shortcut)

### Scene Tree

```
DuskfenSpiritShrine (Node2D)
  metadata: location_name="Duskfen Spirit Shrine",
            auto_sequence="caden_binding",
            auto_sequence_flag="caden_binding_complete"
├── TileMapLayer (16x12, shrine stone + spirit water accent tiles)
├── Entities
│   ├── SavePoint (save_point_id="duskfen_shrine_save")
│   └── CadenPostEvent (NPC, npc_id="caden_duskfen",
│         visible only when caden_binding_complete flag set)
├── Transitions
│   └── OverworldExit (Area2D → overworld, spawn from_duskfen_shrine)
├── PlayerSpawn (Marker2D at top-center)
└── CadenSpawnPoint (Marker2D at off-screen right, x=288, y=80)
```

### Auto-Sequence: caden_binding

Triggered on first visit (flag `caden_binding_complete` NOT set):

1. Player spawns at top, input enabled, can walk around
2. 0.5s delay timer
3. Instantiate NPC scene at CadenSpawnPoint (288, 80)
4. Tween: fade alpha 0→1 over 0.5s simultaneously with walk to
   center (128, 80) over 1.5s
5. Push dialogue overlay with `caden_binding.json`
6. On dialogue complete:
   - Append `fenmothers_blessing` to key_items
   - Flash "Received Fenmother's Blessing!"
   - Set flag `caden_binding_complete`
   - Free the instantiated Caden NPC
   - Make CadenPostEvent NPC visible (permanent ambient NPC)

**F3 chest conflict resolution:** The F3 post-boss chest
(`fenmothers_hollow_blessing`) currently contains `fenmothers_blessing`.
Since Caden now gives this item in the shrine, the F3 chest is
**removed** from F3.tscn. The blessing acquisition is Caden-only.
This matches the dungeons-world.md narrative: "presented to Caden to
secure the alliance" — Caden is the giver, not a chest.

### Dialogue File

**File:** `game/data/dialogue/caden_binding.json`

```json
{
    "scene_id": "caden_binding",
    "entries": [
        {"id": "caden_binding_001", "speaker": "caden", "lines": ["I felt it through the water. The old channels are open", "again."], "condition": null, "animations": null, "choice": null, "sfx": null},
        {"id": "caden_binding_002", "speaker": "caden", "lines": ["She's free. Weakened, but free. The binding I'll place", "will protect her while she heals."], "condition": null, "animations": null, "choice": null, "sfx": null},
        {"id": "caden_binding_003", "speaker": "torren", "lines": ["You came all the way from the Duskfen?"], "condition": null, "animations": null, "choice": null, "sfx": null},
        {"id": "caden_binding_004", "speaker": "caden", "lines": ["The spirits carried me. They remember the paths even", "when the water forgets."], "condition": null, "animations": null, "choice": null, "sfx": null},
        {"id": "caden_binding_005", "speaker": "narrator", "lines": ["Caden kneels beside the shrine and traces a pattern in", "the water. Light follows his fingertips."], "condition": null, "animations": [{"who": "caden", "anim": "head_down", "when": "before_line_0"}], "choice": null, "sfx": null},
        {"id": "caden_binding_006", "speaker": "caden", "lines": ["It's done. Take this -- the Fenmother's Blessing. Her", "domain is yours to pass through freely."], "condition": null, "animations": null, "choice": null, "sfx": null},
        {"id": "caden_binding_007", "speaker": "edren", "lines": ["Thank you, Caden."], "condition": null, "animations": null, "choice": null, "sfx": null},
        {"id": "caden_binding_008", "speaker": "caden", "lines": ["Don't thank me. Thank her. She chose to trust you."], "condition": null, "animations": null, "choice": null, "sfx": null}
    ]
}
```

### Overworld Integration

Add transition on overworld near Thornmere Wetlands:
- New Area2D: `target_map: "dungeons/duskfen_spirit_shrine"`,
  `target_spawn: "from_overworld"`
- Add `from_overworld` Marker2D to shrine scene (bottom exit area)
- Add `from_duskfen_shrine` Marker2D to overworld

### On Revisit

Flag `caden_binding_complete` is set → auto-sequence skipped.
CadenPostEvent NPC is visible with ambient dialogue:
- "The Fenmother grows stronger each day. The water remembers."

### Tests (~6)

- auto-sequence fires on first visit
- auto-sequence skipped on revisit (flag set)
- blessing added to key_items
- flag set after dialogue
- Caden NPC visible on revisit
- overworld shortcut transition works

---

## Section 9: Exploration.gd Integration Summary

### New Entity Signal Handling

Add to `_initialize_entities()`:

```gdscript
## Water wheels
elif child.has_signal("wheel_toggled"):
    var wid: String = child.get_meta("wheel_id", "")
    var did: String = child.get_meta("dungeon_id", "")
    child.initialize(wid, did)

## Pure springs (no initialize needed)
elif child.has_signal("spring_filled"):
    pass  # signal connection only

## Spirit plants
elif child.has_signal("plant_restored"):
    var pid: String = child.get_meta("plant_id", "")
    var did: String = child.get_meta("dungeon_id", "")
    child.initialize(pid, did)

## Damage zones
elif child.has_signal("zone_damage_dealt"):
    var zid: String = child.get_meta("zone_id", "")
    var dpt: int = child.get_meta("damage_per_tick", 8)
    var ti: float = child.get_meta("tick_interval", 1.0)
    var se: String = child.get_meta("status_effect", "poison")
    child.initialize(zid, dpt, ti, se)
```

Add to `_connect_entity_signals()` / `_disconnect_entity_signals()`:
- `wheel_toggled` → `_on_wheel_toggled`
- `spring_filled` → `_on_spring_filled`
- `plant_restored` → `_on_plant_restored`
- `zone_damage_dealt` → `_on_zone_damage_dealt`

Also call `refresh()` on all water_zone entities during map init.

### Auto-Walk Detection

In `load_map()`, after entity setup:
```gdscript
if _current_map.get_meta("is_auto_walk", false):
    _start_auto_walk()
```

### Auto-Sequence Detection

In `load_map()`, after entity setup:
```gdscript
var seq_id: String = _current_map.get_meta("auto_sequence", "")
var seq_flag: String = _current_map.get_meta("auto_sequence_flag", "")
if not seq_id.is_empty() and not EventFlags.get_flag(seq_flag):
    _run_auto_sequence(seq_id)
```

### Cleansing Sequence Changes

**`_start_cleansing_sequence()`:** Instantiate ritual_meter, show it.

**`_continue_cleansing_sequence()`:**
1. Process battle rewards (existing)
2. Calculate ritual meter drain from transition_data (turn_count, KO count)
3. If meter failed: show failure dialogue, re-launch same wave
4. Spawn 1-2 poison pools in F3 arena (capped at 4 total)
5. Launch next wave (existing)

**`_complete_cleansing()`:**
1. Existing logic (restore Torren, set fenmother_cleansed flag)
2. Hide + free ritual meter
3. Load `dungeons/fenmothers_hollow_spirit_path` instead of staying on F3

### Battle Manager Changes

```gdscript
var _turn_counter: int = 0

## Reset in _start_battle or equivalent
## Increment on each combatant action

func get_turn_count() -> int:
    return _turn_counter

## In victory transition data:
"turn_count": _turn_counter
```

Also count KO'd party members for transition data:
```gdscript
"ko_count": _count_ko_party_members()
```

---

## Section 10: Modified Files Summary

### New Files (16)

| File | Purpose |
|------|---------|
| `game/scenes/entities/water_wheel.tscn` | Water wheel prefab |
| `game/scripts/entities/water_wheel.gd` | Water wheel logic |
| `game/scenes/entities/water_zone.tscn` | Water level zone prefab |
| `game/scripts/entities/water_zone.gd` | Water level zone logic |
| `game/scenes/entities/pure_spring.tscn` | Pure spring prefab |
| `game/scripts/entities/pure_spring.gd` | Pure spring logic |
| `game/scenes/entities/spirit_plant.tscn` | Spirit-plant prefab |
| `game/scripts/entities/spirit_plant.gd` | Spirit-plant logic |
| `game/scenes/entities/damage_zone.tscn` | Poison damage zone prefab |
| `game/scripts/entities/damage_zone.gd` | Poison damage zone logic |
| `game/scenes/ui/ritual_meter.tscn` | Ritual meter HUD |
| `game/scripts/ui/ritual_meter.gd` | Ritual meter logic |
| `game/scenes/maps/dungeons/fenmothers_hollow_spirit_path.tscn` | Spirit-path tunnel |
| `game/scenes/maps/dungeons/duskfen_spirit_shrine.tscn` | Shrine hub |
| `game/data/dialogue/caden_binding.json` | Caden binding dialogue |
| `game/tests/test_fenmother_puzzles.gd` | All Phase A2b tests (~53) |

### Modified Files (10)

| File | Changes |
|------|---------|
| `game/scripts/autoload/party_state.gd` | Add puzzle_state dict + API + save/load |
| `game/scripts/autoload/inventory_helpers.gd` | Add puzzle_state to build_save_dict |
| `game/scripts/autoload/save_manager.gd` | Add puzzle_state to _validate required keys |
| `game/scripts/core/exploration.gd` | New entity handlers, auto-walk, auto-sequence, cleansing changes |
| `game/scripts/entities/player_character.gd` | Add set_input_enabled |
| `game/scripts/combat/battle_manager.gd` | Add turn_counter + ko_count to victory data |
| `game/data/items/key_items.json` | Add spirit_vessel + spirit_vessel_filled |
| `game/scenes/maps/dungeons/fenmothers_hollow_f1.tscn` | Add wheels, spring, vessel chest, water zones, alcove geometry |
| `game/scenes/maps/dungeons/fenmothers_hollow_f2.tscn` | Replace dialogue trigger with spirit-plant, add wheel 3, water zones, damage zones |
| `game/scenes/maps/dungeons/fenmothers_hollow_f3.tscn` | Add damage zones, remove fenmothers_blessing chest (Caden gives it now) |

---

## What This Does NOT Include (Deferred)

- **Rising water timer mechanic** — Water wheel state changes are instant, no 10s flood timer
- **Air pocket breath timer** — Submerged corridor traversal with 30s breath limit
- **Collapsing ceiling debris** — Minor cosmetic damage on F1
- **Corrupted ley-crystal flares** — Periodic pulse damage on F3 (separate from poison pools)
- **Stone tablet hint system** — Pictographic puzzle hint near Wheel 1
- **Full NPC dialogue for water_of_life** — Maren conditional dialogue (if present) deferred
- **In-battle ritual meter** — Canonical design has Torren as targetable entity with real-time meter drain during combat. Implemented as between-battle performance-based drain instead (see Section 6 simplification note)
- **Art assets** — All sprites are placeholders (colored rectangles)
- **Audio integration** — SFX for wheel toggle, water drain, plant restoration
