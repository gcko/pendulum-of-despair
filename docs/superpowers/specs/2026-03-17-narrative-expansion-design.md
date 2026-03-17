# Narrative Expansion Design

> **For agentic workers:** This spec defines narrative presentation systems
> for Pendulum of Despair. Implementation touches story docs only (no code).
> Use superpowers:writing-plans to create the implementation plan.

**Goal:** Add an FF6-style opening sequence, a formal cutscene tier system,
playable scenes with narrative/mechanical repercussions, and a death/fast-reload
mechanic.

**Inspiration:** Final Fantasy VI's Narshe opening (tutorial + mini-boss +
playable credits), the Emperor's Banquet (social encounter with mechanical
payoff), and FF6's instant game-over reload.

---

## 1. The Opening Sequence (Ember Vein)

Three beats that mirror FF6's Narshe opening. The player meets Edren and Cael,
learns combat across the existing Ember Vein dungeon (4 floors), encounters the
Pendulum and Vaelith, escapes with Lira and Sable, and watches opening credits
roll over a playable dawn march.

**Relationship to existing content:** The Ember Vein dungeon already exists in
`dungeons-world.md` as the game's first dungeon (4 floors, Ember Drake mini-boss
on Floor 2, Vein Guardian boss on Floor 4, Lira and Sable join during the escape).
This spec adds the "taste of power" overlay, the Vaelith encounter framing, and
the opening credits sequence. It does NOT replace the Ember Vein's floor layouts,
puzzles, or encounter tables.

### Beat 1: The Ember Vein Descent (Tutorial)

Edren and Cael enter the Ember Vein on King Aldren's orders. The player
controls Edren. Cael is AI-controlled and follows. The existing 4-floor
dungeon structure teaches the player through its progression:

- **Floor 1 (Upper Mine):** Movement, interaction, mine cart routing puzzle.
  Dead miners line the corridors. Cael: *"No wounds. They just... stopped."*
- **Floor 2 (Lower Mine):** Escalating encounters. Wall switch sequence. The
  **Ember Drake** mini-boss serves as the first real combat test.
- **Floor 3 (Ancient Ruin):** Geometric murals. Dying ember crystal puzzle.
  The tone shifts from mine to something older.
- **Floor 4 (Pendulum Chamber):** The Pendulum is discovered. The **Vein
  Guardian** boss assembles from crystal formations when the party tries to
  leave.

**The "taste of power" -- dual preview:**

- **Edren carries Arcanite-enhanced gear** from the Valdris armory (standard
  issue for royal knights on investigation missions). The sword and shield hit
  harder and block more than normal Act I levels. This gear breaks during the
  escape from Carradan soldiers after the Vein Guardian fight, giving the
  player a mechanical preview of Arcanite Forging that Lira will unlock later.

- **Cael has unexplained extra power.** His attacks shimmer faintly. His damage
  output is slightly higher than his stats justify. The game offers no
  explanation. In hindsight -- after the betrayal in Act II -- the player
  realizes this was the Pallor's first touch. Cael was already marked before
  the story began. The shimmer is most visible during the Ember Drake and
  Vein Guardian fights.

### Beat 2: Escape and Vaelith (Post-Vein Guardian)

After the Vein Guardian falls:

1. Edren picks up the Pendulum. The needle twitches.
2. Carradan soldiers arrive. The party flees through the secret exit.
3. During the escape, **Lira** and **Sable** join (as already documented).
4. The party emerges from the mine into the cold night air. **Vaelith** is
   already there -- leaning against a broken stone column. *"A fragile little
   thing to build hope around."* Bows. Walks into the dark. No threat is
   made. No threat is needed.
5. Smash cut to black.

### Beat 3: The Dawn March (Opening Credits)

Music shifts. The player controls Edren walking the trail from Ironmouth toward
the Thornmere Wilds -- forward only, no encounters, no branching. Cael walks
alongside (Lira and Sable trail behind, visible but not in dialogue). The
landscape opens as they travel: forests, distant peaks, the continent's scale
revealing itself in the dawn light.

