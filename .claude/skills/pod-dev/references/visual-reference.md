# Visual Reference -- FF6 Screenshots

Reference screenshots from Final Fantasy VI illustrating the key visual systems
and aesthetic targets for Pendulum of Despair. Use these when building or
reviewing any visual system to ensure fidelity to the 16-bit SNES era.

All images are in [`ff6_screenshots/`](ff6_screenshots/).

---

## Overworld & Exploration

| Screenshot | Description | Reference For |
|-----------|-------------|---------------|
| `ff6shot010.png` | Outdoor field map -- character on a bridge over a river, lush forests and cliffs | Tilemap rendering, terrain variety, bridge traversal |
| `ff6shot089.png` | Mountain pass -- character entering a narrow path through dense forest/mountains | Overworld terrain transitions, forest tileset |
| `ff6shot174.png` | Mode 7 world map -- character on chocobo-back at coastline with minimap overlay | World map rendering, minimap UI, Mode 7 perspective |
| `ff6shot182.png` | Mountain world map -- character traversing rocky terrain with grass patches | World map terrain detail, mountain tileset |
| `ff6shot183.png` | Rope bridge scene -- dramatic parallax bridge over a misty canyon | Scenic set pieces, parallax scrolling, environmental storytelling |

## Towns & Interiors

| Screenshot | Description | Reference For |
|-----------|-------------|---------------|
| `ff6shot065.png` | Narshe mines -- industrial town with buildings, waterfall, gears, and mine cart | Town tileset, steampunk/industrial aesthetic, vertical level design |
| `ff6shot176.png` | Pub interior -- detailed room with bar, patrons, furniture, and multiple NPCs | Interior tileset, NPC placement, furniture/prop detail |

## Dialogue System

| Screenshot | Description | Reference For |
|-----------|-------------|---------------|
| `ff6shot083.png` | Character dialogue (Terra) -- blue gradient dialogue box with speaker name, castle interior | Dialogue box styling, speaker label format, font rendering |
| `ff6shot084.png` | Character dialogue (Kefka) -- desert scene with soldiers, dialogue box at bottom | Dialogue box positioning, NPC dialogue during scenes |
| `ff6shot085.png` | Chocobo escape scene (Kefka) -- outdoor castle scene with chocobos and dialogue | Cutscene dialogue, character sprite animation during story events |
| `ff6shot085b (ff6shot176.png)` | Meeting dialogue (Banon) -- large interior meeting hall with many characters | Multi-character scene dialogue, large room composition |

## Combat System

| Screenshot | Description | Reference For |
|-----------|-------------|---------------|
| `ff6shot054.png` | Magitek intro -- three Magitek armor suits marching through snow at night | Opening sequence, Magitek/mech sprites, snow environment |
| `ff6shot076.png` | Magitek combat -- town battle with ability menu (Fire Beam, Ice Beam, Bolt Beam, Heal Force) | Magitek ability menu layout, town battle backdrop |
| `ff6shot080.png` | Magitek ability select -- battle in town showing the ability selection submenu | Combat ability submenu, Magitek combat UI |
| `ff6shot171.png` | Desert boss fight -- party (Edgar, Locke, Terra) vs large mechanical boss with ATB bars | ATB combat UI layout, HP display, boss sprite, desert backdrop |
| `ff6shot172.png` | Forest battle -- party vs Rhinotaur + enemies, enemy name list, forest backdrop | Random encounter UI, enemy name display, forest battle background |
| `ff6shot181.png` | Grassland boss -- large monster encounter with party, empty command box visible | Boss encounter framing, outdoor battle background |
| `ff6shot183b (ff6shot183.png)` | River boss (Ultros) -- 4-party battle with dialogue during combat | In-battle dialogue, boss banter, 4-character party layout |

## Story & Cutscenes

| Screenshot | Description | Reference For |
|-----------|-------------|---------------|
| `ff6shot043.png` | Snowy cliff -- party of Magitek soldiers on a mountain overlook at night | Dramatic scene composition, nighttime palette, group formation |
| `ff6shot082.png` | Frozen Esper -- cave scene with frozen creature in ice, Magitek soldiers flanking | Story set piece, magical/mystical visual effects, cave tileset |
| `ff6shot173.png` | Overworld travel -- character walking along mountain path | Exploration feel, scale of world map terrain |

---

## Key Visual Takeaways

When building visual systems for Pendulum of Despair, reference these patterns:

1. **Dialogue boxes**: Blue-to-dark gradient with thin silver/white border, white bitmap font, speaker name prefix in caps
2. **Combat UI**: Bottom-of-screen split layout -- commands on left, party HP/ATB on right; blue gradient background panels
3. **Tilemap detail**: Rich environmental variety -- forests, mountains, snow, desert, caves, towns all have distinct tilesets with high detail density
4. **Sprite scale**: Characters are roughly 16x24 pixels (1.5 tiles tall), enemies vary from 1x to 4x character size
5. **Color palettes**: Distinct per-environment -- cool blues for caves/night, warm browns for desert, rich greens for forest, muted grays for industrial
6. **Parallax/depth**: Background layers create depth (mountains behind bridges, sky behind cliffs)
7. **Interior detail**: Rooms are dense with props -- furniture, decorations, NPCs -- conveying lived-in spaces
