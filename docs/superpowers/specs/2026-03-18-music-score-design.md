# Music Score Overview Design Spec

**Date:** 2026-03-18
**Status:** Draft
**Scope:** New file `docs/story/music.md` — comprehensive music score sheet
covering every location, dungeon, narrative moment, and character in the game.
All music is instrumental (no singing/vocals).

---

## 1. Purpose

Define the complete musical identity of Pendulum of Despair as a reference
document for sourcing tracks from free music libraries. Each entry specifies
instruments, mood, tempo, key characteristics, and narrative context so that
a music sourcer can find appropriate tracks without playing the game.

## 2. Design Principles

1. **Faction palettes define regional sound.** Each of the three factions has
   a distinct instrument set. Locations inherit their faction's palette.
2. **Character leitmotifs weave through the score.** Seven characters have
   melodic signatures that appear in location and narrative themes.
3. **The Pallor corrupts, it doesn't compose.** The antagonist force has a
   short motif (3-4 descending notes) that infects other music. It never
   gets a full theme of its own.
4. **Music evolves with the world.** Each location's theme has act variants
   — the same melody progressively damaged by the Unraveling, then rebuilt.
5. **Silence is sacred.** True silence (zero audio) appears exactly twice
   in the entire game. Every other moment has at least ambient sound.
6. **All music is instrumental.** No singing, no vocals, no chanting.
   Choir-like textures use sustained string instruments, not voices.
7. **The framework is composable.** New locations derive their music from
   the palette + mood + corruption matrix. No custom design needed.

## 3. Faction Palettes

Each faction defines an instrument set that governs all music in its territory.

### 3.1 Valdris (Kingdom/Military)

| Role | Instruments |
|------|-------------|
| Lead | Brass (horn, trumpet) |
| Harmony | Strings (violin, cello) |
| Rhythm | Military percussion (snare rolls, timpani) |
| Ambient | Sustained string pads |

**Character:** Noble, structured, formal. Marches and fanfares. Warm but
authoritative — Valdris is flawed but not evil.

**Corruption variant:** Brass becomes muted/distant, strings thin out,
percussion loses cadence. The structure crumbles.

### 3.2 Carradan Compact (Industrial/Mercantile)

| Role | Instruments |
|------|-------------|
| Lead | Hammered dulcimer |
| Harmony | Bass strings, accordion |
| Rhythm | Mechanical percussion (anvil strikes, steam rhythms) |
| Ambient | Factory/machine hum |

**Character:** Busy, layered, rhythmic. Factory rhythms underneath folk
melodies. Steampunk meets Eastern European folk.

**Corruption variant:** Mechanical rhythms become irregular/grinding,
melodies replaced by repetitive loops. The machine breaks down.

### 3.3 Thornmere Wilds (Nature/Spiritual)

| Role | Instruments |
|------|-------------|
| Lead | Wooden flute |
| Harmony | Harp |
| Rhythm | Hand drums, frame drum |
| Ambient | Nature sounds (wind, water, birdsong), ley-line hum |

**Character:** Organic, flowing, modal scales. Celtic/forest folk influence.
The ley-line hum is literally part of the music — not sound design, score.

**Corruption variant:** Flute goes breathy/pitchless, harp detuned, nature
sounds replaced by silence. The forest goes quiet.

### 3.4 Ancient (Pre-Civilization Ruins)

| Role | Instruments |
|------|-------------|
| Lead | Crystalline bells, glass tones |
| Harmony | Low sustained drones |
| Rhythm | None or sparse resonance |
| Ambient | Ley energy hum (harmonic, not the Thornmere naturalistic variant) |

**Character:** Timeless, geometric, inhuman. Not threatening — just old
beyond comprehension. The builders are gone; the stones remember.

### 3.5 Neutral (Cross-Faction / Transitional)

| Role | Instruments |
|------|-------------|
| Lead | Piano or solo acoustic guitar |
| Harmony | Light strings |
| Rhythm | Simple percussion |
| Ambient | Environmental ambience |

**Character:** Unaffiliated spaces. Inns, roads, transitions. Simple and
warm without faction identity.

## 4. Character Leitmotifs

Seven characters have distinct melodic motifs that weave through the score.

### 4.1 Edren — Duty and Quiet Resolve

