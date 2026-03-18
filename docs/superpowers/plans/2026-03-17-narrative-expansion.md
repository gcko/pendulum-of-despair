# Narrative Expansion Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an FF6-style opening sequence, cutscene tier system, playable
scenes with repercussions, and death/fast-reload mechanic to the story docs.

**Architecture:** Pure documentation pass -- no code. All changes are to
markdown files in `docs/story/`. Each task modifies 1-2 files. Verification
is via `pnpm lint && pnpm test` (which validates markdown structure) and
cross-referencing against the spec.

**Tech Stack:** Markdown, git, pnpm (for lint/test verification)

**Spec:** `docs/superpowers/specs/2026-03-17-narrative-expansion-design.md`

---

## File Map

All story doc changes are modifications to existing files. This plan and its companion spec (`docs/superpowers/specs/2026-03-17-narrative-expansion-design.md`) are the only new files.

| File | What Changes |
|------|-------------|
| `docs/story/outline.md` | Tasks 1, 3, 4, 5, 6 -- Opening sequence beats, Cael's Last Night, Council scene, campfire, cutscene tier reference |
| `docs/story/events.md` | Task 2 -- New event flags, cutscene catalog, Council/Last Night event flow |
| `docs/story/characters.md` | Task 3 -- Cael shimmer note, Edren Arcanite gear note, Cael control switch |
| `docs/story/npcs.md` | Task 4 -- Expand Savanh, Caden, Wynne with Council profiles; expand Seyth |
| `docs/story/dungeons-world.md` | Tasks 1, 7 -- Ember Vein "taste of power" overlay, siege difficulty scaling |
| `docs/story/dynamic-world.md` | Task 7 -- Council outcome effects on siege state |
| `docs/story/sidequests.md` | Task 8 -- Cross-reference Council scene against Ashgrove Proving Grounds trigger |

---

## Chunk 1: Opening Sequence and Event Flags

### Task 1: Opening Sequence in outline.md and dungeons-world.md

Add the FF6-style opening beats to the story outline and layer the "taste of
power" mechanic onto the existing Ember Vein dungeon.

**Files:**
- Modify: `docs/story/outline.md:5-33` (Act I: The Gathering Storm)
- Modify: `docs/story/dungeons-world.md:64-113` (Ember Vein dungeon overview and Floor 1)

**Reference:** Spec Section 1 (The Opening Sequence)

- [ ] **Step 1: Read current Act I opening in outline.md**

Read `docs/story/outline.md` lines 5-33. Note the existing structure:
Setup (line 7), The Discovery (line 11), Party Assembly (line 15),
The Stranger at the Mine (line 22), The First Warning (line 26),
Act I Ends (line 30).

- [ ] **Step 2: Add opening sequence section to outline.md**

Insert a new `### The Opening (Tutorial)` section BEFORE the existing
`### Setup` section (after line 5, before line 7). This section describes
the player's first experience:

Content to add:

```markdown
### The Opening (Tutorial)

The game opens in the Ember Vein -- a Carradan mine where something ancient
has been unearthed. **Edren** and **Cael** descend on King Aldren's orders.
The player controls Edren. Cael follows.

**The taste of power (dual preview):**

- Edren carries **Arcanite-enhanced gear** from the Valdris armory -- standard
  issue for royal knights. The sword and shield hit harder than normal Act I
  levels. This gear breaks during the escape from Carradan soldiers after the
  Vein Guardian, giving the player a preview of Arcanite Forging that Lira
  unlocks later.
- Cael has **unexplained extra power**. His attacks shimmer faintly. His damage
  output exceeds his stats. The game offers no explanation. In hindsight --
  after the betrayal -- the player realizes this was the Pallor's first touch.
  Cael was already marked before the story began.

The dungeon teaches combat across four floors (see Ember Vein in
`dungeons-world.md`). After the Vein Guardian falls and Carradan soldiers
force the party to flee, Lira and Sable join during the escape.

### The Dawn March (Opening Credits)

As the party emerges from the mine, **Vaelith** is waiting (see `vaelith_ember_vein`
flag in `events.md`). After Vaelith's departure, the screen cuts to black.

Music shifts. The player controls Edren walking a trail from Ironmouth toward
the Thornmere Wilds at dawn -- forward only, no encounters. Cael walks
alongside. Lira and Sable trail behind, visible but not in dialogue.

Dialogue triggers as they walk:

1. Cael: *"Those miners... they just stopped. No fight, no wounds. They gave up."*
2. Edren: *"We'll let the court decide what it is."*
3. Cael: *"And the stranger? You're not concerned?"*
4. Edren: *"I'm concerned about all of it."*
5. *(Beat of silence as the trail widens to show the valley below)*
6. Cael: *"...I keep thinking about their faces."*

Character names, game title, and credits overlay the walk. The sequence ends
at the Wilds border.

**Game title card: PENDULUM OF DESPAIR.**

The `opening_credits_seen` flag is set.
```

- [ ] **Step 3: Update Setup section in outline.md**

The existing `### Setup` section (line 7) currently opens with "The story opens
in **Valdris**..." This needs a brief note acknowledging the tutorial precedes
it. Edit the opening paragraph to clarify that Setup describes the narrative
context that the player learns through the tutorial:

