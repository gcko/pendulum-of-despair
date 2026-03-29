# Full Dialogue Script — Design Spec

**Gap:** 3.7 Full Dialogue Tree & Story Script
**Status:** Approved design, ready for implementation
**Date:** 2026-03-29
**Depends On:** 3.3 Dialogue System Mechanics (COMPLETE), Story & Narrative (outline.md, events.md), NPC Design (npcs.md), Characters (characters.md), UI Design (ui-design.md)
**Unblocks:** Full game implementation, text rendering pipeline, localization
**Reference Scripts:** `docs/references/scripts/` — FF4, FF6, Chrono Trigger, Secret of Mana

---

## Overview

The final design gap. All mechanical systems are complete — combat,
economy, progression, dialogue mechanics, post-game. This gap produces
the actual words characters speak: ~5,000-8,000 lines of dialogue
across 37 major story scenes, 74 named NPCs, and 58 event flags.

**Core philosophy: "Write a screenplay, not a database."** The script
is a readable, emotionally complete document first and an
implementation source second. Scene-by-scene prose with embedded
metadata — readable as literature, parseable for implementation.
FF6 brevity (2-3 sentences per text box), CT party awareness for
key scenes, dialogue-system.md sprite animations instead of portraits.

**Layered delivery model:** Three self-contained layers, each a
complete deliverable. Layer 1 alone produces a playable narrative.
Layers 2 and 3 add world texture and system polish.

---

## Section 1: Layered Priority Structure

### Layer 1: Narrative Spine (~2,500 lines)

The emotional core. All Tier 1 cutscenes, key Tier 2 walk-and-talks,
boss pre-fight/post-fight dialogue, trial scenes, and party-aware
dialogue for key scenes. Covers ~45 scripted scenes from Act I
through Epilogue.

**Delivers:** A complete, playable story script. Every major plot
beat has dialogue. A player could finish the game on Layer 1 alone
and experience the full narrative arc.

### Layer 2: NPC Ambient (~1,500 lines)

World texture. Town NPC dialogue with flag-dependent variations
across acts, shop/inn/service lines, quest-giver dialogue trees,
and environmental storytelling examine text.

**Delivers:** A living world. NPCs react to story progression,
towns feel inhabited, and exploration rewards reading.

### Layer 3: Battle & System (~1,000 lines)

Mechanical text. Boss phase transition barks, in-battle party
callouts, tutorial prompts, item descriptions not already in
items.md, menu help text, and system messages.

**Delivers:** Polished combat and UI. Bosses taunt during phase
shifts, party members react to critical moments, and the system
communicates clearly.

---

## Section 2: File Structure

All files live in `docs/story/script/`. The directory does not yet
exist and will be created during implementation.

```
docs/story/script/
  README.md                 Index, format spec, navigation, cross-ref guide
  act-i.md                  ~800-1,200 lines (Ember Vein through Valdris)
  act-ii-part-1.md          ~1,000-1,200 lines (diplomacy through Council)
  act-ii-part-2.md          ~800-1,000 lines (Cael's Last Night through Siege)
  interlude.md              ~1,200-1,500 lines (Sable's journey, reunions, truth)
  act-iii.md                ~1,200-1,500 lines (march, trials, Vaelith, approach)
  act-iv-epilogue.md        ~600-900 lines (final battle, sacrifice, epilogue)
  npc-ambient.md            ~800-1,200 lines (town dialogue, flag variations)
  battle-dialogue.md        ~400-600 lines (boss barks, callouts, system text)
```

**Split rationale:** Act II splits at the betrayal — a natural tonal
break. Act IV and Epilogue combine because they share a single
emotional arc (sacrifice through memorial). NPC ambient and battle
dialogue are separated from the narrative files because they serve
different authoring workflows.

**Cross-reference requirements per file:**
- Header blockquote linking to related canonical docs
- Scene metadata comments linking to events.md flag numbers
- NPC names matching npcs.md exactly
- Location names matching locations.md exactly
- Boss names matching bestiary/bosses.md exactly
- Item/equipment names matching items.md and equipment.md exactly
- Animation IDs matching dialogue-system.md Section 2 exactly
- Flag names matching events.md exactly

All cross-references use relative paths from `docs/story/script/`
(e.g., `../outline.md`, `../events.md`, `../npcs.md`).

---

## Section 3: Script Format Specification

A hybrid screenwriter-prose format with structured metadata.
Optimized for readability as a screenplay while embedding
implementation-ready data.