A steady, ascending brass phrase over sustained strings. Simple, grounded —
like a soldier's oath spoken aloud. Appears in: Valdris Crown theme, the
Dawn March, siege command moments, and the Act I-II overworld as the melodic
backbone.

### 4.2 Cael — Warmth That Darkens

A lyrical cello melody, hopeful and earnest. Across Act II, the Pallor's
descending motif appears as a countermelody beneath it, growing louder. By
the betrayal, the Pallor motif has consumed Cael's theme entirely. At his
sacrifice, his original melody returns — clean, uncorrupted — for the first
and last time since Act I. Then silence. Then the bird.

### 4.3 Lira — Forgewright's Fire

Hammered dulcimer and bright strings — she bridges Valdris and Carradan
palettes. Rhythmic, precise, creative. During the grief arc (Interlude),
her theme slows and loses its rhythmic drive. When she forges the weapon
from Cael's ley energy mid-battle, her motif and Cael's original
uncorrupted motif harmonize for the only time in the game.

### 4.4 Torren — Spirit-Song

Wooden flute carrying a pentatonic melody, with a ley-hum undertone. His
theme IS the Wilds — they share musical DNA. During the Ley Leech boss
fight, his melody is literally what's being corrupted; restoring it through
Spiritcall is the resolution mechanic. Music-as-gameplay.

### 4.5 Sable — The Observer

Solo pizzicato strings or plucked lute. Quick, light, always moving. Her
theme appears most prominently during the Interlude when she's the player
character searching for the party. Each reunion layers her motif with the
found character's motif — the ensemble rebuilds around her.

### 4.6 Maren — Ancient Knowledge

Low strings and a glass-like sustained tone (evoking crystal/ley energy).
Slow, contemplative, slightly unsettling. Carries weight — she knows more
than she says. Appears when lore is revealed, especially "it's a door."

### 4.7 Vaelith — The Pallor Motif

The Pallor's 3-4 note descending motif IS Vaelith's theme. In early
appearances (charming scholar), it's disguised — played in a major key on
pleasant instruments, almost inviting. Each appearance strips away the
disguise until the motif is bare and dissonant. After their dissolution
("Eight hundred years..."), the motif plays one final time — slowly, almost
gently — then fades.

### 4.8 Motif Layering Rules

When a character is relevant to a scene, their motif appears. HOW it
appears depends on their narrative role:

