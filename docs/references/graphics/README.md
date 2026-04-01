# Graphics & Animation References

Resources for sourcing, creating, and generating pixel art sprites,
tilesets, and animations for Pendulum of Despair. Researched April 2026.

## Documents

| File | Content |
|------|---------|
| [sprite-libraries.md](sprite-libraries.md) | Free/low-cost sprite and tileset packs (OpenGameArt, Kenney, itch.io JRPG packs) |
| [creation-tools.md](creation-tools.md) | Pixel art editors (Aseprite, Pyxel Edit), VFX tools, tilemap editors, animation approach (frame-by-frame, SNES frame counts) |
| [ai-art-generation.md](ai-art-generation.md) | AI pixel art generation (PixelLab, Retro Diffusion, Scenario), concept art workflow, limitations, **MCP integration for Claude Code** |

## Quick Start

**Need sprites now?** Download [Ninja Adventure](https://pixel-boy.itch.io/ninja-adventure-asset-pack)
(free, CC0) — massive RPG pack with characters, enemies, tilesets, UI.

**Need to create original art?** Buy [Aseprite](https://www.aseprite.org)
($20) — the industry standard for pixel art. Pair with Godot's
built-in TileMap editor.

**Want AI-assisted?** Read [ai-art-generation.md](ai-art-generation.md)
for the PixelLab + Aseprite hybrid workflow.

**Want Claude Code to generate sprites directly?** PixelLab has an MCP
server — one command to set up, then Claude Code can generate characters,
animations, and tilesets during dev sessions. See
[ai-art-generation.md Section 5](ai-art-generation.md#5-mcp-integration-claude-code).

## Related Game Design Docs

- `docs/story/visual-style.md` — art direction, palettes, Pallor corruption effects
- `docs/story/ui-design.md` — UI layout, 320x180 viewport, screen elements
- `docs/story/accessibility.md` — resolution scaling, color-blind palettes
- `docs/plans/technical-architecture.md` — asset pipeline, sprite sheet format, import settings
