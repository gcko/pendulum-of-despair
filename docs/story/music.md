# Music Score Overview

> **All music is instrumental** — no singing, no vocals, no chanting.
> Choir-like textures use sustained string instruments, not voices.
>
> This document defines every track, motif, and audio rule in the game.
> It is the primary reference for sourcing music from free libraries.
> Each entry specifies instruments, mood, tempo, and narrative context
> so that a music sourcer can find appropriate tracks without playing
> the game.
>
> **Related docs:** [locations.md](locations.md) |
> [dungeons-world.md](dungeons-world.md) |
> [dungeons-city.md](dungeons-city.md) | [events.md](events.md) |
> [characters.md](characters.md) | [dynamic-world.md](dynamic-world.md) |
> [biomes.md](biomes.md)

## Musical Rules

1. **Faction palettes define regional sound.** Each of the three factions has
   a distinct instrument set. Locations inherit their faction's palette.
2. **Character leitmotifs weave through the score.** Seven characters have
   melodic signatures that appear in location and narrative themes.
3. **The Pallor corrupts, it doesn't compose.** The antagonist force has a
   short motif (3-4 descending notes) that infects other music. It never
   gets a full theme of its own.
4. **Music evolves with the world.** Each location's theme has act variants
   — the same melody progressively damaged by the Unraveling, then rebuilt.
5. **Silence is sacred.** Narrative true silence (zero audio, sustained
   for dramatic effect) appears exactly twice: after the Ley Line Rupture
   (5s) and before the bird call at Cael's sacrifice (3s). Other
   moments where music stops (Game Over, the Betrayal, Pallor Wastes
   biome transition) retain ambient sound or transition to drone within
   seconds — these are music-stops, not true silence. The Pallor Wastes
   transition has a brief gap before the drone fades in over 5 seconds
   (per [biomes.md](biomes.md)), but this is a transition effect, not a
   narrative beat.
6. **All music is instrumental.** No singing, no vocals, no chanting.
   Choir-like textures use sustained string instruments, not voices.
7. **The framework is composable.** New locations derive their music from
   the palette + mood + corruption matrix. No custom design needed.

## Faction Palettes

Each faction defines an instrument set that governs all music in its territory.

### Valdris (Kingdom/Military)

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

### Carradan Compact (Industrial/Mercantile)

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

### Thornmere Wilds (Nature/Spiritual)

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

### Ancient (Pre-Civilization Ruins)

| Role | Instruments |
|------|-------------|
| Lead | Crystalline bells, glass tones |
| Harmony | Low sustained drones |
| Rhythm | None or sparse resonance |
| Ambient | Ley energy hum (harmonic, not the Thornmere naturalistic variant) |

**Character:** Timeless, geometric, inhuman. Not threatening — just old
beyond comprehension. The builders are gone; the stones remember.

### Neutral (Cross-Faction / Transitional)

| Role | Instruments |
|------|-------------|
| Lead | Piano or solo acoustic guitar |
| Harmony | Light strings |
| Rhythm | Simple percussion |
| Ambient | Environmental ambience |

**Character:** Unaffiliated spaces. Inns, roads, transitions. Simple and
warm without faction identity.

## Character Leitmotifs

Seven characters have distinct melodic motifs that weave through the score.

### Edren — Duty and Quiet Resolve

A steady, ascending brass phrase over sustained strings. Simple, grounded —
like a soldier's oath spoken aloud. Appears in: Valdris Crown theme, the
Dawn March, siege command moments, and the Act I-II overworld as the melodic
backbone.

### Cael — Warmth That Darkens

A lyrical cello melody, hopeful and earnest. Across Act II, the Pallor's
descending motif appears as a countermelody beneath it, growing louder. By
the betrayal, the Pallor motif has consumed Cael's theme entirely. At his
sacrifice, his original melody returns — clean, uncorrupted — for the first
and last time since Act I. Then silence. Then the bird.

### Lira — Forgewright's Fire

Hammered dulcimer and bright strings — she bridges Valdris and Carradan
palettes. Rhythmic, precise, creative. During the grief arc (Interlude),
her theme slows and loses its rhythmic drive. When she forges the weapon
from Cael's ley energy mid-battle, her motif and Cael's original
uncorrupted motif harmonize for the only time in the game.

### Torren — Spirit-Song

