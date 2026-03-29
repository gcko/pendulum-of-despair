# Pendulum of Despair — Complete Script

> The full dialogue script for Pendulum of Despair. Written as a
> readable screenplay with embedded implementation metadata. Each
> scene includes animation cues, branching conditions, and
> cross-references to canonical design docs.
>
> **Core philosophy: "Write a screenplay, not a database."** The
> script is literature first, implementation source second. FF6
> brevity, CT party awareness, sprite animations for emotion.
>
> **Design spec:**
> [2026-03-29-dialogue-script-design.md](../../superpowers/specs/2026-03-29-dialogue-script-design.md)
>
> **Related docs:** [outline.md](../outline.md) |
> [events.md](../events.md) | [characters.md](../characters.md) |
> [npcs.md](../npcs.md) | [dialogue-system.md](../dialogue-system.md) |
> [ui-design.md](../ui-design.md) | [locations.md](../locations.md) |
> [dynamic-world.md](../dynamic-world.md)

---

## File Index

| File | Act | Layer | Scenes | Lines | Status |
|------|-----|-------|--------|-------|--------|
| [act-i.md](act-i.md) | Act I | 1 | 7 | 929 | **Complete** |
| [act-ii-part-1.md](act-ii-part-1.md) | Act II (diplomacy) | 1 | 8 | 668 | **Complete** |
| [act-ii-part-2.md](act-ii-part-2.md) | Act II (betrayal) | 1 | 4 | 520 | **Complete** |
| [interlude.md](interlude.md) | Interlude | 1 | 8 | 865 | **Complete** |
| [act-iii.md](act-iii.md) | Act III | 1 | 9 | 732 | **Complete** |
| [act-iv-epilogue.md](act-iv-epilogue.md) | Act IV + Epilogue | 1 | 8 | 651 | **Complete** |
| npc-ambient.md | All | 2 | — | — | Planned |
| battle-dialogue.md | All | 3 | — | — | Planned |

**Layers:**
- **Layer 1 (Narrative Spine):** Story cutscenes, party dialogue, boss
  encounters, trial scenes. A complete, playable narrative.
- **Layer 2 (NPC Ambient):** Town NPC dialogue with flag variations,
  shop/service lines, quest-giver trees, examine text.
- **Layer 3 (Battle & System):** Boss barks, party callouts, tutorials,
  system messages.

---

## Format Specification

### Scene Headers

Every scene opens with a Markdown heading and HTML comment metadata:

```markdown
### Scene Title
<!-- Scene: scene_id | Tier: 1/2/3/4 | Trigger: flag_name -->
<!-- Location: Location Name | Party: who is present -->
<!-- Variants: flag-dependent variations -->
<!-- Cross-ref: relevant_doc.md § Section Name -->
```

**Tier values:** `1` = full cutscene, `2` = walk-and-talk,
`3` = playable, `4` = micro-cutscene. Composite tiers: `1+2` =
cutscene with walk-and-talk elements; `1+3` = cutscene with
playable section; `2+3` = walk-and-talk with playable section;
`1 → 3` = transitions from cutscene to playable during scene.

### Dialogue Lines

```markdown
*(Stage direction. Character enters from east.)*

**CHARACTER** : Dialogue line. Max 3 rendered lines per text box
per ui-design.md § 12. Two to three sentences per box.

*(Character [animation_id]. Another [animation_id].)*

**CHARACTER** : Next text box.
```

- Speaker names in **bold** followed by ` : ` (space-colon-space)
- Stage directions in *italics* enclosed in parentheses
- One `**CHARACTER** :` block = one text box
- Max 3 rendered lines per box, 2--3 sentences

### Animation Notation

Bracket notation `[animation_id]` in stage directions, mapping to
[dialogue-system.md](../dialogue-system.md) § 2:

| ID | Use | ID | Use |
|----|-----|----|-----|
| `jump` | Surprise, excitement | `shake` | Anger, frustration |
| `turn_away` | Shame, rejection | `head_down` | Sadness, defeat |
| `bubble_exclaim` | Shock, realization | `bubble_ellipsis` | Hesitation, tension |
| `bubble_question` | Confusion | `sweat_drop` | Nervousness |
| `cry` | Grief (loops) | `red_tint` | Embarrassment, rage |
| `arms_up` | Celebration, rallying | `collapse` | Overwhelm |
| `nod` | Agreement, determination | `step_back` | Fear, recoil |
| `clear` | Reset to idle | | |

**Character preferences:**
- **Edren:** `shake`, `nod` — restrained, military
- **Cael:** `turn_away` — signature (shame, conflict)
- **Maren:** `bubble_ellipsis`, `head_down` — processing, overwhelm
- **Lira:** `bubble_exclaim`, `arms_up` — expressive
- **Torren:** `step_back`, `nod` — stoic, measured
- **Sable:** `sweat_drop`, `red_tint` rare — humor, rare anger

### Branching Dialogue

```markdown
(If `flag_name` set.)
*(Variant stage direction.)*
**CHARACTER** : Variant line.

(If `party_has(torren)`.)
**TORREN** : Party-aware reaction.
```

### Choice Nodes

```markdown
**CHARACTER** : Question prompting choice.

> **Choice: "Option A"** → `score_name` +N
> **Choice: "Option B"** → `score_name` +N

(If player chose "Option A".)
**CHARACTER** : Response A.
```

