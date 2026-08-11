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
- **Choice prompts:** 2–4 options, vertical layout, hand cursor. Yellow
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

### 2.1 Animation Catalog (14 Animations + 1 Control Command)

| ID | Animation | Visual Description | Duration | Use Case |
|----|-----------|--------------------|----------|----------|
| `jump` | 1–2 vertical hops | Sprite lifts 4–8px, lands | 0.4s | Surprise, excitement, realization |
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
| `collapse` | Sprite drops to ground | Falls down (0.6s), holds at fallen position until sequence end or `clear` | 0.6s | Overwhelm, comedic shock |
| `nod` | Small downward bob | Sprite dips 2px and returns, 1–2x | 0.4s | Agreement, determination |
| `step_back` | Sprite retreats 8–16px | Quick backward move, holds | 0.3s | Fear, recoil, intimidation |
| `clear` | Reset to idle | Control command: resets the character to idle pose, canceling any held or looping animation | — | End a `cry` loop or reset a held position early |

### 2.2 Timing Rules

- Animations trigger **between** dialogue boxes, not during text
  rendering.
- The dialogue engine pauses text advance until the animation completes.
- Multiple characters can animate simultaneously (e.g., the full party
  reacts to Cael's betrayal — Edren shakes, Maren steps back, Lira
  shows a `bubble_exclaim`, all at once).
- Looping animations (`cry`) persist across dialogue boxes until
  explicitly cleared via the special animation ID `clear` (e.g.,
  `anim: clear` on the character resets the character to idle).
- **Hold vs reset rule:** Non-looping animations that "hold" (`step_back`,
  `head_down`, `arms_up`, `collapse`) reset to the character's idle
  pose when the dialogue sequence ends (the full NPC interaction or
  cutscene, not between individual boxes). Subsequent animations on
  the same character during the same sequence play at the held
  position. Use `anim: clear` to reset a held animation early.
- Animations are referenced by ID in the dialogue data format
  (Section 4).

### 2.3 Usage Guidelines

Animations are used **judiciously** — not every line gets one. The
writing carries baseline emotion; animations punctuate key moments. A
typical scene with 10 dialogue boxes might have 2–3 sprite animations.
Overuse cheapens the effect.

**Good usage:** Edren shakes with anger after Cael's betrayal reveal,
then the next 4 lines of shocked dialogue play with no animation — the
shake already set the tone.

**Bad usage:** Every character animates on every line, turning a tense
scene into a puppet show.

**Character-specific notes:**