Wooden flute carrying a pentatonic melody, with a ley-hum undertone. His
theme IS the Wilds — they share musical DNA. During the Ley Leech boss
fight, his melody is literally what's being corrupted; restoring it through
Spiritcall is the resolution mechanic. Music-as-gameplay.

### Sable — The Observer

Solo pizzicato strings or plucked lute. Quick, light, always moving. Her
theme appears most prominently during the Interlude when she's the player
character searching for the party. Each reunion layers her motif with the
found character's motif — the ensemble rebuilds around her.

### Maren — Ancient Knowledge

Low strings and a glass-like sustained tone (evoking crystal/ley energy).
Slow, contemplative, slightly unsettling. Carries weight — she knows more
than she says. Appears when lore is revealed, especially "it's a door."

### Vaelith — The Pallor Motif

The Pallor's 3-4 note descending motif IS Vaelith's theme. In early
appearances (charming scholar), it's disguised — played in a major key on
pleasant instruments, almost inviting. Each appearance strips away the
disguise until the motif is bare and dissonant. After their dissolution
("Eight hundred years..."), the motif plays one final time — slowly, almost
gently — then fades.

### Motif Layering Rules

When a character is relevant to a scene, their motif appears. HOW it
appears depends on their narrative role:

| Motif Role | Treatment |
|------------|-----------|
| Primary (scene is about this character) | Motif carries the melody line |
| Supporting (present, not focal) | Counter-melody or harmonic fragment |
| Absent echo (referenced but not present) | Brief quote on a non-native instrument (e.g., Cael's cello motif on glass tones = presence felt through the Pallor) |
| Corrupted (under Pallor influence) | Motif plays with Pallor motif as counterpoint, progressively consumed |

## Overworld Themes

One composition that evolves across four act variants. Edren's motif serves
as the melodic backbone throughout. During the Interlude, the overworld
retains the Stripped variant regardless of which faction zone Sable enters —
the devastation is universal. Faction palette influence returns gradually
in Act III as regions begin to recover.

| Variant | Acts | Arrangement | Mood |
|---------|------|-------------|------|
| Full Orchestral | I-II | All three faction palettes layered — brass foundation, dulcimer counter-rhythms, flute ornamentation. Hopeful, adventurous, forward-moving. | The world is troubled but alive. |
| Stripped | Interlude | Same melody reduced to solo instrument (harp or music box). Sparse. Pallor motif pulses underneath like a heartbeat. | The world lost its voice. |
| Rebuilding | III | Instruments return one by one as the party reunites. Nearly full orchestration by the march — but minor key. Pallor motif audible but melody pushes through. | Determined, not hopeful. |
| Renewed | IV / Epilogue | Original Act I melody in full, transposed up. Brighter. Pallor motif absent for the first time. Fragments of every character theme woven in as counter-melodies. | Changed but whole. |

## Town Themes

See [city-valdris.md](city-valdris.md), [city-carradan.md](city-carradan.md), [city-thornmere.md](city-thornmere.md) for settlement details.

Each settlement gets a unique theme built from its faction palette + mood.
Themes have act variants per the corruption evolution system. Towns listed
for a single act range are only visited in that state — no additional
variants needed. Multi-visit towns show separate rows per act state.

### Valdris Faction Towns

| Town | Acts | Corruption Stage | Mood | Music Notes |
|------|------|-----------------|------|-------------|
| Valdris Crown | I-II | Stage 0-1 | Hopeful / Solemn | Proud, bustling. Brass fanfare on entry, settles into warm strings. Royal court undertone. Edren's motif as harmonic foundation. |
| Valdris Crown | Interlude+ | Stage 2 | Corrupted | Muted horn over empty streets. Military snare replaces court strings — Cordwyn's de facto command. Ghost of the original fanfare in reverb. |
| Aelhart | I | Stage 0 | Pastoral | Lighter brass, pastoral strings. Small-town warmth. Market day feel. Relaxed tempo. Inaccessible after Act I (border road too dangerous). |
| Highcairn | Interlude | Stage 1-2 | Solemn / Sacred | Monastery setting. Low sustained strings, sparse brass. Deeper areas introduce Stage 2 corruption where Pallor manifestations appear. |
| Thornwatch | II | Stage 0-1 | Tense | Martial Valdris variant. Drums prominent, brass restrained. Border watchtower vigil. |
| Greyvale | I-II | Stage 0 | Pastoral / Solemn | Rural Valdris. Gentle strings, distant horn. |
| Greyvale | Interlude+ | Stage 2 | Corrupted | Pastoral melody struggles against Pallor drone. Strings thin. |

### Carradan Compact Towns

| Town | Acts | Corruption Stage | Mood | Music Notes |
|------|------|-----------------|------|-------------|
| Corrund | I-II | Stage 0 | Industrial / Hopeful | Full Carradan palette. Layered rhythms, merchant energy, hammered dulcimer lead. Busiest track in the game. |
| Corrund | Interlude+ | Stage 1-2 | Corrupted | Rhythms stutter. Factory sounds become arrhythmic. Resistance hideout sections drop to acoustic-only (rebel theme). |
| Ashmark | II | Stage 0 | Industrial (heavy) | Darker Carradan variant. Deeper percussion, more anvil/forge sounds. Smoke and labor. |
| Bellhaven | II | Stage 0 | Pastoral / Industrial | Accordion-forward, lighter. Sea breeze influence — open fifths, rolling wave rhythm. Port town ease. |
| Millhaven | II | Stage 0 | Pastoral | Gentle hammered dulcimer, pastoral. Lightest Carradan theme. |
| Millhaven | Interlude+ | Destroyed | Silence | Physically destroyed by Ley Line Rupture — not Pallor-consumed. No music. Wind ambience only. |
| Ironmouth | I-II | Stage 0-1 | Industrial / Tense | Heavy port. Deep mechanical rhythm, foghorn-like bass tones. Commercial urgency. Accessible from Act I (Ember Vein mine entrance, Dawn March origin). |
| Caldera | III | Stage 1 | Industrial / Urgent | Deep bass drums, forge palette at maximum intensity. Volcanic heat and pressure. |
| Ashport | II | Stage 0 | Industrial / Hopeful | Mid-weight Carradan. Trade hub energy, dulcimer and accordion trading phrases. |
| Gael's Span | II-III | Stage 0-1 | Neutral + Carradan | Cross-faction bridge town. Neutral palette base with Carradan undercurrent. Trade and tension — factions meet here. |
| Kettleworks | II-III | Stage 0-1 | Industrial / Mysterious | Research campus. Lighter Carradan with Ancient palette influence — experimental tech meets ley energy. Curious, inventive. |

### Thornmere Wilds Settlements

| Town | Acts | Corruption Stage | Mood | Music Notes |
|------|------|-----------------|------|-------------|
| Roothollow | I-II | Stage 0 | Pastoral | Gentle flute and harp. Welcoming. Deepest forest feel — nature ambience woven into score. |
| Duskfen | II | Stage 0 | Mysterious | Muted hand drums, breathy flute. Fog and wetland. Spirit-hum more prominent than melody. |
| Ashgrove | II | Stage 0 | Sacred | Harp-dominant. Reverent. Council stones give the ley-hum harmonic resonance — the earth is singing. |
| Canopy Reach | II | Stage 0 | Hopeful / Sacred | Flute at its brightest. Wind sounds. The panoramic view moment swells to incorporate all three faction palettes in the distance — first continental overview. |
| Greywood Camp | II | Stage 0 | Tense / Mysterious | Sparse hand drums, low flute. Ranger outpost on the edge of safe territory. |
| Stillwater Hollow | II | Stage 0 | Solemn | Near-silence. Harp notes with long decay. The water reflects sound. |
| Sunstone Ridge | II-Interlude | Stage 0-1 | Sacred / Tense | Ley nexus guardian camp. Thornmere drums with prominent ley-hum harmonic layer. Spiritual vigilance — the guardians are watching the energy. |
| Deeproot Shrine | II | Stage 0 | Sacred | Deep Thornmere. Harp and ley-hum dominant. Ancient growth. |

### Cross-Faction / Special Locations

| Location | Acts | Mood | Music Notes |
|----------|------|------|-------------|
| Three Roads Inn | I-II | Neutral / Hopeful | Acoustic warmth. Neutral palette. Traveler's rest — the one place all factions mingle. Gentle, inviting. |
| Maren's Refuge | Interlude | Mysterious / Ancient | Ancient palette. Maren's glass-tone motif as lead. Where the cycle's history is revealed. |
| The Pendulum (tavern) | Epilogue | Hopeful | Sable's pizzicato motif as lead. Warm, acoustic, simple. Every character motif appears as a brief quote — patrons coming and going. Final piece of music in the game. |

## Dungeon Themes

See [dungeons-world.md](dungeons-world.md) and [dungeons-city.md](dungeons-city.md) for dungeon layouts.

Each dungeon gets a unique atmospheric track. Dungeons blend faction
palettes based on their location and history. City dungeons (sewers,
undercities, secret passages) use a darkened variant of their parent city's
theme unless specified otherwise — the same palette at Tense or Mysterious
mood with reduced instrumentation.

### World Dungeons

| Dungeon | Act | Palette Blend | Mood | Music Notes |
|---------|-----|--------------|------|-------------|
| Ember Vein | I | Carradan → Ancient | Mysterious → Solemn | Starts with mining sounds (pick strikes, cart wheels). Transitions floor by floor to ancient geometry — mining percussion fades, replaced by crystalline resonance and sustained tones. Floor 4: pure Ancient palette, no faction identity. Ley energy hum and silence. |
| Fenmother's Hollow | II | Thornmere (submerged) | Mysterious | Underwater distortion of Wilds palette. Flute replaced by murky sustained tones. Bubbles and current as percussion. Cleansing sequence: music drains with corruption, floods back as clean Thornmere theme. |
| Frostcap Caverns | Interlude-III | Neutral (alpine) | Mysterious / Sacred | Crystal-clear acoustics. Sparse — solo instruments with natural reverb. Ice and altitude. No faction identity. |
| Windshear Peak | II-III | Neutral (alpine) | Tense / Sacred | High-altitude wind as rhythmic base. Sparse brass and strings fighting the wind. Exposed, elemental. |
| Ashgrove Proving Grounds | II | Thornmere + Ancient | Tense / Sacred | Trial ground. Thornmere drums at combat tempo with Ancient crystalline undertone. Spiritual test energy. |
| Carradan Rail Tunnels | II-Interlude | Carradan (dark) | Tense / Industrial | Echoing mechanical palette. Train-rhythm percussion (clack-clack tempo). Darkness and distance. Collapse sections: rhythm breaks apart. |
| Ley Line Depths | II-III | Ancient + Thornmere | Sacred / Mysterious | Deep underground ley channels. Ancient palette dominant, Thornmere hum woven in. Crystalline resonance at maximum. The music feels like the planet's heartbeat. |
| Archive of Ages | II-III | Ancient | Solemn / Mysterious | Pure Ancient palette. Glass tones and sustained drones. Vast, echoing, cataloguing millennia. Maren's motif as harmonic undercurrent. |
| Monastery of the Vigil (Highcairn) | Interlude | Valdris (sacred) | Sacred → Corrupted | Low sustained strings mimicking monastic chant (instrumental, not vocal). As Pallor influence deepens, the "chant" decomposes into the Pallor motif. |
| Corrund Sewers | Interlude | Carradan (dark) | Tense | Industrial palette stripped to bare percussion and dripping. Resistance sections introduce quiet acoustic rebel theme. |
| Ley Nexus Hollow | Interlude | Thornmere + Ancient | Sacred / Urgent | Torren's reunion location. His flute motif corrupted by Ley Leech — the music IS the boss fight. Thornmere palette at maximum spiritual intensity. |
| Sunken Rig | Interlude | Carradan (submerged) | Mysterious / Tense | Underwater-distorted industrial palette. Drowned machinery sounds. Accordion replaced by murky sustained tones. Eerie. |
| Dry Well of Aelhart | Interlude+ | Valdris + Ancient | Solemn / Mysterious | Beneath Aelhart. Starts Valdris but transitions to Ancient as depth increases. Drought and abandonment — dry acoustics, no reverb. |
| Axis Tower | Interlude | Carradan (power) | Urgent / Industrial | Ascending — music literally rises in register and intensity floor by floor. Peak Carradan: precision, power, control. |
| Caldera Forge Depths | II/Interlude | Carradan (volcanic) | Urgent / Industrial | Deepest forge. Bass drums and anvil strikes at maximum. Heat shimmer as ambient. Carradan industrial pushed past safe limits. |
| Thornvein Passage | III | Thornmere (corrupted) | Tense / Mysterious | Corrupted root network. Thornmere palette at Stage 2-3 corruption. Flute pitchless, hand drums irregular. The forest is sick. |
| Pallor Wastes | III | Pallor dominant | Consumed | The Pallor motif as a sustained, cycling drone. Ghost fragments of all three faction palettes drift in and out — memories of the world before. No melody, no rhythm, no structure. Anti-music given geography. Vaelith encounter sections intensify the motif to dissonant layering. |
| The Grey March | III | Overworld variant | Urgent / Solemn | Uses Act III overworld variant with encounter-rate tension layered in. Drumbeat underneath like a war march. Dead forest ambience. |
| The Convergence | III-IV | All palettes merging | Urgent → Sacred → Resolved | Every faction palette present, cycling and compressing. Trial rooms isolate one character's motif in distorted form. Final chamber: all motifs attempt to play simultaneously (cacophony) until party unity resolves them into harmony. |
| Valdris Siege Battlefield | II | Valdris (war) | Urgent | Valdris brass at war tempo. Most intense military percussion in the game. Wall breach = instruments drop out, replaced by chaos. Vaelith arrival = hard cut to Pallor motif. |
| Dreamer's Fault | Post-game | Ancient + Pallor residue | Mysterious / Solemn | Post-game optional. Ancient palette with lingering Pallor echoes — corruption receding but not gone. Contemplative, archaeological. |

### City Dungeons

City dungeons use a darkened variant of their parent city's theme unless
noted otherwise. Same faction palette, shifted to Tense or Mysterious mood,
reduced instrumentation.

| Dungeon | Parent City | Mood Shift | Music Notes |
|---------|-------------|-----------|-------------|
| Valdris Crown Catacombs | Valdris Crown | Solemn | Unique track: slow brass in reverb-heavy space. Echoes of royal marches. Deeper floors = more ancient sound — Valdris predates the monarchy. Interlude (mandatory escape route), optional return post-Interlude. |
| Ironmark Citadel Dungeons | Ironmark Citadel | Urgent / Tense | Unique track: march tempo. Oppressive brass borrowed from Valdris palette but mechanized. Stage 2 corruption deliberately embraced by Kole — the Pallor motif is woven in intentionally, not as decay but as power. Interlude (reached via Axis Tower tunnel). |
| Corrund Sewers | Corrund | Industrial → Tense | See world dungeons above (unique track due to Resistance narrative). |
| Caldera Undercity | Caldera | Urgent → Tense | Caldera's forge intensity muted by stone. Deep percussion remains, dulcimer echoes off tunnel walls. |
| Ashmark Factory Depths | Ashmark | Industrial → Mysterious | Factory rhythms continue below but distorted by depth. Machinery sounds become alien at lower levels. |
| Bellhaven Smuggler Tunnels | Bellhaven | Pastoral → Tense | Bellhaven's accordion and wave rhythm replaced by dripping water and hushed urgency. Compact palette stripped to bare bones. |
| Secret Passages / Hidden Rooms | Various | Parent city -30% volume | Parent city theme at reduced volume with reverb. Dampened — the player is between walls. Not a unique track; a processing rule. |

## Battle Themes

Four tiers of combat music, faction-aware.

### Standard Battle

Faction palette of current region at Urgent mood. Short loop (60-90
seconds). Each faction's random encounters sound different:

- **Valdris zones:** Brass and snare-driven
- **Carradan zones:** Mechanical percussion and dulcimer
- **Thornmere zones:** Driving hand drums and aggressive flute
- **Corrupted zones:** Standard battle theme with corruption level applied
- **Ancient/Neutral zones:** Boss battle palette at reduced intensity

### Boss Battle

Full orchestral regardless of faction. All three palettes contribute.
Intense, layered, 2-3 minute loop. Character motifs for relevant party
members woven into the arrangement. Each boss fight feels like a convergence
of the world's musical forces.

### Vaelith Encounters

Not a standalone theme. Starts with the location's current music. Vaelith's
presence introduces the Pallor motif, which progressively overtakes the
track. Mirrors their narrative arc:

- **Appearance 1-2 (charming scholar):** Pallor motif hidden in pleasant harmonics
- **Appearance 3-4 (true nature revealed):** Motif bare, dissonant, growing
- **Siege encounter (unwinnable):** Pallor motif IS the battle music — oppressive, atonal, overwhelming

### Final Battle (3 Phases)

The "six motifs in unison" at Phase 3 victory refers to the six party
members' motifs (Edren, Cael's clean version, Lira, Torren, Sable, Maren).
Vaelith has dissolved before this point and is absent.

