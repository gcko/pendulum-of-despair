# Audio Implementation

> Defines the SFX catalog, ambient audio specs, and audio implementation
> rules for Pendulum of Despair. Covers everything NOT in music.md —
> sound effects, ambient loops, mixing model, channel budget, and
> priority stack. music.md (the composer's reference) stays unchanged.
> This document is the sound engineer/programmer reference.
>
> **Design principle:** SNES soul, modern execution. Audio should *sound*
> like SNES (short, punchy, synthesized SFX; chiptune-inspired instruments)
> but *behave* like modern audio (smooth crossfades, priority management,
> no channel starvation).
>
> **Related docs:** [music.md](music.md) | [biomes.md](biomes.md) |
> [accessibility.md](accessibility.md) |
> [bestiary/README.md](bestiary/README.md) |
> [combat-formulas.md](combat-formulas.md) |
> [overworld.md](overworld.md) | [save-system.md](save-system.md)

---

## 1. Master SFX Catalog

~51 SFX IDs organized by context. All SFX are SNES-inspired: short,
punchy, synthesized. No orchestral swells or realistic foley. Each SFX
under 2 seconds except jingles (2-8s per music.md).

### 1.1 Combat SFX (19)

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
| `phase_change` | Boss enters new phase | Ominous shift — low rumble + high chime. Priority 2 (Battle jingles). |

#### Enemy Type KO Sound Mapping

All 8 enemy types from [bestiary/README.md](bestiary/README.md) mapped
to 4 KO sounds. Boss type uses whichever fits the boss's primary nature.

| Enemy Type | KO Sound | Rationale |
|------------|----------|-----------|
| Beast | `ko_beast` | Organic collapse — flesh and bone |
| Humanoid | `ko_beast` | Same organic body — crumble/collapse fits |
| Undead | `ko_undead` | Death/entropy entity — dissolves to dust |
| Pallor | `ko_undead` | Shares dissolution aesthetic — fades to grey rather than collapsing. Both are death/entropy entities. |
| Construct | `ko_construct` | Mechanical breakdown — metal and gears shatter |
| Spirit | `ko_spirit` | Ethereal fade — dissipates into nothing |
| Elemental | `ko_spirit` | Same non-physical nature — energy dispersal |
| Boss | Per boss nature | Matches primary creature type (e.g., construct boss uses `ko_construct`) |

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

### 1.3 Exploration SFX (8)

| ID | Trigger | Notes |
|----|---------|-------|
| `door_open` | Dungeon or building door opened | Creak / thud depending on material |
| `chest_open` | Treasure chest opened | Classic hinged-lid sound |
| `save_point_chime` | Player enters save point proximity | Soft crystalline tone — maps to music.md save point jingle (3-5s) |
| `encounter_trigger` | Split-second before battle transition | Brief alarm / flash cue |
| `ley_crystal_obtain` | Ley Crystal acquired | Special, rarer — resonant, sustained |
| `item_pickup` | Field item collected | Maps to music.md Item Acquisition jingle (1-2s) |
| `rest_complete` | Rest at save point finished | Restored tone (warm, resolved) |
| `quest_complete` | Sidequest completed | Triumphant short jingle (distinct from victory fanfare) |

### 1.4 Environmental / Narrative SFX (~16)

All `[SFX:]` IDs referenced in script files.

| ID | Context | Script Usage |
|----|---------|-------------|
| `ley_surge` | Ley energy visual manifestation | Act I |
| `ley_rupture` | Ley Line Rupture (world event) | Interlude |
| `pallor_surge` | Pallor corruption burst | Acts II, III, IV, Interlude |
| `pallor_surge_final` | Final climactic Pallor surge | Act IV |
| `pallor_transform` | Pallor entity transformation | Act IV |
| `pallor_ambience` | Pallor atmosphere onset | Act III |
| `alarm_bells` | Warning / alarm bells | Acts I, II |
| `wall_breach` | Structural wall collapse | Act II |
| `door_breach` | Door buckles / breaks | Script scenes |
| `sword_draw` | Weapon drawn (combat prep) | Act IV |
| `weapon_forge` | Lira's forging | Act III |
| `machine_activate` | Machine powers up | Act IV |
| `wind_quiet` | Quiet wind (narrative beat) | Act IV |
| `pendulum_shatter` | Pendulum artifact shatters | Act IV |
| `title_reveal` | Title card + credits roll | Acts I, IV |
| `drums_war` | Siege / battle onset | Act II |

---

### 1.5 SFX Reuse for Unlisted Events

The ~51 SFX catalog covers core interactions. Many gameplay events reuse
generic SFX rather than having dedicated sounds:

- **Combat interactions** (Frozen Shatter, Smoke Ignition, Conductive
  Water per [combat-formulas.md](combat-formulas.md)): use `hit_magic`
  or `critical` with the interaction's visual effect providing the
  distinct feedback
- **Character abilities** (Lira's device deploy, Maren's Weave Gauge,
  Torren's Spirit Favor, Sable's Filch): use `status_apply` for
  positive effects, `confirm` for successful actions, `error_buzz`
  for failures
- **Magic traditions** (Ley Line resonance, Arcanite mechanical,
  Spirit Communion natural per [abilities.md](abilities.md)): use
  `hit_magic` for all traditions. The visual effects and animation
  distinguish tradition, not the SFX.
- **Combo abilities** (dual techs): use `critical` as the activation
  cue — the amplified sound signals a special moment

If future implementation reveals that a reused SFX feels inadequate for
a specific event, a dedicated SFX can be added to the catalog. The ID
naming convention (`category_name`) supports expansion.

---

## 2. Ambient Audio

### 2.1 Biome Loops

One seamless ambient loop per biome (30-60 seconds). Designed to be
felt, not noticed — if a player says "I didn't notice the ambient,"
that is a success.

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

The balance between music and ambient shifts by context. Music carries
atmosphere on the overworld (SNES model); ambient takes over in
dungeons and interiors.

| Context | Music Volume | Ambient Volume |
|---------|-------------|----------------|
| Overworld | 100% | 30-40% (subtle texture) |
| Towns | 100% | 20-30% (crowd murmur) |
| Dungeons / Interiors | 50-60% | 80-100% (environment is the star) |
| Narrative dungeons | 100% | 30-40% (music-dominant, see below) |
| Pallor Wastes | 0% | 40% (Pallor drone plays on ambient channels) |
| Battle | 100% | 0% (ambient cuts) |
| Cutscene | Per scene direction | Per scene direction |

All percentages are relative to the player's Music Volume and SFX
Volume config settings (see [save-system.md](save-system.md) and
[accessibility.md](accessibility.md) Section 7), not absolute values.

**Narrative dungeon exception:** Some dungeons have musically intense
scores that should not be suppressed. These use overworld-style mixing
(100% music / 30-40% ambient): Valdris Siege Battlefield, The
Convergence, Axis Tower Interior. The music IS the atmosphere in these
locations. All other dungeons use the standard 50-60% / 80-100% split.

**Pallor drone channel:** The Pallor drone plays on ambient channels,
not music channels. In the Pallor Wastes, music is silent (0%) and
the drone is part of the ambient biome loop. This avoids channel
conflicts with music.md's Corruption Evolution System, which describes
how the *music* degrades — at Stage 3 (Full Corruption), the music is
gone and only the ambient drone remains.

### 2.3 Corruption Stage Effects on Ambient

Per [biomes.md](biomes.md) Pallor Corruption Overlay System (3 stages):

| Stage | Name (per biomes.md) | Ambient Effect |
|-------|---------------------|---------------|
| 0 (no corruption) | Clean | No modification |
| 1 | Early Corruption (Subtle) | Volume -10%, faint sub-bass tone added |
| 2 | Mid Corruption (Obvious) | Volume -30%, nature sounds thin out, sub-bass audible |
| 3 | Full Corruption (The Pallor Wastes) | Nature sounds replaced with static / wind. Only Pallor drone + faint static remain. |

---

## 3. Implementation Rules

### 3.1 Channel Budget

**24 channels total:**

| Pool | Channels | Purpose |
|------|----------|---------|
| Music | 8 reserved | Never drops below 4 even under channel pressure |
| SFX | 12 | Combat, UI, exploration, narrative |
| Ambient | 4 | Biome loop + up to 3 spot effects |

### 3.2 Priority Stack

When channels are full, higher-priority sounds steal from lower.
Channel steal rule: when a higher-priority sound needs a channel and
none are free, the lowest-priority currently-playing sound is cut with
a 50ms fade-out to avoid clicks.

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

### 3.3 Crossfade Rules

| Transition | Duration | Behavior |
|------------|----------|----------|
| Overworld biome change | 3 seconds | 1.5s out + 1.5s in. Applies to BOTH music and ambient simultaneously. |
| Town entry / exit | 1 second | Faster, more immediate. |
| Battle enter | 0ms (hard cut) | Music hard-cuts to battle theme. Ambient cuts to silence. |
| Battle exit | 1 second | Battle music fades, exploration music + ambient resume from where they left off. |
| Pallor Wastes entry | 5s (music) / 3s (ambient) | Music cuts to silence, drone fades in over 5s (per music.md). Ambient crossfades to Pallor loop over 3s. |
| Ley Nexus | Additive | Surrounding biome music retained; ley hum layers underneath (additive blend, not replacement). |

### 3.4 SFX Overlap Rules

- **Same ID limit:** Max 2 simultaneous instances of the same SFX ID.
  Prevents stacking (e.g., 4 party members attacking = 2 `hit_physical`
  instances, not 4).
- **Different IDs:** Overlap freely within channel budget.
- **Spatial panning:** Combat SFX have light stereo panning based on
  source position (left party = left pan, right enemy = right pan).
  UI SFX are mono (center).
- **Stereo / Mono:** Respects the player's Sound config (Stereo / Mono
  per [accessibility.md](accessibility.md) Section 7). In Mono mode,
  all panning collapses to center.

