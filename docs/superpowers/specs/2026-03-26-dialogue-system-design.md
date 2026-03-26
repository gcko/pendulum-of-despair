# Dialogue System Mechanics — Design Spec

**Gap:** 3.3 Dialogue System Mechanics
**Status:** Approved design, ready for implementation
**Date:** 2026-03-26
**Depends On:** 2.3 UI & Menu Design (COMPLETE)
**Unblocks:** 3.7 Full Dialogue Tree & Story Script

---

## Overview

Formalizes the dialogue system mechanics for Pendulum of Despair. The visual
presentation (dialogue box layout, text speed, choice prompts) is already
specified in `docs/story/ui-design.md`. This spec covers the remaining
mechanical layer: sprite emotion animations, NPC dialogue state resolution,
party-aware dialogue, and the dialogue data format.

**Core philosophy:** SNES FF6 pure. No portraits in dialogue — ever. Emotion
is conveyed through judicious writing and character sprite animations
(jumping, shaking, turning away, crying, etc.). The world feels alive because
sprites act out emotions on screen while clean text boxes deliver the words.

---

## Section 1: Dialogue Box & Text Rendering (Confirmed)

Already fully specified in `docs/story/ui-design.md` Section 12. No changes
needed. Summary for cross-reference:

- Full screen width, bottom-anchored, 3 visible lines max
- Dark navy background (#000040), 2px blue-grey border (#5566aa)
- Speaker name: small inset tag at top-left corner
- No portraits in dialogue
- Typewriter effect: Slow (30 cps), Normal (60 cps), Fast (120 cps), Instant
- Confirm instantly completes current box; bouncing down-arrow when complete
- Multi-page: advance arrow pauses, confirm continues, no scrollback
- Choice prompts: 2–4 options, vertical, hand cursor, yellow selected / pale blue unselected
- Cancel selects bottom option (typically "No")
- One exception: Cael's final Act IV dialogue — border flickers grey for 2 frames, then returns to canonical blue-grey
- The 32x32 menu portraits use a single neutral expression per character. Emotion variants (deferred by ui-design.md Section 1.1) are not needed — the sprite emotion system (Section 2) handles all in-scene emotion.

---

## Section 2: Sprite Emotion System

The primary tool for conveying emotion during dialogue. These are character
sprite animations that fire between dialogue boxes, replacing the portrait
emotion system used in later FF6 ports.

### Animation Catalog (14 Animations)

| ID | Animation | Visual Description | Duration | Use Case |
|----|-----------|-------------------|----------|----------|
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
| `collapse` | Sprite drops to ground | Falls down, holds until cleared | 0.6s | Overwhelm, comedic shock |
| `nod` | Small downward bob | Sprite dips 2px and returns, 1–2x | 0.4s | Agreement, determination |
| `step_back` | Sprite retreats 8–16px | Quick backward move, holds | 0.3s | Fear, recoil, intimidation |

### Timing Rules

- Animations trigger **between** dialogue boxes, not during text rendering
- The dialogue engine pauses text advance until the animation completes
- Multiple characters can animate simultaneously (e.g., party reacts to betrayal)
- Looping animations (`cry`) persist across dialogue boxes until explicitly cleared
- Animations are referenced by ID in the dialogue data format (Section 4)

### Usage Guidelines

Animations are used **judiciously** — not every line gets one. The writing
carries baseline emotion; animations punctuate key moments. A typical scene
with 10 dialogue boxes might have 2–3 sprite animations. Overuse cheapens
the effect.

**Good usage:** Edren shakes with anger after Cael's betrayal reveal, then
the next 4 lines of shocked dialogue play with no animation — the shake
already set the tone.

**Bad usage:** Every character animates on every line, turning a tense scene
into a puppet show.

---

## Section 3: NPC Interaction Model & Party-Aware Dialogue

### NPC Interaction Rules

- **Single interaction per confirm press** — no dialogue trees
- **Re-talking repeats current dialogue** (may change based on event flags)
- Current dialogue determined by **priority stack** — ordered list of
  flag-gated entries, first true match wins
- NPCs never have branching conversation flows — just linear exchanges
  with occasional choice prompts

### Priority Stack Resolution

Each NPC has an ordered list of dialogue entries. The engine walks
top-to-bottom and serves the first entry whose condition evaluates true.
Authors control priority through ordering — later story states go higher
in the stack.

```
NPC: Scholar Aldis
  [convergence_reached]          -> "The equations... they were wrong all along."
  [cael_betrayal_complete]       -> "I catalogued his notes for months. I should have seen it."
  [cael_nightmares_begin]        -> "Have you noticed Cael seems... distracted lately?"
  [pendulum_to_capital]          -> "Cael's temporal research is remarkable. Truly remarkable."
  [default]                      -> "Welcome to the Valdris archives."
```

### Flag Types in Conditions

| Type | Syntax | Example |
|------|--------|---------|
| Binary flag | `flag_name` | `cael_betrayal_complete` |
| Numeric comparison | `score_name >= N` | `council_savanh_approval >= 2` |
| String comparison | `flag_name == value` | `reunion_order_1 == edren` |
| Party presence | `party_has(member)` | `party_has(torren)` |

String comparison supports the reunion order system (`reunion_order_1`
through `reunion_order_4` store character IDs) and any future flags that
store a value rather than a boolean.

Conditions can be combined with AND logic (all must be true). OR logic is
handled by separate entries in the priority stack.

### Choice Consequences (Two Patterns Only)

1. **Binary flag set:** Choice sets a flag gating future dialogue/events.
   Example: visiting Cael's vault sets `cael_last_night_vault`.

2. **Numeric score increment:** Choice adds points to a named score.
   Example: diplomatic answer adds +2 to `council_savanh_approval`.

No hidden tracking. No relationship meters. No timed choices. Every
consequence is one of these two patterns.

### Party-Aware Dialogue

**Tier 1 — Key Story Scenes (~15–20 scenes):**

Party composition changes specific lines during major story beats.
Implemented as `party_has()` checks in the priority stack. Scenes that
get party-aware treatment:

- Reunion scenes (reunion order changes who greets whom)
- Cael's betrayal (last-night visit flags change framing)
- Thornmere Council (Torren present changes NPC demeanor)
- Bellhaven arrival (Sable's hometown — locals recognize her)
- Campfire scene (requires all 4 companions spoken to)
- Final confrontation (party composition affects Cael's dialogue)
- Key dungeon entrances (character-specific reactions)

**Tier 2 — NPC Reactions (~2–3 per town, ~100–150 extra lines total):**

Town NPCs occasionally notice who's in the party. Sprinkled lightly —
not every NPC, not every party member. Enough to make the world feel
aware of the party without ballooning the script.

```
NPC: Valdris Merchant
  [party_has(torren)]  -> "A Thornmere tribesman? Haven't seen one in the capital in years."
  [party_has(lira)]    -> "Is that a Forgewright's hammer? Compact-made, isn't it?"
  [default]            -> "Roads aren't safe with all these ley surges."
```

**Estimated script impact:** ~100–150 additional lines for Tier 2, on top of
whatever Tier 1 variations require. Total script target remains 5,000–8,000
lines per Gap 3.7 analysis.

---

## Section 4: Dialogue Data Format

Defines the structure of dialogue entries. This is the design-level format —
the engine implementation may serialize this as JSON, YAML, or a custom
format, but the information per entry is fixed.

### Entry Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `id` | Yes | string | Unique identifier, e.g., `aldis_act2_early` |
| `speaker` | Yes | string | Character name shown in name tag. Empty string for narration. |
| `lines` | Yes | string[] | Array of text boxes (each 1–3 lines of text). Multi-page = multiple entries. |
| `condition` | No | expression | Flag expression for priority stack. Supports binary flags, numeric comparisons, string comparisons, `party_has()` checks, and AND combinations. Omit for default/fallback. |
| `animations` | No | animation[] | Sprite animation triggers. Each: `who`, `anim`, `when`. |
| `choice` | No | choice[] | Choice prompt: array of options with label + consequence. |
| `sfx` | No | sfx_trigger[] | Sound effect triggers. Each: `line` (zero-indexed), `id` (sound ID). |

### Animation Trigger Fields

| Field | Type | Description |
|-------|------|-------------|
| `who` | string | Character sprite ID (e.g., `edren`, `aldis`, `cael`) |
| `anim` | string | Animation ID from catalog (e.g., `shake`, `jump`, `cry`) |
| `when` | string | Timing: `before_line_N` or `after_line_N` (zero-indexed) |

### Choice Option Fields

| Field | Type | Description |
|-------|------|-------------|
| `label` | string | Text shown in choice prompt |
| `flag_set` | string | Binary flag to set (optional) |
| `score_name` | string | Score variable to increment (optional, paired with `score_delta`) |
| `score_delta` | number | Points to add to `score_name` (optional) |

### Examples

**Simple NPC:**
```
id: thornmere_villager_01_default
speaker: Villager
lines:
  - "Roads aren't safe with all these ley surges."
```

**Flag-Gated with Animation:**
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

**Party-Aware:**
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

**Narration (no speaker):**
```
id: act1_opening_narration
speaker: ""
lines:
  - "The ley lines had sustained the world for a thousand years."
  - "No one asked what would happen when they began to fail."
```

When `speaker` is empty, the name tag is hidden entirely. The dialogue box
displays text only — used for scene-setting narration and environmental text.

**Choice with Score Consequence:**
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

Note: This is one question in the Savanh audience. The full scoring system
(0–3, including the Grandmother Seyth bonus dialogue path) is defined in
events.md.

**Reunion Order (String Comparison):**
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

**Sound Effect Trigger:**
```
id: siege_door_breach
speaker: ""
lines:
  - "The great doors buckle inward with a sound like thunder."
sfx:
  - line: 0, id: door_breach
```

**Multiple Characters Animating (Betrayal Scene):**
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

### File Organization

- **Location NPC files:** One per location (e.g., `valdris-npcs`, `thornmere-npcs`).
  Contains all NPCs for that location with priority stacks.
- **Scene files:** One per major story scene (e.g., `scene-betrayal`,
  `scene-council`). Contains cutscene dialogue with animations and choices.
- Priority stack order = entry order within each NPC's block.

---

## What This Unblocks

- **Gap 3.7 (Full Dialogue Tree & Story Script):** All mechanical questions
  are now answered. Script authors know the format, the emotion tools
  available, and the rules for party-aware and flag-gated dialogue.
- **Engine implementation:** The dialogue data format is defined well enough
  to build the parser and renderer.
- **Sprite work:** The 14-animation catalog gives artists a concrete list
  of emotion animations to create per character.

---

## What This Does NOT Cover

- **Full dialogue script content** — that's Gap 3.7
- **Dialogue engine code implementation** — that's game development work
- **Sprite art creation** — that's art pipeline work
- **Voice acting** — not in scope for SNES-era aesthetic
- **Localization infrastructure** — deferred; format is localization-friendly
  (all text in string fields) but no i18n tooling is specified