| Phase | Palette | Music Description |
|-------|---------|-------------------|
| Phase 1: Cael (physical) | Full orchestral + corrupted Cael motif | Cael's motif as lead, consumed by Pallor counterpoint. Tragic — you're fighting your friend. Boss battle intensity with an emotional core. |
| Phase 2: Machine activation | Carradan at maximum | Mechanical urgency. Industrial palette pushed to extremes. Lira's motif fighting through — she's the key to this phase. |
| Phase 3: Pallor incarnation | All palettes in conflict → resolution | All six party member motifs playing simultaneously in dissonance. As party holds, motifs gradually synchronize. Lira forges the weapon: her motif + Cael's clean motif harmonize. Victory = full orchestral resolution of all six motifs in unison — the only moment in the game where every character theme plays together in harmony. |

## Corruption Evolution System

Every location theme has act variants. Rather than composing entirely new
tracks, each variant modifies the original through corruption stages.

**Terminology note:** [biomes.md](biomes.md) defines a 3-stage Pallor
overlay system (Stages 1-3) for visual corruption;
[dynamic-world.md](dynamic-world.md) uses Stages 0-3 for location state
tracking. This music system maps to those stages for audio effects (Stage
0 = clean/no corruption, Stages 1-3 = audio equivalents of the visual
corruption levels). Stage 4 ("Consumed") is a music-specific extension
for locations where Pallor corruption has completely replaced the original
soundscape (e.g., Pallor Wastes). Note: Millhaven is physically destroyed
by ley line eruption (not Pallor corruption) and uses silence + wind
ambience instead of Stage 4 — see Special Cases below.

