# Bestiary Act II Implementation Plan (Gap 1.3, Sub-project 2a)

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Populate act-ii.md with 33 Act II enemies across 5 areas, add 9
new palette-swap families, and update 12 existing families with Tier 2 entries.

**Architecture:** Pure documentation pass — rewrite act-ii.md from TBD placeholder
to full stat tables, update palette-families.md with new and revised families,
update CONTINUATION.md and gap tracker.

**Tech Stack:** Markdown, git, pnpm (for lint/test verification)

**Spec:** `docs/superpowers/specs/2026-03-22-bestiary-act-ii-design.md`

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `docs/story/bestiary/act-ii.md` | Rewrite | Full Act II enemy stat tables (33 entries) |
| `docs/story/bestiary/palette-families.md` | Modify | Add 9 new families, revise Tier 2 for 12 existing |
| `docs/story/bestiary/CONTINUATION.md` | Modify | Update Sub-project 2a status |
| `docs/analysis/game-design-gaps.md` | Modify | Check off Act II items in Gap 1.3 |

---

## Chunk 1: Act II Stat Tables

### Task 1: Populate act-ii.md with all 33 enemies

**Files:**
- Rewrite: `docs/story/bestiary/act-ii.md`
- Reference: `docs/story/bestiary/README.md` (formulas, types)
- Reference: `docs/story/dungeons-world.md` (boss HP, enemy names)
- Reference: `docs/story/dungeons-city.md` (Ashmark, Bellhaven enemies)
- Reference: `docs/superpowers/specs/2026-03-22-bestiary-act-ii-design.md`

- [ ] **Step 1: Compute base stats for all 33 enemies**

Use the formulas from README.md. For each enemy, compute stats at
its level, then apply role adjustments per the spec.

Stat formulas:
```
HP   = floor(level² × 1.8 + level × 12 + 20)
MP   = floor(level × 3.5)  (0 for physical-only, 0 for Constructs)
ATK  = floor(level × 1.6 + 8)
DEF  = floor(level × 1.2 + 5)
MAG  = floor(level × 1.4 + 6)
MDEF = floor(level × 1.0 + 4)
SPD  = floor(level × 0.8 + 8)
```

Reward formulas:
```
base_gold(level) = floor(10000 / (1 + 824 × e^(-0.0754 × level)))
base_exp(level)  = floor(30000 / (1 + 1188 × e^(-0.0696 × level)))
```
Multiply by threat: Trivial ×0.15, Low ×0.35, Standard ×0.60,
Dangerous ×1.0, Boss = hand-tuned.

Role adjustments:
- Swarm: HP up to -32%, ATK -10%
- Glass cannon: ATK +15%, DEF/HP up to -25%
- Caster: MAG +15%, ATK up to -21%, MDEF +10%
- Tank: DEF +15%, HP +10%, SPD up to -18%
- Balanced: no adjustment

- [ ] **Step 2: Write the Ley Line Depths section**

Rewrite `docs/story/bestiary/act-ii.md` (replacing TBD placeholder).
Start with:

```markdown
# Act II Bestiary

Enemies encountered during Act II: Ley Line Depths (floors 1–3),
Ashmark Factory Depths, Bellhaven Smuggler Tunnels, Valdris Siege,
and the Overworld between cities. See [README.md](README.md) for
type rules, stat formulas, and reward calculations.

**Total:** 33 enemies (28 regular + 2 unique + 1 spawn + 2 bosses)

---

## Ley Line Depths (Floors 1–3)

Recommended party level: 16–22. Optional dungeon accessed via
Millhaven pit. Natural caverns and crystal formations with
ley-infused creatures.
```

