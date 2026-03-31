# Audio Implementation Design

> **Gap:** 4.2 Sound Effects & Audio Implementation
> **Status:** Spec complete, pending implementation
> **Date:** 2026-03-31

## Overview

Defines the SFX catalog, ambient audio specs, and audio implementation
rules for Pendulum of Despair. This spec covers everything NOT in
music.md — sound effects, ambient loops, mixing model, channel budget,
and priority stack. music.md (the composer's reference) stays unchanged.

**Design principle:** SNES soul, modern execution. Audio should *sound*
like SNES (short, punchy, synthesized SFX; chiptune-inspired instruments)
but *behave* like modern audio (smooth crossfades, priority management,
no channel starvation).

**File:** `docs/story/audio.md` — the sound engineer/programmer reference.

---

## 1. Master SFX Catalog

~51 SFX IDs organized by context. All SFX should be SNES-inspired:
short, punchy, synthesized. No orchestral swells or realistic foley.
Each SFX under 2 seconds (except jingles at 2-8s per music.md).

### 1.1 Combat SFX (18)

| ID | Trigger | Notes |
|----|---------|-------|
| `hit_physical` | Physical attack connects | Crunchy, impactful |
| `hit_magic` | Magical attack connects | Shimmery, resonant |
| `miss` | Attack misses / dodged | Whiff / whoosh |
| `critical` | Critical hit | Amplified hit variant — louder, sharper |
| `guard` | Defend action activated | Shield / brace sound |
| `heal` | HP or MP restoration | Warm chime |
| `status_apply` | Status effect inflicted | Generic negative tone |
| `status_remove` | Status effect cured | Generic positive tone |
| `ko_party` | Party member falls | Dramatic, emotional — lower pitch, longer decay |
| `ko_beast` | Beast or Humanoid enemy dies | Organic crumble / collapse |
| `ko_undead` | Undead or Pallor enemy dies | Hollow dissolution |
| `ko_construct` | Construct enemy dies | Metallic breakdown / shatter |
| `ko_spirit` | Spirit or Elemental enemy dies | Ethereal dissipation / fade |
| `flee` | Party flees battle | Whoosh / retreat |
| `victory_fanfare` | Battle won | Maps to music.md jingle (5-8s) |
| `level_up` | Level gained | Maps to music.md jingle (2-3s) |
| `battle_onset_boss` | Boss encounter begins | Heavy, dramatic hit — plays after transition, before dialogue |
| `battle_onset_superboss` | Superboss encounter begins | Elevated variant — longer, more ominous (The Lingering, echo bosses) |

**Enemy KO type mapping** (from bestiary/README.md 8 enemy types):
- Beast + Humanoid → `ko_beast`
- Undead + Pallor → `ko_undead`
- Construct → `ko_construct`
- Spirit + Elemental → `ko_spirit`
- Boss type uses whichever fits their primary nature

Pallor shares `ko_undead` because both are death/entropy entities that
dissolve rather than collapse. Pallor enemies fade to grey; undead
crumble to dust. The "hollow dissolution" sound fits both.

### 1.2 UI SFX (8)

| ID | Trigger | Notes |
|----|---------|-------|
| `cursor_move` | Menu cursor moves (any direction) | Single short tick — same for up/down/left/right. FF6 model. Soft, non-fatiguing (heard hundreds of times). |
| `confirm` | Selection accepted | Deeper, decisive |
| `cancel` | Back / exit | Lighter, retreating |
| `menu_open` | Main menu opens | Subtle whoosh / reveal |
| `menu_close` | Main menu closes | Reverse of open |
| `equip_change` | Equipment equipped or removed | Metallic clink |
| `error_buzz` | Invalid action (greyed option, can't equip) | Short buzz / denied |
| `save_confirm` | Save completed | Positive chime (distinct from `confirm`) |

### 1.3 Exploration SFX (7)

| ID | Trigger | Notes |
|----|---------|-------|
| `door_open` | Dungeon or building door opened | Creak / thud depending on material |
| `chest_open` | Treasure chest opened | Classic hinged-lid sound |
| `save_point_chime` | Player enters save point proximity | Soft crystalline tone — maps to music.md save point jingle |
| `encounter_trigger` | Split-second before battle transition | Brief alarm / flash cue |
| `ley_crystal_obtain` | Ley Crystal acquired | Special, rarer — resonant, sustained |
| `item_pickup` | Field item collected | Maps to music.md "Item Acquisition" jingle (1-2s) |
| `rest_complete` | Rest at save point finished | Restored tone (warm, resolved) |
| `quest_complete` | Sidequest completed | Triumphant short jingle (distinct from victory fanfare) |
| `phase_change` | Boss enters new phase | Ominous shift — low rumble + high chime |

### 1.4 Environmental / Narrative SFX (~15)

These are referenced in script files using `[SFX: id]` notation.

| ID | Context | Script Usage |
|----|---------|-------------|
| `ley_surge` | Ley energy visual manifestation | act-i |
| `ley_rupture` | Ley Line Rupture (world event) | interlude |
| `pallor_surge` | Pallor corruption burst | act-ii, act-iii, act-iv, interlude |
| `pallor_surge_final` | Final climactic Pallor surge | act-iv |
| `pallor_transform` | Pallor entity transformation | act-iv |
| `pallor_ambience` | Pallor atmosphere onset | act-iii |
| `alarm_bells` | Warning / alarm bells | act-i, act-ii |
| `wall_breach` | Structural wall collapse | act-ii |
| `door_breach` | Door buckles / breaks | script scenes |
| `sword_draw` | Weapon drawn (combat prep) | act-iv |
| `weapon_forge` | Lira's forging | act-iii |
| `machine_activate` | Machine powers up | act-iv |
| `wind_quiet` | Quiet wind (narrative beat) | act-iv |
| `pendulum_shatter` | Pendulum artifact shatters | act-iv |
| `title_reveal` | Title card + credits roll | act-i, act-iv |
| `drums_war` | Siege / battle onset | act-ii |

---

## 2. Ambient Audio

### 2.1 Biome Loops

One seamless ambient loop per biome (30-60 seconds). Designed to be
felt, not noticed — if a player says "I didn't notice the ambient,"
that's a success.

| Biome | Ambient Loop | Character |
|-------|-------------|-----------|
| Valdris Highlands | Light wind, distant birds, faint ley hum | Open, pastoral |
| Carradan Industrial | Machine drone, distant hammering, steam hiss | Oppressive, rhythmic |
| Thornmere Forest | Rustling leaves, birdsong, water trickle, insect chirps | Dense, alive |
| Thornmere Marsh (Duskfen) | Water lapping, frog croaks, bubbling | Damp, uneasy |
| Mountain (Windshear) | Strong wind, sparse echoes | Exposed, cold |
| Coastal | Waves, seagulls, creaking wood | Salt air |
| Underground / Cave | Dripping water, distant rumble, stone echo | Enclosed, deep |
| Ley Line Depths | Crystalline resonance, harmonic hum | Otherworldly |
| Factory Interior | Grinding gears, furnace roar, metal stress | Mechanical, hot |
| Pallor Wastes | Near-silence, flat sub-bass drone, faint static | Dead, wrong |
| Town (generic) | Crowd murmur, footsteps, distant conversation | Inhabited, busy |
| Sacred Sites | Soft ley hum, wind chime tones | Peaceful, safe |

### 2.2 Mixing Model

The balance between music and ambient shifts by context. The music
carries atmosphere on the overworld (SNES model); ambient takes over
in dungeons and interiors.

| Context | Music Volume | Ambient Volume |
|---------|-------------|----------------|
| Overworld | 100% | 30-40% (subtle texture) |
| Towns | 100% | 20-30% (crowd murmur) |
| Dungeons / Interiors | 50-60% | 80-100% (environment is the star) |
| Pallor Wastes | 0% (drone only) | 40% (muffled, lifeless) |
| Battle | 100% | 0% (ambient cuts) |
| Cutscene | Per scene direction | Per scene direction |

These percentages are relative to the player's Music Volume and SFX
Volume config settings, not absolute values.

### 2.3 Corruption Stage Effects on Ambient

Per biomes.md corruption evolution (3 stages):

| Stage | Name (per biomes.md) | Ambient Effect |
|-------|---------------------|---------------|
| 0 (no corruption) | Clean | No modification |
| 1 | Early Corruption (Subtle) | Volume -10%, faint sub-bass tone added |
| 2 | Mid Corruption (Obvious) | Volume -30%, nature sounds thin out, sub-bass audible |
| 3 | Full Corruption (Pallor Wastes) | Nature sounds replaced with static / wind. Only Pallor drone + faint static remain. |

---

## 3. Audio Implementation Rules

### 3.1 Channel Budget

**24 channels total:**

| Pool | Channels | Purpose |
|------|----------|---------|
| Music | 8 reserved | Never drops below 4 even under channel pressure |
| SFX | 12 | Combat, UI, exploration, narrative |
| Ambient | 4 | Biome loop + up to 3 spot effects |

### 3.2 Priority Stack

When channels are full, higher-priority sounds steal from lower:

| Priority | Category | Examples |
|----------|----------|----------|
| 1 (highest) | Cutscene SFX | `pallor_surge`, `pendulum_shatter`, `ley_rupture` |
| 2 | Battle jingles | `victory_fanfare`, `level_up`, phase change |
| 3 | Boss onset | `battle_onset_boss`, `battle_onset_superboss` |
| 4 | Battle SFX | `hit_physical`, `critical`, `ko_beast`, `heal`, `status_apply` |
| 5 | UI SFX | `cursor_move`, `confirm`, `cancel`, `equip_change` |
| 6 | Exploration SFX | `door_open`, `chest_open`, `save_point_chime` |
| 7 | Music | Always playing, yields channels to higher priority |
| 8 (lowest) | Ambient | First to be dropped under pressure |

**Channel steal rule:** When a higher-priority sound needs a channel
and none are free, the lowest-priority currently-playing sound is cut
with a 50ms fade-out to avoid clicks.

### 3.3 Crossfade Rules

| Transition | Duration | Behavior |
|------------|----------|----------|
| Overworld biome change | 3 seconds | 1.5s out + 1.5s in. Applies to BOTH music and ambient simultaneously. |
| Town entry / exit | 1 second | Faster, more immediate. |
| Battle enter | 0ms (hard cut) | Music hard-cuts to battle theme. Ambient cuts to silence. |
| Battle exit | 1 second | Battle music fades, exploration music + ambient resume from where they left off. |
| Pallor Wastes entry | 5 seconds (music) / 3 seconds (ambient) | Music cuts to silence, drone fades in over 5s (per music.md). Ambient crossfades to Pallor loop over 3s. |
| Ley Nexus | Additive | Surrounding biome music retained; ley hum layers underneath (additive blend, not replacement). |

### 3.4 SFX Overlap Rules

- **Same ID limit:** Max 2 simultaneous instances of the same SFX ID.
  Prevents stacking (e.g., 4 party members attacking = 2 `hit_physical`
  instances, not 4).
- **Different IDs:** Overlap freely within channel budget.
- **Spatial panning:** UI SFX are mono (center). Combat SFX have light
  stereo panning based on source position (left party = left pan, right
  enemy = right pan).
- **Stereo / Mono:** Respects the player's Sound config (Stereo / Mono).
  In Mono mode, all panning collapses to center.

### 3.5 Narrative Silence

Per music.md, true silence (zero audio, ALL channels silent) occurs
exactly twice in the entire game:

1. **5 seconds** after the Ley Line Rupture (Interlude)
2. **3 seconds** before Cael's sacrifice bird call (Act IV)

All other "silence" moments (Pallor transitions, battle end, boss
deaths) retain ambient sound or transition to drone within seconds.
These two moments are sacred — nothing else in the game uses true
silence.

### 3.6 Audio Asset Format

- **SFX format:** OGG Vorbis (.ogg). Lightweight, Godot-native, good
  compression for short samples.
- **Music format:** OGG Vorbis (.ogg) for streamed tracks. Seamless
  loop points defined in Godot's import settings.
- **Ambient loops:** OGG Vorbis (.ogg), seamless loop.
- **Sample rate:** 44.1 kHz (CD quality — standard for game audio)
- **Bit depth:** 16-bit (sufficient for SNES-style audio)
- **Naming convention:** `category_name.ogg` (e.g., `combat_hit_physical.ogg`,
  `ambient_thornmere_forest.ogg`, `ui_cursor_move.ogg`)
