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
   in the entire game: after the Ley Line Rupture (5s) and before the bird
   call at Cael's sacrifice (3s). Every other moment has at least ambient
   sound or drone. The Pallor Wastes hard-cut transition uses drone (not
   true silence) — it fades in within 1 second.
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

## 6. Town Themes

Each settlement gets a unique theme built from its faction palette + mood.
Themes have act variants per Section 9 (corruption evolution). Towns listed
for a single act range are only visited in that state — no additional
variants needed. Multi-visit towns show separate rows per act state.

### 6.1 Valdris Faction Towns

| Town | Acts | Corruption Stage | Mood | Music Notes |
|------|------|-----------------|------|-------------|
| Valdris Crown | I-II | Stage 0-1 | Hopeful / Solemn | Proud, bustling. Brass fanfare on entry, settles into warm strings. Royal court undertone. Edren's motif as harmonic foundation. |
| Valdris Crown | Interlude+ | Stage 2 | Corrupted | Muted horn over empty streets. Military snare replaces court strings — Cordwyn's de facto command. Ghost of the original fanfare in reverb. |
| Aelhart | I | Stage 0 | Pastoral | Lighter brass, pastoral strings. Small-town warmth. Market day feel. Relaxed tempo. Inaccessible after Act I (border road too dangerous). |
| Highcairn | Interlude | Stage 1-2 | Solemn / Sacred | Monastery setting. Low sustained strings, sparse brass. Deeper areas introduce Stage 2 corruption where Pallor manifestations appear. |
| Thornwatch | II | Stage 0-1 | Tense | Martial Valdris variant. Drums prominent, brass restrained. Border watchtower vigil. |
| Greyvale | I-II | Stage 0 | Pastoral / Solemn | Rural Valdris. Gentle strings, distant horn. |
| Greyvale | Interlude+ | Stage 2 | Corrupted | Pastoral melody struggles against Pallor drone. Strings thin. |

### 6.2 Carradan Compact Towns

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

### 6.3 Thornmere Wilds Settlements

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

### 6.4 Cross-Faction / Special Locations

| Location | Acts | Mood | Music Notes |
|----------|------|------|-------------|
| Three Roads Inn | I-II | Neutral / Hopeful | Acoustic warmth. Neutral palette. Traveler's rest — the one place all factions mingle. Gentle, inviting. |
| Maren's Refuge | Interlude | Mysterious / Ancient | Ancient palette. Maren's glass-tone motif as lead. Where the cycle's history is revealed. |
| The Pendulum (tavern) | Epilogue | Hopeful | Sable's pizzicato motif as lead. Warm, acoustic, simple. Every character motif appears as a brief quote — patrons coming and going. Final piece of music in the game. |

## 7. Dungeon Themes

Each dungeon gets a unique atmospheric track. Dungeons blend faction
palettes based on their location and history. City dungeons (sewers,
undercities, secret passages) use a darkened variant of their parent city's
theme unless specified otherwise — the same palette at Tense or Mysterious
mood with reduced instrumentation.

### 7.1 World Dungeons

| Dungeon | Act | Palette Blend | Mood | Music Notes |
|---------|-----|--------------|------|-------------|
| Ember Vein | I | Carradan → Ancient | Mysterious → Solemn | Starts with mining sounds (pick strikes, cart wheels). Transitions floor by floor to ancient geometry — mining percussion fades, replaced by crystalline resonance and sustained tones. Floor 4: pure Ancient palette, no faction identity. Ley energy hum and silence. |
| Fenmother's Hollow | II | Thornmere (submerged) | Mysterious | Underwater distortion of Wilds palette. Flute replaced by murky sustained tones. Bubbles and current as percussion. Cleansing sequence: music drains with corruption, floods back as clean Thornmere theme. |
| Valdris Crown Catacombs | Interlude | Valdris (solemn) | Solemn | Slow brass in reverb-heavy space. Echoes of royal marches. Deeper floors = more ancient sound — Valdris predates the monarchy. |
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
| Axis Tower | III | Carradan (power) | Urgent / Industrial | Ascending — music literally rises in register and intensity floor by floor. Peak Carradan: precision, power, control. |
| Ironmark Citadel | III | Carradan (military) | Urgent / Tense | March tempo. Oppressive brass borrowed from Valdris palette but mechanized. Stage 2 corruption deliberately embraced by Kole — the Pallor motif is woven in intentionally, not as decay but as power. |
| Caldera Forge Depths | III | Carradan (volcanic) | Urgent / Industrial | Deepest forge. Bass drums and anvil strikes at maximum. Heat shimmer as ambient. Carradan industrial pushed past safe limits. |
| Thornvein Passage | III | Thornmere (corrupted) | Tense / Mysterious | Corrupted root network. Thornmere palette at Stage 2-3 corruption. Flute pitchless, hand drums irregular. The forest is sick. |
| Pallor Wastes | III | Pallor dominant | Consumed | The Pallor motif as a sustained, cycling drone. Ghost fragments of all three faction palettes drift in and out — memories of the world before. No melody, no rhythm, no structure. Anti-music given geography. Vaelith encounter sections intensify the motif to dissonant layering. |
| The Grey March | III | Overworld variant | Urgent / Solemn | Uses Act III overworld variant with encounter-rate tension layered in. Drumbeat underneath like a war march. Dead forest ambience. |
| The Convergence | III-IV | All palettes merging | Urgent → Sacred → Resolved | Every faction palette present, cycling and compressing. Trial rooms isolate one character's motif in distorted form. Final chamber: all motifs attempt to play simultaneously (cacophony) until party unity resolves them into harmony. |
| Valdris Siege (encounter) | II | Valdris (war) | Urgent | Valdris brass at war tempo. Most intense military percussion in the game. Wall breach = instruments drop out, replaced by chaos. Vaelith arrival = hard cut to Pallor motif. |
| Dreamer's Fault | Post-game | Ancient + Pallor residue | Mysterious / Solemn | Post-game optional. Ancient palette with lingering Pallor echoes — corruption receding but not gone. Contemplative, archaeological. |