### Corruption Stages

| Stage | Name | Effect on Music |
|-------|------|-----------------|
| 0 | Clean | No modification. |
| 1 | Touched | Sub-audible low drone added. Slight detuning on sustained notes. Player may not consciously notice. |
| 2 | Strained | Audible drone. Lead instrument occasionally wavers in pitch. Tempo drops 5-10%. Ambient layer thins. |
| 3 | Corrupted | Pallor motif replaces counter-melody. Lead instrument breathy/muted. Tempo drops 15-20%. Nature sounds gone. |
| 4 | Consumed | Only Pallor motif and drone remain. Original melody audible as ghost fragments. Reverb collapses to dry, flat sound. |

### Location Corruption by Act

Most locations progress through corruption stages across acts. These align
with the staging in [dynamic-world.md](dynamic-world.md):

| Act | Typical Corruption | Notes |
|-----|--------------------|-------|
| I | Stage 0 | Clean. The world before the storm. |
| II (early) | Stage 0-1 | Touched. Subtle wrongness creeping in. |
| II (late, post-siege) | Stage 1-2 | Strained. The cracks are audible. |
| Interlude | Stage 1-3 (varies by location) | The Unraveling. See per-location entries in Town Themes for specific stages. |
| III | Stage 1-3 (varies) | Some locations recovering (party influence), others worsening. |
| IV / Epilogue | Stage 0-1 | Healing. Corruption receding. |