Then the stat table with these 8 enemies:

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Extraction Drone | Automata | 1 | 16 | Construct | Low | Balanced |
| Cave Vermin | Vermin | 2 | 16 | Beast | Low | Swarm |
| Cave Crawler | Crawler | 1 | 17 | Beast | Standard | Tank |
| Prism Moth | Moth | 1 | 18 | Elemental | Low | Swarm/Caster |
| Ley Wisp | Wisp | 2 | 18 | Elemental | Standard | Caster |
| Deep Serpent | Serpent | 2 | 19 | Beast | Standard | Glass cannon |
| Crystal Sentry | Crystal | 2 | 20 | Elemental | Standard | Tank |
| *Ley Colossus* | — | — | 22 | Elemental | Dangerous | Mini-boss |

Use exact column format from act-i.md:
```
| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
```

**Elemental profiles for Ley Line Depths enemies:**
- Extraction Drone (Construct): Weak→Storm, no Resists/Absorbs
- Cave Vermin (Beast): — (no elemental affinity)
- Cave Crawler (Beast): — (no elemental affinity)
- Prism Moth (Elemental): Weak→Frost (light-crystal creature), Absorbs→Ley
- Ley Wisp (Elemental): Weak→Frost, Absorbs→Flame (Tier 2 of Ember Wisp)
- Deep Serpent (Beast): Weak→Frost (cave creature)
- Crystal Sentry (Elemental): Weak→Storm, Absorbs→Earth
- Ley Colossus: Absorbs ALL magic (Flame, Frost, Storm, Earth, Ley, Spirit, Void)

**Status immunities per type:**
- Construct (Extraction Drone): Poison, Sleep, Confusion, Berserk, Despair
- Elemental (Prism Moth, Ley Wisp, Crystal Sentry, Ley Colossus): Petrify
- Beast (Cave Vermin, Cave Crawler, Deep Serpent): —
- Boss-typed enemies: N/A (Ley Colossus is Elemental, not Boss)

Add Boss Notes for **Ley Colossus** after the table:
- HP: 7,000 (per dungeons-world.md)
- Phase 1 (7,000–3,500): Crystal Fists, Ley Pulse (1-turn charge AoE).
  Absorbs all magic. Vulnerable to physical.
- Phase 2 (below 3,500): Shatters/reforms, faster. Gains Prism Beam
  (single-target, 1-turn warning). Loses Ley Pulse. Physical
  vulnerability increases.
- Not hostile — guardian testing visitors.
- Absorbs: Flame, Frost, Storm, Earth, Ley, Spirit, Void (all)
- Immunities: Petrify (Elemental default only)
- Drops: Ley Crystal Fragment (crafting), Colossus Shard (accessory)

- [ ] **Step 3: Write the Ashmark Factory Depths section**

5 enemies. Include the Pallor foreshadowing note for Pallor-Touched
Worker:

```markdown
> **Pallor foreshadowing:** The Pallor-Touched Worker is the first
> encounter where the party fights a human victim of the Pallor. At
> 0 HP the worker "wakes up" confused — they cannot be killed. No
> Gold/Exp is awarded. This encounter signals that something is
> deeply wrong before the Interlude reveals the full scope.
```

Enemies:

| Name | Lv | Type | Threat | Role |
|------|----|------|--------|------|
| Forge Roach | 18 | Beast | Low | Swarm |
| Pipe Wraith | 19 | Spirit | Standard | Caster |
| Overclocked Automata | 20 | Construct | Standard | Glass cannon |
| Pallor-Touched Worker | 20 | Humanoid | Standard | Balanced (unique, non-lethal) |
| *The Forge Warden* | 24 | Boss | Boss | Boss |

Boss Notes for **The Forge Warden** from spec Section 4.2:
- HP: 8,500 (per dungeons-city.md)
- Two phases, Lira interaction (Pipeline Drain disable, Override abort)
- Weakness: Storm (150%), Spirit (125%)
- Resistance: Flame (50%), Earth (75%)
- Immunities: Death, Petrify, Stop, Sleep, Confusion, Poison
- Drops: Drayce's Failsafe Core, Corrupted Tuning Fork, 2,000 Gold

- [ ] **Step 4: Write the Bellhaven Smuggler Tunnels section**

3 enemies, all regular:

| Name | Lv | Type | Threat | Role |
|------|----|------|--------|------|
| Smuggler Thug | 17 | Humanoid | Low | Balanced |
| Sea Crawler | 18 | Beast | Standard | Tank |
| Tide Wraith | 19 | Spirit | Standard | Caster |

- [ ] **Step 5: Write the Valdris Siege section**

6 enemies + gauntlet wave structure. This is the most complex section.

Start with:
```markdown
## Valdris Siege — Castle Defense Gauntlet

Recommended party level: 18–22. Act II climax. The Carradan Compact
assaults Valdris. Scripted wave encounters (FF4 Baron Castle defense
style) culminating in the Ashen Ram boss.

**Guest NPC:** Dame Cordwyn (5,000 HP, ATK 85, DEF 70) fights alongside
the party during all waves and the boss. Cannot be controlled. Uses
Shield Wall (party DEF up) and Rally Cry (party ATK up).
```

Pre-boss random encounter enemies (battlefield traversal):

| Name | Lv | Type | Threat | Role |
|------|----|------|--------|------|
| Compact Soldier | 18 | Humanoid | Low | Balanced |
| Compact Engineer | 19 | Humanoid | Standard | Support (heals allied Constructs) |

Gauntlet wave enemies:

| Name | Lv | Type | Threat | Role |
|------|----|------|--------|------|
| Siege Ballista Crew | 20 | Humanoid | Standard | Ranged (back-row) |
| Compact Gyrocopter | 20 | Construct | Standard | Flying, spawn-on-death |
| Downed Pilot | 18 | Humanoid | Low | Spawned by Gyrocopter |
| *The Ashen Ram* | 22 | Boss | Boss | 3-phase boss |

After the stat table, add the **Gauntlet Wave Structure**:

```markdown
### Castle Defense Gauntlet

Scripted wave sequence. Party cannot flee. HP/MP carry over between
waves. Dame Cordwyn fights alongside throughout.

- **Wave 1:** 4 Compact Soldiers + 2 Compact Engineers
  (Establish the army. Engineers heal soldiers — focus them first.)
- **Wave 2:** 3 Compact Soldiers + 2 Siege Ballista Crews
  (Ranged pressure. Back-row targeting forces defensive play.)
- **Wave 3:** 2 Compact Gyrocopters + 2 Compact Soldiers
  (Air support debut. Spawn-on-death mechanic introduced.)
- **Breather:** Dame Cordwyn rallies. Party can heal and save.
- **Boss:** The Ashen Ram breaches the wall.
```

Then Boss Notes for **The Ashen Ram** from spec Section 4.1:
- HP: 25,000 (per dungeons-world.md)
- 3 phases with full ability lists
- Weakness: Storm (150%), Flame (125% Phase 3 core only)
- Resistance: Earth (absorbs), Frost (75%)
- Drops: Pallor-Laced Iron, Compact Battle Standard

Add **Spawn-on-Death Mechanic** note:
```markdown
### Spawn-on-Death (Airborne Family Trait)

When a Compact Gyrocopter reaches 0 HP:
1. The Construct is removed from battle
2. A Downed Pilot spawns in its place at full HP
3. The pilot acts on the next available turn
4. Gold/Exp = sum of both enemies
```

- [ ] **Step 6: Write the Overworld Act II section**

11 enemies with family/tier and biome assignments:

| Name | Family | Tier | Lv | Type | Threat | Role | Biome |
|------|--------|------|----|------|--------|------|-------|
| Tunnel Mite | Mite | 2 | 14 | Beast | Low | Swarm | Mountain caves |
| Coastal Crab | Crawler | 1 | 14 | Beast | Low | Tank | Bellhaven coast |
| Road Viper | Serpent | 2 | 15 | Beast | Low | Glass cannon | Roads, grassland |
| Sewer Leech | Leech | 2 | 15 | Beast | Low | Balanced | Coastal, swamp |
| Highwayman | Bandit | 2 | 15 | Humanoid | Standard | Balanced | Roads between cities |
| Iron Beetle | Beetle | 2 | 16 | Beast | Low | Tank | Mountain paths |
| Dire Wolf | Wolf | 2 | 16 | Beast | Standard | Balanced | Forest, mountain |
| Meadow Sprite | Sprite | 2 | 16 | Spirit | Standard | Caster/Support | Grassland, forest |
| Mountain Hawk | Hawk | 1 | 17 | Beast | Standard | Glass cannon | Mountain, highland |
| Razorback | Boar | 2 | 17 | Beast | Standard | Glass cannon | Grassland |
| Thornwood Treant | Treant | 1 | 19 | Elemental | Dangerous | Tank | Deep forest (rare) |