### 3.5 Narrative Silence

Per [music.md](music.md), true silence (zero audio, ALL channels silent)
occurs exactly twice in the entire game:

1. **5 seconds** after the Ley Line Rupture (Interlude)
2. **3 seconds** before Cael's sacrifice bird call (Act IV)

All other "silence" moments (Pallor transitions, battle end, boss
deaths) retain ambient sound or transition to drone within seconds.
These two moments are sacred — nothing else in the game uses true
silence.

### 3.6 Audio Asset Format

| Property | Value |
|----------|-------|
| Format | OGG Vorbis (.ogg) |
| Sample rate | 44.1 kHz |
| Bit depth | 16-bit |
| Naming convention | `{id}.ogg` in category directory |

**Directory layout:** Files are organized by category directory (`sfx/`,
`ambient/`, `music/`) with the SFX ID as the filename. The directory
provides category context, so category prefixes are not repeated in
filenames.

**Examples:** `sfx/hit_physical.ogg`, `ambient/thornmere_forest.ogg`,
`sfx/cursor_move.ogg`, `sfx/pallor_surge.ogg`, `music/title_theme.ogg`

---

## Appendix: Accessibility Caption Mapping

All 8 SFX caption events from [accessibility.md](accessibility.md)
Section 6 mapped to their SFX IDs:

| Caption (accessibility.md) | SFX ID |
|---------------------------|--------|
| [Save Point] | `save_point_chime` |
| [Encounter] | `encounter_trigger` |
| [Level Up] | `level_up` |
| [Victory] | `victory_fanfare` |
| [Item] | `item_pickup` |
| [Quest Complete] | `quest_complete` |
| [Phase Change] | `phase_change` |
| [Alert] | `alarm_bells` |