**Special cases:**
- Millhaven: physically destroyed at the Interlude (not Pallor-consumed — ley line eruption). No corruption stage applies; silence + wind.
- The Convergence: Stage 3-4 throughout (the Pallor's stronghold).
- Ironmark Citadel: Stage 2 corruption deliberately embraced by Kole — treated as empowerment, not decay.

## Narrative Moment Themes

See [events.md](events.md) for flag definitions and [outline.md](outline.md) for story structure.

Event-driven tracks that override location music during story beats.

### Major Cutscene Themes

| Moment | Music Treatment |
|--------|----------------|
| Dawn March (opening credits) | Overworld Act I theme in purest form. Edren and Cael's motifs trading phrases — two friends walking into the unknown. Emotional baseline for the entire game. |
| Maren's Warning ("it's a door") | Music drops to Maren's glass-tone motif alone. Single sustained note that doesn't resolve. Unease without drama. |
| Vaelith's Village Compassion | Location theme continues but Vaelith's disguised Pallor motif (major key, pleasant instruments) layers in warmly. The player should feel comforted. The horror comes later when they recognize this melody stripped bare. |
| Cael's Nightmares (Act II micro-cutscenes) | Cael's motif played backwards/distorted, Pallor motif gaining volume each occurrence. 10 seconds max. Jarring. |
| Thornmere Council | Thornmere sacred palette. Tribal leader approval/disapproval shifts harmonic texture — full approval builds to resonant chord at ley-hum frequency; rejection lets chord collapse. |
| Cael's Last Night | Solo cello (Cael's motif), painfully slow. Each location visited briefly introduces that character's motif underneath. The player doesn't know yet they're saying goodbye. |
| The Betrayal | Cael's motif fully consumed by Pallor motif. Lira's motif plays against it — trying to reach him, failing. Hard cut to silence on his disappearance. (Not true silence — ambient city sound remains. The MUSIC stops.) |
| Siege of Valdris | Valdris brass at war tempo. Most intense military percussion. Wall breach: instruments drop out, chaos. Vaelith arrival: hard cut to Pallor motif. |
| Ley Line Rupture | Every faction palette shuddering simultaneously (3-5 seconds) — hard cut to absolute silence. Silence holds for 5 full seconds. Single low drone fades in. The Unraveling has begun. (First of two true silences.) |
| Sable's Reunions | Sable's pizzicato motif alone. Each reunion layers the found character's motif. By the fourth, four motifs play together. Player-chosen reunion order determines layering sequence. |
| The March (walk-and-talk to Convergence) | Act III overworld at full rebuild. The party is together. Edren's motif leads, other motifs layer in as characters speak. Walking tempo — not urgent, resolute. Transitions to The Grey March route theme as encounters begin. |
| Campfire Scene (pre-Convergence) | Most intimate track. Acoustic-only, no orchestration. Each character's motif on a single instrument, overlapping like conversation. Fire-crackle ambient. Longest non-looping track — plays through the whole scene. |
| Lira Reaches Cael | Lira's motif and Cael's original clean motif reaching toward each other. Harmonize for exactly one phrase. Then Cael's motif begins to fade. |
| The Farewell | Transition from battle victory to sacrifice. Full orchestral resolution fades to solo instruments one by one. Party members' motifs drop out as focus narrows to Cael. Edren's motif plays a quiet phrase — the last thing between friends. |
| Cael's Sacrifice | Cael's clean motif — the Act I version — alone as he walks into the door. Slowing. Each note further apart. Last note sustains and fades to absolute silence. 3 seconds of nothing. Then the bird call. One note. Alive. (Second of two true silences.) |
| Edren at the Meadow | Edren's motif alone, played on a single instrument (not brass — perhaps acoustic guitar or harp). Stripped of duty and authority. Just a man placing his friend's sword. Quiet. |
| Epilogue closing | Overworld Act IV variant. Every character motif woven as fragments. Sable's motif last heard as she opens "The Pendulum" tavern. |