- **Edren** — favors `shake`, `nod`, restrained physicality. Rarely
  `cry` (only the Interlude reunion, when he confronts the full
  weight of Cael's fall).
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
  since the last interaction. The one exception is an NPC with several
  lines authored for the same state — several `[default]` entries, or
  several sharing one condition — which rotates through them, one per
  interaction. See "Multiple defaults" in Section 3.2.
- **Priority stack determines current dialogue.** Each NPC has an
  ordered list of flag-gated entries. The engine evaluates the
  *conditioned* entries top-to-bottom and serves the first whose
  condition is true (first-match-wins). Unconditioned entries are the
  fallback set and are only reached when no condition holds, wherever
  they sit in the file — see "Multiple defaults" in Section 3.2.
- **No branching conversation flows.** NPCs deliver linear exchanges
  with occasional choice prompts (2–4 options). Choices set flags or
  increment scores; they never open sub-menus or nested dialogue
  paths.

### 3.2 Priority Stack Resolution

Each NPC has an ordered list of dialogue entries. The engine walks the
conditioned entries top-to-bottom and serves the **first** whose
condition evaluates true. Authors control priority through entry
ordering — later story states go higher in the stack so they take
precedence. Ordering governs the conditioned entries only: an
unconditioned `[default]` never wins over a matched condition no matter
how high it sits, because defaults are the fallback set rather than
another rung on the ladder.

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
ordering. Moving a conditioned entry higher makes it win over the
conditioned entries below it.

**Multiple defaults — ambient rotation.** Most NPCs have one
`[default]` entry, but ambient townsfolk often carry several
unconditioned lines on different topics (Bren has three, Grandmother
Seyth five). These are not alternatives to each other: every one of
them is authored content the player is meant to see.

When no condition matches, the engine therefore does not pick a single
default. It collects **all** unconditioned entries in authored order
and serves the next one in that list on each interaction, wrapping
back to the first after the last:

```
NPC: Bren (baker, Valdris)
  [default]  -> "Used to sell out by noon..."           <- 1st confirm press
  [default]  -> "My father baked for the old king..."   <- 2nd
  [default]  -> "There's a family in the Lower Ward..." <- 3rd, then wraps
```

Rules for the rotation:

- **Conditions still win outright.** A matched condition is
  first-match-wins: the topmost true condition takes the stack, and a
  lower entry with a *different* condition does not get a turn even if
  it would also be true.
- **A shared condition rotates too.** Several entries may carry the
  *identical* condition string — the same authoring pattern as multiple
  defaults, applied to a story state. Bren has two lines on
  `cael_betrayal_complete` and two on `interlude_begins`. Every entry
  repeating the winning condition joins the rotation, so none of them
  is stranded. A story state with exactly one authored line resolves to
  that line, which repeats on re-talk as usual.
- **One line per interaction.** The rotation advances by one entry per
  interaction. An entry's own multiple text boxes still page within
  that single interaction, consuming several confirm presses but
  advancing the cursor once.
- **The cursor is session state, not save state.** It persists across
  map changes and battles within a play session, and resets to the
  first entry on a new game or on loading a save. Which line comes next
  within a single story state is not progression, so it is deliberately
  absent from save data.
- **Order is authored order.** Entries rotate in the order they appear
  in the NPC's dialogue file.

**Conditions in scene sequences.** A cutscene or scene file is played
in authored order rather than resolved as a priority stack, but its
entries carry the same `condition` field and the engine honours it the
same way: a false condition means that entry does not play. Two
authoring rules follow, and both are checkable by reading the file:

- **A branch is a block, not a line.** When a conditioned entry is
  answered or continued by the entries beneath it, every entry in that
  block must carry the same condition. An unconditioned reply below a
  gated line will play on its own when the gate is false, leaving a
  character answering something nobody said.
- **Mutually exclusive branches need a reachable fallback.** Write the
  else-half as its own condition (Section 3.3 has no NOT operator — use
  `flag == 0`), or leave the last branch unconditioned so exactly one
  always plays. A "default" branch gated on an invented flag name never
  fires.

### 3.3 Flag Types in Conditions

| Type | Syntax | Example | Notes |
|------|--------|---------|-------|
| Binary flag | `flag_name` | `cael_betrayal_complete` | True when the flag has been set |
| Numeric comparison | `score_name >= N` | `council_savanh_approval >= 2` | Supports `>=`, `<=`, `==`, `!=`, `>`, `<` |
| String comparison | `flag_name == value` | `reunion_order_1 == edren` | Used for reunion order and any value-storing flags |
| Party presence | `party_has(member)` | `party_has(torren)` | True when the named character is in the active party |
| Negation | `flag_name == 0` | `scene_7c_cordwyn == 0` | The "not yet" form. An unset flag reads as `0`, so this is true until the flag is set. There is no `NOT`/`!` operator — do not invent `<flag>_not_set` style names, which are just unset flags and are false forever |
| Choice pseudo-flag | `choice_N_selected` | `choice_2_selected` | Scene-local, set by the preceding choice in the same sequence; never an event flag. See Section 3.4 |

**Combination rules:**

- **AND:** Multiple conditions on a single entry must all be true.
  Written as: `condition: cael_betrayal_complete AND party_has(lira)`.
  (The `[...]` notation in priority stack examples is shorthand for the
  `condition:` field — brackets are not part of the expression syntax.)
- **OR:** Handled by separate entries in the priority stack. Each
  entry is its own condition — if you want "A or B triggers this
  line," create two entries with the same dialogue text at the same
  priority level.

**Reunion order flags:** `reunion_order_1` through `reunion_order_4`
(events.md flags 48–51) store character IDs (`edren`, `lira`,
`torren`, `maren`). String comparison against these flags enables
reunion-order-dependent dialogue.

**Score ranges:** `council_savanh_approval` (events.md flag 40) has
range 0–3. Dialogue choices alone earn 0–2; consulting Grandmother
Seyth before the council unlocks a bonus option that reaches 3.
Scores are clamped to their documented range — the engine enforces
`clamp(score, min, max)` after each increment. Score ranges are
defined in events.md alongside the flag definition.

**Starting values.** A score need not start at its minimum. events.md
may document a non-zero starting value — `council_caden_approval`
(flag 41) starts at 1, because Torren is always in the diplomatic party
and his rapport as a spirit-speaker is already banked before anyone
speaks. Dialogue choices add on top of that start, and a condition read
before the first choice sees the documented start, not 0.

**Derived tallies are not scores.** `council_result` (flag 43) is
computed from flags 40–42 once the council concludes and is *assigned*,
not incremented. It uses the same numeric comparison syntax in
conditions, but no choice may carry it as a `score_name`.

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
     (0–3) determines Savanh's support at the tribal council;
     consulting Grandmother Seyth beforehand is what unlocks the bonus
     option that reaches 3.

**Explicit design constraints:**

- No hidden tracking beyond what events.md documents. Scores like
  `council_savanh_approval` are hidden from the player in-game but
  fully documented for designers in events.md.
- No relationship meters. NPC attitudes change via binary flags and
  score thresholds, not continuous affinity values.
- No timed choices. The player has unlimited time to decide.
- Every consequence uses one or both of these two patterns. An option
  may set a flag AND increment a score. A `score_delta` of `0` is a
  valid intentional outcome (records the question was answered with a
  neutral response).

**Reacting to the choice itself.** A question is usually followed by one
reaction entry per option. Those entries are gated on
`choice_1_selected` … `choice_4_selected`, numbered from the top option
down. These are **not** event flags: they are scene-local, live only for
the remainder of the current sequence, and are never written to save
data. Answering a question replaces the previous answer's pseudo-flags:
exactly one of them becomes true and the rest false. Reaction entries
must therefore follow their question within the same sequence — the
pseudo-flags do not survive into a different scene or NPC conversation
— and a question whose reactions matter must itself be unconditioned,
since a question the engine skips leaves the *previous* question's
answer standing and its reactions would fire against that.

```
thornmere_council_005  [default]           -> Savanh's question, 3 options
thornmere_council_006  [choice_1_selected] -> reaction to the first option
thornmere_council_007  [choice_2_selected] -> reaction to the second
thornmere_council_008  [choice_3_selected] -> reaction to the third
```

Because an unanswered question leaves all four false, an entry gated this
way simply does not play if the player never reached the choice.

### 3.5 Party-Aware Dialogue

Party composition affects dialogue at two tiers, balancing narrative
richness against script volume.

#### Tier 1 — Key Story Scenes (~15–20 scenes)

Party composition changes specific lines during major story beats.
Implemented as `party_has()` checks in the priority stack. Scenes
that receive party-aware treatment:

- **Reunion scenes** (Interlude) — Reunion order (`reunion_order_1`
  through `reunion_order_4`) changes who greets whom and how. Finding
  Edren first vs. finding Lira first produces different emotional
  framing for each subsequent reunion.
- **Cael's betrayal** (`cael_betrayal_complete`) — The
  `cael_last_night_*` flags (44–47) change camera framing and
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

#### Tier 2 — NPC Reactions (~2–3 per town, ~100–150 extra lines)

Town NPCs occasionally notice who is in the party. Sprinkled
lightly — not every NPC, not every party member. Enough to make the
world feel aware of the party without ballooning the script.

**Worked example:**

```
NPC: Valdris Merchant
  [party_has(torren)]  -> "A Thornmere tribesman? Haven't seen one in the capital in years."
  [party_has(lira)]    -> "Is that a Forgewright's hammer? Compact-made, isn't it?"
  [default]            -> "Roads aren't safe with all these ley surges."
```

If both Torren and Lira are in the party, the Torren line wins
(first-match-wins). The Lira line only fires if Torren is absent.
This is intentional — the author placed the more location-relevant
reaction higher.

**Distribution guidelines:**

- ~2–3 party-aware NPC reactions per town
- Prioritize reactions that reinforce character identity (Torren
  recognized in Thornmere territory, Sable recognized in Bellhaven,
  Lira's Forgewright craft noticed in Carradan towns)
- Each reaction is a single replacement line, not an additional
  exchange
- Total Tier 2 estimate: ~100–150 additional script lines

**Estimated script impact:** Tier 2 adds ~100–150 lines on top of
whatever Tier 1 scene variations require. Total script target remains
5,000–8,000 lines per Gap 3.7 analysis.

> **Flag note:** Flag names in examples that already exist in
> [events.md](events.md) use their canonical names there. The spec
> originally used shorthand names (`cael_betrayal`,
> `pallor_convergence`, `act2_started`) which have been corrected
> here to their canonical forms: `cael_betrayal_complete` (flag 19),
> `convergence_reached` (flag 35), `pendulum_to_capital` (flag 6).
> Three flags are **scene-local** and do not yet exist in events.md —
> they are defined here and slated for addition during Gap 3.7 script
> work: `savanh_audience_active`, `act2_thornmere_council`,
> `cael_betrayal_cutscene`. Distinct from those are the four
> `choice_1_selected` … `choice_4_selected` **pseudo-flags** of Section
> 3.4: the engine synthesises them from the option the player just
> picked, they live only for the remainder of the sequence, and they
> will never appear in events.md.

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
| `lines` | Yes | string[] | Array of dialogue boxes (each 1–3 rendered lines of text). Multi-page dialogue = multiple entries in the array. Index N in this array is what `before_line_N`/`after_line_N` and `sfx.line` reference — "line" in those contexts means "dialogue box at index N," not a rendered text line within a box. |
| `condition` | No | expression | Flag expression, evaluated both for NPC priority-stack entries and for every entry of a scene or cutscene sequence — a sequence entry whose condition is false does not play. Supports binary flags, numeric comparisons, string comparisons, `party_has()` checks, `choice_N_selected` pseudo-flags, and AND combinations (Section 3.3). Omit for default/fallback entries. |
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
  - "Torren? Son of Haldric?"
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
(0–3, including the Grandmother Seyth bonus dialogue path) is defined
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
- **Priority stack order = entry order.** Within each NPC's block, the
  conditioned entries are evaluated top-to-bottom. Authors control
  priority by reordering them — no separate priority field is needed.
  Unconditioned entries are the fallback set and do not compete for
  position (Section 3.2).
