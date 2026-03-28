# Post-Game & New Game+

> Formalizes the post-game mechanical layer: the No NG+ decision, boss
> rush mode, and completion tracking. The post-game *content* —
> Dreamer's Fault dungeon, The Lingering super boss, post-game
> progression, epilogue world state — is already fully designed across
> [dungeons-world.md](dungeons-world.md),
> [sidequests.md](sidequests.md), [progression.md](progression.md),
> and [dynamic-world.md](dynamic-world.md). This document owns the
> *rules* — how the post-game is structured, accessed, and tracked.
>
> **Core philosophy: "The game ends. The world heals. The player
> explores what's left."** No NG+. The post-game is optional content
> for players who want more — not a second playthrough. FF6's model:
> the game is complete at the ending; everything after is a bonus.
>
> **Related docs:** [dungeons-world.md](dungeons-world.md) |
> [sidequests.md](sidequests.md) | [progression.md](progression.md) |
> [dynamic-world.md](dynamic-world.md) | [events.md](events.md) |
> [combat-formulas.md](combat-formulas.md)
>
> **Cross-links:** [bestiary/bosses.md](bestiary/bosses.md) |
> [items.md](items.md) | [equipment.md](equipment.md)

---

## 1. No New Game+

PoD does not have a New Game+ mode. When the player completes the
epilogue (`epilogue_complete` flag per [events.md](events.md)), the
game saves a post-game state and returns to The Pendulum tavern. The
player can continue exploring post-game content from this save.
Starting a new game always starts fresh — no carryover of levels,
items, bestiary, or flags.

**Rationale:**
- **Narrative integrity.** Cael's sacrifice is the emotional core.
  Replaying the story with max-level characters trivializes both the
  gameplay tension and the narrative weight.
- **Substantial post-game.** The existing post-game content is
  ~25--45+ hours for a completionist: Dreamer's Fault (20 floors),
  The Lingering (super boss), boss rush (3 tiers), epilogue NPC
  conversations, and post-game leveling (71--150).
- **FF6 model.** FF6 had no NG+ and is the primary SNES reference.
  Chrono Trigger's NG+ served a different design (multiple endings
  requiring replays). PoD has one ending.
- **Thematic coherence.** The Pendulum's theme is about breaking
  cycles of suffering. An NG+ would undermine this by literally
  replaying the cycle.

---

## 2. Boss Rush Mode

Accessible from The Pendulum tavern after `epilogue_complete`. Sable
introduces it: "Some old friends left marks on us. Want to revisit
them?"

### Three-Tier Gauntlet

| Tier | Name | Bosses | Source Acts | Estimated Time |
|------|------|--------|------------|----------------|
| 1 | Rising Shadows | Act I bosses | Act I--II | ~20 min |
| 2 | The Unraveling | Act II + Interlude bosses | Act II--Interlude | ~30 min |
| 3 | The Grey March | Act III bosses (including Cael phases 1--3) | Act III | ~40 min |

Boss roster per tier is drawn from
[bestiary/bosses.md](bestiary/bosses.md). Exact boss lists are
implementation-defined based on the boss compendium, but should
include all mandatory story bosses in story order. Optional bosses
(Dreamer's Fault echo bosses, The Lingering) are excluded.

### Rules

- Bosses fought in story order within each tier
- **Full HP/MP/AC restore between fights** — the challenge is each
  individual fight at post-game stats, not attrition
- **Original boss stats** — no scaling or boosting. Post-game
  characters are overpowered, which is the point. The victory lap
  is the fun.
- Party composition chosen at start of each tier, locked for the
  duration
- **Standardized consumable set per tier** — no items from player
  inventory:
  - Tier 1: 10 Potions, 5 Ethers, 2 Phoenix Feathers
  - Tier 2: 10 Hi-Potions, 8 Ethers, 3 Phoenix Feathers, 2 Remedies
  - Tier 3: 5 Megalixirs, 10 Hi-Potions, 10 Ethers, 5 Phoenix
    Feathers, 3 Remedies
- Flee disabled (as in normal boss fights)
- Exiting mid-tier forfeits progress — must restart the tier

### Rewards

| Tier | Reward | Stats | Flavor Text |
|------|--------|-------|-------------|
| 1 | Warrior's Memento (accessory) | ATK +10 | "Remember the first fight" |
| 2 | Survivor's Memento (accessory) | DEF +10, MDEF +10 | "Remember the cost" |
| 3 | Pendulum's Memento (accessory) | All stats +5 | "Remember everything" |

Memento accessories are meaningful but not best-in-slot — Dreamer's
Crest (+30 all stats from Dreamer's Fault floor 20) and The Pallor's
Last (from The Lingering per [sidequests.md](sidequests.md)) are both
superior. The value is the inscription flavor text, not the stats.
One-time rewards — clearing a tier again gives gold instead.