### Special Audio Rules

| Rule | Description |
|------|-------------|
| Silence is sacred | Narrative true silence (zero audio, sustained for dramatic effect) appears exactly twice: after the Ley Line Rupture (5s) and before the bird call at Cael's sacrifice (3s). Other music-stops (Game Over, Betrayal, Pallor Wastes transition) retain ambient sound or transition to drone — these are not true silence. |
| The Bird | Not a musical instrument. A real bird call sample — single note, natural, unprocessed. The first non-musical sound in the entire game's score. Nature reasserting itself after Despair. |
| Pallor drone spec | Sustained low tone (sub-bass + low-mid). No harmonic content — as flat and lifeless as possible. Anti-music. |
| Music-as-mechanic | Torren's Spiritcall ability restores a corrupted melody during the Ley Leech boss fight (Interlude main story). The player hears the music heal in real-time as gameplay. |
| Biome crossfade | Standard 3-second crossfade between biome themes (documented in [biomes.md](biomes.md)). Pallor Wastes exception: hard cut to silence, then Pallor drone fades in over 5 seconds. The brief silence between is deliberate but is not one of the two "sacred" true silences — it is a transition effect, not a narrative beat. Per biomes.md "The Pallor Wastes" section. |
| Ley Nexus layering | Ley nexus locations blend additively with surrounding biome (hum layers underneath, not replacement). Documented in biomes.md. |

