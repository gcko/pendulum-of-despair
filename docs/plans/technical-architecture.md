# Technical Architecture

> Developer implementation reference for the Godot 4.6 project.
> Self-contained — everything needed to start building Pendulum of
> Despair in Godot, in one file.
>
> **Engine:** Godot 4.6+ (stable)
> **Language:** GDScript only (no C#, no .NET dependency)
> **Resolution:** 1280x720 viewport with 4x camera zoom (effective 320x180 game world), integer-scaled (per [accessibility.md](../story/accessibility.md))
> **Frame rate:** 60 fps locked
>
> **Cross-references:** [save-system.md](../story/save-system.md) |
> [audio.md](../story/audio.md) |
> [accessibility.md](../story/accessibility.md) |
> [combat-formulas.md](../story/combat-formulas.md) |
> [dialogue-system.md](../story/dialogue-system.md) |
> [bestiary/README.md](../story/bestiary/README.md) |
> [visual-style.md](../story/visual-style.md) |
> [gdd-overview.md](../story/gdd-overview.md)

---

## 1. Project Setup & Conventions

### 1.1 Directory Structure

```
res://
├── project.godot
├── scenes/                    # .tscn scene files
│   ├── core/                  # Core state scenes
│   │   ├── title.tscn
│   │   ├── exploration.tscn
│   │   └── battle.tscn
│   ├── overlay/               # Overlay state scenes
│   │   ├── menu.tscn
│   │   ├── dialogue.tscn
│   │   ├── save_load.tscn
│   │   ├── cutscene.tscn
│   │   └── shop_overlay.tscn
│   ├── entities/              # Reusable entity prefabs
│   │   ├── player_character.tscn
│   │   ├── npc.tscn
│   │   ├── enemy.tscn
│   │   ├── treasure_chest.tscn
│   │   ├── trigger_zone.tscn
│   │   └── save_point.tscn
│   └── maps/                  # Map scenes (dungeons, towns, overworld)
│       ├── overworld.tscn
│       ├── towns/
│       └── dungeons/
├── scripts/                   # .gd script files
│   ├── autoload/              # Autoload singletons
│   │   ├── game_manager.gd    # State machine, scene transitions
│   │   ├── data_manager.gd    # JSON data loading and caching
│   │   ├── audio_manager.gd   # Music, SFX, ambient (per audio.md)
│   │   ├── save_manager.gd    # Save/load, auto-save, migration
│   │   ├── event_flags.gd     # Global event flag state
│   │   └── party_state.gd     # Party composition, formation, stats
│   ├── core/                  # Core system scripts
│   ├── entities/              # Entity behavior scripts
│   ├── combat/                # Battle system scripts
│   ├── ui/                    # Menu and HUD scripts
│   └── util/                  # Utility functions
├── data/                      # JSON game data (source of truth)
│   ├── enemies/               # Per-act enemy stat tables
│   ├── items/                 # Consumables, materials, key items
│   ├── equipment/             # Weapons, armor, accessories
│   ├── shops/                 # Per-town shop inventories
│   ├── dialogue/              # NPC and scene dialogue trees
│   ├── encounters/            # Per-dungeon encounter tables
│   ├── spells/                # Per-tradition spell definitions
│   ├── crafting/              # Device definitions, forging recipes
│   ├── characters/            # Party member base stats, growth
│   └── config/                # Default settings, constants
├── assets/                    # Art and audio assets
│   ├── sprites/               # Character, enemy, NPC sprites
│   ├── tilesets/              # 16x16 tile PNGs
│   ├── ui/                    # Menu backgrounds, windows, icons
│   ├── music/                 # OGG music tracks
│   ├── sfx/                   # OGG sound effects
│   └── ambient/               # OGG ambient loops
└── export/                    # Export presets (gitignored)
```

### 1.2 Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Files (scripts, scenes) | snake_case | `treasure_chest.tscn`, `audio_manager.gd` |
| Directories | snake_case | `res://scripts/autoload/` |
| GDScript classes | PascalCase | `class_name TreasureChest` |
| Functions | snake_case | `func open_chest()` |
| Signals | snake_case, past tense | `signal chest_opened` |
| Constants | UPPER_SNAKE_CASE | `const MAX_PARTY_SIZE = 4` |
| JSON keys | snake_case | `"atk_growth": 3` |
| Asset files | snake_case with category prefix | `sfx_hit_physical.ogg`, `music_valdris_overworld.ogg` |

### 1.3 Autoload Singletons

Six persistent managers, always available via global name:

| Singleton | Global Name | Responsibility |
|-----------|-------------|---------------|
| `game_manager.gd` | `GameManager` | State machine, scene transitions, pause state |
| `data_manager.gd` | `DataManager` | Load/cache JSON data, provide typed accessors. Validates JSON on load — malformed files trigger a fatal error with file path in the console (game data is not user-editable, so corruption means a broken build). |
| `audio_manager.gd` | `AudioManager` | Music, SFX, ambient per [audio.md](../story/audio.md) rules |
| `save_manager.gd` | `SaveManager` | Save/load, auto-save, migration per [save-system.md](../story/save-system.md) |
| `event_flags.gd` | `EventFlags` | Global event flag dictionary, flag checks |
| `party_state.gd` | `PartyState` | Party composition, formation, character stats |

### 1.4 Viewport Settings

```
# project.godot
[display]
window/size/viewport_width = 1280
window/size/viewport_height = 720
window/size/window_width_override = 1920
window/size/window_height_override = 1080
window/stretch/mode = "viewport"
window/stretch/aspect = "keep"
window/stretch/scale_mode="integer"

[rendering]
textures/canvas_textures/default_texture_filter = 0  # Nearest
2d/snap/snap_2d_transforms_to_pixel = true
2d/snap/snap_2d_vertices_to_pixel = true
```

---

## 2. Data Format Specifications

All game data lives in `res://data/` as JSON files. Design doc tables
are the source of truth; JSON files are the runtime representation.

**Key naming convention:** All JSON keys use `snake_case` (matching
GDScript convention). This applies to all JSON files — game data,
save files, and the pseudo-schema in
[save-system.md](../story/save-system.md) alike.

### 2.1 Enemy Data

**Source:** [bestiary/](../story/bestiary/) act-i.md through optional.md
**File:** `res://data/enemies/{act}.json` (one per act)

```json
{
  "enemies": [
    {
      "id": "ley_vermin",
      "name": "Ley Vermin",
      "type": "beast",
      "level": 1,
      "hp": 23,
      "mp": 0,
      "atk": 8,
      "def": 6,
      "mag": 7,
      "mdef": 5,
      "spd": 8,
      "gold": 1,
      "exp": 4,
      "weaknesses": [],
      "resistances": [],
      "absorb": [],
      "status_immunities": [],
      "steal": {
        "common": { "item_id": "beast_hide", "rate": 75 },
        "rare": { "item_id": "sharp_fang", "rate": 25 }
      },
      "drop": { "item_id": "sharp_fang", "rate": 25 },
      "ko_sound": "ko_beast"
    }
  ]
}
```

### 2.2 Item Data

**Source:** items.md
**File:** `res://data/items/consumables.json`, `materials.json`, `key_items.json`

```json
{
  "items": [
    {
      "id": "potion",
      "name": "Potion",
      "category": "consumable",
      "subcategory": "hp_healing",
      "effect": "restore_hp",
      "value": 100,
      "buy_price": 50,
      "sell_price": 25,
      "stack_limit": 199,
      "description": "Restores 100 HP to one ally.",
      "target": "single_ally",
      "usable_in_battle": true,
      "usable_in_field": true
    }
  ]
}
```

### 2.3 Equipment Data

**Source:** equipment.md
**Files:** `res://data/equipment/weapons.json`, `armor.json`, `accessories.json`

```json
{
  "weapons": [
    {
      "id": "training_sword",
      "name": "Training Sword",
      "type": "sword",
      "tier": 0,
      "equippable_by": ["edren"],
      "atk": 4,
      "def": 0,
      "mag": 0,
      "mdef": 0,
      "spd": 0,
      "element": null,
      "special": null,
      "buy_price": null,
      "sell_price": null
    }
  ]
}
```

### 2.4 Shop Data

**Source:** economy.md
**File:** `res://data/shops/{town}.json`

```json
{
  "shop": {
    "shop_id": "valdris_crown_general",
    "town": "valdris_crown",
    "type": "general",
    "markup": 1.0,
    "inventory": [
      { "item_id": "potion", "buy_price": 50, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "hi_potion", "buy_price": 300, "available_act": 2, "stock_limit": null, "restock_event": null },
      { "item_id": "antidote", "buy_price": 50, "available_act": 1, "stock_limit": null, "restock_event": null }
    ]
  }
}
```

### 2.5 Dialogue Data

**Source:** [dialogue-system.md](../story/dialogue-system.md), script/
**File:** `res://data/dialogue/{scene_id}.json`

```json
{
  "scene_id": "act1_ember_vein_intro",
  "entries": [
    {
      "id": "ember_vein_001",
      "speaker": "edren",
      "lines": ["Something is wrong down here.", "The miners... they look frozen."],
      "condition": null,
      "animations": [
        { "who": "edren", "anim": "look_around", "when": "before_line_0" }
      ],
      "choice": null,
      "sfx": [
        { "line": 1, "id": "ley_surge" }
      ]
    },
    {
      "id": "ember_vein_002",
      "speaker": "cael",
      "lines": ["I can feel something pulling at the ley lines. Like a knot tightening."],
      "condition": "party_has(cael)",
      "animations": null,
      "choice": null,
      "sfx": null
    }
  ]
}
```

Uses [dialogue-system.md](../story/dialogue-system.md) Section 4.1's
canonical 7-field entry format (id, speaker, lines, condition,
animations, choice, sfx). The `condition` field supports flag
expressions and `party_has()` checks for party-aware dialogue.

### 2.6 Encounter Data

**Source:** dungeons-world.md, [combat-formulas.md](../story/combat-formulas.md)
**File:** `res://data/encounters/{dungeon}.json`

```json
{
  "dungeon_id": "ember_vein",
  "floors": [
    {
      "floor": "1-2",
      "danger_increment": 120,
      "groups": [
        {
          "enemies": ["ley_vermin", "ley_vermin", "unstable_crystal"],
          "weight": 31.25
        },
        {
          "enemies": ["ley_vermin", "ley_vermin", "ley_vermin"],
          "weight": 31.25
        },
        {
          "enemies": ["unstable_crystal", "unstable_crystal"],
          "weight": 31.25
        },
        {
          "enemies": ["ley_vermin", "ley_vermin", "ley_vermin", "ley_vermin", "unstable_crystal"],
          "weight": 6.25
        }
      ],
      "back_attack_rate": 12.5,
      "preemptive_rate": 12.5
    }
  ]
}
```

### 2.7 Spell Data

**Source:** [magic.md](../story/magic.md)
**File:** `res://data/spells/{tradition}.json`

```json
{
  "spells": [
    {
      "id": "ember_lance",
      "name": "Ember Lance",
      "tradition": "forgewright",
      "element": "flame",
      "category": "offensive",
      "tier": 1,
      "power": 14,
      "mp_cost": 4,
      "target": "single_enemy",
      "learned_by": [
        { "character": "maren", "level": 1 },
        { "character": "lira", "level": 5 },
        { "character": "cael", "level": 1 }
      ]
    }
  ]
}
```

### 2.8 Crafting Data

**Source:** [crafting.md](../story/crafting.md)
**Files:** `res://data/crafting/devices.json`, `recipes.json`

**Device definitions** (pre-crafted field devices):

```json
{
  "devices": [
    {
      "id": "thermal_charge",
      "name": "Thermal Charge",
      "tier": "basic",
      "ac_cost": 1,
      "category": "offensive",
      "effect": "Flame AoE: 400 dmg",
      "charges": 3,
      "unlock_phase": "act_1"
    }
  ]
}
```

**Forging recipes** (equipment forging at forge locations):

```json
{
  "recipes": [
    {
      "id": "arcanite_blade",
      "name": "Arcanite Blade",
      "result_item": "arcanite_blade",
      "materials": [
        { "item_id": "arcanite_ingot", "quantity": 1 },
        { "item_id": "crystal_shard", "quantity": 3 }
      ],
      "gold_fee": 500,
      "forge_location": ["ashmark", "caldera", "lira_workshop"],
      "unlock_phase": "interlude"
    }
  ]
}
```

### Future Data Format Sections

The following game systems need JSON schemas but are deferred to
implementation time (the design docs are complete, but the data
structures are complex enough to warrant separate design work):

- **Ability data** — 6 unique command systems per
  [abilities.md](../story/abilities.md) (Bulwark, Rally, Forgewright,
  Spiritcall, Tricks, Arcanum) with sub-abilities, costs, and effects
- **Boss AI scripts** — conditional priority lists, mode/stance
  systems, phase transitions, counter tables per
  [bestiary/bosses.md](../story/bestiary/bosses.md) (31 bosses)

**Note on steal schema:** The enemy JSON uses a single `steal` field
(one item + rate) matching the bestiary's single-column format.
[abilities.md](../story/abilities.md) describes Sable's Filch as
having "common and rare steal" — if a two-tier steal system is
implemented, the enemy JSON should be extended with `steal_common` and
`steal_rare` fields.

### 2.9 Event Flags

**Source:** events.md (58 numbered flags + parameterized `boss_cutscene_seen_*`)
**File:** `res://scripts/autoload/event_flags.gd`

Event flags are managed in the `EventFlags` autoload singleton, not in
JSON. The singleton provides typed accessors:

```gdscript
# event_flags.gd
var flags: Dictionary = {}

func set_flag(flag_name: String, value: Variant) -> void:
    flags[flag_name] = value

func get_flag(flag_name: String, default: Variant = false) -> Variant:
    return flags.get(flag_name, default)

func has_flag(flag_name: String) -> bool:
    return flags.has(flag_name)
```

Flags are serialized as part of save data (`world.event_flags` in
[save-system.md](../story/save-system.md) Section 3.6).

### 2.10 Character Data

**Source:** characters.md, progression.md
**File:** `res://data/characters/{character_id}.json`

```json
{
  "id": "edren",
  "name": "Edren",
  "role": "knight_commander",
  "base_stats": {
    "hp": 95, "mp": 15,
    "atk": 18, "def": 16,
    "mag": 6, "mdef": 8,
    "spd": 10, "lck": 8
  },
  "growth": {
    "hp": 85, "mp": 3,
    "atk": 1.8, "def": 1.6,
    "mag": 0.5, "mdef": 0.7,
    "spd": 0.8, "lck": 0.6
  },
  "default_row": "front",
  "weapon_type": "sword",
  "equipment_slots": ["weapon", "head", "body", "accessory", "ley_crystal"]
}
```

---

## 3. Game State Machine

### 3.1 State Types

**Core states** (full scene swap — only one active at a time):

| State | Scene | Description |
|-------|-------|-------------|
| Title | `scenes/core/title.tscn` | Title screen, new game, load game |
| Exploration | `scenes/core/exploration.tscn` | Overworld, towns, dungeons |
| Battle | `scenes/core/battle.tscn` | ATB combat |

**Overlay states** (additive layer — pause core state underneath):

| State | Scene | Description |
|-------|-------|-------------|
| Menu | `scenes/overlay/menu.tscn` | Main menu (items, equipment, status, etc.) |
| Dialogue | `scenes/overlay/dialogue.tscn` | NPC/story dialogue with text box |
| Save/Load | `scenes/overlay/save_load.tscn` | Save point 3-option menu, save/load screens |
| Cutscene | `scenes/overlay/cutscene.tscn` | Scripted narrative sequences |

### 3.2 Transition Rules

| From | To | Trigger | Type |
|------|----|---------|------|
| Title | Exploration | New Game or Load Game | Core swap |
| Exploration | Battle | Encounter trigger (danger counter) | Core swap |
| Battle | Exploration | Victory / Flee | Core swap (reload map) |
| Battle | Exploration | Faint-and-Fast-Reload | Core swap (load save, merge XP/gold) |
| Exploration | Exploration | Map transition (door, dungeon exit) | Map swap within core |
| Any core | Menu | Menu button press | Overlay add |
| Menu | Previous core | Cancel / close | Overlay remove |
| Exploration | Dialogue | NPC interact / story trigger | Overlay add |
| Dialogue | Exploration | Dialogue ends | Overlay remove |
| Exploration | Save/Load | Save point interact | Overlay add |
| Save/Load | Exploration | Save complete / cancel | Overlay remove |
| Any core | Cutscene | Event flag trigger | Overlay add |
| Cutscene | Previous core | Cutscene ends | Overlay remove |

### 3.3 Transition Data

Core state transitions pass context via a `data` dictionary stored on
`GameManager`. The receiving scene reads it on `_ready()`:

| Transition | Data Keys | Description |
|------------|-----------|-------------|
| Exploration -> Battle | `encounter_group`, `formation_type`, `is_boss` | Enemy IDs, back-attack/preemptive, boss flag |
| Battle -> Exploration | `result`, `map_id`, `position` | victory/flee/faint, return location |
| Title -> Exploration | `save_slot` or `new_game` | Which save to load, or fresh start |

### 3.4 Overlay Stacking

Only one overlay at a time. If a second overlay is requested while one
is active, the request is **rejected** (returns false). Exceptions:

- Cutscene can force-close dialogue (cutscene takes priority)
- No other overlay can open during a cutscene

The calling code must check the return value of `push_overlay()`.

### 3.5 GameManager Implementation

```gdscript
# game_manager.gd (Autoload)
enum CoreState { TITLE, EXPLORATION, BATTLE }
enum OverlayState { NONE, MENU, DIALOGUE, SAVE_LOAD, CUTSCENE, SHOP }

var current_core: CoreState = CoreState.TITLE
var current_overlay: OverlayState = OverlayState.NONE
var overlay_node: Node = null

func change_core_state(new_state: CoreState, data: Dictionary = {}) -> void:
    # Full scene swap
    current_overlay = OverlayState.NONE
    current_core = new_state
    match new_state:
        CoreState.TITLE:
            get_tree().change_scene_to_file("res://scenes/core/title.tscn")
        CoreState.EXPLORATION:
            get_tree().change_scene_to_file("res://scenes/core/exploration.tscn")
        CoreState.BATTLE:
            get_tree().change_scene_to_file("res://scenes/core/battle.tscn")

func push_overlay(state: OverlayState) -> bool:
    # Reject if overlay already active (except cutscene overriding dialogue)
    if current_overlay != OverlayState.NONE:
        if state == OverlayState.CUTSCENE and current_overlay == OverlayState.DIALOGUE:
            pop_overlay()  # Cutscene takes priority over dialogue
        else:
            return false
    # Add overlay scene on top, pause core underneath
    get_tree().paused = true
    current_overlay = state
    var scene_path = _overlay_scene_path(state)
    var scene = load(scene_path).instantiate()
    scene.process_mode = Node.PROCESS_MODE_ALWAYS
    get_tree().root.add_child(scene)
    overlay_node = scene
    return true

func pop_overlay(silent: bool = false) -> void:
    # Remove overlay, unpause core
    if overlay_node:
        overlay_node.queue_free()
        overlay_node = null
    current_overlay = OverlayState.NONE
    if not silent:
        overlay_state_changed.emit(OverlayState.NONE)
    get_tree().paused = false
```

---

## 4. Entity Architecture

### 4.1 Design Principle

Godot-native scene composition. Each entity type is a `.tscn` prefab
file composed of standard Godot nodes with an attached GDScript. No
custom component system — Godot's scene tree IS the component system.

### 4.2 Entity Types

**PlayerCharacter** (`scenes/entities/player_character.tscn`):
```
PlayerCharacter (CharacterBody2D)
├── Sprite2D (character sprite, 16x24 or 16x16)
├── CollisionShape2D (movement collision)
├── AnimationPlayer (walk cycle, idle, interact)
└── player_character.gd
    -> loads character data from JSON
    -> handles movement input
    -> emits signals for interaction
```

**NPC** (`scenes/entities/npc.tscn`):
```
NPC (Area2D)
├── Sprite2D (NPC sprite)
├── CollisionShape2D (interaction zone)
├── AnimationPlayer (idle, emotion animations per dialogue-system.md)
└── npc.gd
    -> loads dialogue from JSON via DataManager
    -> on interact: emits npc_interacted signal (exploration handles overlay)
    -> flag-gated dialogue (checks EventFlags)
```

**Enemy** (`scenes/entities/enemy.tscn` — instantiated at runtime by battle scene):
```
Enemy (Node2D)
├── Sprite2D (enemy sprite)
├── AnimationPlayer (idle, hit, death)
└── enemy.gd
    -> loaded from JSON enemy data
    -> holds runtime HP/MP/status
    -> AI behavior (weighted random per bestiary)
```

**TreasureChest** (`scenes/entities/treasure_chest.tscn`):
```
TreasureChest (Area2D)
├── Sprite2D (closed/open frames)
├── CollisionShape2D (interaction zone)
└── treasure_chest.gd
    -> chest_id for save tracking
    -> on interact: check EventFlags, give item, set flag
```

**TriggerZone** (`scenes/entities/trigger_zone.tscn`):
```
TriggerZone (Area2D)
├── CollisionShape2D (trigger area)
└── trigger_zone.gd
    -> event_flag condition check
    -> on body entered: emit signal, set flags
    -> used for: story triggers, boss rooms, area transitions
```

**SavePoint** (`scenes/entities/save_point.tscn`):
```
SavePoint (Area2D)
├── Sprite2D (ley crystal, 2-frame shimmer)
├── CollisionShape2D (interaction zone)
├── AnimationPlayer (shimmer cycle)
└── save_point.gd
    -> on interact: GameManager.push_overlay(SAVE_LOAD)
    -> plays save_point_chime SFX on proximity
```

---

## 5. Asset Pipeline

### 5.1 Tilesets

- **Tile size:** 16x16 pixels (per [visual-style.md](../story/visual-style.md))
- **Format:** PNG, indexed color (256 colors max per scene)
- **Naming:** `tileset_{biome}.png` (e.g., `tileset_valdris_highlands.png`)
- **Godot import:** TileSet resource with TileMapLayer nodes
- **Import settings:** Filter = Nearest, no mipmaps, no compression

### 5.2 Sprite Sheets

| Type | Frame Size | Format | Naming |
|------|-----------|--------|--------|
| Character (walk) | 16x24 | PNG strip | `sprite_{character}_{direction}.png` |
| Character (battle) | 32x32 | PNG strip | `battle_{character}_{action}.png` |
| Enemy (battle) | varies (32x32 to 64x64) | PNG strip | `enemy_{id}_{action}.png` |
| NPC | 16x24 | PNG strip | `npc_{id}_{direction}.png` |
| UI elements | varies | PNG atlas | `ui_{element}.png` |
| Status icons | 8x8 | PNG atlas | `status_icons.png` |

**Animation data:** SpriteFrames resource in Godot, configured per
entity scene. Frame timing matches SNES conventions (8-12 fps walk
cycle, 15-20 fps battle animations).

### 5.3 Audio Assets

Per [audio.md](../story/audio.md) Section 3.1 — 24 channels total
(8 music / 12 SFX / 4 ambient):

| Type | Format | Sample Rate | Bit Depth | Naming |
|------|--------|-------------|-----------|--------|
| Music | OGG Vorbis | 44.1 kHz | 16-bit | `music_{context}_{name}.ogg` |
| SFX | OGG Vorbis | 44.1 kHz | 16-bit | `sfx_{category}_{name}.ogg` |
| Ambient | OGG Vorbis | 44.1 kHz | 16-bit | `ambient_{biome}.ogg` |

**Godot import settings:** Loop mode set per track in import dialog.
Music and ambient loop seamlessly. SFX do not loop (except specified
jingles).

### 5.4 Pixel Art Import Settings

All sprite and tileset imports must use:
```
# .import file settings (auto-generated by Godot)
[params]
compress/mode = 0          # Lossless
compress/hdr_compression = 0
mipmaps/generate = false
roughness/mode = 0
process/fix_alpha_border = false
process/premult_alpha = false
detect_3d/compress_to = 0  # Disabled
```

These prevent Godot from applying filtering, compression, or mipmap
generation that would blur pixel art.

---

## 6. Persistence Interface

> Replaces the "Server API contract" checklist item from the original
> gap analysis. The game is single-player local (Godot desktop) — no
> server, no auth endpoints, no network API. All persistence uses local
> file I/O via Godot's `FileAccess` class.

### 6.1 File Location

```
user://
├── saves/
│   ├── slot_1.json          # Manual save slot 1
│   ├── slot_2.json          # Manual save slot 2
│   ├── slot_3.json          # Manual save slot 3
│   └── auto.json            # Auto-save slot
└── config.json              # Global config (separate from saves)
```

`user://` maps to the OS-specific user data directory:
- Windows: `%APPDATA%/Godot/app_userdata/Pendulum of Despair/`
- macOS: `~/Library/Application Support/Godot/app_userdata/Pendulum of Despair/`
- Linux: `~/.local/share/godot/app_userdata/Pendulum of Despair/`

### 6.2 Save File Format

JSON matching [save-system.md](../story/save-system.md) Section 3
schema (10 groups):

```json
{
  "meta": {
    "version": 1,
    "playtime": 3600,
    "saved_at": "2026-03-31T12:00:00Z",
    "slot_type": "manual"
  },
  "party": [],
  "formation": { "active": [], "reserve": [], "rows": {} },
  "inventory": { "consumables": {}, "materials": {}, "key_items": [] },
  "owned_equipment": [],
  "crafting": { "arcanite_charges": 12, "device_loadout": [], "discovered_synergies": [], "unlocked_recipes": [] },
  "ley_crystals": { "collected": [] },
  "world": { "event_flags": {}, "act": "1", "current_location": "...", "current_position": { "x": 0, "y": 0 }, "gold": 0 },
  "quests": { "active": [], "completed": [] },
  "completion": { "bestiary": [], "treasures": [], "items_found": [] }
}
```

### 6.3 SaveManager Implementation

```gdscript
# save_manager.gd (Autoload)
const CURRENT_SAVE_VERSION = 1
const SAVE_DIR = "user://saves/"
const CONFIG_PATH = "user://config.json"

func save_game(slot: int) -> bool:
    var data = _build_save_data()
    data.meta.version = CURRENT_SAVE_VERSION
    data.meta.saved_at = Time.get_datetime_string_from_system()
    data.meta.slot_type = "manual" if slot <= 3 else "auto"

    var path = _slot_path(slot)
    var file = FileAccess.open(path, FileAccess.WRITE)
    if not file:
        return false
    file.store_string(JSON.stringify(data, "\t"))
    file.close()
    return true

func load_game(slot: int) -> Dictionary:
    var path = _slot_path(slot)
    if not FileAccess.file_exists(path):
        return {}
    var file = FileAccess.open(path, FileAccess.READ)
    var json = JSON.new()
    var result = json.parse(file.get_as_text())
    file.close()
    if result != OK:
        return {"error": "corrupted"}
    var data = json.data
    data = _migrate(data)
    if not _validate(data):
        return {"error": "invalid"}
    return data

func _migrate(data: Dictionary) -> Dictionary:
    var version = data.get("meta", {}).get("version", 0)
    while version < CURRENT_SAVE_VERSION:
        data = _migration_steps[version].call(data)
        version += 1
    data.meta.version = CURRENT_SAVE_VERSION
    return data

func _validate(data: Dictionary) -> bool:
    # Check required top-level keys exist
    var required = ["meta", "party", "formation", "inventory", "owned_equipment",
                    "crafting", "ley_crystals", "world", "quests", "completion"]
    for key in required:
        if not data.has(key):
            return false
    return true

func _slot_path(slot: int) -> String:
    if slot == 0:
        return SAVE_DIR + "auto.json"
    return SAVE_DIR + "slot_%d.json" % slot
```

### 6.4 Auto-Save

Per [save-system.md](../story/save-system.md) Section 6, auto-save
fires silently on:
1. Entering a new dungeon floor
2. Entering a boss trigger zone
3. Entering a new town
4. Completing a sidequest

```gdscript
# Called by exploration scene on relevant transitions
func auto_save() -> void:
    save_game(0)  # Slot 0 = auto-save
```

### 6.5 Faint-and-Fast-Reload

Per [save-system.md](../story/save-system.md) Section 7, on party wipe:

```gdscript
func faint_and_fast_reload() -> void:
    # 1. Capture death-persistent values from current game state
    var preserved_xp = _capture_party_xp()
    var preserved_gold = _capture_gold()
    var preserved_flags = _capture_boss_cutscene_flags()

    # 2. Load most recent save (manual or auto, whichever newer)
    var data = _load_most_recent_save()

    # 3. Merge death-persistent values
    _merge_xp(data, preserved_xp)
    data.world.gold = preserved_gold
    _merge_flags(data, preserved_flags)

    # 4. Process level-ups from accumulated XP
    _process_level_ups(data)

    # 5. Set HP/MP to 100%, clear ailments
    _full_restore(data)

    # 6. Write merged state back to save file
    _write_save(data)

    # 7. Load the merged save
    _apply_save_data(data)
    GameManager.change_core_state(GameManager.CoreState.EXPLORATION)
```

### 6.6 Global Config

Separate from saves per [save-system.md](../story/save-system.md)
Section 2. All 17 settings per
[accessibility.md](../story/accessibility.md) Section 7:

```json
{
  "battle_speed": 3,
  "atb_mode": "active",
  "text_speed": "normal",
  "battle_cursor": "reset",
  "window_color": { "r": 0, "g": 0, "b": 8 },
  "sound_mode": "stereo",
  "music_volume": 8,
  "sfx_volume": 8,
  "screen_shake": true,
  "mode7_intensity": 6,
  "patience_mode": false,
  "color_blind_mode": "off",
  "high_res_text": false,
  "reduce_motion": false,
  "flash_intensity": "full",
  "transition_style": "classic",
  "sfx_captions": false
}
```

---

## 7. Performance Budgets

### Runtime Budgets

| Budget | Value | Rationale |
|--------|-------|-----------|
| Frame rate | 60 fps (locked) | ATB ticks at 60/s per [combat-formulas.md](../story/combat-formulas.md) |
| Max entities per exploration scene | 64 | NPCs + chests + triggers + decorations |
| Max enemies per battle | 6 | Per [bestiary/README.md](../story/bestiary/README.md) encounter groups |
| Max simultaneous particle emitters | 16 | Battle effects + corruption + ambient |
| Audio channels | 24 | Per [audio.md](../story/audio.md) (8 music / 12 SFX / 4 ambient) |
| Max tilemap layers | 4 | Ground, decoration, overlay, collision |
| Scene load time | <1 second | For core state transitions |
| Save file size | <256 KB | Per [save-system.md](../story/save-system.md) Section 11 |
| Max active overlay scenes | 1 | Only one overlay at a time |

### Memory Budgets Per Scene Type (approximate)

| Scene Type | Tilemap | Sprites | JSON Data | Audio | Total Estimate |
|------------|---------|---------|-----------|-------|----------------|
| Overworld | 1 large map | ~10 NPC sprites | encounter tables | 1 music + 1 ambient | ~20-30 MB |
| Town | 1-3 screens | ~20 NPC sprites | dialogue, shop data | 1 music + 1 ambient | ~15-25 MB |
| Dungeon floor | 1 map | ~10 entities | encounters, chests | 1 music + 1 ambient | ~15-20 MB |
| Battle | no tilemap | 4 party + 6 enemy | enemy stats, abilities | 1 music | ~10-15 MB |
| Menu overlay | no tilemap | UI sprites | inventory, equipment | none (music continues) | ~5-10 MB |

These are generous estimates for a pixel-art game (1280x720 viewport, 4x zoom). Modern
hardware has 8-16 GB RAM — memory is not a constraint for this project.
The budgets exist to catch accidental asset bloat (e.g., uncompressed
textures, unoptimized spritesheets).

These are ceilings, not targets. If a scene works with 20 entities,
don't add more because the budget allows 64.