### 3.1 Scene Headers

Every scene opens with a Markdown heading and an HTML comment block
containing machine-readable metadata:

```markdown
### Scene Title
<!-- Scene: scene_id | Tier: 1/2/3/4 | Trigger: flag_name -->
<!-- Location: Location Name | Party: who is present -->
<!-- Variants: description of flag-dependent variations -->
<!-- Cross-ref: relevant_doc.md section name -->
```

- `scene_id` maps to events.md scene identifiers
- `Tier` matches outline.md scene tier classification
- `Trigger` is the event flag that activates this scene
- `Variants` describes which flags produce alternate dialogue
- `Cross-ref` links to the canonical source for this scene

### 3.2 Dialogue Lines

```markdown
*(Stage direction. Character enters from east.)*

**CHARACTER_NAME** : Dialogue line here. Maximum 3 rendered
lines per text box per ui-design.md.

*(Character [animation_id]. Another character [animation_id].)*

**CHARACTER_NAME** : Next dialogue box.
```

- Speaker names in `**BOLD**` followed by ` : ` (space-colon-space)
- Stage directions in `*(italics)*` on their own lines
- One text box per `**CHARACTER** : ` block
- Max 3 rendered lines per box (per ui-design.md Section 12)
- 2-3 sentences per box max — FF6 brevity

### 3.3 Animation Notation

Use `[animation_id]` inline in stage directions, mapping to the 14
animations + `clear` command from dialogue-system.md Section 2:

`jump`, `shake`, `turn_away`, `head_down`, `bubble_exclaim`,
`bubble_ellipsis`, `bubble_question`, `sweat_drop`, `cry`,
`red_tint`, `arms_up`, `collapse`, `nod`, `step_back`, `clear`

Character-specific animation preferences (per dialogue-system.md):
- **Edren:** `shake`, `nod` (restrained, military bearing)
- **Cael:** `turn_away` (signature move, shame/conflict)
- **Maren:** `bubble_ellipsis`, `head_down` (processing, overwhelm)
- **Lira:** `bubble_exclaim`, `arms_up` (expressive, technical energy)
- **Torren:** `step_back`, `nod` (stoic, measured)
- **Sable:** `sweat_drop`, `red_tint` rare (humor, rare anger)

SFX notation: `[SFX: sound_id]` inline in stage directions.

### 3.4 Branching Dialogue

Flag-conditional variants use parenthetical conditions:

```markdown
(If `flag_name` set.)
*(Variant stage direction.)*
**CHARACTER** : Variant dialogue.

(If `party_has(torren)`.)
**TORREN** : Party-aware reaction line.
```

### 3.5 Choice Nodes

Player choices use blockquote syntax with outcome annotations:

```markdown
**CHARACTER** : Question that prompts choice.

> **Choice: "Option A text"** -> sets `flag_name` / `score_name` +N
> **Choice: "Option B text"** -> sets `flag_name` / `score_name` +N
> **Choice: "Option C text"** -> sets `flag_name` / `score_name` +N

(If player chose "Option A".)
**CHARACTER** : Response to Option A.
```

Choice consequences reference events.md flag definitions. Faction
reputation scores reference the scoring system in events.md.

---

## Section 4: Voice Guidelines

Voice definitions live in characters.md (party) and npcs.md
(non-party). The script must embody these voices consistently.
Summary for quick reference during authoring:

### 4.1 Party Members

| Character | Voice | Signature Traits |
|-----------|-------|-----------------|
| **Edren** | Direct, duty-focused, formal military | Short sentences. Leads by example. Carries weight willingly. |
| **Cael** (pre-betrayal) | Warm, intellectual, self-deprecating | Genuine care masked by scholarly distance. |
| **Cael** (post-corruption) | Cold, certain, grieving underneath | Same vocabulary, stripped of warmth. |
| **Lira** | Technical, pragmatic, sharp | Guilt-driven. Speaks about craft and consequence. Not soft. |
| **Torren** | Measured, plainspoken wisdom | Older, patient, world-weary. Few words, each weighted. |
| **Sable** | Quick-witted, sarcastic, young | Covers pain with humor and bravado. Most human character. |
| **Maren** | Careful, measured, guarded | Hints rather than explains. Knows more than she reveals. |

### 4.2 Key NPCs

