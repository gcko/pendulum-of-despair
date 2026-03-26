# Difficulty & Balance Framework Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `docs/story/difficulty-balance.md` — the canonical difficulty and balance framework for Pendulum of Despair.

**Architecture:** Single markdown document organized by balance concern. All content derived from the approved spec at `docs/superpowers/specs/2026-03-26-difficulty-balance-design.md`. Numeric values verified against canonical story docs.

**Tech Stack:** Markdown documentation (no code changes).

---

## Chunk 1: Philosophy, Combat Pacing, and Resource Management

### Task 1: Create difficulty-balance.md with Design Philosophy

**Files:**
- Create: `docs/story/difficulty-balance.md`

**Context:** Establishes the FF6 Accessible philosophy, core principles, and one-fixed-difficulty mandate. All subsequent sections build on this foundation.

**Cross-reference files to verify against:**
- `docs/story/combat-formulas.md` — damage formulas, ATB timing
- `docs/story/progression.md` — stat growth, XP curve, level milestones

- [ ] **Step 1: Create the file with header and Section 1 (Design Philosophy)**

Write:
- Document header with cross-reference note
- Section 1.1: FF6 Accessible (combat serves story, no grinding on critical path, Pallor is the emotional challenge, one fixed difficulty)
- Section 1.2: Core Principles (trash fast/bosses events, HP abundant/MP constraint, 70% equipment affordability, no frustration loops)

- [ ] **Step 2: Commit**

```bash
git add docs/story/difficulty-balance.md
git commit -m "docs(shared): add difficulty-balance.md with design philosophy"
```

---

### Task 2: Combat Pacing Targets

**Files:**
- Modify: `docs/story/difficulty-balance.md`

**Context:** Defines how fast enemies die, how long boss fights last, and random encounter duration. These are the core "feel" numbers.

**Cross-reference files to verify against:**
- `docs/story/combat-formulas.md` § Physical Damage — ATK²/6 - DEF formula
- `docs/story/progression.md` § Character Growth — Edren ATK at milestones
- `docs/story/bestiary/act-i.md` — Ley Vermin (HP 23, DEF 6)
- `docs/story/bestiary/bosses.md` — Vein Guardian (6,000 HP, DEF 24)

- [ ] **Step 1: Write Section 2 (Combat Pacing Targets)**

Include:
- 2.1 Regular Enemies — Hits to Kill: 1–2 hits from physical, 1 hit from AoE magic. Verification table at levels 5/12/20/30/40 with approximate ATK, enemy DEF/HP, damage/hit, hits to kill. Note these are approximate (link to progression.md and equipment.md for exact values).
- 2.2 Boss Fight Duration: table with mini-boss (1–2 min), story boss Act I (2–3), story boss Act II (3–4), story boss Interlude (3–5), story boss Act III (4–6), act-ending (5–7), final boss (6–8), superboss (8–12). Include worked Vein Guardian example (6,000 HP, ~1.5–2 min) and Cael example (80,000 HP, ~6–7 min). Explain what governs duration (HP, phases, healing pressure, mechanics).
- 2.3 Encounter Duration: table with trash (10–15s), standard (15–25s), dangerous (25–40s), back attack (+10–15s), preemptive (-5–10s). Rule: never exceed 1 minute at-level.

- [ ] **Step 2: Verify Vein Guardian HP**

Read `docs/story/bestiary/bosses.md` and confirm: Vein Guardian = 6,000 HP (one HP pool, 2 behavior phases). NOT 12,000.

- [ ] **Step 3: Verify damage formula produces expected results**

Run the ATK²/6 - DEF calculation for Edren at level 5 (ATK ~26) vs Ley Vermin (DEF 6, HP 23): `(26²/6) - 6 = 107`. Confirm one-shot.

- [ ] **Step 4: Commit**

```bash
git add docs/story/difficulty-balance.md
git commit -m "docs(shared): add combat pacing targets to difficulty-balance.md"
```

---

### Task 3: Resource Management

**Files:**
- Modify: `docs/story/difficulty-balance.md`

**Context:** HP healing is abundant, MP is the soft constraint. Defines the dungeon supply budget and sustainability targets.

**Cross-reference files to verify against:**
- `docs/story/items.md` — Potion (100 HP, 50g), Hi-Potion (500 HP, 300g, Act II), Ether (30 MP, 200g)
- `docs/story/economy.md` § Gold Pacing Targets — expected gold per act
- `docs/story/magic.md` — Mend (3 MP), Leybalm (3 MP), Breath of the Wilds (8 MP)

- [ ] **Step 1: Write Section 3 (Resource Management)**

