# Game Systems Reference -- Pendulum of Despair

## Inspiration Games Quick Reference

| System | Primary Inspiration | Notes |
|--------|--------------------|----|
| Combat | Final Fantasy VI (ATB) | Multi-character, ability-based |
| Story pacing | Final Fantasy IV | Character-driven, cinematic scenes |
| Combo abilities | Chrono Trigger (Dual/Triple Techs) | Simplified version |
| Menu UI | Secret of Mana (ring menu) | Consider for item/ability selection |
| World map | Final Fantasy VI | Overworld + Mode 7 feel |
| Dialogue | Final Fantasy VI | Named speaker, portrait, iconic lines |

---

## Combat System

### Design Target: ATB-Style Turn-Based
Inspired by FF6's Active Time Battle system.

**Core loop:**
1. Each character and enemy has an ATB gauge that fills over time
2. When a gauge fills, that actor can act
3. Player selects action from a menu (Fight / Magic / Item / etc.)
4. Animations play, effects resolve, gauges reset

**Battle UI layout (inspired by FF6):**
```
[ Battle scene -- sprites on canvas ]
-------------------------------------
[ Action Menu ]    [ Party Status   ]
  > Fight            TERRA    210 ==
    Magic            EDGAR    185 ==
    Item             LOCKE    194 ==
```

**Character action menus (unique per character):**
- Each character has a unique "special" command slot (like FF6's Tools / Blitz / Magic)
- Always confirm with the user what each character's unique ability is before implementing

**Enemies:**
- Can have hidden steal-able items (FF6-style) -- flag to implement later
- Boss encounters get a pre-battle cutscene and unique music sting
- Some enemies are immune to certain elements (fire/ice/lightning/earth)

### Damage Formula (starting point -- adjust with user)
```
physical_damage = max(1, (attacker.atk * 4) - (defender.def * 2)) + random(-5, 5)
magic_damage    = max(1, (caster.mag * spell.power) - (target.mdef)) + random(-3, 3)
```

---

## Character System

### Stats
Each character tracks:
```json
{
  "name": "Terra",
  "level": 1,
  "hp": { "current": 210, "max": 210 },
  "mp": { "current": 80,  "max": 80  },
  "stats": {
    "strength": 28,
    "speed":    30,
    "stamina":  26,
    "magic":    42,
    "attack":   14,
    "defense":  12,
    "mdefense": 14,
    "evade":    5
  },
  "status": [],
  "equipment": { "weapon": null, "armor": null, "relic1": null, "relic2": null },
  "abilities": ["fight", "magic", "item"],
  "unique_command": "magic",
  "exp": 0,
  "next_level_exp": 32
}
```

### Leveling
- Simple EXP curve: `exp_to_next = floor(base * level^1.5)` where `base = 20`
- On level up: display message, animate, increase stats by small fixed amounts
- Confirm exact growth rates with user before implementing

### Status Effects (start with these, expand later)
| Status | Effect | Cure |
|--------|--------|------|
| Poison | Lose HP each turn | Antidote |
| Sleep  | Can't act, wake on damage | Alarm Clock |
| Muddle | Act randomly | Remedy |
| Stop   | ATB gauge frozen | Wears off |
| Stone  | Removed from battle | Soft |

---

## Save System

### Save State JSON Schema
```json
{
  "_comment": "Full game save state -- serialized and stored as a single JSON blob",
  "version": 1,
  "playtime_seconds": 3600,
  "location": {
    "map_id": "overworld",
    "x": 12,
    "y": 8,
    "facing": "south"
  },
  "party": ["terra", "edgar", "locke"],
  "characters": { },
  "inventory": {
    "items": [{ "id": "tonic", "qty": 5 }],
    "equipment": [],
    "key_items": []
  },
  "gil": 500,
  "world_flags": {
    "intro_complete": true,
    "met_locke": true,
    "south_figaro_locked": false
  },
  "espers": []
}
```

### Auto-save Triggers
Auto-save should fire on:
- Map transitions (entering/leaving any area)
- After every battle
- After key story flag changes
- Before any boss fight

### Manual Save Points
- Inns (staying at an inn saves + restores HP/MP)
- Save point objects on map (glowing crystals, campfires -- to be decided)

### New Game vs. Continue
On login:
1. Check if user has an existing save
2. If yes: show "Continue" (default) and "New Game" (with warning modal)
3. If no: go straight into new game intro

---

## Dialogue System

### Dialogue Box Spec
- Dark blue gradient background (see `tech-stack.md` for CSS)
- Speaker name displayed in yellow/gold at top left
- Text appears character-by-character (typewriter effect, ~40ms per char)
- Player presses confirm to advance or skip to end of current line
- Dialogue stored in JSON files under `packages/client/src/data/dialogue/`

### Dialogue JSON Format
```json
{
  "_comment": "Dialogue scripts. speaker: character id or null for narration.",
  "scene_intro_001": [
    { "speaker": null,    "text": "1000 years have passed since the War of the Magi..." },
    { "speaker": "terra", "text": "Wh... where am I?" },
    { "speaker": "locke", "text": "Easy. You're safe now." }
  ]
}
```

### Writing Style Guidelines
Dialogue should be punchy and memorable -- inspired by the best lines from the source games:
- **Kefka:** Manic, theatrical, menacing. Short bursts. ("Son of a submariner!")
- **Terra:** Quiet, searching, self-doubting. ("But I'm hardly... normal...")
- **Edgar:** Charming, slightly roguish. ("What man could refuse a lady?")
- **Locke:** Earnest, protective. Always "treasure hunter", never "thief."

Avoid exposition dumps. Break up long lore into multiple exchanges.

---

## Map System

### Tile Grid
- **Tile size:** 16x16 pixels (matches SNES sprite scale)
- **Map format:** Tiled JSON (`.tmj`) -- create maps in [Tiled Map Editor](https://www.mapeditor.org/)
- **Layers (minimum):**
  - `ground` -- walkable terrain
  - `decoration` -- trees, rocks, objects above ground
  - `collision` -- invisible layer marking impassable tiles
  - `events` -- trigger zones (NPC positions, doors, transitions)

### Encounter Design
Two options -- **confirm with user before implementing:**
- **Option A (Random):** Invisible step counter triggers battles -- classic FF feel
- **Option B (Visible):** Enemies visible on map, contact triggers battle -- more modern, less frustrating

### Overworld Map
- Uses a zoomed-out tileset for the world map (like FF6's overworld)
- Player character shrinks to "world scale" sprite when on overworld
- Towns and dungeons are entry points -- walking onto them triggers transition

---

## Aesthetic & Tone

### Visual Target
- 16x16 or 32x32 tile grid
- SNES color palette feel -- rich but constrained
- Parallax scrolling for battle backgrounds (Mode 7 homage)
- Screen-wipe transitions between scenes (classic RPG style)

### Music
- Chiptune/MIDI-style compositions
- Each area gets a distinct theme (town, dungeon, overworld, battle)
- Each major character gets a leitmotif that appears in their story scenes
- Boss battles get unique music distinct from regular battles
- Implementation: **Howler.js** for audio, or **Web Audio API** directly
- File format: `.ogg` (primary) + `.mp3` (fallback) for browser compatibility

### Boss Battle Checklist
Before implementing any boss encounter, confirm:
- [ ] Unique sprite designed?
- [ ] Pre-battle cutscene / dialogue written?
- [ ] Unique music track ready?
- [ ] Special mechanic (phase change, unique ability, gimmick)?
- [ ] Steal item defined?
- [ ] Post-battle reward / story beat written?
