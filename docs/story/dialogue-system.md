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

Dialogue choices produce exactly one of two consequence types:

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
- Every consequence is one of these two patterns. No exceptions.

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

> **Flag note:** All flag names in examples match their canonical
> names in [events.md](events.md). The spec originally used shorthand
> names (`cael_betrayal`, `pallor_convergence`, `act2_started`,
> `savanh_audience_active`) which have been corrected here to their
> canonical forms: `cael_betrayal_complete` (flag 19),
> `convergence_reached` (flag 35), `pendulum_to_capital` (flag 6).
> The `savanh_audience_active` flag (*) is defined here as a
> scene-local flag for the Savanh audience sequence and will be added
> to events.md during Gap 3.7 script work.