Change the first sentence from:
> The story opens in **Valdris**, an ancient kingdom in decline.

To:
> The narrative context begins in **Valdris**, an ancient kingdom in decline.
> (The player experiences this through the Ember Vein tutorial above.)

- [ ] **Step 4: Add "taste of power" notes to Ember Vein in dungeons-world.md**

Read `docs/story/dungeons-world.md` lines 64-113 (Ember Vein section). Add a
new subsection after the existing `### Puzzle Mechanics` section (after line
84) and before `### Floor 1` (line 86):

```markdown
### Opening Sequence Overlay

The Ember Vein serves as the game's tutorial and opening sequence (see
`outline.md` "The Opening (Tutorial)" section).

**Arcanite-enhanced gear (Edren):** Edren's starting equipment is Arcanite-
enhanced from the Valdris armory -- confiscated Compact prototypes, issued only
for high-risk missions.
ATK and DEF are ~30% above normal Act I baselines. The gear breaks during the
Carradan escape after the Vein Guardian (Floor 4 exit), forcing Edren to
standard equipment. This previews the Arcanite Forging system Lira unlocks
later.

**Pallor shimmer (Cael):** Cael's attacks have a faint visual shimmer
throughout the Ember Vein. His damage output is ~10% above his stat line. No
in-game explanation is given. This is the Pallor's first touch -- retroactive
foreshadowing visible only on replay or careful observation.

**Dawn march (opening credits):** After the Vaelith encounter outside the mine
(`vaelith_ember_vein` flag) and the party's escape with Lira and Sable, the
game transitions to a playable Walk-and-Talk credits sequence. See
`outline.md` "The Dawn March" section for dialogue and pacing.
```

- [ ] **Step 5: Verify no contradictions**

Read the Ember Vein Narrative Beats table (`dungeons-world.md` lines 341-354)
and confirm the new overlay does not contradict the existing floor-by-floor
beats. The overlay adds to Floors 1-4 (Arcanite gear, Cael shimmer) but does
not change the existing narrative progression.

- [ ] **Step 6: Run verification**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 7: Commit**

```bash
git add docs/story/outline.md docs/story/dungeons-world.md
cat > /tmp/commit-msg.txt << 'COMMIT_EOF'
docs: add FF6-style opening sequence to outline and Ember Vein

- Add tutorial opening and dawn march credits sections to outline.md
- Add taste-of-power overlay to Ember Vein (Arcanite gear, Cael shimmer)
- Opening credits sequence uses existing vaelith_ember_vein flag

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
COMMIT_EOF
git commit -F /tmp/commit-msg.txt
```

---

### Task 2: Event Flags and Cutscene Catalog in events.md

Add all new event flags from the spec and create the cutscene catalog as a new
section in events.md.

**Files:**
- Modify: `docs/story/events.md` (multiple sections)

**Reference:** Spec Sections 2 (Cutscene Tier System), 5 (Event Flag Additions)

- [ ] **Step 1: Read current flag tables**

Read `docs/story/events.md` lines 247-315 (Story Event Triggers). Note:
- Act I flags: lines 251-260 (flags 1-6)
- Act II flags: lines 262-278 (flags 7-19)
- Interlude flags: lines 280-291 (flags 20-27)
- Act III flags: lines 293-304 (flags 28-35)
- Act IV flags: lines 306-315 (flags 36-38)

The last flag is #38 (`epilogue_complete`). New flags start at #39.

- [ ] **Step 2: Add new flags to appropriate act sections**

Add the following flags to the existing tables. Insert each flag at the end
of its act's table section.

**Act I flags** (add after flag 6, end of Act I section ~line 260):

```markdown
| 39 | `opening_credits_seen` | Dawn march credits sequence ends at Wilds border | Tutorial complete. True game start. Prevents credits replay. Dawn march uses existing `vaelith_ember_vein` (flag 2) as prerequisite. | Edren, Cael, Lira, Sable |
```

**Act II flags** (add after flag 19, end of Act II section ~line 278):

```markdown
| 40 | `council_savanh_approval` | Private audience with Elder Savanh at Ashgrove | Hidden score (0-3). Dialogue choices alone earn 0-2; consulting Grandmother Seyth before the council unlocks a bonus option that reaches 3. | Elder Savanh, Edren |
| 41 | `council_caden_approval` | Private audience with Spirit-speaker Caden at Ashgrove | Hidden score (0-3). Caden's score starts at 1 because Torren (always in the diplomatic party) has natural rapport as a spirit-speaker; dialogue choices add 0-2 more. | Spirit-speaker Caden, Edren, Torren |
| 42 | `council_wynne_approval` | Private audience with Wynne at Ashgrove | Hidden score (0-3). Tracks Wynne's support based on dialogue choices. | Wynne, Edren, Lira |
| 43 | `council_result` | All three tribal leaders vote at the Ashgrove council fire | Stores outcome tier (0-3). 3 = full Thornmere tribal support at siege; 2 = archers only; 1 = token squad; 0 = party alone. Read by Valdris Siege encounter. Computed from individual approval scores (flags 40-42) before `tribal_alliance_complete` (flag 11) fires — the council tallies votes first, then the alliance flag resolves. | Elder Savanh, Caden, Wynne |
| 44 | `cael_last_night_lira` | Cael visits Lira's workshop the night before the betrayal | Binary. Affects `cael_betrayal_complete` cutscene: camera lingers on Lira's face. | Cael, Lira |
| 45 | `cael_last_night_edren` | Cael visits the training grounds the night before the betrayal | Binary. Affects `cael_betrayal_complete` cutscene: Edren's reaction shot is longer. | Cael, Edren |
| 46 | `cael_last_night_maren` | Cael visits Maren's study the night before the betrayal | Binary. Recontextualizes betrayal: Cael was researching what the Pallor wanted, not seeking a cure. | Cael, Maren |
| 47 | `cael_last_night_vault` | Cael visits the Pendulum vault the night before the betrayal | Binary. Reveals Pallor contact was pre-existing: Cael's reflection is wrong for one frame. | Cael |
```