- [ ] **Step 7: Write the Act II Summary section**

```markdown
## Act II Summary

- **Total:** 33 enemies (28 regular + 2 unique + 1 spawn + 2 bosses)
- **Type coverage:** Beast (14), Construct (4), Humanoid (7),
  Spirit (3), Elemental (5), Boss (2)
- **Threat spread:** Low (10), Standard (14), Dangerous (2), Boss (2),
  unique (2), spawn (1)
- **Level range:** 14–24
- **New families:** Automata, Crawler, Soldier, Airborne, Roach,
  Wraith, Moth, Hawk, Treant (9)
- **Existing families progressed to Tier 2:** Vermin, Wisp, Serpent,
  Crystal, Mite, Bandit, Beetle, Wolf, Sprite, Boar, Leech (11)
- **New mechanics:** Spawn-on-death (Airborne), Castle defense gauntlet,
  Non-lethal encounter (Pallor-Touched Worker)
- **Pallor foreshadowing:** Pallor-Touched Worker (non-lethal victim),
  The Ashen Ram (corrupted siege construct boss)
```

- [ ] **Step 8: Verify stat blocks**

Spot-check at least 5 enemies:

1. **Extraction Drone (Lv 16, Construct, Low):** HP = floor(256×1.8 +
   16×12 + 20) = floor(460.8+192+20) = 672. Construct: MP = 0.
   Gold = floor(base_gold(16) × 0.35). Immunities: Poison, Sleep,
   Confusion, Berserk, Despair.

2. **Cave Crawler (Lv 17, Beast, Standard, Tank):** HP baseline = 771.
   Tank: HP +10% = 848, DEF +15%, SPD -18%.

3. **Compact Gyrocopter (Lv 20, Construct, Standard):** Construct
   rules: MP = 0, immune to Poison/Sleep/Confusion/Berserk/Despair.

4. **The Ashen Ram (Lv 22, Boss):** HP = 25,000 (hand-tuned, matches
   dungeons-world.md). Boss immunities: Death, Petrify, Stop, Sleep,
   Confusion.

5. **Thornwood Treant (Lv 19, Elemental, Dangerous):** HP baseline =
   891. Dangerous threat: Gold × 1.0, Exp × 1.0. Elemental immunity:
   Petrify.

- [ ] **Step 9: Commit**

```bash
git add docs/story/bestiary/act-ii.md
```
Commit message: `docs(shared): populate Act II bestiary (33 enemies across 5 areas)`

---

## Chunk 2: Palette Family Updates

### Task 2: Add 9 new families to palette-families.md

**Files:**
- Modify: `docs/story/bestiary/palette-families.md`
- Reference: `docs/superpowers/specs/2026-03-22-bestiary-act-ii-design.md` (Sections 6.1–6.9)

- [ ] **Step 1: Add all 9 new family definitions**

Append after the existing 19 families (Wolf is the last). Add these
in order: Crawler, Automata, Soldier, Airborne, Roach, Wraith, Moth,
Hawk, Treant.

For each family, use the exact format from the spec Sections 6.1–6.9.
Include:
- Base enemy name, level, type, threat
- Planned tiers count
- Tier table with Name, Lv, Type, Element Shift, New Abilities, Threat
- Tier 1 Element Shift = — (em dash, per Sub-project 1 lesson)
- Design rationale note below each table

**Special: Airborne family** uses a "Death Spawn" column instead of
"Element Shift":

