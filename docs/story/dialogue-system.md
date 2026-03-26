# Dialogue System Mechanics

> Formalizes the mechanical layer of the dialogue system: sprite emotion
> animations, NPC dialogue state resolution, party-aware dialogue, and
> the dialogue data format. Visual presentation (box layout, text speed,
> choice prompts) is already specified in
> [ui-design.md](ui-design.md) Section 12.
>
> **Core philosophy:** SNES FF6 pure. No portraits in dialogue — ever.
> Emotion is conveyed through judicious writing and character sprite
> animations (jumping, shaking, turning away, crying, etc.). The world
> feels alive because sprites act out emotions on screen while clean
> text boxes deliver the words.
>
> **Related docs:** [ui-design.md](ui-design.md) |
> [characters.md](characters.md) | [events.md](events.md) |
> [npcs.md](npcs.md) | [magic.md](magic.md) |
> [abilities.md](abilities.md)

---

## 1. Dialogue Box Summary

Already fully specified in [ui-design.md](ui-design.md) Section 12. Key
values for quick reference:

- **Layout:** Full screen width, bottom-anchored, 3 visible lines max.
  Dark navy background (#000040), 2px blue-grey border (#5566aa).
  Speaker name in small inset tag at top-left corner.
- **Text speeds:** Slow (30 cps), Normal (60 cps), Fast (120 cps),
  Instant. Confirm instantly completes current box; bouncing down-arrow
  when complete. Multi-page advances on confirm, no scrollback.
- **Choice prompts:** 2-4 options, vertical layout, hand cursor. Yellow
  selected / pale blue unselected. Cancel selects bottom option
  (typically "No").

Portrait emotion variants are **not needed**. The 32x32 menu portraits
use a single neutral expression per character. All in-scene emotion is
handled by the sprite emotion system (Section 2).

One exception: Cael's final Act IV dialogue — the border flickers grey
for 2 frames, then returns to canonical blue-grey. This is the only
dialogue box visual variation in the entire game.

---

## 2. Sprite Emotion System

The primary tool for conveying emotion during dialogue. These are
character sprite animations that fire between dialogue boxes, replacing
the portrait emotion system used in later FF6 ports.

### 2.1 Animation Catalog (14 Animations)

| ID | Animation | Visual Description | Duration | Use Case |
|----|-----------|--------------------|----------|----------|
| `jump` | 1-2 vertical hops | Sprite lifts 4-8px, lands | 0.4s | Surprise, excitement, realization |
| `shake` | Rapid horizontal vibration | Sprite oscillates +/-2px | 0.5s | Anger, frustration, strain |
| `turn_away` | Rotate to face away | Sprite flips to opposite direction | 0.3s | Shame, rejection, hiding emotion |
| `head_down` | Slight downward shift | Sprite drops 2px, holds position | 0.4s | Sadness, defeat, resignation |
| `bubble_exclaim` | "!" above sprite | Popup, fades | 1.0s | Shock, sudden realization |
| `bubble_ellipsis` | "..." above sprite | Popup, fades | 1.5s | Hesitation, processing, tension |
| `bubble_question` | "?" above sprite | Popup, fades | 1.0s | Confusion, suspicion |
| `sweat_drop` | Drop at temple | Animated drop slides down, fades | 0.8s | Nervousness, awkwardness |
| `cry` | Tear streams from eyes | 2 animated streams, loops until cleared | Loop | Grief, overwhelming emotion |
| `red_tint` | Full body flashes red | Sprite tints red, fades back | 0.5s | Embarrassment, intense rage |
| `arms_up` | Arms raise overhead | Sprite frame swap, holds | 0.5s | Celebration, triumph, rallying |
| `collapse` | Sprite drops to ground | Falls down, holds until cleared | 0.6s | Overwhelm, comedic shock |
| `nod` | Small downward bob | Sprite dips 2px and returns, 1-2x | 0.4s | Agreement, determination |
| `step_back` | Sprite retreats 8-16px | Quick backward move, holds | 0.3s | Fear, recoil, intimidation |

### 2.2 Timing Rules

- Animations trigger **between** dialogue boxes, not during text
  rendering.
- The dialogue engine pauses text advance until the animation completes.
- Multiple characters can animate simultaneously (e.g., the full party
  reacts to Cael's betrayal — Edren shakes, Maren steps back, Lira
  shows a `bubble_exclaim`, all at once).
- Looping animations (`cry`) persist across dialogue boxes until
  explicitly cleared.
- Animations are referenced by ID in the dialogue data format
  (Section 4).

### 2.3 Usage Guidelines

Animations are used **judiciously** — not every line gets one. The
writing carries baseline emotion; animations punctuate key moments. A
typical scene with 10 dialogue boxes might have 2-3 sprite animations.
Overuse cheapens the effect.

**Good usage:** Edren shakes with anger after Cael's betrayal reveal,
then the next 4 lines of shocked dialogue play with no animation — the
shake already set the tone.

**Bad usage:** Every character animates on every line, turning a tense
scene into a puppet show.

**Character-specific notes:**

- **Edren** — favors `shake`, `nod`, restrained physicality. Rarely
  `cry` (only the Interlude).
- **Cael** — `turn_away` is his signature. Used during the betrayal and
  any moment he hides his true feelings.
- **Maren** — `bubble_ellipsis` when processing, `head_down` when
  overwhelmed by scholarly failure.
- **Lira** — `bubble_exclaim` and `arms_up` — expressive, quick to
  react.
- **Torren** — `step_back` (recoil from magic he distrusts), `nod`
  (stoic agreement).
- **Sable** — `sweat_drop` (deflecting with humor), `red_tint`
  (rare genuine anger).

---

## 3. NPC Interaction Model & Party-Aware Dialogue

### 3.1 NPC Interaction Rules

- **Single interaction per confirm press** — no dialogue trees. The
  player presses confirm, the NPC delivers their current dialogue
  (one or more text boxes), and the interaction ends.
- **Re-talking repeats current dialogue.** Talking to the same NPC
  again delivers the same lines, unless an event flag has changed
  since the last interaction.
- **Priority stack determines current dialogue.** Each NPC has an
  ordered list of flag-gated entries. The engine evaluates
  top-to-bottom and serves the first entry whose condition is true
  (first-match-wins).
- **No branching conversation flows.** NPCs deliver linear exchanges
  with occasional choice prompts (2-4 options). Choices set flags or
  increment scores; they never open sub-menus or nested dialogue
  paths.

### 3.2 Priority Stack Resolution

Each NPC has an ordered list of dialogue entries. The engine walks
top-to-bottom and serves the **first** entry whose condition evaluates
true. Authors control priority through entry ordering — later story
states go higher in the stack so they take precedence.

**Worked example — Scholar Aldis:**

```
NPC: Scholar Aldis
  [convergence_reached]          -> "The equations... they were wrong all along."
  [cael_betrayal_complete]       -> "I catalogued his notes for months. I should have seen it."
  [cael_nightmares_begin]        -> "Have you noticed Cael seems... distracted lately?"
  [pendulum_to_capital]          -> "Cael's temporal research is remarkable. Truly remarkable."
  [default]                      -> "Welcome to the Valdris archives."
```

The engine checks each condition in order:

1. Has the party reached the Convergence? If yes, serve that line.
2. Otherwise, has Cael's betrayal completed? If yes, serve that line.
3. Otherwise, have Cael's nightmares begun? And so on.
4. If no condition matches, the `[default]` entry fires.

The author never writes `if/else` logic. Priority is implicit in the
ordering. Moving an entry higher makes it win over entries below it.

### 3.3 Flag Types in Conditions

| Type | Syntax | Example | Notes |
|------|--------|---------|-------|
| Binary flag | `flag_name` | `cael_betrayal_complete` | True when the flag has been set |
| Numeric comparison | `score_name >= N` | `council_savanh_approval >= 2` | Supports `>=`, `<=`, `==`, `!=`, `>`, `<` |
| String comparison | `flag_name == value` | `reunion_order_1 == edren` | Used for reunion order and any value-storing flags |
| Party presence | `party_has(member)` | `party_has(torren)` | True when the named character is in the active party |

**Combination rules:**

- **AND:** Multiple conditions on a single entry must all be true.
  Written as: `[cael_betrayal_complete AND party_has(lira)]`.
- **OR:** Handled by separate entries in the priority stack. Each
  entry is its own condition — if you want "A or B triggers this
  line," create two entries with the same dialogue text at the same
  priority level.

**Reunion order flags:** `reunion_order_1` through `reunion_order_4`
(events.md flags 48-51) store character IDs (`edren`, `lira`,
`torren`, `maren`). String comparison against these flags enables
reunion-order-dependent dialogue.

**Score ranges:** `council_savanh_approval` (events.md flag 40) has
range 0-3. Dialogue choices alone earn 0-2; consulting Grandmother
Seyth before the council unlocks a bonus option that reaches 3.

### 3.4 Choice Consequences (Two Patterns Only)

Dialogue choices produce one or both of two consequence types:

1. **Binary flag set:** The choice sets a flag that gates future
   dialogue or events.
   - Example: Cael visits the Pendulum vault the night before the
     betrayal, setting `cael_last_night_vault` (events.md flag 47).
     This flag alters the betrayal cutscene — Cael's reflection is
     wrong for one frame, revealing pre-existing Pallor contact.

2. **Numeric score increment:** The choice adds points to a named
   score variable.
   - Example: A diplomatic answer during Savanh's audience adds +2 to
     `council_savanh_approval` (events.md flag 40). The total score
     (0-3) determines Savanh's support at the tribal council and
     unlocks the Grandmother Seyth bonus dialogue path at score 3.

**Explicit design constraints:**

- No hidden tracking. Every flag and score is documented in events.md.
- No relationship meters. NPC attitudes change via binary flags and
  score thresholds, not continuous affinity values.
- No timed choices. The player has unlimited time to decide.
- Every consequence uses one or both of these two patterns. An option
  may set a flag AND increment a score. A `score_delta` of `0` is a
  valid intentional outcome (records the question was answered with a
  neutral response).

### 3.5 Party-Aware Dialogue

Party composition affects dialogue at two tiers, balancing narrative
richness against script volume.

#### Tier 1 — Key Story Scenes (~15-20 scenes)

Party composition changes specific lines during major story beats.
Implemented as `party_has()` checks in the priority stack. Scenes
that receive party-aware treatment:

- **Reunion scenes** (Interlude) — Reunion order (`reunion_order_1`
  through `reunion_order_4`) changes who greets whom and how. Finding
  Edren first vs. finding Lira first produces different emotional
  framing for each subsequent reunion.
- **Cael's betrayal** (`cael_betrayal_complete`) — The
  `cael_last_night_*` flags (44-47) change camera framing and
  emotional weight depending on which locations Cael visited.
- **Thornmere Council at Ashgrove** — `party_has(torren)` changes
  Elder Savanh's demeanor (Torren is from Thornmere; his presence
  shifts the political dynamic).