**Interlude flags** (add after flag 27, end of Interlude section ~line 291):

```markdown
| 48 | `reunion_order_1` | Sable finds the first party member | Stores character ID. Previously reunited members are present for later reunions, changing dialogue. | Sable + first found member |
| 49 | `reunion_order_2` | Sable finds the second party member | Stores character ID. Dialogue varies based on who is already present. | Sable + found members |
| 50 | `reunion_order_3` | Sable finds the third party member | Stores character ID. | Sable + found members |
| 51 | `reunion_order_4` | Sable finds the fourth (final) party member | Stores character ID. Final reunion is most emotionally charged. | Sable + all members |
```

**Act III flags** (add after flag 35, end of Act III section ~line 304):

```markdown
| 52 | `campfire_complete` | Player speaks to all party members at the campfire | Binary. Triggers group moment: Edren says something that binds the party. If the player walks to the exit without speaking to everyone, the march begins without it. | Edren, Lira, Torren, Sable, Maren |
```

- [ ] **Step 3: Add Cutscene Tier System section**

Insert a new top-level section after the existing `## 2. Story Event Triggers`
section (after the Act IV flags table, ~line 315) and before `## 3. NPC Story
Threads` (line 316):

```markdown
## 2b. Cutscene Tier System

All scripted narrative content uses one of four presentation tiers:

| Tier | Name | Player Control | Presentation | Use For |
|------|------|---------------|--------------|---------|
| 1 | Full Cutscene | None (input locked) | Letterboxed (black bars) | Major emotional beats |
| 2 | Walk-and-Talk | Movement only | Normal camera, proximity dialogue | Exposition, arrival, character building |
| 3 | Playable Scene | Full control + choices | Normal camera, dialogue menus | Social encounters, moral choices, perspective shifts |
| 4 | Micro-Cutscene | Briefly interrupted (<10s) | Brief camera shift, then back | Foreshadowing, character moments, environmental storytelling |

**Micro-cutscene rule:** Each fires once per playthrough, tied to a one-time
flag. If the player misses one (wrong party lead, did not visit the area), it
is gone.

### Cutscene Catalog

See `docs/superpowers/specs/2026-03-17-narrative-expansion-design.md` Section 2
for the full act-by-act cutscene catalog with tier assignments and trigger flags.

### Key Cutscene Assignments

| Moment | Act | Tier | Trigger |
|--------|-----|------|---------|
| Ember Vein tutorial | I | Playable | Game start |
| Vaelith outside the mine | I | Full (T1) | `vaelith_ember_vein` |
| Dawn march (opening credits) | I | Walk-and-Talk (T2) | Post-`vaelith_ember_vein` |
| Maren examines the Pendulum | I | Full (T1) | `maren_warning` |
| Cael's first nightmare | II | Micro (T4) | `cael_nightmares_begin` |
| Vaelith comforts a village | II | Full (T1) | `vaelith_doma_moment` |
| Panoramic view from Observatory | II | Full (T1) | `canopy_alliance` |
| Thornmere Council at Ashgrove | II | Playable (T3) | Post individual alliances (flags 9-10), arrive at Ashgrove |
| Cael's Last Night | II | Playable (T3) | Night before `cael_betrayal_complete` |
| Cael's betrayal | II | Full (T1) | `cael_betrayal_complete` |
| Siege of Valdris | II | Full -> Playable | `carradan_assault_begins` |
| Ley Line Rupture | Interlude | Full (T1) | `ley_line_rupture` |
| Sable alone in aftermath | Interlude | Walk-and-Talk (T2) | Post-rupture |
| Party reunions | Interlude | Walk-and-Talk -> Playable | Per reunion flag |
| March to Convergence | III | Walk-and-Talk (T2) | Act III opening |
| Campfire scene | III | Playable (T3) | Pre-Convergence |
| Pallor Trials | III | Playable (T3) | Per trial entry |
| Vaelith's release | III | Full (T1, in-battle) | `vaelith_defeated` |
| Lira reaches Cael | IV | Full (T1) | `pallor_defeated` |
| Cael walks into the door | IV | Full (T1) | Narrative climax |
| Edren places sword | Epilogue | Full (T1) | Final scene |
```