**Dialogue triggers as they walk (4-5 exchanges):**

1. Cael: *"Those miners... they just stopped. No fight, no wounds. They gave up."*
2. Edren: *"We'll let the court decide what it is."*
3. Cael: *"And the stranger? You're not concerned?"*
4. Edren: *"I'm concerned about all of it."*
5. *(Beat of silence as the trail widens to show the valley below)*
6. Cael: *"...I keep thinking about their faces."*

Character names, game title, and key credits appear overlaid during the walk.
The sequence ends as the party reaches the Wilds border.

**Game title card: PENDULUM OF DESPAIR.**

The `opening_credits_seen` flag is set. The game continues into the Wilds
(Torren encounter, then Maren at her refuge).

---

## 2. Cutscene Tier System

All scripted narrative content falls into one of four tiers. Each tier has
distinct rules for player control, camera behavior, and presentation.

### Tier 1: Full Cutscene

- **Player control:** None. Input locked.
- **Presentation:** Screen letterboxes (black bars top and bottom). Camera is
  director-controlled.
- **Use for:** Major emotional beats with maximum impact. Sparingly deployed.

### Tier 2: Walk-and-Talk

- **Player control:** Movement within the scene space. No combat, no choices.
- **Presentation:** No letterboxing. Normal camera follows the player. NPCs
  deliver dialogue triggered by proximity or progress.
- **Use for:** Exposition, character building, arrival at new locations. The
  player's agency is in pacing and observation, not outcomes.

### Tier 3: Playable Scene

- **Player control:** Full control. Real decisions with tracked outcomes.
- **Presentation:** Normal gameplay camera. Dialogue choices appear as menu
  options. Hidden approval scores or flag-setting based on choices.
- **Use for:** Banquet-style social encounters, moral choices, perspective
  shifts. These are the moments where player agency shapes the experience.

### Tier 4: Micro-Cutscene

- **Player control:** Briefly interrupted (under 10 seconds), then returned.
- **Presentation:** No letterboxing. A brief camera shift, character reaction,
  or visual flash, then back to gameplay.
- **Use for:** Environmental storytelling, character moments, foreshadowing.
  These fire during exploration without feeling like interruptions.
- **Design rule:** Micro-cutscenes never repeat. Each is tied to a one-time
  flag. If the player misses one (wrong party lead, did not visit the area),
  it is gone. This makes exploration feel alive.

### Cutscene Catalog

#### Act I