- **Bellhaven arrival** — `party_has(sable)` triggers recognition
  lines from locals (Bellhaven is Sable's hometown).
- **Campfire scene** — Requires all four companions spoken to.
  Dialogue varies based on who Sable found first (`reunion_order_1`).
- **Cael's Last Night** (playable) — Player controls Cael, visits up
  to 3 of 4 locations. Each visit sets a binary flag affecting the
  betrayal cutscene.
- **Final confrontation** (`convergence_reached`) — Party composition
  affects Cael's dialogue. Lira's presence triggers the release
  scene; her absence changes the emotional climax.
- **Key dungeon entrances** — Character-specific reactions (e.g.,
  Lira at Caldera Forge Depths, Torren at Frostcap Caverns).
- **Vaelith encounters** — Party composition determines which
  characters Vaelith addresses and what unsettling observations they
  make.
- **Maren's briefing** (`party_reassembled`) — Full party assembled.
  Dialogue adjusts for reunion order and relationship flags.

#### Tier 2 — NPC Reactions (~2-3 per town, ~100-150 extra lines)

Town NPCs occasionally notice who is in the party. Sprinkled
lightly — not every NPC, not every party member. Enough to make the
world feel aware of the party without ballooning the script.

**Worked example:**

```
NPC: Thornmere Villager
  [party_has(torren)]  -> "Haven't seen a Thornmere boy in the capital in years."
  [party_has(lira)]    -> "Is that a Forgewright's hammer? Compact-made, isn't it?"
  [default]            -> "Roads aren't safe with all these ley surges."
```

If both Torren and Lira are in the party, the Torren line wins
(first-match-wins). The Lira line only fires if Torren is absent.
This is intentional — the author placed the more location-relevant
reaction higher.

**Distribution guidelines:**

- ~2-3 party-aware NPC reactions per town
- Prioritize reactions that reinforce character identity (Torren
  recognized in Thornmere territory, Sable recognized in Bellhaven,
  Lira's Forgewright craft noticed in Carradan towns)
- Each reaction is a single replacement line, not an additional
  exchange
- Total Tier 2 estimate: ~100-150 additional script lines

**Estimated script impact:** Tier 2 adds ~100-150 lines on top of
whatever Tier 1 scene variations require. Total script target remains
5,000-8,000 lines per Gap 3.7 analysis.

> **Flag note:** Flag names in examples that already exist in
> [events.md](events.md) use their canonical names there. The spec
> originally used shorthand names (`cael_betrayal`,
> `pallor_convergence`, `act2_started`) which have been corrected
> here to their canonical forms: `cael_betrayal_complete` (flag 19),
> `convergence_reached` (flag 35), `pendulum_to_capital` (flag 6).
> Three flags are **scene-local** and do not yet exist in events.md —
> they are defined here and slated for addition during Gap 3.7 script
> work: `savanh_audience_active`, `act2_thornmere_council`,
> `cael_betrayal_cutscene`.

---

## 4. Dialogue Data Format

Defines the structure of dialogue entries. This is the design-level
format — the engine implementation may serialize this as JSON, YAML, or
a custom format, but the information per entry is fixed.

### 4.1 Entry Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `id` | Yes | string | Unique identifier, e.g., `aldis_act2_early` |
| `speaker` | Yes | string | Character name shown in name tag. Empty string `""` hides the name tag entirely (used for narration). |
| `lines` | Yes | string[] | Array of text boxes (each 1-3 lines of text). Multi-page dialogue = multiple entries in the array. |
| `condition` | No | expression | Flag expression for priority stack. Supports binary flags, numeric comparisons, string comparisons, `party_has()` checks, and AND combinations (Section 3.3). Omit for default/fallback entries. |
| `animations` | No | animation[] | Sprite animation triggers fired between dialogue boxes. Each trigger specifies `who`, `anim`, and `when` (see Animation Trigger Fields). |
| `choice` | No | choice[] | Choice prompt displayed after the final line. Array of options, each with a label and consequence (see Choice Option Fields). |
| `sfx` | No | sfx_trigger[] | Sound effect triggers tied to specific lines. Each trigger specifies `line` and `id` (see SFX Trigger Fields). |

### 4.2 Animation Trigger Fields

| Field | Type | Description |
|-------|------|-------------|
| `who` | string | Character sprite ID (e.g., `edren`, `aldis`, `cael`) |
| `anim` | string | Animation ID from the catalog in Section 2.1 (e.g., `shake`, `jump`, `cry`) |
| `when` | string | Timing: `before_line_N` or `after_line_N` (zero-indexed into the `lines` array) |

### 4.3 Choice Option Fields

| Field | Type | Description |
|-------|------|-------------|
| `label` | string | Text shown in the choice prompt |
| `flag_set` | string | Binary flag to set when this option is chosen (optional; omit if not needed) |
| `score_name` | string | Score variable to increment (optional; must be paired with `score_delta`) |
| `score_delta` | number | Points to add to `score_name` (optional; must be paired with `score_name`) |

Each option must have at least one consequence (`flag_set` or
`score_name`/`score_delta`). An option may have both.

### 4.4 SFX Trigger Fields

| Field | Type | Description |
|-------|------|-------------|
| `line` | number | Zero-indexed line number into the `lines` array. The sound plays when this line begins rendering. |
| `id` | string | Sound effect asset ID (e.g., `door_breach`, `thunder_rumble`) |

### 4.5 Worked Examples

#### Example 1 — Simple NPC (one line, no conditions)

```
id: thornmere_villager_01_default
speaker: Villager
lines:
  - "Roads aren't safe with all these ley surges."
```

A single line with no condition acts as the default/fallback entry in
a priority stack. No animations, choices, or sound effects.

#### Example 2 — Flag-Gated with Animation (Aldis post-betrayal)

```
id: aldis_post_betrayal
speaker: Aldis
condition: cael_betrayal_complete
lines:
  - "I catalogued his notes for months."
  - "Every formula, every late-night revision..."
  - "I should have seen it."
animations:
  - who: aldis, anim: head_down, when: after_line_2
```

The entry only fires when `cael_betrayal_complete` is set. Aldis drops
his head after the final line lands — the animation punctuates the
guilt, not every line.

#### Example 3 — Party-Aware (Elder Savanh + Torren)

```
id: thornmere_elder_council_torren
speaker: Elder Savanh
condition: act2_thornmere_council AND party_has(torren)
lines:
  - "Torren? Son of Aldric?"
  - "...You've your father's jaw. Speak, then."
animations:
  - who: savanh, anim: bubble_exclaim, when: before_line_0
  - who: torren, anim: step_back, when: after_line_0
```

The AND condition requires both the council scene flag and Torren in
the active party. Note: `act2_thornmere_council` is a scene-local flag
pending addition to events.md during Gap 3.7. Two characters animate:
Savanh reacts with surprise before speaking, and Torren recoils after
being recognized.

#### Example 4 — Narration (no speaker, hidden name tag)

```
id: act1_opening_narration
speaker: ""
lines:
  - "The ley lines had sustained the world for a thousand years."
  - "No one asked what would happen when they began to fail."
```

When `speaker` is an empty string, the name tag is hidden entirely.
The dialogue box displays text only — used for scene-setting narration
and environmental text.

#### Example 5 — Choice with Score Consequence (Savanh audience)

```
id: savanh_audience_q1
speaker: Savanh
condition: savanh_audience_active
lines:
  - "The ley storms threaten our borders. What would you have us do?"
choice:
  - label: "Reinforce the ward stones together."
    score_name: council_savanh_approval
    score_delta: 2
  - label: "Your warriors should hold the perimeter."
    score_name: council_savanh_approval
    score_delta: 1
  - label: "We'll handle it. Stay out of our way."
    score_name: council_savanh_approval
    score_delta: 0
```

This is one question in the Savanh audience. The full scoring system
(0-3, including the Grandmother Seyth bonus dialogue path) is defined
in events.md. Note: `savanh_audience_active` (*) is a scene-local
flag for the Savanh audience sequence, pending addition to events.md
during Gap 3.7 script work.

#### Example 6 — Reunion Order String Comparison (Maren)

```
id: maren_reunion_edren_first
speaker: Maren
condition: reunion_order_1 == edren
lines:
  - "Edren told me you'd come."
  - "He's been keeping watch from the ridge since dawn."
animations:
  - who: maren, anim: nod, when: before_line_0
```

String comparison against `reunion_order_1` fires this entry only if
Edren was the first companion reunited. Other reunion orders would
have separate entries at the same priority level, each with their own
condition.

#### Example 7 — Sound Effect Trigger (siege door breach)

```
id: siege_door_breach
speaker: ""
lines:
  - "The great doors buckle inward with a sound like thunder."
sfx:
  - line: 0, id: door_breach
```

The `door_breach` sound effect plays as line 0 begins rendering. No
speaker (narration) — the sound effect and text work together to sell
the moment without a character attribution.

#### Example 8 — Multiple Characters Animating (betrayal scene)

```
id: cael_betrayal_reveal
speaker: Cael
condition: cael_betrayal_cutscene
lines:
  - "I'm sorry, Edren."
  - "This was always how it had to end."
animations:
  - who: edren, anim: shake, when: after_line_0
  - who: maren, anim: step_back, when: after_line_0
  - who: lira, anim: bubble_exclaim, when: after_line_0
  - who: cael, anim: turn_away, when: after_line_1
```

Three party members react simultaneously after Cael's first line
(Edren shakes, Maren recoils, Lira is shocked). The engine plays all
three `after_line_0` animations at the same time. Then Cael turns
away after delivering the second line — his signature `turn_away`
animation closing the moment. Note: `cael_betrayal_cutscene` is a
scene-local flag pending addition to events.md during Gap 3.7.

### 4.6 File Organization

- **Location NPC files:** One file per location (e.g.,
  `valdris-npcs`, `thornmere-npcs`). Contains all NPC dialogue
  entries for that location, with each NPC's priority stack as an
  ordered block.
- **Scene files:** One file per major story scene (e.g.,
  `scene-betrayal`, `scene-council`). Contains cutscene dialogue with
  animations, choices, and sound effects.
- **Priority stack order = entry order.** Within each NPC's block,
  entries are evaluated top-to-bottom. Authors control priority by
  reordering entries — no separate priority field is needed.
