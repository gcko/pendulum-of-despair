# Pixel Art & Animation Creation Tools

> Tools for creating original SNES-style sprites, tilesets, and
> animations for Pendulum of Despair. Researched April 2026.

## Pixel Art Editors

### Tier 1: Recommended

| Tool | Cost | Platform | Best For |
|------|------|----------|----------|
| [Aseprite](https://www.aseprite.org) | $20 one-time (or free if compiled from source) | All | **Industry standard.** Animation timeline, onion skinning, palette management, tilemap mode, indexed color, Lua scripting. Exports sprite sheets with JSON metadata. Used by most shipped indie pixel art games. |
| [Pyxel Edit](https://pyxeledit.com) | $9 | All | **Tileset-focused.** Built-in tile placement mode — paint with tiles and it auto-generates the tileset. Complements Aseprite for map design. |

### Tier 2: Free Alternatives

| Tool | Cost | Platform | Best For |
|------|------|----------|----------|
| [Pixelorama](https://orama-interactive.itch.io/pixelorama) | Free (open source) | All | Built in Godot. Actively maintained. Better long-term free alternative than LibreSprite. |
| [LibreSprite](https://libresprite.github.io) | Free (GPL v2) | All | Older Aseprite fork. Functional but lacks newer features (scripting, tablet support, tilemaps). |
| [GraphicsGale](https://graphicsgale.com) | Free | Windows only | Solid frame-by-frame animation. Dated UI but capable for SNES-style work. |
| [Piskel](https://www.piskelapp.com) | Free (browser) | Any | Quick prototyping. No indexed color mode. Fine for sketching, not production. |

### Aseprite Key Features for This Project

- **Animation timeline:** Organize walk/idle/attack cycles with frame tags
- **Onion skinning:** See previous/next frames while drawing
- **Indexed color mode:** Enforce SNES-style palette constraints (8-16 colors per sprite)
- **Tilemap mode:** Grid snapping for 16x16 tile work
- **Sprite sheet export:** JSON atlas export compatible with Godot
- **Lua scripting:** Automate palette swaps for enemy variants (classic SNES technique — one base sprite, multiple color palettes)
- **Batch export:** Export all tagged animations as separate sheets

## VFX / Particle Tools

| Tool | Cost | Platform | Best For |
|------|------|----------|----------|
| [Pixel FX Designer](https://codemanu.itch.io/particle-fx-designer) | ~$5-10 | Desktop | Dedicated pixel art particle/effect tool. Explosions, fire, magic spells, hit sparks. Exports sprite sheets. Very useful for battle spell effects. |
| [Pixel Composer](https://makham.itch.io/pixel-composer) | Free/PWYW | Desktop | Node-based pixel art effects. Procedural VFX sprite sheet generation. More advanced than Pixel FX Designer. |

## Tilemap Editors

| Tool | Cost | Platform | Best For |
|------|------|----------|----------|
| [Tiled](https://www.mapeditor.org) | Free (PWYW on itch) | All | The standard external tilemap editor. JSON/XML export, Godot import plugins, auto-tiling, object layers for events/NPCs. Massive community. |
| [LDtk](https://ldtk.io) | Free (MIT) | All | Modern, streamlined. Auto-tiling, entity placement, enum-based data. Good Godot integration. Created by Dead Cells developer. |
| **Godot 4.x TileMap** | Built-in | N/A | Avoids export/import pipeline. Terrain auto-tiling, multiple layers, physics/navigation painting. Recommended as primary editor for this Godot project. |

**Recommendation:** Use Godot's built-in TileMap editor as the primary
tool. Fall back to Tiled for complex maps that need object layer data
(NPC placement, event triggers) beyond what Godot's editor handles.

## Animation Approach

### Frame-by-Frame (Recommended for SNES Authenticity)

The authentic SNES approach — every frame is hand-drawn. This is what
gives FF6 and Chrono Trigger their look.

**Typical SNES JRPG frame counts:**
| Animation | Frames | Notes |
|-----------|--------|-------|
| Walk cycle (per direction) | 3-4 | Up/down/left/right = 12-16 total frames |
| Battle idle | 2-4 | Gentle breathing/sway |
| Attack | 3-6 | Wind-up, strike, follow-through |
| Magic cast | 2-4 | Raise hands, channel, release |
| Hit/damage | 2 | Recoil, recovery |
| Death/KO | 3-4 | Collapse sequence |
| Victory pose | 2-3 | Celebrate |

**Target: 8-12 fps** for walk cycles, 15-20 fps for battle animations.
SNES games were economical with frames — quality over quantity.

### Skeletal/Tweened (Not Recommended)

Tools like Spine or DragonBones produce smooth animation but look
"puppet-like" rather than hand-animated. Not appropriate for SNES
aesthetic. Use only for non-character elements (camera shake,
projectile paths, UI transitions).

### Palette Swap Workflow (Enemy Variants)

Classic SNES technique — one base enemy sprite, multiple color
palettes. Aseprite's Lua scripting automates this:

1. Draw base enemy in indexed color mode (8-16 colors)
2. Create alternate palettes (stronger variant = darker/redder,
   ice variant = blue/white, etc.)
3. Script swaps palette A → palette B across all frames
4. Export each variant as a separate sprite sheet

This matches the bestiary's 32 palette-swap families.

## Recommended Setup for This Project

| Purpose | Tool | Cost |
|---------|------|------|
| All sprite art | Aseprite | $20 |
| Tileset design | Aseprite + Pyxel Edit | $20 + $9 |
| Battle VFX | Pixel FX Designer | $5-10 |
| Map layout | Godot TileMap editor | Free |
| Complex maps | Tiled (backup) | Free |
| **Total** | | **$34-39** |

Sources:
- [Aseprite](https://www.aseprite.org)
- [Aseprite vs LibreSprite comparison](https://www.virtualcuriosities.com/articles/4997/aseprite-vs-libresprite-feature-comparison)
- [Pixel Art Tools Guide 2026](https://medium.com/@atnoforgamedev/aseprite-piskel-and-pixel-art-tools-a-game-developers-guide-to-2d-art-525792428486)