| Moment | Tier | Trigger |
|--------|------|---------|
| Ember Vein dungeon (Floors 1-4) | Playable (tutorial) | Game start |
| Vaelith appears outside the mine | Full | `vaelith_ember_vein` (post-Vein Guardian, during escape) |
| Lira and Sable join during escape | Full (brief) | Ember Vein escape sequence |
| Dawn march (opening credits) | Walk-and-Talk | `opening_credits_seen` trigger |
| Torren finds the party in the Wilds | Walk-and-Talk | Story progression |
| Maren examines the Pendulum | Full | `maren_warning` (arrive at Maren's Refuge) |

#### Act I-II Transition

| Moment | Tier | Trigger |
|--------|------|---------|
| Figure on a ridge (Vaelith) | Micro | Travel between acts |
| Campsite with two teacups and journal fragment | Micro | Exploration |
| Torren pieces together the cycle fragments | Walk-and-Talk | Enough fragments collected |

#### Act II

| Moment | Tier | Trigger |
|--------|------|---------|
| Cael's first nightmare | Micro | `cael_nightmares_begin`, triggers during rest |
| Subsequent nightmares (escalating) | Micro (x3-4) | Progression through Act II |
| Vaelith at the tavern (Corrund/Bellhaven) | Walk-and-Talk | `vaelith_tavern_encounter` |
| The Stranger's Work (Vaelith comforts a village) | Full | `vaelith_doma_moment` (automatic, party not present) |
| Panoramic view from Wynne's Observatory | Full | `canopy_alliance` |
| The Thornmere Council at Ashgrove | Playable Scene | `tribal_alliance_complete` progression |
| Cael's Last Night | Playable Scene | Night before `cael_betrayal_complete` |
| Cael's betrayal | Full | `cael_betrayal_complete` |
| Siege of Valdris (opening) | Full (transitions to playable battle) | `carradan_assault_begins` |
| Vaelith at the siege (unwinnable fight) | Full | Post-Ashen Ram defeat |

#### Interlude

| Moment | Tier | Trigger |
|--------|------|---------|
| The Ley Line Rupture | Full | `interlude_begins` |
| Sable alone in the aftermath | Walk-and-Talk | Immediately after rupture |
| Each party reunion approach | Walk-and-Talk | Per reunion flag |
| Each party reunion resolution | Playable Scene (dialogue choices) | Per reunion flag |

#### Act III

| Moment | Tier | Trigger |
|--------|------|---------|
| The march to the Convergence | Walk-and-Talk | Act III opening |
| The Night Before the Convergence (campfire) | Playable Scene | Pre-Convergence |
| Each Pallor Trial | Playable Scene | Per trial entry |
| Vaelith's release (10-attack threshold) | Full (in-battle) | Battle mechanic |
| Lira reaches Cael | Full | Post-final-battle |
| Cael: *"I'm sorry."* Edren: *"I know."* | Full | Post-Lira scene |

#### Act IV

| Moment | Tier | Trigger |
|--------|------|---------|
| Cael explains the door must close from inside | Full | Act IV opening |
| The party's farewell | Walk-and-Talk | Pre-final sequence |
| Cael walks into the door | Full | Narrative climax |
| The Pendulum shatters | Full | Door closes |

#### Epilogue

| Moment | Tier | Trigger |
|--------|------|---------|
| Epilogue montage (each character's fate) | Full | Post-game |
| Edren places Cael's sword at the Convergence | Full | Final scene |

#### Micro-Cutscene Pool (Non-Exhaustive)

These are examples. Additional micro-cutscenes can be added during
implementation without changing the system design.

| Moment | Location | Trigger |
|--------|----------|---------|
| Vaelith watching from a ridge | Overworld transitions | One-time, early Act II |
| Cael flinches near Pallor-touched area | Any corrupted zone | First visit with Cael in party |
| Nightmare flash at save point | Any save point rest | Random, Act II only, Cael in party |
| Torren's spirits react to ley disturbance | Near ley rupture sites | First visit with Torren |
| Sable pockets something | Towns/shops | One-time per town, Sable in party |
| Lira pauses at Forgewright machinery | Carradan locations | One-time, Lira in party |
| Vaelith's teacup left behind | Various campsites | Discovery-based |

---

## 3. Playable Scenes with Repercussions

Four major Tier 3 scenes, each demonstrating a different relationship between
player choice and consequence.

### Scene 1: The Thornmere Council at Ashgrove

**Act:** II
**Type:** Mechanical consequences (choices affect Valdris Siege difficulty)
**Duration:** 15-20 minutes of gameplay

**Setup:** Edren leads the diplomatic mission to unite three Thornmere tribes
against the Pallor. The Council takes place at the Council Stones in Ashgrove.

#### Phase 1: Private Audiences (Exploration + Dialogue)

Before the council fire, the player moves freely around Ashgrove and speaks
with each tribal leader privately. Each conversation offers 2-3 dialogue
choices. Each leader tracks a hidden approval score (0-3 scale).

The three tribal leaders correspond to the existing alliance structure in
`events.md`: Greywood/Ashgrove (Elder Savanh), Duskfen (Spirit-speaker
Caden), and Canopy Reach (Wynne). The individual alliance quests
(`diplomatic_mission_start` through `tribal_alliance_complete`) culminate
in this council scene at Ashgrove.

**Elder Savanh (Greywood tribe / Ashgrove council host)**
- Values: Honesty and historical awareness. The eldest tribal leader.
- Responds to: Admissions of Valdris's past failures toward the Wilds.
- Penalizes: Flattery, dismissiveness, treating alliance as Valdris's right.
- Party interaction: Grandmother Seyth (herbalist, oral historian at Greywood
  Camp) can be consulted before the council for insight into Savanh's
  priorities. Seyth is not a leader herself but her counsel carries weight.

**Spirit-speaker Caden (Duskfen)**
- Values: The land's spiritual balance and ley line health.
- Responds to: Ley line knowledge, genuine concern for the Wilds' survival.
- Penalizes: Treating the Wilds as a resource, instrumentalizing spirit-speech.
- Party interaction: Torren's spirit-speaker status creates natural rapport.
  Referencing Maren's Pendulum research (if the player has it) impresses Caden.

**Wynne (Canopy Reach)**
- Values: Strength, pragmatism, and strategic clarity.
- Responds to: Concrete battle plans, honest assessment of the Pallor threat.
- Penalizes: Vague promises, appeals to emotion over tactics.
- Party interaction: Lira's Forgewright background can help (she understands
  military engineering) or hurt (Forgewrights damaged ley lines) depending on
  how the player frames her expertise.

#### Phase 2: The Council Fire (Structured Debate)

All three leaders, the party, and witnesses gather. Three topics are raised in
sequence. For each, the player picks from 3-4 response options. Leaders react
openly -- the player can see approval shifting through dialogue and body
language.

**Topic 1:** *"Why should the Wilds bleed for Valdris's war?"*
(Justify the alliance. The player must explain why the Pallor is everyone's
problem, not just Valdris's.)

**Topic 2:** *"The Pendulum -- who controls it?"*
(Trust and transparency. The player chooses how much to reveal about the
Pendulum's nature and the party's plans for it.)

**Topic 3:** *"What happens after?"*
(Post-war commitments. The player makes promises about Valdris's relationship
with the Wilds after the Pallor is dealt with.)

#### Phase 3: The Vote

Each leader votes independently based on cumulative approval score.

| Council Result | `council_result` | Siege Impact |
|----------------|-------------------|-------------|
| All three support | 3 | Full Thornwatch: archers on walls, barricades at gates, healing herbs for infirmary. Siege significantly easier. |
| Two of three | 2 | Partial: archers only, no barricades. Siege is standard difficulty. |
| One of three | 1 | Token: a small ranger squad. Siege is harder -- fewer allied NPCs, no environmental advantages. |
| None support | 0 | Party goes alone. Siege at maximum difficulty. Cordwyn's HP drops to 25% earlier in the fight (start of Phase 2 instead of Phase 3), giving the player less time before the dialogue choice. |

The player does not see exact scores. They read the room and make their case.
No single "correct" path -- different leaders respond to different approaches.

### Scene 2: Cael's Last Night

**Act:** II (night before the betrayal)
**Type:** Narrative consequences (choices affect player understanding, not
mechanics)
**Duration:** 10-15 minutes of gameplay

**Setup:** The night before Cael takes the Pendulum and vanishes. The player
controls **Cael** -- the only time in the game the player controls anyone other
than Edren (outside of Sable's Interlude). The player does not know this is
the last night. It feels like a quiet character moment.

#### Structure: Open Exploration, Time-Limited

Cael is in Valdris at night. Four locations are available. There is time for
**three visits** before dawn triggers the betrayal cutscene
(`cael_betrayal_complete`). The player must choose.

**Lira's Workshop**
Lira is working late on Arcanite research. Cael watches her from the doorway.
Their conversation is tender, guarded. Lira almost tells him something. Cael
almost tells her something. Neither does.
- **Flag set:** `cael_last_night_lira`
- **Betrayal cutscene effect:** The camera lingers on Lira's face. She knew
  something was wrong.

**The Training Grounds (Edren)**
Edren is practicing sword forms alone. They spar like old times. The dialogue
is easy, familiar -- two friends who do not need to say much. Edren: *"Same
time tomorrow?"* Cael: *"...Same time tomorrow."*
- **Flag set:** `cael_last_night_edren`
- **Betrayal cutscene effect:** Edren's reaction shot is longer. The player
  feels the weight of the broken promise.

**Maren's Study**
Maren is reading about previous Pallor cycles. Cael asks questions that are too
specific -- what does the Pallor want? What did it offer the last time? Maren
notices but does not press.
- **Flag set:** `cael_last_night_maren`
- **Betrayal cutscene effect:** The player understands Cael was researching
  what the Pallor wanted, not looking for a cure. His betrayal was informed,
  not impulsive.

**The Pendulum Vault**
Cael stands alone with the Pendulum. No dialogue. The camera holds. The
Pendulum's glow reflects in his eyes. A micro-cutscene: for one frame, his
reflection in the glass case is not quite right -- the silhouette is taller,
the posture different. Then it is gone.
- **Flag set:** `cael_last_night_vault`
- **Betrayal cutscene effect:** The player knows Cael was already in contact
  with the Pallor. The betrayal was decided before this night began.

**Design rules:**
- No visit is "wrong." Each reveals a different truth about Cael's state.
- The combination the player chooses creates their personal understanding of
  who Cael was in his last hours.
- On replay, visiting different locations tells a different story with the
  same ending. This is not branching -- it is perspective.
- **Subtle tell:** The player may not realize they are controlling Cael until
  after the betrayal cutscene, when control returns to Edren. The switch is
  unmarked. On reflection, it hits.

### Scene 3: Sable's Reunion Order

**Act:** Interlude
**Type:** Dialogue and emotional texture (choices affect character interactions,
not plot)
**Duration:** Spread across the entire Interlude

**Setup:** After the party scatters, Sable must find all four members. The
player chooses the reunion order.

**Reunion targets:** Edren, Lira, Torren, Maren.

**How order matters:** Previously reunited members are present for later
reunions. This changes the dialogue and emotional dynamics:
- Finding Lira first: she is present for Torren's reunion and helps stabilize
  the ley nexus with her Forgewright tools.
- Finding Edren first: his steadiness grounds Lira's Forgewright infiltration
  sequence.
- Finding Torren first: his spirit-sense helps locate the others more quickly
  (additional dialogue hints in subsequent reunions).
- Finding Maren first: her knowledge recontextualizes the other reunions --
  she explains what the Pallor has done to each of them.

**The final reunion** (whichever member is found last) gets the most
emotionally charged version. Sable is exhausted, the stakes are clear, and the
reunion dialogue reflects the accumulated weight of the journey.

**Flags:** `reunion_order_1` through `reunion_order_4` track the sequence.
The story converges at the same point regardless of order.

### Scene 4: The Night Before the Convergence

**Act:** III (pre-final push)
**Type:** Purely emotional (no mechanical or narrative consequence)
**Duration:** 5-10 minutes

**Setup:** A campfire scene. The remaining party (Edren, Lira, Torren, Sable,
Maren) is together for the last time before the march to the Convergence.
Cael is absent -- he betrayed the party in Act II and is at the Convergence.

**Structure:** The player moves freely around the campfire. Each party member
can be spoken to for a short conversation. No grand speeches -- just people
being honest before the end.

- **Torren** talks about the spirits going quiet.
- **Lira** adjusts her tools, mentions something she never finished building.
- **Sable** makes a joke that does not land. Then a real one that does.
- **Maren** stares at the fire. Says she has seen this story before in the
  old texts. This time might be different.

**Optional group moment:** If the player talks to every party member, a group
moment triggers. Edren says something simple that binds them -- not a battle
speech, just acknowledgment. If the player walks to the exit without speaking
to everyone, the march begins without it.

**Flag:** `campfire_complete` is set only if the group moment triggers.

---

## 4. Death Scene and Fast Reload

When all party members are KO'd in battle, the game executes a clean
three-beat sequence.

### The Sequence

**Beat 1: The Fall (2 seconds)**
The last party member's KO animation plays. The battle UI fades out. The music
cuts -- not a fade, a hard stop. One beat of silence.

**Beat 2: Fade to Black (2 seconds)**
The screen fades to black. No text, no menu, no "Game Over" title card. Just
black. The silence holds.

**Beat 3: Instant Reload (immediate)**
The screen fades back in at the last save point. The party is at full HP/MP
as of the last save. The save point marker glows briefly so the player
registers their location. Ambient music resumes. Player control returns.

**Total elapsed time from KO to gameplay: approximately 4 seconds.**

### Design Rules

- **No menu.** No "Continue?" prompt. No "Return to Title" option. The player
  saved at that point; that is where they go.
- **Boss cutscene skip:** Bosses with pre-battle cutscenes (Tier 1) set a
  "seen" flag on first viewing. On reload, the cutscene does not replay. The
  player spawns at the save point, walks to the boss room, and the fight
  starts immediately.
- **Narrative defeats are exempt.** The unwinnable Vaelith fight at the Siege
  (Act II) does NOT trigger this sequence. That defeat is scripted -- it
  transitions to the aftermath cutscene. The death/reload mechanic fires only
  on genuine gameplay losses.
- **No save data edge case:** If the player dies before reaching the first
  save point in the Ember Vein (unlikely given Arcanite gear), the game
  reloads at the dungeon entrance. The early floors are forgiving enough
  that this is never punishing.
- **Party menu handles "Return to Title"** as a separate player-initiated
  action (future scope, outside this spec).

---

## 5. Event Flag Additions

New flags required by the systems in this spec. These integrate with the
existing event flag system in `events.md`.

### Tutorial and Opening

| Flag | Type | Trigger | Purpose |
|------|------|---------|---------|
| `opening_credits_seen` | Progression | Dawn march ends at Wilds border | Prevents replay, marks true game start. Sequencing: Vein Guardian defeated -> escape with Lira/Sable -> `vaelith_ember_vein` cutscene -> dawn march -> this flag set. |

### Thornmere Council

| Flag | Type | Trigger | Purpose |
|------|------|---------|---------|
| `council_savanh_approval` | Hidden (0-3) | Private audience choices | Tracks Elder Savanh's support |
| `council_caden_approval` | Hidden (0-3) | Private audience choices | Tracks Spirit-speaker Caden's support |
| `council_wynne_approval` | Hidden (0-3) | Private audience choices | Tracks Wynne's support |
| `council_result` | Progression (0-3) | Council vote resolves | Stores outcome tier, read by siege encounter |

### Cael's Last Night

| Flag | Type | Trigger | Purpose |
|------|------|---------|---------|
| `cael_last_night_lira` | Binary | Visited Lira's workshop | Affects betrayal cutscene camera |
| `cael_last_night_edren` | Binary | Visited training grounds | Affects betrayal reaction shot |
| `cael_last_night_maren` | Binary | Visited Maren's study | Recontextualizes betrayal motive |
| `cael_last_night_vault` | Binary | Visited Pendulum vault | Reveals Pallor contact pre-existing |

### Interlude Reunions

| Flag | Type | Trigger | Purpose |
|------|------|---------|---------|
| `reunion_order_1` | Character ID | First reunion | Tracks sequence for dialogue variation |
| `reunion_order_2` | Character ID | Second reunion | Tracks sequence for dialogue variation |
| `reunion_order_3` | Character ID | Third reunion | Tracks sequence for dialogue variation |
| `reunion_order_4` | Character ID | Fourth reunion | Tracks sequence for dialogue variation |

### Campfire

| Flag | Type | Trigger | Purpose |
|------|------|---------|---------|
| `campfire_complete` | Binary | Spoke to all party members | Triggers group moment |

### Boss Cutscene Tracking

| Flag | Type | Trigger | Purpose |
|------|------|---------|---------|
| `boss_cutscene_seen_<boss_id>` | Binary | First viewing of any boss intro | Prevents replay on death/reload |

---

## 6. Integration with Existing Systems

### Siege Difficulty Scaling

The `council_result` flag modifies the Valdris Siege encounter already
documented in `dungeons-world.md`. The siege's existing design (Ashen Ram
fight, Cordwyn's breaking point, Vaelith unwinnable fight) remains unchanged.
What changes:

| `council_result` | Allied Support | Mechanical Effect |
|-------------------|---------------|-------------------|
| 3 (full) | Archers, barricades, healing herbs | Archer volleys thin pre-battle waves. Barricades grant DEF +20% in certain positions. Infirmary save point also restores MP. |
| 2 (partial) | Archers only | Standard siege as currently designed. |
| 1 (token) | Small ranger squad | One-time wave clear assist. Otherwise harder than standard. |
| 0 (none) | No allies | More enemy waves. Cordwyn's HP drops to 25% earlier in the fight (start of Phase 2 instead of Phase 3), giving the player less time before the dialogue choice. |

### Pallor Trial Interaction

The Pallor Trials (designed in the boss deep pass, PR #12) are Tier 3 playable
scenes. They are the Act III payoff for the choice systems established in
Act II. The Council teaches "read the room, choose wisely." Cael's Last Night
teaches "your perspective shapes meaning." The trials combine both -- read
the manifestation, choose acceptance over defiance, and the player's
understanding of each character (built across the whole game) informs whether
the correct response feels earned or forced.

### Save Point Interaction

Save points already exist before every boss and in every settlement. The fast
reload mechanic does not change save point placement. It changes what happens
when the player loses. The `boss_cutscene_seen_<boss_id>` flag system ensures
cutscenes play once and are skipped on reload.

### What This Spec Does NOT Change

- Pallor Trial mechanics (boss stats, dialogue choices, ability unlocks)
- Vaelith encounter progression (7 appearances -- the opening uses the
  existing `vaelith_ember_vein` appearance, not a new one)
- Boss stat blocks (HP values, movesets, drops) -- the Ember Drake and Vein
  Guardian remain as documented
- Dungeon layouts and floor structures (including Ember Vein's 4 floors)
- Side quest system
- Party composition or character abilities
- Existing event flags (new flags are additive only)
- The existing diplomatic mission arc (Duskfen, Canopy Reach, Ashgrove
  alliances) -- the Council scene is the culmination of this arc, not a
  replacement

---

## 7. Files Affected

Implementation will modify the following story documents:

| File | Changes |
|------|---------|
| `docs/story/outline.md` | Add opening sequence beats (taste of power, dawn march, credits), formalize cutscene placement, add Cael's Last Night and campfire scene to narrative arc |
| `docs/story/events.md` | Add ~12 new event flags, add cutscene catalog reference, add Council scene and Last Night to event flow |
| `docs/story/characters.md` | Add notes on Cael's shimmer (Pallor's first touch visible in Ember Vein), Cael's Last Night control switch, Arcanite gear preview for Edren |
| `docs/story/npcs.md` | Expand Elder Savanh, Spirit-speaker Caden, and Wynne entries with Council scene dialogue profiles. Expand Grandmother Seyth with pre-council consultation role |
| `docs/story/dungeons-world.md` | Add "taste of power" overlay notes to Ember Vein section (Arcanite gear, Cael shimmer), add siege difficulty scaling table to Valdris Siege Battlefield |
| `docs/story/sidequests.md` | Cross-reference Council scene if any quests are affected by council outcome |
| `docs/story/dynamic-world.md` | Add Council outcome effects on siege state |

No code files are modified. This is a story documentation pass.