| Motif Role | Treatment |
|------------|-----------|
| Primary (scene is about this character) | Motif carries the melody line |
| Supporting (present, not focal) | Counter-melody or harmonic fragment |
| Absent echo (referenced but not present) | Brief quote on a non-native instrument (e.g., Cael's cello motif on glass tones = presence felt through the Pallor) |
| Corrupted (under Pallor influence) | Motif plays with Pallor motif as counterpoint, progressively consumed |

## 5. Overworld Themes

One composition that evolves across four act variants. Edren's motif serves
as the melodic backbone throughout.

| Variant | Acts | Arrangement | Mood |
|---------|------|-------------|------|
| Full Orchestral | I-II | All three faction palettes layered — brass foundation, dulcimer counter-rhythms, flute ornamentation. Hopeful, adventurous, forward-moving. | The world is troubled but alive. |
| Stripped | Interlude | Same melody reduced to solo instrument (harp or music box). Sparse. Pallor motif pulses underneath like a heartbeat. | The world lost its voice. |
| Rebuilding | III | Instruments return one by one as the party reunites. Nearly full orchestration by the march — but minor key. Pallor motif audible but melody pushes through. | Determined, not hopeful. |
| Renewed | IV / Epilogue | Original Act I melody in full, transposed up. Brighter. Pallor motif absent for the first time. Fragments of every character theme woven in as counter-melodies. | Changed but whole. |

## 6. Town Themes

Each settlement gets a unique theme built from its faction palette + mood.
Themes have act variants per Section 9 (corruption evolution).

### 6.1 Valdris Faction Towns

| Town | Acts | Mood | Music Notes |
|------|------|------|-------------|
| Valdris Crown | I-II | Hopeful / Solemn | Proud, bustling. Brass fanfare on entry, settles into warm strings. Royal court undertone. Edren's motif as harmonic foundation. |
| Valdris Crown | Interlude+ | Corrupted (L3) | Muted horn over empty streets. Military snare replaces court strings — Cordwyn's de facto command. Ghost of the original fanfare in reverb. |
| Aelhart | I-II | Pastoral | Lighter brass, pastoral strings. Small-town warmth. Market day feel. Relaxed tempo. |
| Highcairn | Interlude | Solemn / Sacred | Monastery setting. Low sustained strings, sparse brass. Pallor manifestations introduce corruption level 2 in deeper areas. |
| Thornwatch | II | Tense | Martial Valdris variant. Drums prominent, brass restrained. Border watchtower vigil. |
| Greyvale | I-II | Pastoral / Solemn | Rural Valdris. Gentle strings, distant horn. Post-Interlude: corruption level 2 — the pastoral melody struggles. |

### 6.2 Carradan Compact Towns

| Town | Acts | Mood | Music Notes |
|------|------|------|-------------|
| Corrund | I-II | Industrial / Hopeful | Full Carradan palette. Layered rhythms, merchant energy, hammered dulcimer lead. Busiest track in the game. |
| Corrund | Interlude+ | Corrupted (L2) | Rhythms stutter. Factory sounds become arrhythmic. Resistance hideout sections drop to acoustic-only (rebel theme). |
| Ashmark | II | Industrial (heavy) | Darker Carradan variant. Deeper percussion, more anvil/forge sounds. Smoke and labor. |
| Bellhaven | II | Pastoral / Industrial | Accordion-forward, lighter. Sea breeze influence — open fifths, rolling wave rhythm. Port town ease. |
| Millhaven | II | Pastoral | Gentle hammered dulcimer, pastoral. Lightest Carradan theme. |
| Millhaven | Interlude+ | Consumed (L4) | Destroyed in the Ley Line Rupture. Silence + wind. No music — only ambient desolation. |
| Ironmouth | II-III | Industrial / Tense | Heavy port. Deep mechanical rhythm, foghorn-like bass tones. Commercial urgency. |
| Caldera | III | Industrial / Urgent | Deep bass drums, forge palette at maximum intensity. Volcanic heat and pressure. |
| Ashport | II | Industrial / Hopeful | Mid-weight Carradan. Trade hub energy, dulcimer and accordion trading phrases. |

### 6.3 Thornmere Wilds Settlements

| Town | Acts | Mood | Music Notes |
|------|------|------|-------------|
| Roothollow | I-II | Pastoral | Gentle flute and harp. Welcoming. Deepest forest feel — nature ambience woven into score. |
| Duskfen | II | Mysterious | Muted hand drums, breathy flute. Fog and wetland. Spirit-hum more prominent than melody. |
| Ashgrove | II | Sacred | Harp-dominant. Reverent. Council stones give the ley-hum harmonic resonance — the earth is singing. Savanh/Caden/Wynne approval shifts the harmonic texture during the council scene. |
| Canopy Reach | II | Hopeful / Sacred | Flute at its brightest. Wind sounds. The panoramic view moment swells to incorporate all three faction palettes in the distance — first continental overview. |
| Greywood Camp | II | Tense / Mysterious | Sparse hand drums, low flute. Ranger outpost on the edge of safe territory. |
| Stillwater Hollow | II | Solemn | Near-silence. Harp notes with long decay. The water reflects sound. |

### 6.4 Cross-Faction / Special Locations

| Location | Acts | Mood | Music Notes |
|----------|------|------|-------------|
| Three Roads Inn | I-II | Neutral / Hopeful | Acoustic warmth. Neutral palette. Traveler's rest — the one place all factions mingle. Gentle, inviting. |
| Maren's Refuge | Interlude | Mysterious / Ancient | Ancient palette. Maren's glass-tone motif as lead. Where the cycle's history is revealed. |
| The Pendulum (tavern) | Epilogue | Hopeful | Sable's pizzicato motif as lead. Warm, acoustic, simple. Every character motif appears as a brief quote — patrons coming and going. Final piece of music in the game. |

## 7. Dungeon Themes

Each dungeon gets a unique atmospheric track. Dungeons blend faction
palettes based on their location and history.

| Dungeon | Act | Palette Blend | Mood | Music Notes |
|---------|-----|--------------|------|-------------|
| Ember Vein | I | Carradan → Ancient | Mysterious → Solemn | Starts with mining sounds (pick strikes, cart wheels). Transitions floor by floor to ancient geometry — mining percussion fades, replaced by crystalline resonance and sustained tones. Floor 4: pure Ancient palette, no faction identity. Ley energy hum and silence. |
| Fenmother's Hollow | II | Thornmere (submerged) | Mysterious | Underwater distortion of Wilds palette. Flute replaced by murky sustained tones. Bubbles and current as percussion. Cleansing sequence: music drains with corruption, floods back as clean Thornmere theme. |
| Valdris Catacombs | II | Valdris (solemn) | Solemn | Slow brass in reverb-heavy space. Echoes of royal marches. Deeper floors = more ancient sound — Valdris predates the monarchy. |
| Corrund Sewers | Interlude | Carradan (dark) | Tense | Industrial palette stripped to bare percussion and dripping. Resistance sections introduce quiet acoustic rebel theme. |
| Axis Tower | III | Carradan (power) | Urgent / Industrial | Ascending — music literally rises in register and intensity floor by floor. Peak Carradan: precision, power, control. |
| Ironmark Citadel | III | Carradan (military) | Urgent / Tense | March tempo. Oppressive brass borrowed from Valdris palette but mechanized. The Compact's answer to royal authority. |
| Frostcap Caverns | II | Neutral (alpine) | Mysterious / Sacred | Crystal-clear acoustics. Sparse — solo instruments with natural reverb. Ice and altitude. No faction identity. |
| Monastery of the Vigil | Interlude | Valdris (sacred) | Sacred → Corrupted | Low sustained strings mimicking monastic chant (instrumental, not vocal). As Pallor influence deepens, the "chant" decomposes into the Pallor motif. |
| Ashgrove Proving Grounds | II | Thornmere + Ancient | Tense / Sacred | Trial ground. Thornmere drums at combat tempo with Ancient crystalline undertone. Spiritual test energy. |
| Grey March Path | III | Overworld variant | Urgent / Solemn | Not a dungeon track — uses Act III overworld variant with encounter-rate tension layered in. Drumbeat underneath like a war march. Dead forest ambience. |
| Valdris Siege (encounter) | II | Valdris (war) | Urgent | Valdris brass at war tempo. Most intense military percussion in the game. Wall breach = instruments drop out, replaced by chaos. Vaelith arrival = hard cut to Pallor motif. |
| The Convergence | III-IV | All palettes merging | Urgent → Sacred → Resolved | Every faction palette present, cycling and compressing. Trial rooms isolate one character's motif in distorted form. Final chamber: all motifs attempt to play simultaneously (cacophony) until party unity resolves them into harmony. |

## 8. Battle Themes

Four tiers of combat music, faction-aware.

### 8.1 Standard Battle

Faction palette of current region at Urgent mood. Short loop (60-90
seconds). Each faction's random encounters sound different:

- **Valdris zones:** Brass and snare-driven
- **Carradan zones:** Mechanical percussion and dulcimer
- **Thornmere zones:** Driving hand drums and aggressive flute
- **Corrupted zones:** Standard battle theme with corruption level applied

### 8.2 Boss Battle

Full orchestral regardless of faction. All three palettes contribute.
Intense, layered, 2-3 minute loop. Character motifs for relevant party
members woven into the arrangement. Each boss fight feels like a convergence
of the world's musical forces.

### 8.3 Vaelith Encounters

Not a standalone theme. Starts with the location's current music. Vaelith's
presence introduces the Pallor motif, which progressively overtakes the
track. Mirrors their narrative arc:

- **Appearance 1-2 (charming scholar):** Pallor motif hidden in pleasant harmonics
- **Appearance 3-4 (true nature revealed):** Motif bare, dissonant, growing
- **Siege encounter (unwinnable):** Pallor motif IS the battle music — oppressive, atonal, overwhelming

### 8.4 Final Battle (3 Phases)

| Phase | Palette | Music Description |
|-------|---------|-------------------|
| Phase 1: Cael (physical) | Full orchestral + corrupted Cael motif | Cael's motif as lead, consumed by Pallor counterpoint. Tragic — you're fighting your friend. Boss battle intensity with an emotional core. |
| Phase 2: Machine activation | Carradan at maximum | Mechanical urgency. Industrial palette pushed to extremes. Lira's motif fighting through — she's the key to this phase. |
| Phase 3: Pallor incarnation | All palettes in conflict → resolution | All character motifs playing simultaneously in dissonance. As party holds, motifs gradually synchronize. Lira forges the weapon: her motif + Cael's clean motif harmonize. Victory = full orchestral resolution of all six motifs in unison — the only moment in the game where every character theme plays together in harmony. |

## 9. Corruption Evolution System

Every location theme has act variants. Rather than composing entirely new
tracks, each variant modifies the original through corruption levels.

### 9.1 Corruption Levels

| Level | Name | Effect on Music |
|-------|------|-----------------|
| 0 | Clean | No modification. |
| 1 | Touched | Sub-audible low drone added. Slight detuning on sustained notes. Player may not consciously notice. |
| 2 | Strained | Audible drone. Lead instrument occasionally wavers in pitch. Tempo drops 5-10%. Ambient layer thins. |
| 3 | Corrupted | Pallor motif replaces counter-melody. Lead instrument breathy/muted. Tempo drops 15-20%. Nature sounds gone. |
| 4 | Consumed | Only Pallor motif and drone remain. Original melody audible as ghost fragments. Reverb collapses to dry, flat sound. |

### 9.2 Location Corruption by Act

Most locations progress through corruption levels across acts:

| Act | Typical Corruption | Notes |
|-----|--------------------|-------|
| I | Level 0 | Clean. The world before the storm. |
| II (early) | Level 0-1 | Touched. Subtle wrongness creeping in. |
| II (late, post-siege) | Level 1-2 | Strained. The cracks are audible. |
| Interlude | Level 2-3 | Corrupted. The Unraveling has happened. |
| III | Level 2-3 (varies) | Some locations recovering (party influence), others worsening. |
| IV / Epilogue | Level 0-1 | Healing. Corruption receding. |

Exceptions: Millhaven jumps to Level 4 (destroyed) at the Interlude.
The Convergence dungeon interior is Level 3-4 throughout.

## 10. Narrative Moment Themes

Event-driven tracks that override location music during story beats.

### 10.1 Major Cutscene Themes

| Moment | Music Treatment |
|--------|----------------|
| Dawn March (opening credits) | Overworld Act I theme in purest form. Edren and Cael's motifs trading phrases — two friends walking into the unknown. Emotional baseline for the entire game. |
| Maren's Warning ("it's a door") | Music drops to Maren's glass-tone motif alone. Single sustained note that doesn't resolve. Unease without drama. |
| Cael's Nightmares (Act II micro-cutscenes) | Cael's motif played backwards/distorted, Pallor motif gaining volume each occurrence. 10 seconds max. Jarring. |
| Thornmere Council | Thornmere sacred palette. Tribal leader approval/disapproval shifts harmonic texture — full approval builds to resonant chord at ley-hum frequency; rejection lets chord collapse. |
| Cael's Last Night | Solo cello (Cael's motif), painfully slow. Each location visited briefly introduces that character's motif underneath. The player doesn't know yet they're saying goodbye. |
| The Betrayal | Cael's motif fully consumed by Pallor motif. Lira's motif plays against it — trying to reach him, failing. Hard cut to silence on his disappearance. |
| Siege of Valdris | Valdris brass at war tempo. Most intense military percussion. Wall breach: instruments drop out, chaos. Vaelith arrival: hard cut to Pallor motif. |
| Ley Line Rupture | Every faction palette shuddering simultaneously (3-5 seconds) — hard cut to absolute silence. Silence holds for 5 full seconds. Single low drone fades in. The Unraveling has begun. |
| Sable's Reunions | Sable's pizzicato motif alone. Each reunion layers the found character's motif. By the fourth, four motifs play together. Player-chosen reunion order determines layering sequence. |
| Campfire Scene (pre-Convergence) | Most intimate track. Acoustic-only, no orchestration. Each character's motif on a single instrument, overlapping like conversation. Fire-crackle ambient. Longest non-looping track — plays through the whole scene. |
| Lira Reaches Cael | Lira's motif and Cael's original clean motif reaching toward each other. Harmonize for exactly one phrase. Then Cael's motif begins to fade. |
| Cael's Sacrifice | Cael's clean motif — the Act I version — alone as he walks into the door. Slowing. Each note further apart. Last note sustains and fades to absolute silence. 3 seconds of nothing. Then the bird call. One note. Alive. |
| Epilogue closing | Overworld Act IV variant. Every character motif woven as fragments. Sable's motif last heard as she opens "The Pendulum" tavern. |