Include:
- 3.1 HP Healing — Abundant: table with Potion/Hi-Potion/Ley Tonic/X-Potion (effect, cost, GP/HP ratio, availability). Note Hi-Potion is Act II per items.md. Explain healing spells supplement but cost the real resource: MP.
- 3.2 MP — The Soft Constraint: table with Ether/Hi-Ether/X-Ether (effect, cost). Explain intentional cost asymmetry (Ethers expensive vs Potions cheap). The gameplay loop: physical for trash, spells for bosses. MP sustainability targets per dungeon length (short 60–70%, medium 40–55%, long 25–40%, gauntlet 15–30% MP remaining at boss).
- 3.3 Dungeon Supply Budget: table per act with recommended Potions/Ethers/status cures, total cost, % of gold. Note supply cost shrinks as % of wealth over time. "Comfortable" = 30–50% supplies remaining at boss.

- [ ] **Step 2: Verify item prices**

Read `docs/story/items.md` and confirm: Potion 50g, Hi-Potion 300g (Act II), Ether 200g, Hi-Ether 800g, X-Potion 1,500g, X-Ether 2,000g, Ley Tonic 800g.

- [ ] **Step 3: Commit**

```bash
git add docs/story/difficulty-balance.md
git commit -m "docs(shared): add resource management to difficulty-balance.md"
```

---

## Chunk 2: Progression, Anti-Frustration, and Difficulty Escalation

### Task 4: Progression Pacing

**Files:**
- Modify: `docs/story/difficulty-balance.md`

**Context:** Expected level per area, catch-up mechanics, equipment progression curve.

**Cross-reference files to verify against:**
- `docs/story/progression.md` — level milestones (~18 end Act I, ~50 end Interlude, ~70 end Act III), XP targets, party join rule (party_avg - 1), 50% absent XP share
- `docs/story/equipment.md` § Weapons — tier ATK ranges
- `docs/story/bestiary/bosses.md` — boss levels

- [ ] **Step 1: Write Section 4 (Progression Pacing)**

Include:
- 4.1 Expected Level per Area: table with area, act, target level range, boss level, level buffer (0–2 above boss). Cover: Aelhart (1–3), Ember Vein (5–8), Fenmother (10–14), Valdris Siege (14–18), Ley Line Depths (18–22), Ashmark (20–24), Bellhaven (22–26), Interlude (25–50), Pallor Wastes/Act III (50–70), Dreamer's Fault (42–100). Note: critical path without grinding.
- 4.2 Catch-Up Mechanics: party join at avg-1, 50% absent XP, level-up HP/MP restore, Ley Scar grinding zone.
- 4.3 Equipment Progression Curve: table with Tier 0–5 + Forged, act, ATK range, relative power, hours between tiers. Note 70% affordability and ATK² scaling (50% ATK increase → 125% damage increase).

- [ ] **Step 2: Verify level targets match progression.md milestones**

Read `docs/story/progression.md` and confirm: End Act I ~18, End Interlude ~50, End Act III ~70. Verify these match the area table.

- [ ] **Step 3: Commit**

```bash
git add docs/story/difficulty-balance.md
git commit -m "docs(shared): add progression pacing to difficulty-balance.md"
```

---

### Task 5: Anti-Frustration Features

**Files:**
- Modify: `docs/story/difficulty-balance.md`

**Context:** Auto-save, save point density, flee reliability, no missable content, party wipe recovery.

**Cross-reference files to verify against:**
- `docs/story/events.md` § Faint and Fast Reload — instant reload, no game over screen, XP/gold preserved
- `docs/story/combat-formulas.md` § Flee Formula — `50 + (party_avg_SPD - enemy_avg_SPD) × 2`, min 10%, max 90%
- `docs/story/combat-formulas.md` — Smokeveil (Sable, 4 MP, 100% flee), Smoke Bomb (100g, 100% flee)
- `docs/story/equipment.md` — Ward Talisman (1,500g, ×0.5 encounters), Infiltrator's Cloak (×0.5, treasure)

- [ ] **Step 1: Write Section 5 (Anti-Frustration Features)**

Include:
- 5.1 Auto-Save (Invisible): triggers (dungeon floor, pre-boss, town, quest complete). Dedicated slot separate from 3 manual slots. No UI. Relationship to Faint-and-Fast-Reload (loads most recent save, manual or auto). Does NOT: save mid-floor, save during boss, overwrite manual saves.
- 5.2 Save Point Density: table by area type (towns, short/medium/long dungeons, overworld). Rule: never more than 10–15 minutes from a save point.
- 5.3 Flee Reliability: full formula with ×2 multiplier, min/max, Smoke Bomb (100g, 100%), Smokeveil (Sable 4 MP, 100%), Ward Talisman (1,500g ×0.5), Infiltrator's Cloak (×0.5 treasure). Boss: flee disabled.
- 5.4 No Missable Content: all side quests available until point of no return (Convergence gauntlet), explicit NPC warnings, Oasis C completable before fall, Dreamer's Fault post-game.
- 5.5 Party Wipe Recovery: per events.md — NO game over screen, instant reload to save point (~4s), XP/gold/levels preserved, HP/MP set to 100%, boss cutscenes auto-skip on retry.