## System & UI Music

Standard JRPG music cues for non-narrative game systems.

| Cue | Duration | Style | Notes |
|-----|----------|-------|-------|
| Title Screen | Loop | Overworld Act I theme, orchestral arrangement. Establishes the game's identity before the player presses start. | Full production quality — first impression. |
| Victory Fanfare | 5-8s | Brass-led celebratory phrase. Valdris palette — Edren's motif fragment as the melodic hook. | Plays after every standard battle. Must not fatigue after hundreds of plays. Short, punchy, satisfying. |
| Level Up | 2-3s | Ascending arpeggio — crystalline bells over brass swell. Ancient + Valdris blend. | Layered on top of victory fanfare when applicable. |
| Item Acquisition | 1-2s | Single bright chime followed by a short melodic phrase. Neutral palette. | Treasure chests and field pickups. Iconic, recognizable. |
| Save Point | 3-5s | Gentle harp arpeggio with ley-hum fade. Thornmere palette — save points are ley-crystal formations. | Warmth and safety. Brief comfort before continuing. |
| Inn / Rest | 8-10s | Soft acoustic passage. Neutral palette. Resolves on a warm major chord as HP/MP restore. | Plays over the rest animation. |
| Shop | Loop (short) | Light arrangement of the current town's theme. Same palette, reduced to lead + rhythm only. More casual, transactional. | Not a unique track — a processing rule applied to the town theme. |
| Game Over / Reload | 4s | The fast-reload sequence from [events.md](events.md) section 2c. Last Faint animation, fade to black, instant reload. Music stops on Faint (not true silence — ambient sound continues during the 2s fade to black), then save point jingle on reload. | No "Game Over" screen or unique game-over theme. |
| Menu Screen | None | No unique menu music. The current location/overworld theme continues playing underneath the menu UI. | Maintains immersion. No jarring music switch when pausing. |