- [ ] **Step 4: Add Death/Fast Reload section**

Insert after the new Cutscene Tier System section:

```markdown
## 2c. Death and Fast Reload

When all party members are KO'd in battle:

1. **The Fall (2s):** Last KO animation plays. Battle UI fades. Music hard-cuts
   to silence.
2. **Fade to Black (2s):** Black screen. No text, no menu, no "Game Over."
3. **Instant Reload:** Fade in at last save point. Full HP/MP as of last save.
   Save point marker glows briefly. Ambient music resumes. ~4 seconds total.

**Rules:**
- No menu, no prompt. Save point is where you go.
- Boss pre-battle cutscenes (Tier 1) set a `boss_cutscene_seen_<boss_id>` flag
  on first viewing. On reload, the cutscene skips. (Note: this is a
  parameterized flag pattern, not a numbered flag -- each boss gets its own
  instance at runtime. Document the pattern in events.md but do not assign a
  fixed flag number.)
- Narrative defeats are exempt (e.g., the unwinnable Vaelith fight at the
  siege transitions to an aftermath cutscene, not this sequence).
- If the player dies before the first save point in the Ember Vein (unlikely
  given Arcanite gear), reload at the dungeon entrance.
```

- [ ] **Step 5: Verify flag numbering**

Read the updated events.md and confirm:
- No duplicate flag numbers
- New flags are in the correct act sections
- Flag names match the spec exactly

- [ ] **Step 6: Run verification**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 7: Commit**

```bash
git add docs/story/events.md
cat > /tmp/commit-msg.txt << 'COMMIT_EOF'
docs: add narrative expansion flags, cutscene tier system, death mechanic

- Add 14 new event flags (39-52) for opening, council, last night, reunions, campfire
- Add cutscene tier system (Full/Walk-and-Talk/Playable/Micro) with catalog
- Add death/fast-reload mechanic (fade to black, instant reload, ~4 seconds)

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
COMMIT_EOF
git commit -F /tmp/commit-msg.txt
```

---

## Chunk 2: Characters, NPCs, and Playable Scenes

### Task 3: Character Updates in characters.md

Add notes about Cael's shimmer, Edren's Arcanite gear, and the Cael control
switch during Last Night.

**Files:**
- Modify: `docs/story/characters.md:5-23` (Edren and Cael entries)