### Sound Effects

```markdown
*(The door buckles. [SFX: door_breach])*
```

---

## Voice Quick Reference

| Character | Voice | Signature |
|-----------|-------|-----------|
| **Edren** | Direct, duty-focused, formal | Short sentences. Leads by example. |
| **Cael** (pre-betrayal) | Warm, intellectual, self-deprecating | Genuine care, scholarly distance. |
| **Cael** (corrupted) | Cold, certain, grieving underneath | Same words, stripped of warmth. |
| **Lira** | Technical, pragmatic, sharp | Guilt-driven. Craft metaphors. |
| **Torren** | Measured, plainspoken, patient | Few words, each weighted. |
| **Sable** | Quick-witted, sarcastic, young | Humor as armor. Most human. |
| **Maren** | Careful, measured, guarded | Hints, not explains. Scholarly. |
| **Vaelith** | Warm, witty, knowing | "Likes people the way an entomologist likes butterflies." |

Full character details: [characters.md](../characters.md)
Full NPC details: [npcs.md](../npcs.md)

---

## Flag Quick Reference

Flags most frequently used in dialogue branching. Full list:
[events.md](../events.md).

| # | Flag | Act | Dialogue Use |
|---|------|-----|-------------|
| 1 | `pendulum_discovered` | I | NPC reactions to artifact |
| 2 | `vaelith_ember_vein` | I | Grey stranger gossip |
| 4 | `torren_joined` | I | Wilds NPC recognition |
| 5 | `maren_warning` | I | Pendulum danger awareness |
| 6 | `pendulum_to_capital` | I→II | Act transition, NPC updates |
| 19 | `cael_betrayal_complete` | II | Massive NPC dialogue shift |
| 20 | `interlude_begins` | Int. | World state collapse text |
| 21 | `ley_line_rupture` | Int. | Environmental change text |
| 27 | `party_reassembled` | Int.→III | Full party dialogue |
| 29--33 | `trial_*_complete` | III | Post-trial character growth |
| 34 | `vaelith_defeated` | III | Pre-final approach |
| 37 | `cael_sacrifice` | IV | Epilogue state |
| 38 | `epilogue_complete` | Epi. | Post-game dialogue |
| 40--42 | `council_*_approval` | II | Tribal leader approval scores |
| 43 | `council_result` | II | Aggregated tribal support (0--3) |
| 44--47 | `cael_last_night_*` | II | Betrayal scene framing |
| 48--51 | `reunion_order_*` | Int. | Reunion dialogue variants |
| 52 | `campfire_complete` | III | Optional group moment |
| 58 | `postgame_greeting_seen` | Post | Sable's one-time greeting |

---

## Cross-Reference Guide

| Script File | Primary Sources |
|-------------|----------------|
| act-i.md | [outline.md](../outline.md) Act I, [events.md](../events.md) flags 1--6/39, [locations.md](../locations.md) § Aelhart/Ironmouth/Roothollow, [dungeons-world.md](../dungeons-world.md) § Ember Vein |
| act-ii-part-1.md | [outline.md](../outline.md) Act II early, [events.md](../events.md) flags 8--14/40--43/54, [locations.md](../locations.md) § Duskfen/Canopy Reach/Ashgrove, [sidequests.md](../sidequests.md) |
| act-ii-part-2.md | [outline.md](../outline.md) Act II late, [events.md](../events.md) flags 7/15--19/44--47, [locations.md](../locations.md) § Valdris Crown |
| interlude.md | [outline.md](../outline.md) Interlude, [events.md](../events.md) flags 20--27/48--51/55--56, [locations.md](../locations.md) § all reunion locations |
| act-iii.md | [outline.md](../outline.md) Act III, [events.md](../events.md) flags 28--35/52--53, [dungeons-world.md](../dungeons-world.md) § Pallor Wastes |
| act-iv-epilogue.md | [outline.md](../outline.md) Act IV + Epilogue, [events.md](../events.md) flags 36--38, [bestiary/bosses.md](../bestiary/bosses.md) § Cael |
| npc-ambient.md | [npcs.md](../npcs.md), [locations.md](../locations.md), [events.md](../events.md) all flags |
| battle-dialogue.md | [bestiary/bosses.md](../bestiary/bosses.md), [abilities.md](../abilities.md), [combat-formulas.md](../combat-formulas.md) |

---

## Authoring Guidelines

1. **FF6 brevity.** 2--3 sentences per text box. No exposition dumps.
   Spread information across NPCs and scenes.
2. **Show, don't tell.** Use stage directions and animations to convey
   emotion. Dialogue carries subtext, not thesis statements.
3. **CT party awareness.** Key scenes (Tier 1) include party-dependent
   reaction lines. NPC reactions (Tier 2) are single replacement lines.
4. **Judicious animation.** A typical 10-box scene has 2--3 animations.
   Overuse cheapens the effect.
5. **Consistent voice.** Every line should sound like the character
   speaking it. When in doubt, check
   [characters.md](../characters.md) and [npcs.md](../npcs.md).
6. **Flag-first branching.** All conditional dialogue references
   [events.md](../events.md) flags by name. No invented flags.
7. **Cross-reference everything.** Names must match canonical docs.
   Boss names per [bestiary/bosses.md](../bestiary/bosses.md). Item
   names per [items.md](../items.md). Location names per
   [locations.md](../locations.md).