- [ ] **Step 2: Verify Smokeveil is correct (NOT Sable's Coin)**

Read `docs/story/combat-formulas.md` and confirm: Smokeveil = 100% flee (Sable, 4 MP). Sable's Coin = preemptive strike (NOT flee).

- [ ] **Step 3: Verify Faint-and-Fast-Reload rules**

Read `docs/story/events.md` § Faint and Fast Reload and confirm: no menu, no prompt, instant reload, XP/gold preserved, HP/MP 100%, boss cutscene skip flag.

- [ ] **Step 4: Commit**

```bash
git add docs/story/difficulty-balance.md
git commit -m "docs(shared): add anti-frustration features to difficulty-balance.md"
```

---

### Task 6: Difficulty Escalation and Balance Methodology

**Files:**
- Modify: `docs/story/difficulty-balance.md`

**Context:** Per-act difficulty escalation and the validation methodology for verifying balance.

**Cross-reference files to verify against:**
- `docs/story/bestiary/` — enemy complexity by act
- `docs/story/economy.md` — affordability rates per act
- `docs/story/combat-formulas.md` — all damage/healing/flee formulas

- [ ] **Step 1: Write Section 6 (Difficulty Escalation by Act)**

Include:
- 6.1 Act I — Learning: low stats, simple patterns, abundant resources, low threat
- 6.2 Act II — Expanding: status effects introduced, 2-phase bosses, party splits, moderate threat
- 6.3 Interlude — Pressure: Pallor Infection, Kole difficulty spike, tighter economy, party rebuilding
- 6.4 Act III — The Gauntlet: Pallor Wastes high encounter rate, Despair common, limited Oases, full mechanical complexity
- 6.5 Post-Game — Optional Challenge: Dreamer's Fault (Lv 42–100), superbosses, no difficulty toggle needed

- [ ] **Step 2: Write Section 7 (Balance Validation Methodology)**

Include:
- 7.1 Damage Sanity Checks: physical dealt/received, magic dealt, healing output formulas
- 7.2 Boss Duration Check: formula with ATB-aware actions_per_second calculation, worked example template
- 7.3 Economy Verification: expected gold → equipment cost → 70% affordability → consumable budget
- 7.4 Encounter Rate Sanity Check: encounters per floor, total per dungeon, rare formation stats

- [ ] **Step 3: Write Section 8 (Cross-References)**

Include table with all 13 system references using correct section headings:
- combat-formulas.md § Physical Damage, § Magic Damage, § ATB Gauge System, § Encounter System, § Flee Formula
- progression.md § Character Growth, § Two-Phase XP Curve
- bestiary/ (act files + bosses.md)
- equipment.md § Weapons
- economy.md § Gold Pacing Targets
- events.md § Faint and Fast Reload
- locations.md § Pallor Wastes Oases
- bestiary/optional.md (Dreamer's Fault)

- [ ] **Step 4: Commit**

```bash
git add docs/story/difficulty-balance.md
git commit -m "docs(shared): add difficulty escalation and balance methodology"
```

---

## Chunk 3: Gap Update and Final Verification

### Task 7: Update Gap Analysis and Final Verification

**Files:**
- Modify: `docs/story/difficulty-balance.md` (final read-through)
- Modify: `docs/analysis/game-design-gaps.md`

**Context:** Mark Gap 3.4 as COMPLETE and verify the entire document against canonical sources.

- [ ] **Step 1: Full document verification**

Re-read the entire `docs/story/difficulty-balance.md` and verify:
- Vein Guardian HP = 6,000 (not 12,000)
- Smokeveil for flee (not Sable's Coin)
- Faint-and-Fast-Reload: no game over screen, instant reload
- Hi-Potion = Act II (not Act I)
- Act III levels = 50–70 (not 32–38)
- Flee formula includes ×2 multiplier
- All cross-references point to real sections
- No "Crit%" (should be "CRIT%")
- Ward Talisman price = 1,500g

- [ ] **Step 2: Update gap analysis**

In `docs/analysis/game-design-gaps.md`:
- Change Gap 3.4 status from MISSING to COMPLETE
- Check off all 6 checklist items
- Add completion date (2026-03-26)
- Add progress tracking row
- Note what this enables (balance validation for all existing systems)

- [ ] **Step 3: Commit**

```bash
git add docs/story/difficulty-balance.md docs/analysis/game-design-gaps.md
git commit -m "docs(shared): complete difficulty-balance.md and mark Gap 3.4 COMPLETE"
```