### 10.2 Special Audio Rules

| Rule | Description |
|------|-------------|
| Silence is sacred | True silence (zero audio) appears exactly twice: after the Ley Line Rupture (5s) and before the bird call at Cael's sacrifice (3s). No other moment goes fully silent. |
| The Bird | Not a musical instrument. A real bird call sample — single note, natural, unprocessed. The first non-musical sound in the entire game's score. Nature reasserting itself after Despair. |
| Pallor drone spec | Sustained low tone (sub-bass + low-mid). No harmonic content — as flat and lifeless as possible. Anti-music. |
| Music-as-mechanic | Torren's Spiritcall sidequest restores a corrupted melody in real-time gameplay. The player hears the music heal as they play. |
| Biome crossfade | Standard 3-second crossfade between biome themes (already documented in biomes.md). Pallor Wastes exception: hard cut to silence, then 5-second drone fade-in. |
| Ley Nexus layering | Ley nexus locations blend additively with surrounding biome (hum layers underneath, not replacement). Already documented in biomes.md. |

## 11. Composable Framework for New Content

Any new location, dungeon, or narrative moment can derive its musical
identity from this matrix without custom design.

### 11.1 Step 1: Pick the Faction Palette

Choose from: Valdris, Carradan, Thornmere, Ancient, Neutral (Section 3).
Blend two palettes for cross-faction or transitional spaces.