### 7.2 City Dungeons

City dungeons use a darkened variant of their parent city's theme unless
noted otherwise. Same faction palette, shifted to Tense or Mysterious mood,
reduced instrumentation.

| Dungeon | Parent City | Mood Shift | Music Notes |
|---------|-------------|-----------|-------------|
| Corrund Sewers | Corrund | Industrial → Tense | See world dungeons above (unique track due to Resistance narrative). |
| Caldera Undercity | Caldera | Urgent → Tense | Caldera's forge intensity muted by stone. Deep percussion remains, dulcimer echoes off tunnel walls. |
| Ashmark Factory Depths | Ashmark | Industrial → Mysterious | Factory rhythms continue below but distorted by depth. Machinery sounds become alien at lower levels. |
| Bellhaven Smuggler Tunnels | Bellhaven | Pastoral → Tense | Bellhaven's accordion and wave rhythm replaced by dripping water and hushed urgency. Compact palette stripped to bare bones. |
| Secret Passages / Hidden Rooms | Various | Parent city -30% volume | Parent city theme at reduced volume with reverb. Dampened — the player is between walls. Not a unique track; a processing rule. |

## 8. Battle Themes

Four tiers of combat music, faction-aware.

### 8.1 Standard Battle

Faction palette of current region at Urgent mood. Short loop (60-90
seconds). Each faction's random encounters sound different:

- **Valdris zones:** Brass and snare-driven
- **Carradan zones:** Mechanical percussion and dulcimer
- **Thornmere zones:** Driving hand drums and aggressive flute
- **Corrupted zones:** Standard battle theme with corruption level applied
- **Ancient/Neutral zones:** Boss battle palette at reduced intensity

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

The "six motifs in unison" at Phase 3 victory refers to the six party
members' motifs (Edren, Cael's clean version, Lira, Torren, Sable, Maren).
Vaelith has dissolved before this point and is absent.

| Phase | Palette | Music Description |
|-------|---------|-------------------|
| Phase 1: Cael (physical) | Full orchestral + corrupted Cael motif | Cael's motif as lead, consumed by Pallor counterpoint. Tragic — you're fighting your friend. Boss battle intensity with an emotional core. |
| Phase 2: Machine activation | Carradan at maximum | Mechanical urgency. Industrial palette pushed to extremes. Lira's motif fighting through — she's the key to this phase. |
| Phase 3: Pallor incarnation | All palettes in conflict → resolution | All six party member motifs playing simultaneously in dissonance. As party holds, motifs gradually synchronize. Lira forges the weapon: her motif + Cael's clean motif harmonize. Victory = full orchestral resolution of all six motifs in unison — the only moment in the game where every character theme plays together in harmony. |

## 9. Corruption Evolution System

Every location theme has act variants. Rather than composing entirely new
tracks, each variant modifies the original through corruption stages.

**Terminology note:** Stages 0-3 align with the corruption system in
`dynamic-world.md` and `biomes.md`. Stage 4 ("Consumed") is a
music-specific extension for locations where corruption has completely
replaced the original soundscape (Pallor Wastes, destroyed Millhaven).
"Stage" is the canonical term across all story docs.

### 9.1 Corruption Stages

| Stage | Name | Effect on Music |
|-------|------|-----------------|
| 0 | Clean | No modification. |
| 1 | Touched | Sub-audible low drone added. Slight detuning on sustained notes. Player may not consciously notice. |
| 2 | Strained | Audible drone. Lead instrument occasionally wavers in pitch. Tempo drops 5-10%. Ambient layer thins. |
| 3 | Corrupted | Pallor motif replaces counter-melody. Lead instrument breathy/muted. Tempo drops 15-20%. Nature sounds gone. |
| 4 | Consumed | Only Pallor motif and drone remain. Original melody audible as ghost fragments. Reverb collapses to dry, flat sound. |

### 9.2 Location Corruption by Act

Most locations progress through corruption stages across acts. These align
with the staging in `dynamic-world.md`:

| Act | Typical Corruption | Notes |
|-----|--------------------|-------|
| I | Stage 0 | Clean. The world before the storm. |
| II (early) | Stage 0-1 | Touched. Subtle wrongness creeping in. |
| II (late, post-siege) | Stage 1-2 | Strained. The cracks are audible. |
| Interlude | Stage 1-3 (varies by location) | The Unraveling. See per-location entries in Section 6 for specific stages. |
| III | Stage 1-3 (varies) | Some locations recovering (party influence), others worsening. |
| IV / Epilogue | Stage 0-1 | Healing. Corruption receding. |

**Special cases:**
- Millhaven: physically destroyed at the Interlude (not Pallor-consumed — ley line eruption). No corruption stage applies; silence + wind.
- The Convergence: Stage 3-4 throughout (the Pallor's stronghold).
- Ironmark Citadel: Stage 2 corruption deliberately embraced by Kole — treated as empowerment, not decay.

## 10. Narrative Moment Themes

Event-driven tracks that override location music during story beats.

### 10.1 Major Cutscene Themes

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
| The March (walk-and-talk to Convergence) | Act III overworld at full rebuild. The party is together. Edren's motif leads, other motifs layer in as characters speak. Walking tempo — not urgent, resolute. Transitions to Grey March Path dungeon theme as encounters begin. |
| Campfire Scene (pre-Convergence) | Most intimate track. Acoustic-only, no orchestration. Each character's motif on a single instrument, overlapping like conversation. Fire-crackle ambient. Longest non-looping track — plays through the whole scene. |
| Lira Reaches Cael | Lira's motif and Cael's original clean motif reaching toward each other. Harmonize for exactly one phrase. Then Cael's motif begins to fade. |
| The Farewell | Transition from battle victory to sacrifice. Full orchestral resolution fades to solo instruments one by one. Party members' motifs drop out as focus narrows to Cael. Edren's motif plays a quiet phrase — the last thing between friends. |
| Cael's Sacrifice | Cael's clean motif — the Act I version — alone as he walks into the door. Slowing. Each note further apart. Last note sustains and fades to absolute silence. 3 seconds of nothing. Then the bird call. One note. Alive. (Second of two true silences.) |
| Edren at the Meadow | Edren's motif alone, played on a single instrument (not brass — perhaps acoustic guitar or harp). Stripped of duty and authority. Just a man placing his friend's sword. Quiet. |
| Epilogue closing | Overworld Act IV variant. Every character motif woven as fragments. Sable's motif last heard as she opens "The Pendulum" tavern. |

### 10.2 Special Audio Rules

| Rule | Description |
|------|-------------|
| Silence is sacred | True silence (zero audio) appears exactly twice: after the Ley Line Rupture (5s) and before the bird call at Cael's sacrifice (3s). No other moment goes fully silent. The Pallor Wastes hard-cut transition fades to drone within 1 second — not true silence. |
| The Bird | Not a musical instrument. A real bird call sample — single note, natural, unprocessed. The first non-musical sound in the entire game's score. Nature reasserting itself after Despair. |
| Pallor drone spec | Sustained low tone (sub-bass + low-mid). No harmonic content — as flat and lifeless as possible. Anti-music. |
| Music-as-mechanic | Torren's Spiritcall ability restores a corrupted melody during the Ley Leech boss fight (Interlude main story). The player hears the music heal in real-time as gameplay. |
| Biome crossfade | Standard 3-second crossfade between biome themes (documented in biomes.md). Pallor Wastes exception: hard cut, then immediate 1-second drone fade-in (not true silence). |
| Ley Nexus layering | Ley nexus locations blend additively with surrounding biome (hum layers underneath, not replacement). Documented in biomes.md. |

## 11. System & UI Music

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
| Game Over / Reload | 4s | The fast-reload sequence from events.md section 2c. Last Faint animation, fade to black, instant reload. Music stops on Faint (not true silence -- ambient sound continues during the 2s fade to black), then save point jingle on reload. | No "Game Over" screen or unique game-over theme. |
| Menu Screen | None | No unique menu music. The current location/overworld theme continues playing underneath the menu UI. | Maintains immersion. No jarring music switch when pausing. |

## 12. Composable Framework for New Content

Any new location, dungeon, or narrative moment can derive its musical
identity from this matrix without custom design.

### 12.1 Step 1: Pick the Faction Palette

Choose from: Valdris, Carradan, Thornmere, Ancient, Neutral (Section 3).
Blend two palettes for cross-faction or transitional spaces.

### 12.2 Step 2: Pick the Mood

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

### 12.3 Step 3: Apply Corruption Stage

See Section 9.1 for corruption stages 0-4. Determine the location's
corruption state by act (Section 9.2) and apply modifications.

### 12.4 Step 4: Layer Character Motifs

If any character is narratively relevant to this location, layer their motif
per the rules in Section 4.8.

### 12.5 Example: Composing for a New Dungeon

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

## 13. Track Count Summary

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

## 14. Out of Scope

- Actual music composition or file creation (this is a reference spec)
- Sound effects (footsteps, UI clicks, spell effects)
- Voice acting direction
- Technical audio implementation (file formats, channel mixing, engine integration)
- Music licensing or sourcing (this spec feeds into that process)