## Composable Framework for New Content

Any new location, dungeon, or narrative moment can derive its musical
identity from this matrix without custom design.

### Step 1: Pick the Faction Palette

Choose from: Valdris, Carradan, Thornmere, Ancient, Neutral (see Faction Palettes).
Blend two palettes for cross-faction or transitional spaces.

### Step 2: Pick the Mood

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

### Step 3: Apply Corruption Stage

See Corruption Stages for stages 0-4. Determine the location's
corruption state by act (Location Corruption by Act) and apply modifications.

### Step 4: Layer Character Motifs

If any character is narratively relevant to this location, layer their motif
per the rules in Motif Layering Rules.

### Example: Composing for a New Dungeon

> "Thornmere Crystal Caves, Act II, light corruption, Torren-focused"
>
> 1. **Palette:** Thornmere + Ancient blend (flute lead, crystalline bells
>    harmony, hand drums + resonance)
> 2. **Mood:** Mysterious (70-90 BPM, chromatic, sparse, detuned)
> 3. **Corruption:** Stage 1 (sub-audible drone, slight detuning)
> 4. **Character:** Torren's flute motif carries melody; ley-hum prominent
> 5. **Result:** Sparse crystalline exploration track with Torren's
>    pentatonic melody winding through detuned cave resonance, barely
>    perceptible Pallor drone beneath

## Track Count Summary

| Category | Count | Notes |
|----------|-------|-------|
| Overworld variants | 4 | One composition, four arrangements |
| Town themes | ~25 | Each settlement unique, with act variants per corruption system |
| Dungeon themes (world) | ~22 | Unique per dungeon, palette-blended |
| Dungeon themes (city) | ~4 unique + rule | Unique city dungeons + "parent theme darkened" rule for secret passages |
| Battle themes | 4 tiers | Standard (3 faction variants + corrupted), Boss, Vaelith, Final (3 phases) |
| Narrative moment themes | ~17 | Event-driven overrides |
| System/UI cues | ~8 | Title, victory, level up, item, save, inn, game over, shop (rule-based) |
| Character leitmotifs | 7 | Woven throughout, not standalone tracks |
| **Total unique tracks** | **~70-80** | Plus corruption variants and rule-based derivatives |