### 11.2 Step 2: Pick the Mood

| Mood | Tempo | Key Tendency | Dynamics | Texture |
|------|-------|-------------|----------|---------|
| Hopeful | 100-120 BPM | Major / Lydian | Medium, building | Full, layered |
| Tense | 80-100 BPM | Minor / Dorian | Restrained, sudden swells | Sparse with punctuation |
| Solemn | 60-80 BPM | Minor / Aeolian | Quiet, sustained | Thin, reverb-heavy |
| Urgent | 120-140 BPM | Minor / Phrygian | Loud, driving | Dense, percussive |
| Sacred | 60-80 BPM | Modal (Mixolydian) | Quiet to medium | Open fifths, sustained harmonics |
| Mysterious | 70-90 BPM | Chromatic / whole-tone | Quiet, unpredictable | Sparse, detuned |
| Industrial | 100-120 BPM | Minor / Locrian | Steady, mechanical | Rhythmic loops, layered |
| Pastoral | 80-100 BPM | Major / Pentatonic | Gentle | Acoustic, airy |

### 11.3 Step 3: Apply Corruption Level

See Section 9.1 for corruption levels 0-4. Determine the location's
corruption state by act (Section 9.2) and apply modifications.

### 11.4 Step 4: Layer Character Motifs

If any character is narratively relevant to this location, layer their motif
per the rules in Section 4.8.