**Reference:** Spec Sections 1 (taste of power) and 3 (Cael's Last Night)

- [ ] **Step 1: Read current Edren and Cael entries**

Read `docs/story/characters.md` lines 5-23. Note the existing structure --
each character has Role, Personality, Arc, Fate fields.

- [ ] **Step 2: Add Arcanite gear note to Edren's entry**

After Edren's existing `**Arc:**` line, add a new field:

```markdown
**Opening:** Carries Arcanite-enhanced gear from the Valdris armory during the
Ember Vein tutorial. The gear breaks during the Carradan escape, previewing
the Arcanite Forging system Lira unlocks later.
```

- [ ] **Step 3: Add shimmer and control switch notes to Cael's entry**

After Cael's existing `**Arc:**` line, add:

```markdown
**Opening:** Cael's attacks shimmer faintly throughout the Ember Vein -- the
Pallor's first touch, visible only in hindsight after the betrayal. His damage
output is ~10% above his stat line with no in-game explanation.

**Last Night (Playable):** The night before the betrayal, the player controls
Cael -- the only time in the game someone other than Edren is controlled
(outside Sable's Interlude). The player does not know this is the last night.
Four locations are available (Lira's workshop, training grounds, Maren's
study, the Pendulum vault); time allows three visits. Each visit sets a flag
that alters the betrayal cutscene's camera and emotional framing. The control
switch is unmarked -- the player may not realize until control returns to Edren
after the betrayal.
```

- [ ] **Step 4: Run verification**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 5: Commit**

```bash
git add docs/story/characters.md
cat > /tmp/commit-msg.txt << 'COMMIT_EOF'
docs: add opening and Last Night notes to Edren and Cael entries

- Edren: Arcanite gear preview during Ember Vein tutorial
- Cael: Pallor shimmer foreshadowing, Last Night control switch mechanic

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
COMMIT_EOF
git commit -F /tmp/commit-msg.txt
```

---

### Task 4: NPC Council Profiles in npcs.md

Expand Elder Savanh, Spirit-speaker Caden, and Wynne with Council dialogue
profiles. Expand Grandmother Seyth with pre-council consultation role.

**Files:**
- Modify: `docs/story/npcs.md:715-774` (Caden, Wynne, Savanh entries)
- Modify: `docs/story/npcs.md:910-926` (Grandmother Seyth entry)

**Reference:** Spec Section 3, Scene 1 (Thornmere Council)

- [ ] **Step 1: Read current NPC entries**

Read `docs/story/npcs.md` lines 715-774 (Caden, Wynne, Savanh) and lines
910-926 (Grandmother Seyth). Note the existing structure of each entry.

- [ ] **Step 2: Add Council profile to Elder Savanh**

After Savanh's existing content (~line 774), add a new subsection:

```markdown
**Council Profile (Ashgrove):**
Savanh hosts the formal alliance council at the Ashgrove council stones. She
is the senior tribal leader and sets the tone. Values honesty and historical
awareness above all else.
- **Responds to:** Admissions of Valdris's past failures toward the Wilds.
  Acknowledgment that the Compact's ley line damage is partly Valdris's
  negligence.
- **Penalizes:** Flattery, dismissiveness, treating the alliance as Valdris's
  right rather than a request.
- **Hidden approval score:** 0-3 (flag `council_savanh_approval`).
- **Grandmother Seyth connection:** If the player speaks with Seyth before the
  council (see Seyth's entry), dialogue options that reference Seyth's
  historical perspective are available and earn +1 with Savanh.
```

- [ ] **Step 3: Add Council profile to Spirit-speaker Caden**

After Caden's existing content (~line 733), add:

```markdown
**Council Profile (Ashgrove):**
Caden represents Duskfen at the alliance council. Values the land's spiritual
balance and ley line health above political concerns.
- **Responds to:** Ley line knowledge, genuine concern for the Wilds' survival,
  references to Maren's Pendulum research (Maren is always visited in Act I).
- **Penalizes:** Treating the Wilds as a resource to exploit, instrumentalizing
  spirit-speech, dismissing the spirits' warnings.
- **Hidden approval score:** 0-3 (flag `council_caden_approval`).
- **Party interaction:** Torren's spirit-speaker status creates natural rapport.
  Torren is always present (diplomatic mission includes Edren, Lira, Torren), so
  Caden's baseline starts at +1 (still capped at 3).
```

- [ ] **Step 4: Add Council profile to Wynne**

After Wynne's existing content (~line 753), add:

```markdown
**Council Profile (Ashgrove):**
Wynne represents Canopy Reach at the alliance council. The most pragmatic of
the three leaders -- values strength and strategic clarity.
- **Responds to:** Concrete battle plans, honest assessment of the Pallor
  threat's military dimension, evidence of tactical preparation.
- **Penalizes:** Vague promises, appeals to emotion over strategy, lack of
  concrete plans.
- **Hidden approval score:** 0-3 (flag `council_wynne_approval`).
- **Party interaction:** Lira's Forgewright background can help (she understands
  military engineering) or hurt (Forgewrights damaged ley lines) depending on
  how the player frames her expertise during the audience.
```

- [ ] **Step 5: Add pre-council consultation to Grandmother Seyth**

After Seyth's existing content (~line 926), add:

```markdown
**Pre-Council Consultation:**
If the player visits Grandmother Seyth at Greywood Camp before the Ashgrove
council, she shares insights about Savanh's priorities in particular. She is not
a leader herself, but her counsel carries weight with Elder Savanh. Speaking
with Seyth unlocks additional dialogue options during the Savanh private
audience that reference the Wilds' oral history of previous "grey times."
Seyth: *"Savanh does not want to hear that Valdris needs help. She wants to
hear that Valdris finally understands what it costs to ignore the Wilds."*
```

- [ ] **Step 6: Verify cross-references**

Confirm that all flag names match events.md (`council_savanh_approval`,
`council_caden_approval`, `council_wynne_approval`). Confirm NPC names match
existing entries exactly.

- [ ] **Step 7: Run verification**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 8: Commit**

```bash
git add docs/story/npcs.md
cat > /tmp/commit-msg.txt << 'COMMIT_EOF'
docs: add Thornmere Council profiles to Savanh, Caden, Wynne, Seyth

- Elder Savanh: council host, values honesty and historical awareness
- Spirit-speaker Caden: values spiritual balance, Torren rapport bonus
- Wynne: pragmatic, values strategy, Lira interaction (help or hurt)
- Grandmother Seyth: pre-council consultation unlocks Savanh dialogue

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
COMMIT_EOF
git commit -F /tmp/commit-msg.txt
```

---

### Task 5: Playable Scenes in outline.md

Add Cael's Last Night, Thornmere Council scene, Sable's Reunion Order, and
the Campfire scene to the narrative outline.

**Files:**
- Modify: `docs/story/outline.md:52-87` (Act II diplomatic mission through siege)
- Modify: `docs/story/outline.md:106-124` (Interlude: Sable's Journey)
- Modify: `docs/story/outline.md:128-134` (Act III: pre-Convergence)

**Reference:** Spec Section 3 (Playable Scenes) and Section 5 (Additional Scenes)

- [ ] **Step 1: Read current diplomatic mission and betrayal sections**

Read `docs/story/outline.md` lines 52-87. Note the existing structure:
The Diplomatic Mission (line 52), The Stranger's Work (line 58), Sable's
Warning (line 62), The Romance in Bloom (line 66), The Betrayal (line 70),
The Siege of Valdris (line 76), Act II Ends (line 82).

- [ ] **Step 2: Expand The Diplomatic Mission with Council scene**

The existing section (line 52) describes the diplomatic mission in general
terms. Add a subsection describing the Ashgrove Council as a Tier 3 playable
scene. Insert after the existing diplomatic mission content:

```markdown
#### The Thornmere Council (Playable Scene)

The diplomatic mission culminates at the Ashgrove council stones -- a Tier 3
playable scene where the player's choices determine siege support levels.

**Phase 1 (Private Audiences):** The player moves freely around Ashgrove,
speaking with Elder Savanh, Spirit-speaker Caden, and Wynne privately. Each
conversation offers 2-3 dialogue choices. Hidden approval scores track each
leader's support (see `council_savanh_approval`, `council_caden_approval`,
`council_wynne_approval` flags in `events.md`).

**Phase 2 (Council Fire):** Three topics are debated: why the Wilds should
help Valdris, who controls the Pendulum, and what happens after. Leaders react
openly to the player's responses.

**Phase 3 (Vote):** Each leader votes independently. Result stored in
`council_result` flag (0-3). Outcome determines allied support at the Valdris
Siege -- from full Thornmere tribal commitment (archers, barricades, healing herbs)
to no support at all.

See `docs/superpowers/specs/2026-03-17-narrative-expansion-design.md` Section 3,
Scene 1 for full Council design.
```

- [ ] **Step 3: Add Cael's Last Night before The Betrayal**

Insert a new section between The Romance in Bloom (line 66) and The Betrayal
(line 70):

```markdown
### Cael's Last Night (Playable Scene)

The night before the betrayal. The player controls **Cael** -- the only time
in the game outside of Sable's Interlude. The player does not know this is the
last night.

Four locations in Valdris Crown are available; time allows three visits:
- **Lira's Workshop:** Tender, guarded conversation. Neither says what they need to.
- **Training Grounds (Edren):** They spar like old times. Edren: *"Same time
  tomorrow?"* Cael: *"...Same time tomorrow."*
- **Maren's Study:** Cael asks questions too specific about the Pallor's
  previous offers. Maren notices but does not press.
- **Pendulum Vault:** No dialogue. Cael's reflection in the glass is wrong for
  one frame.

Each visit sets a flag (`cael_last_night_lira`, `cael_last_night_edren`, `cael_last_night_maren`, `cael_last_night_vault`) that alters
the betrayal cutscene's camera work and emotional framing. No visit is wrong --
each reveals a different truth about Cael's state. The control switch to Cael
is unmarked; it hits only in retrospect.

See `docs/superpowers/specs/2026-03-17-narrative-expansion-design.md` Section 3,
Scene 2 for full design.
```

- [ ] **Step 4: Add Reunion Order note to Sable's Journey**

Read `docs/story/outline.md` lines 106-124 (Sable's Journey). Add a paragraph
at the start of the section noting that reunion order is player-chosen:

```markdown
The player chooses the order of reunions. Previously reunited members are
present for later reunions, changing dialogue and emotional dynamics. Finding
Lira first means she helps stabilize Torren's ley nexus. Finding Edren first
means his steadiness grounds Lira's infiltration. Finding Torren first
provides spirit-sense hints for subsequent searches. Finding Maren first
recontextualizes all other reunions. The final reunion is always the most
emotionally charged. Flags `reunion_order_1` through `reunion_order_4` track
the sequence. The story converges at the same point regardless of order.
```

- [ ] **Step 5: Add Campfire scene before The March**

Insert a new section inside Act III, after `## Act III: The Convergence`
(line 128) and before `### The March` (line 130):

```markdown
### The Night Before the Convergence (Playable Scene)

A campfire scene. The remaining party (Edren, Lira, Torren, Sable, Maren) is
together for the last time. Cael is absent -- he is at the Convergence.

The player moves freely around the campfire. Each member can be spoken to:
- **Torren** talks about the spirits going quiet.
- **Lira** adjusts her tools, mentions something she never finished building.
- **Sable** makes a joke that does not land. Then a real one that does.
- **Maren** stares at the fire. Says she has seen this story before in the old texts. This time might be different.

If the player speaks to everyone, a group moment triggers -- Edren says
something simple that binds them. Not a battle speech, just acknowledgment.
If the player walks to the exit, the march begins without it.

`campfire_complete` flag set only if the group moment triggers.
```

- [ ] **Step 6: Run verification**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 7: Commit**

```bash
git add docs/story/outline.md
cat > /tmp/commit-msg.txt << 'COMMIT_EOF'
docs: add playable scenes to outline (Council, Last Night, campfire)

- Thornmere Council: Tier 3 playable scene with siege support consequences
- Cael Last Night: player controls Cael, 4 locations, unmarked switch
- Sable Reunion Order: player-chosen sequence affects dialogue
- Campfire: optional group moment before final march

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
COMMIT_EOF
git commit -F /tmp/commit-msg.txt
```

---

## Chunk 3: Siege Integration and Propagation

### Task 6: Cutscene Tier Assignments in outline.md

Add tier annotations to existing cutscene moments already described in the
outline, so they are formally classified.

**Files:**
- Modify: `docs/story/outline.md` (multiple sections)

**Reference:** Spec Section 2 (Cutscene Catalog)

- [ ] **Step 1: Read existing cutscene moments in outline.md**

Scan the full outline for existing cutscene moments that need tier annotations.
Key sections:
- The Stranger at the Mine (line 22) -- needs Tier 1 tag
- The Stranger's Work (Cutscene) (line 58) -- already labeled "Cutscene",
  needs Tier 1 tag
- The Betrayal (line 70) -- needs Tier 1 tag
- The Siege of Valdris (line 76) -- needs Tier 1 -> Playable tag
- The World Changes (line 92) -- needs Tier 1 tag (Ley Rupture)
- The Party Scatters (line 96, opening paragraph) -- needs Tier 2 tag for
  Sable's initial solo Walk-and-Talk after the rupture
- The March (line 130) -- needs Tier 2 tag
- Vaelith's release (line 146) -- needs Tier 1 (in-battle) tag
- Lira Reaches Cael (line 162) -- needs Tier 1 tag
- The Sacrifice (line 187) -- needs Tier 1 tag
- Final Scene (line 217) -- needs Tier 1 tag

- [ ] **Step 2: Add tier annotations**

For each section identified in Step 1, add a brief parenthetical tier label
at the start of the section's description. Example for The Stranger at the
Mine:

Before: `### The Stranger at the Mine`
After: `### The Stranger at the Mine`

Add as the first line of the section body:
`*(Tier 1: Full Cutscene)*`

Apply the same pattern to all identified sections with appropriate tiers:
- The Stranger at the Mine: *(Tier 1: Full Cutscene)*
- The Stranger's Work: *(Tier 1: Full Cutscene -- party not present)*
- The Betrayal: *(Tier 1: Full Cutscene)*
- The Siege of Valdris: *(Tier 1: Full Cutscene, transitions to playable)*
- The World Changes: *(Tier 1: Full Cutscene -- Ley Rupture)*
- The March: *(Tier 2: Walk-and-Talk)*
- The Trials: individual trial entries already Tier 3 (Playable Scene)
- Vaelith release in The Pallor Wastes: *(Tier 1: Full Cutscene, in-battle)*
- Lira Reaches Cael: *(Tier 1: Full Cutscene)*
- The Sacrifice: *(Tier 1: Full Cutscene)*
- Final Scene: *(Tier 1: Full Cutscene)*

- [ ] **Step 3: Run verification**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 4: Commit**

```bash
git add docs/story/outline.md
cat > /tmp/commit-msg.txt << 'COMMIT_EOF'
docs: add cutscene tier annotations to outline narrative beats

Classify existing cutscene moments with their presentation tier
(Full/Walk-and-Talk/Playable/Micro) per the cutscene tier system.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
COMMIT_EOF
git commit -F /tmp/commit-msg.txt
```

---

### Task 7: Siege Difficulty Scaling in dungeons-world.md and dynamic-world.md

Add the Council outcome's mechanical effect on the Valdris Siege encounter.

**Files:**
- Modify: `docs/story/dungeons-world.md:4556-4610` (Valdris Siege Battlefield)
- Modify: `docs/story/dynamic-world.md` (Valdris Crown location state)

**Reference:** Spec Section 6 (Siege Difficulty Scaling)

- [ ] **Step 1: Read current siege section**

Read `docs/story/dungeons-world.md` lines 4556-4610 (Valdris Siege Battlefield
overview and encounter design). Note the existing Allied NPC: Dame Cordwyn
section and the Phase 3 Cordwyn HP-drop mechanic.

- [ ] **Step 2: Add siege difficulty scaling table**

After the existing `**Allied NPC: Dame Cordwyn**` section (~line 4595),
insert:

```markdown
**Thornmere Alliance Support (Council Result)**

The `council_result` flag (set during the Thornmere Council at Ashgrove)
determines allied support during the siege. The siege's core design remains
the same -- what changes is the support infrastructure around it.

| `council_result` | Allied Support | Mechanical Effect |
|-------------------|---------------|-------------------|
| 3 (full) | Archers, barricades, healing herbs | Archer volleys thin pre-battle enemy waves. Barricades grant DEF +20% in certain tile positions. Infirmary save point also restores MP. |
| 2 (partial) | Archers only | Standard siege as designed above. |
| 1 (token) | Small ranger squad | One-time wave clear assist (removes one full wave of adds). Otherwise harder than standard. |
| 0 (none) | No allies | More enemy waves (+1 wave per phase). Cordwyn's HP-drop event moves to start of Phase 2 (replaces the Phase 3 drop), giving the player less time before the dialogue choice. |

**Default assumption:** The siege encounter tables above are balanced for
`council_result` = 2 (partial support). Full support makes it easier; no
support makes it harder.
```

- [ ] **Step 3: Add council outcome to dynamic-world.md**

Read `docs/story/dynamic-world.md` and find the Valdris Crown location entry
in the Location Transformation Atlas (Valdris Locations section, starting
~line 30). Add a note about how council outcome affects the siege state:

```markdown
**Thornmere Alliance (Council Outcome):** The Ashgrove council result
(`council_result` flag) visibly affects the siege battlefield. At full support
(3), Thornmere tribal archers line the walls and barricades block key chokepoints.
At partial (2), archer positions are manned but barricades are absent. At
token (1), a small ranger squad camps near the gate. At no support (0), the
walls are defended only by Valdris regulars -- visually thinner, more
desperate.
```

- [ ] **Step 4: Verify cross-references**

Confirm `council_result` flag name matches events.md. Confirm Cordwyn's
Phase 2/3 description matches the existing siege design.

- [ ] **Step 5: Run verification**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 6: Commit**

```bash
git add docs/story/dungeons-world.md docs/story/dynamic-world.md
cat > /tmp/commit-msg.txt << 'COMMIT_EOF'
docs: add siege difficulty scaling from Thornmere Council outcome

- Siege scales based on council_result flag (0-3)
- Full support: archers, barricades, MP restore at infirmary
- No support: extra waves, Cordwyn HP drop moves to Phase 2
- Visual changes in dynamic-world.md (wall defenders, barricades)

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
COMMIT_EOF
git commit -F /tmp/commit-msg.txt
```

---

## Chunk 4: Propagation Sweep and Final Verification

### Task 8: Cross-Document Propagation Sweep

Verify all new content is consistent across all modified files. This is the
mandatory propagation sweep -- the #1 failure mode is fixing in one file but
not others.

**Files:**
- Read: All files modified in Tasks 1-7

**Reference:** Entire spec

- [ ] **Step 1: Grep for all new flag names across all story docs**

For each new flag, verify it appears in events.md AND is referenced correctly
in any file that mentions it:

```bash
# Run these greps and verify consistency:
grep -r "opening_credits_seen" docs/story/
grep -r "council_savanh_approval\|council_caden_approval\|council_wynne_approval\|council_result" docs/story/
grep -r "cael_last_night" docs/story/
grep -r "reunion_order" docs/story/
grep -r "campfire_complete" docs/story/
```

For each flag, confirm:
- Defined in events.md with correct flag number and description
- Referenced in outline.md where the scene is described
- Referenced in any NPC entry that participates in the flagged event

- [ ] **Step 2: Verify NPC name consistency**

Grep for all three council leaders across all story docs:

```bash
grep -r "Elder Savanh\|Spirit-speaker Caden\|Wynne" docs/story/
grep -r "Grandmother Seyth" docs/story/
```

Confirm:
- Names are spelled identically everywhere
- No file still refers to "Elder Seyth" (the fabricated title from the
  original spec draft)
- No references to "Warden Bryn" or "Speaker Fael" (removed during review)

- [ ] **Step 3: Verify Ember Vein references**

Confirm the opening sequence overlay in dungeons-world.md does not contradict:
- The existing Narrative Beats table (lines 341-354)
- The existing Encounter Table
- The existing boss descriptions (Ember Drake, Vein Guardian)
- The existing Vaelith appearance (`vaelith_ember_vein`)

- [ ] **Step 4: Verify siege scaling**

Confirm the siege difficulty table in dungeons-world.md:
- References `council_result` with the same values as events.md
- Does not contradict Cordwyn's existing Phase 3 HP-drop mechanic
- The "standard" difficulty (council_result = 2) matches the existing
  encounter tables

- [ ] **Step 5: Verify sidequests.md cross-references**

Read `docs/story/sidequests.md` and search for "Ashgrove" and "council" and
"Proving Grounds". The Ashgrove Proving Grounds sidequest (~line 526) triggers
during the tribal alliance gathering -- the same event the new Council playable
scene covers. Verify:
- The quest's trigger and availability window are still valid with the Council
  scene's three-phase structure (private audiences -> council fire -> vote)
- If the quest is available "during the gathering," annotate whether it is
  available during Phase 1 (exploration) or throughout
- Add a cross-reference note if needed

- [ ] **Step 6: Verify cutscene tier assignments**

Cross-reference the tier annotations in outline.md against the cutscene
catalog in events.md. Every moment listed in one must match the other.
Also verify against the spec's full cutscene catalog -- check that Act IV
moments (Cael explains, farewell, Pendulum shatters), Act I-II transition
micros (figure on ridge, two teacups), and Act II moments (Vaelith tavern,
siege unwinnable fight) all have matching annotations.

- [ ] **Step 7: Final full verification**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 8: Commit any fixes found during sweep**

If the propagation sweep found inconsistencies, fix them and commit:

```bash
git add docs/story/
cat > /tmp/commit-msg.txt << 'COMMIT_EOF'
docs: propagation sweep fixes for narrative expansion

- [list specific fixes found]

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
COMMIT_EOF
git commit -F /tmp/commit-msg.txt
```

If no fixes needed, skip this step.

---

## Dependency Map

```
Task 1 (Opening/Ember Vein) ──┐
                               ├── Task 8 (Propagation Sweep)
Task 2 (Events/Flags) ────────┤
                               │
Task 3 (Characters) ──────────┤
                               │
Task 4 (NPCs/Council) ────────┤
                               │
Task 5 (Playable Scenes) ─────┤
                               │
Task 6 (Tier Annotations) ────┤
                               │
Task 7 (Siege Scaling) ───────┘
```

Tasks 1-7 are largely independent (different files or different sections of
the same file). Task 8 depends on all of them. Tasks 1 and 2 should be done
first since other tasks reference the flags and opening sequence they define.
Tasks 3-7 can be done in any order after 1 and 2. Task 8 must be last.
