# Game Design Document -- Pendulum of Despair

> **Version:** 1.0 | **Status:** 24 of 25 design gaps complete (4.5 Localization deferred)
>
> This document is the entry point to the game's design. Page 1 is the
> pitch. Pages 2--3 are the developer reference. Every number is
> cross-referenced to its source doc. Nothing here is invented --
> everything links deeper.

---

## Page 1 -- The Pitch

### Elevator Pitch

Pendulum of Despair is a single-player JRPG built with Godot Engine,
inspired by the golden age of 16-bit RPGs (Final Fantasy IV/VI, Chrono
Trigger, Secret of Mana). Six heroes investigate a mysterious artifact
called the Pendulum, only to discover it is a conduit for an abstract
cosmic force of Despair -- the Pallor. When Cael, the deuteragonist and
Edren's closest friend, falls under its influence and steals the
Pendulum, the party must confront a truth that cannot be fought with
swords: Despair is overcome through acceptance, not resistance.

### Genre & Platform

- **Genre:** Single-player JRPG with ATB combat
- **Engine:** Godot Engine 4.x
- **Platform:** Desktop (Windows, macOS, Linux)
- **Resolution:** 320x180 native, integer-scaled (pixel art)

### Design Pillars

1. **SNES soul, modern comfort** -- pixel art aesthetic and ATB combat
   with quality-of-life features (auto-save, fast reload, accessibility
   options) that SNES games lacked.
2. **Narrative-driven systems** -- every mechanic serves the story. The
   Pallor desaturates the world visually. Arcanite Forging reflects
   industrial exploitation. Ley Crystals embody the old world's fading
   power.
3. **Accessible depth** -- one fixed difficulty, beatable by anyone who
   engages with the systems. Optional post-game content (Dreamer's
   Fault, boss rush) for players who want challenge.
4. **Interlinked design** -- equipment affects stats affects damage
   affects encounter difficulty affects economy. No system exists in
   isolation.

### Target Audience

- **Age range:** 13+ (ESRB T equivalent -- themes of grief, sacrifice,
  betrayal; no graphic violence or sexual content)
- **Genre familiarity:** Players who grew up with or enjoy SNES-era
  JRPGs. Also targets modern indie RPG fans.
- **Comparable titles:** Final Fantasy VI (ATB combat, ensemble cast,
  world-in-ruin), Chrono Trigger (party-aware dialogue), Sea of Stars
  (modern retro JRPG, pixel art at higher resolution)

### Thematic Core

"Acceptance over victory." The Pendulum is a MacGuffin with no real
power. The true antagonist is Despair itself, embodied as the Pallor --
a cosmic presence that feeds on unresolved grief. The game's emotional
arc is told through color: the world desaturates from warm to grey as
the Pallor spreads. The epilogue introduces new colors -- not the old
ones restored, but something changed. Characters overcome Despair by
acknowledging it, not defeating it. Cael's sacrifice is permanent.
There is no New Game+.

---

## Page 2 -- The Game

### Act Structure

| Act | Name | Summary |
|-----|------|---------|
| I | Discovery | Ember Vein tutorial, Pendulum found, journey to Valdris capital. Party assembles. |
| II | Diplomacy | Three-faction council, diplomatic missions. Cael's nightmares worsen. Betrayal -- Cael steals the Pendulum. |
| Interlude | Unraveling | World breaks. Sable alone, reuniting party one by one. Ley lines rupture. |
| III | The Convergence | Five character-defining trials. March on the Convergence. Campfire scene. |
| IV | Reckoning | Final dungeon. Cael's sacrifice closes the Pallor's door. Memorial. |
| Epilogue | After | New world. Survivors rebuild. Post-game content unlocks. |

Full story outline: [outline.md](outline.md)

### Party Members

| Character | Role | One Line |
|-----------|------|----------|
| Edren | Knight-commander (tank) | Loyal, disciplined. Carries guilt over failing to see Cael's descent. |
| Cael | Commander, then betrayer | Charismatic but wounded by grief. Dies closing the Pallor's door. |
| Maren | Court mage (archmage) | Lore-keeper. Discovers the Pallor's cyclical nature. |
| Sable | Thief (fastest, fragile) | Young, quick-witted, covers pain with humor. The party's heart. |
| Lira | Forgewright (engineer) | Technical specialist. Cael's love interest (tragic romance). |
| Torren | Ranger/spirit-speaker (sage) | Moral compass. World-weary elder from the Thornmere Wilds. |