```markdown
## Airborne Family (Spawn-on-Death Trait)

**Base:** Compact Gyrocopter (Lv 20, Construct, Standard)
**Planned Tiers:** 3
**Family trait:** Spawns a linked Humanoid ground unit on death.

| Tier | Name | Lv | Type | Death Spawn | New Abilities | Threat |
|------|------|----|------|-------------|---------------|--------|
| 1 | Compact Gyrocopter | 20 | Construct | Downed Pilot (Lv 18, Humanoid) | Bomb Run (AoE), Strafe (back-row), high melee evasion | Standard |
| 2 | Assault Rotorcraft | 28 | Construct | Parachute Trooper (Lv 25, Humanoid) | +Napalm Drop (AoE + Burn), +Evasive Maneuver | Dangerous |
| 3 | Pallor Drone | 40 | Pallor | Pallor Pilot (Lv 38, Pallor) | +Despair Bomb (AoE Despair), +Grey Static (Silence) | Rare |

**Spawned units:**

| Name | Lv | Type | Abilities | Threat |
|------|----|------|-----------|--------|
| Downed Pilot | 18 | Humanoid | Sword Slash, Pistol Shot (ranged) | Low |
| Parachute Trooper | 25 | Humanoid | +Grenade (AoE), +Emergency Stim (self-heal) | Standard |
| Pallor Pilot | 38 | Pallor | +Despair Touch, +Frenzied Slash (2-hit) | Standard |
```

- [ ] **Step 2: Commit new families**

```bash
git add docs/story/bestiary/palette-families.md
```
Commit message: `docs(shared): add 9 new palette-swap families (Crawler, Automata, Soldier, Airborne, Roach, Wraith, Moth, Hawk, Treant)`

---

### Task 3: Update 12 existing families with Tier 2 revisions

**Files:**
- Modify: `docs/story/bestiary/palette-families.md`
- Reference: spec Section 7 (revision table)

- [ ] **Step 1: Update existing family Tier 2 entries**

For each of the 11 existing families below (Crawler is a new family
handled in Task 2), update the Tier 2 row in palette-families.md to
match the spec's revised names and levels:

| Family | Old Tier 2 | New Tier 2 | Action |
|--------|-----------|-----------|--------|
| Vermin | Cave Vermin (Lv 10) | Cave Vermin (Lv 16) | Level up |
| Wisp | Storm Wisp (Lv 20) | Ley Wisp (Lv 18) | Name + level |
| Crystal | Resonant Crystal (Lv 18) | Crystal Sentry (Lv 20) | Name + level |
| Mite | Tunnel Mite (Lv 14) | Tunnel Mite (Lv 14) | No change needed — already matches |
| Beetle | Iron Beetle (Lv 18) | Iron Beetle (Lv 16) | Level down |
| Wolf | Dire Wolf (Lv 19) | Dire Wolf (Lv 16) | Level down |
| Sprite | Meadow Sprite (Lv 19) | Meadow Sprite (Lv 16) | Level down |
| Boar | Razorback (Lv 20) | Razorback (Lv 17) | Level down |
| Leech | Sewer Leech (Lv 18) | Sewer Leech (Lv 15) | Level down |
| Bandit | Highwayman (Lv 16) | Smuggler Thug (Lv 17) / Highwayman (Lv 15) | Split into 2 variants |
| Serpent | Corrupted Spawn (Lv 10) | Keep + add Deep Serpent (Lv 19) | Add second Tier 2 |

**Bandit family special case:** Add a second Tier 2 row for Smuggler
Thug. The Bandit family now has TWO Tier 2 variants (different biomes,
same tier power). Add a note:

```markdown
> Bandit family has two Tier 2 variants: Highwayman (overworld roads)
> and Smuggler Thug (Bellhaven coast). Same power tier, different
> biomes — follows FF6's multi-location family pattern.
```

**Serpent family special case:** Do NOT replace Corrupted Spawn (Lv 10)
as Tier 2. Instead, add Deep Serpent (Lv 19) as a SECOND Tier 2
variant, same as the Bandit treatment:

```markdown
> Serpent family has two Tier 2 variants: Corrupted Spawn (Lv 10,
> Fenmother's Hollow) and Deep Serpent (Lv 19, Ley Line Depths).
```

For families where only the level changed (Beetle, Wolf, Sprite, Boar,
Leech), update the level number in the existing Tier 2 row.

- [ ] **Step 2: Verify all 11 existing families addressed**

Read palette-families.md and verify:
- Wisp Tier 2 = Ley Wisp, Lv 18
- Crystal Tier 2 = Crystal Sentry, Lv 20
- Serpent has TWO Tier 2 entries
- Bandit has TWO Tier 2 entries
- All level revisions applied

- [ ] **Step 3: Commit**

```bash
git add docs/story/bestiary/palette-families.md
```
Commit message: `docs(shared): revise 11 existing family Tier 2 entries for Act II`

---

## Chunk 3: Cross-References and Tracking

### Task 4: Update CONTINUATION.md

**Files:**
- Modify: `docs/story/bestiary/CONTINUATION.md`

- [ ] **Step 1: Update status table**

Change Sub-project 2 row:
```markdown
| **2: Act II + Interlude** | IN PROGRESS (Act II done) | — | ~33 (Act II) | act-ii.md |
```

- [ ] **Step 2: Commit**

```bash
git add docs/story/bestiary/CONTINUATION.md
```
Commit message: `docs(shared): update CONTINUATION.md with Act II progress`

---

### Task 5: Update gap analysis

**Files:**
- Modify: `docs/analysis/game-design-gaps.md`

- [ ] **Step 1: Check off Act II items**

In the Gap 1.3 "What's Needed" checklist, the Valdris Siege and
overworld items should be checked off. Also update the per-enemy
data checklist — Ley Line Depths enemies are now partially populated
(floors 1–3 only; floors 4–5 are Act III).

- [ ] **Step 2: Add progress tracking row**

```markdown
| 2026-03-22 | 1.3 Enemy Bestiary | PARTIAL update. Act II enemies (33): Ley Line Depths F1–3, Ashmark Factory, Bellhaven, Valdris Siege gauntlet, Overworld. 9 new families, 12 Tier 2 revisions. | <commit-sha> |
```

- [ ] **Step 3: Commit**

```bash
git add docs/analysis/game-design-gaps.md
```
Commit message: `docs(shared): update Gap 1.3 with Act II bestiary progress`

---

## Chunk 4: Verification and Push

### Task 6: Final verification

- [ ] **Step 1: Run lint and tests**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 2: Cross-reference verification**

1. Ashen Ram HP in act-ii.md = 25,000 (matches dungeons-world.md)
2. Forge Warden HP in act-ii.md = 8,500 (matches dungeons-city.md)
3. Ley Colossus HP in act-ii.md = 7,000 (matches dungeons-world.md)
4. All Construct enemies have MP = 0
5. All Construct enemies have 5 status immunities
6. All Spirit enemies note physical 50% reduction in abilities
7. All Elemental enemies have Petrify immunity
8. Boss enemies have Death + Petrify + Stop + Sleep + Confusion
9. Gold/Exp values match logistic formulas × threat (spot-check 3)
10. All 9 new families present in palette-families.md
11. All 11 existing families have updated Tier 2 entries (Mite = no change)
12. Formatting: em dash (—) for none, en dash (–) for ranges
13. Compact Gyrocopter row notes spawn-on-death
14. Downed Pilot row notes "spawned by Gyrocopter"
15. Dame Cordwyn guest NPC stats documented in siege section

- [ ] **Step 3: Push**

The branch `feature/bestiary-act-ii` should already be checked out.

```bash
git push -u origin feature/bestiary-act-ii
```

- [ ] **Step 4: Handoff**

Print: "Act II bestiary complete. Next step: run `/create-pr` to
open a PR targeting main, then `/pr-review-response <PR#>` to
orchestrate review."