### 11.5 Example: Composing for a New Dungeon

> "Thornmere Crystal Caves, Act II, light corruption, Torren-focused"
>
> 1. **Palette:** Thornmere + Ancient blend (flute lead, crystalline bells
>    harmony, hand drums + resonance)
> 2. **Mood:** Mysterious (70-90 BPM, chromatic, sparse, detuned)
> 3. **Corruption:** Level 1 (sub-audible drone, slight detuning)
> 4. **Character:** Torren's flute motif carries melody; ley-hum prominent
> 5. **Result:** Sparse crystalline exploration track with Torren's
>    pentatonic melody winding through detuned cave resonance, barely
>    perceptible Pallor drone beneath

## 12. Track Count Summary

| Category | Count | Notes |
|----------|-------|-------|
| Overworld variants | 4 | One composition, four arrangements |
| Town themes | ~20 | Each settlement unique, with act variants per corruption system |
| Dungeon themes | ~12 | Unique per dungeon, palette-blended |
| Battle themes | 4 tiers | Standard (3 faction variants), Boss, Vaelith, Final (3 phases) |
| Narrative moment themes | ~13 | Event-driven overrides |
| Character leitmotifs | 7 | Woven throughout, not standalone tracks |
| **Total unique tracks** | **~50-55** | Plus corruption variants generated from the framework |

## 13. Out of Scope

- Actual music composition or file creation (this is a reference spec)
- Sound effects (footsteps, UI clicks, spell effects)
- Voice acting direction
- Technical audio implementation (file formats, channel mixing, engine integration)
- Music licensing or sourcing (this spec feeds into that process)
