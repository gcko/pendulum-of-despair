# GAP-082: EPIC: All art assets are placeholders (no real sprites, biome tilesets, UI frames, or status icons)

| Field | Value |
|-------|-------|
| **ID** | GAP-082 |
| **Area** | Art |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | tracker, exploration |

## Summary

All 22 sprites are placeholder rectangles and tilesets are a few colored squares; no real character/enemy/NPC sprites, the 11 distinct biome tilesets + border tiles, UI window frames, or 22 status icons exist. The game runs on placeholders so this is polish, not a blocker.

## Current state (implementation)

11 designed biomes share one ~13-tile placeholder atlas; find assets returns 22 placeholder PNGs.

## Desired state (per design)

Real pixel art per visual-style.md: 6 party x 4-dir walk/idle, ~198 enemy battle sprites (palette families), NPC sprites, per-biome 16x16 tilesets + border tiles, UI frames/cursors/status icons.

## Proposed approach

Single art-production epic; coordinate palette-family sprite sharing to reduce enemy count; supplies the assets for UI scaffolding gaps (GAP-058/059).

## Acceptance criteria

- [ ] Party/enemy/NPC sprites authored
- [ ] Per-biome tilesets + border tiles authored
- [ ] UI frames/cursors and 22 status icons authored

## Design references

- docs/story/visual-style.md
- docs/story/biomes.md (11 biome tilesets)
- docs/story/building-palette.md

## Code references

- game/assets/sprites/ (22 placeholder PNGs)
- game/assets/tilesets/ (placeholder_dungeon.png, tileset_test.png)
- game/scenes/maps/overworld.tscn:3-33


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/assets/sprites/ holds 20 placeholder PNGs (characters: 6 placeholder_*.png; enemies: 1 placeholder_enemy.png; npcs: 1 placeholder_npc.png; ui: 1 cursor_hand.png; interactables: 11 placeholder_*.png) — all tiny 83-145 byte placeholders. game/assets/tilesets/ has placeholder_dungeon.png (256B) + tileset_test.png (152B), 2 PNGs. Combined = 22 placeholder art PNGs. No real biome tilesets, UI frames, or status icons.
- **Notes:** Confirmed. Minor imprecision: the issue says '22 sprites' but the sprites/ dir has 20 PNGs; the 22 count only holds if the 2 tileset PNGs are included. Substance (everything is placeholder art) is fully accurate. XL art-production epic — polish, not a blocker, and not a safe bounded fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