Full character details: [characters.md](characters.md)

### Core Gameplay Loop

```
Explore (overworld/towns) --> Fight (ATB encounters) --> Progress (level/equip/crystal)
    ^                                                              |
    <-- <-- <-- <-- Story (cutscenes/dialogue/choices) <-- <-- <-- +
```

### Combat Summary

- **ATB (Active Time Battle):** speed-based gauge determines turn order
- **4-member active party** from 6 characters. Front/back row system.
- **Damage:** ATK^2/6 - DEF (physical), MAG x power/4 - MDEF (magic)
- **Elements:** 6 types with weakness/resistance/absorb
- **Special systems:** Arcanite Forging (Lira's devices), Ley Crystal
  invocations, dual techs, Weave Gauge (Maren's Ley Surge)
- See [combat-formulas.md](combat-formulas.md) for full rules

### Progression Summary

- **Level cap:** 150 (critical path reaches ~48, post-game to 150)
- **Stats:** 8 core (HP, MP, ATK, DEF, MAG, MDEF, SPD, LCK), caps at 255
- **Three growth layers:** base per-level growth + Ley Crystal bonuses
  (player choice, 18 crystals) + narrative milestone spikes (12 story events)
- See [progression.md](progression.md) for growth tables

### Key Systems

- **Arcanite Forging:** Lira crafts battle devices from materials. 12 AC pool, 5 device loadout. See [crafting.md](crafting.md).
- **Save/Rest:** 3 manual slots + auto-save. Rest items at save points (tiered HP/MP/AC restore). See [save-system.md](save-system.md).
- **Encounter Rates:** Danger counter model (FF6). Ward Talisman, Ley Stag mount reduce encounters. See [combat-formulas.md](combat-formulas.md).
- **Dialogue:** Party-aware, flag-gated NPC system. Sprite emotions (14 animations). See [dialogue-system.md](dialogue-system.md).

---

## Page 3 -- Scope & Reference

### Content Volume

| Category | Count | Source |
|----------|-------|--------|
| Party members | 6 playable + 2 guests | [characters.md](characters.md) |
| Regular enemies | 204 | [bestiary/](bestiary/) |
| Bosses | 31 (+ 1 scripted loss) | [bestiary/bosses.md](bestiary/bosses.md) |
| Palette-swap families | 32 | [bestiary/palette-families.md](bestiary/palette-families.md) |
| Consumable items | 33 | [items.md](items.md) |
| Equipment (weapons) | 56 | [equipment.md](equipment.md) |
| Equipment (armor) | 49 | [equipment.md](equipment.md) |
| Accessories | 42 | [equipment.md](equipment.md) |
| Crafting materials | 72 | [items.md](items.md) |
| Key items | 26 | [items.md](items.md) |
| Ley Crystals | 18 | [progression.md](progression.md) |
| Towns/settlements | 10+ | [locations.md](locations.md) |
| Dungeons | 13+ | [dungeons-world.md](dungeons-world.md), [dungeons-city.md](dungeons-city.md) |
| Script lines | ~6,300 | [script/](script/) |
| Narrative scenes | 44 | [script/](script/) |
| Sidequests | 25--30 | [sidequests.md](sidequests.md) |

### Estimated Playtime

| Path | Hours |
|------|-------|
| Critical path | 25--35 |
| Critical + sidequests | 35--50 |
| Completionist (bestiary, treasures, quests, items) | 45--60 |
| Completionist + level 150 | 60--80+ |

### Session Structure

- **Minimum session:** ~15 minutes (reach a save point, meaningful
  progress)
- **Typical session:** 1--2 hours (clear a dungeon, advance story)
- **Save-and-quit friendly:** auto-save on dungeon entry, town entry,
  and sidequest completion. Save points every 10--15 minutes on
  critical path.
- **No session-locking content** except optional post-game boss rush
  tiers

### Platform & Accessibility

- **Resolution:** 320x180 native, integer-scaled to display (6x at
  1080p, 12x at 4K). Nearest-neighbor, pixel-perfect.
- **Frame rate target:** 60 fps
- **Engine:** Godot Engine 4.x
- **Input:** Keyboard (fully rebindable) + gamepad (standard mapping)
- **Accessibility:** Color-blind modes (Deutan-Protan, Tritan),
  Patience Mode (zero time pressure ATB), Reduce Motion, High-Res
  Text toggle, SFX captions
- See [accessibility.md](accessibility.md) for full details

### Document Index

Organized by category. Every file lives in `docs/story/` unless noted.
README files in subdirectories serve as navigation indexes.

**Overview:**
- [README.md](README.md) -- story documentation index

**Narrative:**
- [outline.md](outline.md) -- story outline, act structure, themes
- [events.md](events.md) -- event flags, story triggers, branching
- [characters.md](characters.md) -- party members, arcs, stat growth
- [npcs.md](npcs.md) -- NPC roster, dialogue rules
- [world.md](world.md) -- world setting, factions, history
- [script/](script/) -- full dialogue script (8 files, ~6,300 lines)

**Combat & Progression:**
- [combat-formulas.md](combat-formulas.md) -- damage, ATB, encounters, row system
- [progression.md](progression.md) -- leveling, Ley Crystals, milestones
- [abilities.md](abilities.md) -- character abilities, Arcanite Forging
- [magic.md](magic.md) -- spell system
- [bestiary/](bestiary/) -- enemy stat tables, boss AI scripts (8 files)
- [difficulty-balance.md](difficulty-balance.md) -- balance philosophy, anti-frustration

**World & Exploration:**
- [locations.md](locations.md) -- location catalog, act availability
- [dungeons-world.md](dungeons-world.md) -- dungeon layouts, encounter tables
- [dungeons-city.md](dungeons-city.md) -- city dungeon layouts
- [geography.md](geography.md) -- overworld map, terrain types
- [overworld.md](overworld.md) -- traversal, Mode 7, save points
- [transport.md](transport.md) -- rail, ferry, Ley Stag mount
- [city-valdris.md](city-valdris.md), [city-carradan.md](city-carradan.md), [city-thornmere.md](city-thornmere.md) -- city layouts
- [interiors.md](interiors.md) -- interior room layouts, NPC placement
- [building-palette.md](building-palette.md) -- building templates, tile conventions

**Items & Economy:**
- [items.md](items.md) -- consumables, materials, key items
- [equipment.md](equipment.md) -- weapons, armor, accessories
- [economy.md](economy.md) -- shop inventories, pricing, gold pacing
- [crafting.md](crafting.md) -- Arcanite Forging system

**Presentation:**
- [visual-style.md](visual-style.md) -- art direction, palettes, Pallor corruption
- [ui-design.md](ui-design.md) -- battle screen, menus, save/load UI
- [music.md](music.md) -- score, leitmotifs, corruption audio
- [audio.md](audio.md) -- SFX catalog, ambient audio, mixing, channel budget
- [dialogue-system.md](dialogue-system.md) -- text box mechanics, sprite emotions
- [biomes.md](biomes.md) -- terrain palettes, environmental rules

**Systems:**
- [save-system.md](save-system.md) -- save/load, auto-save, death recovery, rest items
- [accessibility.md](accessibility.md) -- display scaling, color-blind, Patience Mode, motion
- [dynamic-world.md](dynamic-world.md) -- act-based world state changes
- [sidequests.md](sidequests.md) -- sidequest catalog
- [postgame.md](postgame.md) -- post-game content, boss rush, completion tracking

**Audits:**
- [continuity-audit.md](continuity-audit.md) -- cross-doc continuity verification
- [layout-audit.md](layout-audit.md) -- save point and layout coverage audit
- [worldbuilding-audit.md](worldbuilding-audit.md) -- worldbuilding consistency audit

**Technical:**
- [technical-architecture.md](../plans/technical-architecture.md) -- Godot 4.6 project setup, data formats, state machine, entities, assets, persistence, performance

**Analysis:**
- `docs/analysis/game-design-gaps.md` -- gap tracker (25 gaps, 24 complete, 4.5 Localization deferred)