| Character | Voice |
|-----------|-------|
| **Vaelith** | Warm, witty, genuinely interested. Charming scholar facade. "Likes people the way an entomologist likes butterflies. Pinned ones." |
| **King Aldren** | Weary authority. Older, practical, beloved but fading. |

Full NPC voice notes in npcs.md. The script must match those
characterizations exactly.

### 4.3 Text Box Constraints

- Max 3 rendered lines per text box (ui-design.md Section 12)
- Keep dialogue punchy — FF6 brevity standard
- CT-style party awareness: key scenes check active party and add
  character-specific reaction lines
- No exposition dumps — spread information across multiple NPCs and
  scenes. Let the player piece it together.

---

## Section 5: Layer 1 Scene Inventory

Layer 1 covers the narrative spine — 45 scripted scenes mapped to
outline.md and events.md. Implementation produces these scenes across
the six narrative script files.

### Act I (7 scenes) -> act-i.md

1. Ember Vein tutorial — Edren/Cael banter, Vein Guardian boss, party meets Lira and Sable
2. Vaelith at Ember Vein — Tier 1 cutscene, charming stranger first appearance
3. Dawn March — Tier 2 walk-and-talk, opening credits sequence, party banter
4. Thornmere Wilds — Torren encounter and recruitment
5. Maren's Warning — Tier 1+2, "It's a door" revelation
6. Arrival at Valdris — King Aldren, mission assignment
7. Valdris Crown NPCs — Aldis, Cordwyn, key NPC introductions

### Act II Part 1 (8 scenes) -> act-ii-part-1.md

8. Road to diplomatic missions
9. Duskfen — Spirit-speaker Caden, Fenmother's Hollow
10. Canopy Reach — Wynne, observatory panoramic (Tier 1)
11. Ley Stag bonding (optional)
12. Thornmere Council — 3 private audiences with choice nodes + formal vote
13. Vaelith tavern encounter
14. Vaelith Doma moment (Tier 1, dramatic irony)
15. Sable's warning

### Act II Part 2 (4 scenes) -> act-ii-part-2.md

16. Cael's nightmares (Tier 4 micro)
17. Cael's Last Night — 4 location variants (Tier 2, player-controlled)
18. The Betrayal — Tier 1, flag-variant framing (events 44-47)
19. Siege of Valdris — Tier 1 to Playable, Aldren death, Vaelith encounter

### Interlude (8 scenes) -> interlude.md

20. Ley Line Rupture — Tier 1 montage
21. Sable wakes in ruins — Tier 2
22. Renn intelligence gathering
23. Finding Edren — monastery, reunion
24. Finding Lira — Compact infiltration, reunion
25. Finding Torren — Wilds ritual, reunion
26. Finding Maren — Archive of Ages, truth revealed
27. Full party briefing — everyone assembled

### Act III (12 scenes) -> act-iii.md

28. March to Convergence — Tier 2 walk-and-talk
29. Edren's trial (Hall of Crowns) — pre-fight + completion
30. Lira's trial (Unfinished Forge) — pre-fight + completion
31. Torren's trial (Silent Grove) — pre-fight + completion
32. Sable's trial (Crooked Mile) — pre-fight + completion
33. Maren's trial (Restricted Stacks) — pre-fight + completion
34. Campfire scene (optional) — Tier 2
35. Vaelith boss — pre-fight + defeat (Tier 1)
36. Convergence approach

### Act IV + Epilogue (6 scenes) -> act-iv-epilogue.md

37. Cael three-phase boss — intro, mid-battle, defeat
38. Cael's explanation — door mechanics
39. The Farewell — party reactions
40. The Sacrifice — Cael enters door (Tier 1)
41. Epilogue — world heals, character fates
42. Memorial scene — sword in meadow (Tier 1)

---

## Section 6: Layer 2 Scope (NPC Ambient)

Layer 2 produces `npc-ambient.md`. Content organized by location,
with flag-dependent dialogue variations.

**Per location:**
- 3-6 named NPCs with 2-4 dialogue variations each (keyed to act
  progression and major event flags)
- Shop/inn/service NPC lines (buy/sell/rest/craft greetings)
- Quest-giver dialogue trees (accept/decline/in-progress/complete)
- Environmental examine text (signs, bookshelves, objects)

**Flag variation model:** NPCs reference events.md flags to determine
which dialogue to display. Major world-state changes (betrayal, siege,
ley rupture) shift entire town dialogue sets. Minor flags adjust
individual NPC lines.

All NPC names, locations, and flag references must match their
canonical docs exactly.

---

