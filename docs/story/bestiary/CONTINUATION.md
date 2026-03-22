# Bestiary Continuation Guide

> **Purpose:** Recovery document for multi-session bestiary work. If context
> is compacted or a new session starts, read this file FIRST to understand
> what has been done, what remains, and how to continue.
>
> **Last updated:** 2026-03-22 (after Sub-project 2a Act II implementation)

---

## Current State

| Sub-project | Status | PR | Enemies | Files |
|-------------|--------|-----|---------|-------|
| **1: Foundation + Act I** | COMPLETE | #19 (merged) | 25 | README.md, act-i.md, palette-families.md |
| **2a: Act II** | COMPLETE | — (pending PR) | 33 | act-ii.md, palette-families.md |
| **2b: Interlude** | NOT STARTED | — | ~50–60 target | interlude.md |
| **3: Act III + Optional** | NOT STARTED | — | ~60–80 target | act-iii.md, optional.md |
| **4: Boss Compendium** | NOT STARTED | — | ~20–25 target | bosses.md |

**Gap 1.3 status:** PARTIAL (in `docs/analysis/game-design-gaps.md`)

---

## What Has Been Established (Do NOT Re-Design)

These are DONE and canonical. Do not brainstorm or redesign them — just
use them when populating new enemies.

### Stat Template (19 columns)
Defined in `docs/story/bestiary/README.md`. Every enemy uses:
Name, Type, Lv, HP, MP, ATK, DEF, MAG, MDEF, SPD, Gold, Exp, Steal,
Drop, Weak, Resists, Absorbs, Status Immunities, Location(s)

### 8 Enemy Types
Beast, Undead, Construct, Spirit, Humanoid, Pallor, Elemental, Boss.
Full rules with inherent traits, immunities, and interactions in README.

### Stat Scaling Formulas
```
HP   = floor(level² × 1.8 + level × 12 + 20)
MP   = floor(level × 3.5)
ATK  = floor(level × 1.6 + 8)
DEF  = floor(level × 1.2 + 5)
MAG  = floor(level × 1.4 + 6)
MDEF = floor(level × 1.0 + 4)
SPD  = floor(level × 0.8 + 8)
```

### Reward Formulas (Bounded Growth / Logistic)
```
base_gold(level) = floor(10000 / (1 + 824 × e^(-0.0754 × level)))
base_exp(level)  = floor(30000 / (1 + 1188 × e^(-0.0696 × level)))
```
Then multiply by threat: Trivial ×0.15, Low ×0.35, Standard ×0.60,
Dangerous ×1.0, Rare ×1.5, Boss = hand-tuned.

### Role Adjustments
- Swarm (Trivial): HP up to -32%
- Glass cannon: ATK +15%, DEF/HP up to -25%
- Caster: MAG +15%, ATK up to -21%
- Tank: DEF/HP +15%, SPD up to -18%

### Palette-Swap Family System
19 families defined in `palette-families.md` with Tier 1–4 projections.
Tier 1 entries match act-i.md. Higher tiers use stat formulas at the
variant's own level with role adjustments — no raw stat multipliers.

### Enemy LCK
Enemies do not have a LCK stat. Fixed 5% crit rate for all enemies.

### Boss Default Immunities
Death, Petrify, Stop, Sleep, Confusion (can be overridden per boss).

---

## What Remains (Sub-projects 2–4)

### Sub-project 2: Act II + Interlude (~80–100 enemies)

**Branch:** `feature/bestiary-act-ii`

**Dungeons to populate:**

| Dungeon | Act | Rec. Level | Source File | Enemies Named |
|---------|-----|-----------|-------------|---------------|
| Valdris Siege area | II | 18–22 | dungeons-world.md | Carradan Soldier, Compact Engineer, etc. |
| Ley Line Depths (F1–3) | II | 18–25 | dungeons-world.md | Ley Construct, Ley Elemental, Ley Colossus |
| Rail Tunnels | Interlude | 18–22 | dungeons-world.md | Forge Phantom, Rail Sentry, Pallor Nest, etc. |
| Axis Tower | Interlude | 22–28 | dungeons-world.md | Compact Guard, Pallor Soldier, Arcanite Hound |
| Ley Line Depths (F4–5) | III | 25–35 | dungeons-world.md | Ley Construct (enhanced), Pallor Soldier |
| Valdris Crown Catacombs | Interlude | 20–25 | dungeons-city.md | Crypt Shade, Bone Warden, Tomb Mite |
| Corrund Undercity | Interlude | 18–22 | dungeons-city.md | Forge-Smoke Creature, Service Automata |
| Caldera Undercity | Interlude | 20–25 | dungeons-city.md | Heat Sprite, Corrupted Forge Construct |
| Ashmark Factory Depths | II/Interlude | 22–28 | dungeons-city.md | Overclocked Automata, Pipe Wraith, etc. |
| Ironmark Citadel Dungeons | Interlude | 24–28 | dungeons-city.md | Pallor-Touched Soldier, Pallor Wisp |
| Bellhaven Smuggler Tunnels | II/Interlude | 15–22 | dungeons-city.md | Sea Crawler, Tide Wraith |
| Overworld Act II | II | 13–25 | — | Terrain-based encounters |

**Process:**
1. `/story-designer` — brainstorm Sub-project 2 (skip template/formula
   design — already done). Focus on: which enemies go where, new families
   vs existing family Tier 2/3 variants, new unique enemies.
