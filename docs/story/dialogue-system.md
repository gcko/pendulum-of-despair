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