## Section 7: Layer 3 Scope (Battle & System)

Layer 3 produces `battle-dialogue.md`. Content organized by category.

**Boss dialogue:**
- Pre-fight intro lines (1-3 boxes per boss)
- Phase transition barks (1-2 boxes per phase shift)
- Defeat dialogue (1-3 boxes)
- References bestiary/bosses.md for boss names and phase definitions

**Party battle callouts:**
- Critical HP warnings (character-specific voice)
- Ally down reactions (relationship-dependent)
- Boss phase reactions
- Victory lines (per-character variants)

**System text:**
- Tutorial prompts (ATB explanation, Ley Crystal usage, row system)
- Item descriptions not already covered in items.md
- Menu help text
- Save point text
- Game over / continue prompt

---

## Section 8: README.md Specification

`docs/story/script/README.md` serves as the index and format
reference for the entire script directory.

**Contents:**
1. Format specification summary (condensed from this spec Section 3)
2. File index with line count estimates and layer assignments
3. Cross-reference guide mapping script files to canonical docs
4. Navigation links to all script files
5. Authoring guidelines (voice reference, text box constraints,
   animation usage rules)
6. Flag quick-reference table (subset of events.md most used in
   dialogue branching)

---

## Section 9: Cross-Reference Integration

The script files are consumers of canonical docs, not replacements.
Every script file must maintain bidirectional linking.

**Script files reference:**
- `../outline.md` — scene tier classifications, act structure
- `../events.md` — flag names, flag numbers, trigger conditions
- `../npcs.md` — NPC names, roles, locations, voice notes
- `../characters.md` — party member backgrounds, voice, relationships
- `../locations.md` — location names, descriptions
- `../dialogue-system.md` — animation IDs, timing rules, data format
- `../ui-design.md` — text box constraints, choice prompt format
- `../bestiary/bosses.md` — boss names, phase definitions
- `../items.md`, `../equipment.md` — item and equipment names

**Canonical docs reference back:**
- outline.md and events.md gain a "Script" column or note linking
  to the relevant script file and scene header for each event

---

## Section 10: Implementation Order

1. **README.md** — Format spec and index (establishes conventions)
2. **act-i.md** — Shortest act, establishes all voice patterns
3. **act-iv-epilogue.md** — Emotional climax, written early to set
   the target the whole script builds toward
4. **interlude.md** — Sable solo + reunions, tests all five voices
5. **act-ii-part-1.md** — Diplomacy scenes, heaviest choice branching
6. **act-ii-part-2.md** — Betrayal sequence, highest dramatic stakes
7. **act-iii.md** — Trials sequence, most structurally repetitive
8. **npc-ambient.md** — Layer 2, requires all act scripts as context
9. **battle-dialogue.md** — Layer 3, requires boss roster finalized

**Rationale:** Write the beginning and end first to establish voice
and emotional targets. The middle fills in between known endpoints.
NPC ambient and battle dialogue come last because they depend on the
narrative spine for tonal consistency.

---

## Section 11: Design Changes to Existing Docs

### 11.1 docs/analysis/game-design-gaps.md

Update Gap 3.7 status from MISSING to COMPLETE and check off all
items in the "What's Needed" checklist.

### 11.2 docs/story/outline.md

Add a "Script Reference" note in the document header linking to
`docs/story/script/README.md` as the dialogue implementation of
the outlined scenes.

### 11.3 docs/story/events.md

Add a "Script Reference" note in the document header linking to
`docs/story/script/README.md`. Individual event entries do not need
modification — the script files reference events.md flags, not the
reverse.

---

## Section 12: What This Does NOT Cover

- **Implementation-ready YAML/JSON dialogue data.** The script is a
  human-readable screenplay. Structured data files for the dialogue
  engine are generated from the script in a separate implementation
  step.
- **Voice acting direction.** No VA is planned. The sprite animation
  system (dialogue-system.md) handles all emotional delivery.
- **Localization string tables.** Generated from the script later.
  The script format supports extraction but is not itself a string
  table.
- **Dreamer's Fault post-game dialogue.** Post-game dungeon NPC
  dialogue is Layer 2/3 scope and may extend beyond the initial
  5,000-8,000 line target.
- **Full ambient dialogue for all 74 NPCs.** Layer 2 covers key
  NPCs per location. Minor NPCs with single generic lines may be
  added in a polish pass.
- **Dynamic dialogue generation.** All dialogue is pre-authored.
  No procedural text generation.