2. Write spec → plan → execute (same workflow as Sub-project 1)
3. Populate `act-ii.md` and `interlude.md` with full stat tables
4. Update `palette-families.md` with Tier 2/3 entries for existing families
5. Add any new families discovered during design
6. Update `docs/analysis/game-design-gaps.md` checklist items
7. `/create-pr` → `/pr-review-response`

**Key design questions for brainstorming:**
- How many NEW families vs Tier 2/3 of existing 19?
- What new enemy types appear? (Pallor enemies debut in Interlude)
- City dungeon enemies: are they distinct families or variants of
  world dungeon enemies?
- Overworld Act II: terrain-based encounters (forest, mountain, road,
  coast) — how many per terrain?

### Sub-project 3: Act III + Optional (~60–80 enemies)

**Dungeons to populate:**
- Pallor Wastes (5 sections + trials)
- The Convergence (outer ring, anchors, central platform)
- Dreamer's Fault (post-game optional)
- Overworld Act III / post-game variants

**Key design questions:**
- Pallor Wastes enemies are heavily Pallor-type — how many Beast→Pallor
  Tier 4 conversions vs pure Pallor-born enemies?
- Trial manifestations (Crowned Hollow, Perfect Machine, etc.) — these
  are unique narrative encounters. Full stat blocks or special rules?
- Post-game enemies: level 70–150. These are the hardest regular enemies.
  How do they relate to earlier families?

### Sub-project 4: Boss Compendium (~20–25 bosses)

**All bosses from dungeons-world.md and dungeons-city.md:**
- Vein Guardian, Corrupted Fenmother (Act I — already in act-i.md as
  brief Boss Notes, need full AI scripts)
- Ember Drake, Drowned Sentinel (mini-bosses, same)
- The Ironbound, General Kole, Ley Colossus (Interlude)
- Archive Guardian, Ashen Ram, Ley Leech, Grey Engine, Forge Heart,
  Frost Warden, Pallor Hollow (various)
- Vaelith the Ashen Shepherd (Act III)
- Cael Phase 1 + Phase 2, Pallor Incarnate (Final)
- Pallor Nest Mother, Forge Warden, Undying Warden (city dungeon bosses)

**Key design questions:**
- AI behavior scripts: how detailed? (Per-turn decision trees? Phase
  triggers only? Conditional abilities?)
- Boss-specific drop tables: hand-tuned or formula-based?
- Multi-phase bosses: how are phases represented in the stat table?

---

## Process for Each Sub-project

```
1. Read this CONTINUATION.md
2. Read docs/story/bestiary/README.md (canonical rules)
3. Read docs/analysis/game-design-gaps.md (Gap 1.3 checklist)
4. Read the relevant dungeon files (dungeons-world.md, dungeons-city.md)
5. /story-designer — brainstorm the sub-project
   - Skip template/formula design (already done)
   - Focus on enemy roster, families, type distribution
6. Write spec → plan → execute
7. Populate the target .md file with stat tables
8. Update palette-families.md with new tier entries
9. Update gap analysis checklist
10. /create-pr → /pr-review-response
11. Update this CONTINUATION.md with new status
```

---

## Reference Files

| File | Purpose |
|------|---------|
| `docs/story/bestiary/README.md` | Canonical rules, formulas, types |
| `docs/story/bestiary/act-i.md` | Completed Act I (25 enemies) |
| `docs/story/bestiary/palette-families.md` | 19 families with tier projections |
| `docs/story/dungeons-world.md` | World dungeon layouts, boss descriptions, enemy names |
| `docs/story/dungeons-city.md` | City dungeon layouts, enemy names |
| `docs/story/combat-formulas.md` | Damage formulas, ATB, boss HP scaling table |
| `docs/story/magic.md` | Elements, status effects, spell list |
| `docs/story/progression.md` | Character stats, level cap 150 |
| `docs/analysis/game-design-gaps.md` | Gap 1.3 status and checklist |
| `docs/superpowers/specs/2026-03-22-enemy-bestiary-design.md` | Original design spec |

---

## Lessons Learned from Sub-project 1

These lessons should inform all future sub-projects:

1. **Copilot catches formatting issues our story-review-loop misses.**
   Dash consistency (em dash vs double-hyphen vs en dash), placeholder
   markers, and column description accuracy are the main gaps. Be precise
   from the start.

2. **Boss descriptions in act files must match dungeons-world.md exactly.**
   Do not invent phase structures or mechanics not in the canonical dungeon
   file. The dungeon file is authoritative for boss behavior.

3. **Elemental profiles must be consistent between act files and
   palette-families.md.** The act file is authoritative for stat data;
   palette-families Tier 1 Element Shift column should always be "—"
   (the base has no shift — its profile lives in the act file).

4. **The ±15% tuning rule needs explicit role-based exceptions.**
   Swarm enemies exceed -30%, casters exceed -20% on ATK. Document
   these exceptions in README rather than silently violating the rule.

5. **Step 6b (post-fix story-review-loop) catches issues that would
   otherwise become another round of Copilot comments.** Always run it
   after fixing valid review comments.

6. **Use em dash (—) for "none/not applicable" in table cells, en dash
   (–) for numeric ranges, and double-hyphen (--) only in prose.**
