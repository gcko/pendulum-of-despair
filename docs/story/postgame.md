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

---

## 3. Completion Tracking

Four categories displayed at The Pendulum tavern. Accessible by
talking to Sable behind the bar: "Want to see how much of the world
you've seen?"

### Categories

| Category | What It Tracks | Denominator |
|----------|---------------|-------------|
| **Bestiary** | Unique enemies encountered (at least one battle) | 232 (per [bestiary/README.md](bestiary/README.md): 25 Act I + 33 Act II + 52 Interlude + 68 Act III + 24 Optional + 30 Bosses) |
| **Treasure** | Chests opened across all dungeons and overworld | Total chest count (implementation-defined per dungeon layouts) |
| **Quests** | Sidequests completed | Total sidequest count per [sidequests.md](sidequests.md) |
| **Items** | Unique items obtained at least once (consumables, equipment, key items, materials) | Total unique item count across [items.md](items.md) and [equipment.md](equipment.md) |

### Display

- Simple percentage per category with fraction: "Bestiary: 142/232
  (61%)"
- No pop-ups or notifications at 100%. The player checks when they
  want to.

### Sable's Comments

Sable has a comment based on overall completion:

- **<50%:** "Plenty more out there."
- **50--79%:** "You've seen a lot. But not everything."
- **80--99%:** "Almost there. You're more thorough than I expected."
- **100% (any single category):** "Huh. You actually found everything.
  I'm impressed."
- **100% (all four):** "...You really don't want to go home, do you?"
  (delivered with a quiet smile)

### No Rewards for Completion

Per SNES philosophy — the game doesn't give you a trophy for 100%.
The completionist's reward is knowing they did it, plus Sable's
acknowledgment. Dreamer's Crest, The Pallor's Last, and The World's
Memory are the post-game's tangible rewards. Completion tracking is
informational, not incentivized.

---

## 4. Post-Game Content Summary

Everything available after `epilogue_complete`, routed through The
Pendulum tavern:

| Content | Access Point | Source Doc | Estimated Hours |
|---------|-------------|-----------|-----------------|
| Dreamer's Fault (20 floors) | Tavern cellar | [dungeons-world.md](dungeons-world.md) | 3--5 hours |
| The Lingering (super boss) | Convergence meadow (requires Dreamer's Fault completion) | [sidequests.md](sidequests.md) | ~30 min |
| Boss Rush (3 tiers) | Tavern (Sable) | postgame.md (this doc) | ~90 min total |
| Completion Tracking | Tavern (Sable) | postgame.md (this doc) | Ongoing |
| Epilogue NPC conversations | Tavern + world | [dynamic-world.md](dynamic-world.md) | ~30 min |
| First Tree Seed scene | Convergence meadow | [dungeons-world.md](dungeons-world.md) (item), [dynamic-world.md](dynamic-world.md) (scene) | ~5 min |
| Post-game leveling (71--150) | Everywhere (Dreamer's Fault optimal) | [progression.md](progression.md) | 20--40+ hours |
| Cael's Echo crystal | Obtained at epilogue | [progression.md](progression.md) | Immediate |

**Total post-game: ~25--45+ hours** for a completionist. Comparable to
FF6's World of Ruin optional content scope.

### The Pendulum Tavern as Post-Game Hub

All post-game content routes through The Pendulum tavern (per
[dynamic-world.md](dynamic-world.md)):

- **Sable:** Completion tracking, boss rush access, general dialogue
- **Dreamer's Fault:** Cellar entrance
- **Party members:** Epilogue conversations (all present except Cael)
- **NPCs:** Characters the player helped throughout the game appear
