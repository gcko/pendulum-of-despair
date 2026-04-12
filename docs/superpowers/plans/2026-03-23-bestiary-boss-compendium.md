# Boss Compendium Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `docs/story/bestiary/bosses.md` with all 29 combat bosses + 1 siege appendix, complete with AI behavior scripts, then trim act-file Boss Notes to stubs.

**Architecture:** Single markdown file organized by act (narrative order). Each boss section has: stat table row(s), AI script block (modes/priorities/counters/events), and cross-references. Act files retain stat rows but lose Boss Notes prose.

**Tech Stack:** Markdown documentation only. No code changes.

**Spec:** `docs/superpowers/specs/2026-03-23-bestiary-boss-compendium-design.md`

---

## Chunk 1: Foundation + Act I–II + Interlude

### Task 1: Create bosses.md Skeleton

**Files:**
- Create: `docs/story/bestiary/bosses.md`

**Context:** This task creates the file structure, header, AI Script Format Reference (condensed from spec Section 1), and the full Quick Reference table for all 29 bosses + siege appendix.

- [ ] **Step 1: Read source files for Quick Reference data**

Read these files to extract boss name, act, location, level, HP, type for every boss:
- `docs/story/bestiary/act-i.md` (boss stat rows)
- `docs/story/bestiary/act-ii.md` (boss stat rows)
- `docs/story/bestiary/interlude.md` (boss stat rows)
- `docs/story/bestiary/act-iii.md` (boss stat rows)
- `docs/story/bestiary/optional.md` (boss stat rows)

- [ ] **Step 2: Write the header, AI Script Format Reference, and Quick Reference table**

Create `docs/story/bestiary/bosses.md` with:
1. Title and blockquote matching spec Section 3.1
2. AI Script Format Reference section — condense spec Section 1 into a reader's guide covering: Modes/Stances, Conditional Priority Lists, Counter Tables, Scripted Events. Include the condition types list and target selection types. This is the "how to read boss scripts" section.
3. Quick Reference table with all 30 rows (29 combat + 1 siege):

```markdown
| # | Name | Act | Location | Lv | HP | Type | Phases | Modes |
```

Populate from the stat rows read in Step 1. Use exact names/HP/levels from the act files (authoritative). Vaelith (Siege) is the last row, marked with `*` footnote.

4. Section headers for all act groups (Act I, Act II, Interlude, Act III with sub-sections, Post-Game, Appendix) — empty, to be filled by subsequent tasks.

- [ ] **Step 3: Verify Quick Reference table**

Cross-check every row against the act file stat tables:
- Boss names match exactly (including italics for boss-type)
- HP values match act file stat rows
- Levels match act file stat rows
- Types match act file stat rows
- Phase counts match spec Section 4 roster tables

- [ ] **Step 4: Commit**

```bash
git add docs/story/bestiary/bosses.md
git commit -F /tmp/commit-msg.txt
# Message: "docs(shared): create bosses.md skeleton with AI format reference and quick reference table"
```

---

### Task 2: Act I Bosses (4)

**Files:**
- Modify: `docs/story/bestiary/bosses.md`

**Context:** 4 bosses — Ember Drake, Vein Guardian, Drowned Sentinel, Corrupted Fenmother. These are intro bosses that teach basic boss mechanics. Source data in `act-i.md` Boss Notes and `dungeons-world.md`.

**Stat computation:** Use boss multipliers from README.md:
- Boss_ATK = floor(floor(Lv × 1.6 + 8) × 1.5)
- Boss_DEF = floor(floor(Lv × 1.2 + 5) × 1.3)
- Boss_MAG = floor(floor(Lv × 1.4 + 6) × 1.8)
- Boss_MDEF = floor(floor(Lv × 1.0 + 4) × 1.5)
- Boss_SPD = floor(floor(Lv × 0.8 + 8) × 1.2)
- HP = hand-tuned (from act file / dungeons-world.md)
- MP = floor(Lv × 3.5) for casters, 0 for physical-only

- [ ] **Step 1: Read source files**

Read `docs/story/bestiary/act-i.md` (Boss Notes section) and search `docs/story/dungeons-world.md` for Ember Vein and Fenmother's Hollow boss encounters.

- [ ] **Step 2: Write Ember Drake (Mini-Boss) section**

Single-mode boss, no counters. Beast type, Lv 8.

```markdown
### Ember Drake (Mini-Boss)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
```

Copy the stat row from act-i.md (authoritative).

AI Script:
- 1 Mode: Normal
- Priority list: Flame Breath (charge telegraph) → Tail Swipe → Pounce (back-row)
- No counters
- Scripted events: None (simple intro boss)

- [ ] **Step 3: Write Vein Guardian section**

Two-mode boss (Normal, Enraged), no counters. Boss type, Lv 12, 6,000 HP.

Copy stat row from act-i.md.

AI Script:
- 2 Modes: Normal (100–50% HP), Enraged (below 50% HP)
- Normal priority: Crystal Slam (telegraphed) → Ember Pulse (AoE, floor glow warning)
- Scripted event at 50% HP: Reconstruct (pauses 1 turn, regenerates 300 HP, one-time)
- Enraged mode: same abilities, faster (SPD +20%), more aggressive targeting
- No counters

- [ ] **Step 4: Write Drowned Sentinel (Mini-Boss) section**

Two-mode boss (Normal, Shield), no counters. Construct type, Lv 10, 4,000 HP.

Copy stat row from act-i.md.

AI Script:
- 2 Modes: Normal, Shield (every 4th turn, enters Shield for 2 turns)
- Normal priority: Stone Slam (heavy single) → Frost Wave (AoE Frost)
- Shield mode: Barnacle Shield active (DEF +100%), only uses Frost Wave
- No counters (Shield is a mode, not a reactive counter)
- Construct immunities: Poison, Sleep, Confusion, Berserk, Despair

- [ ] **Step 5: Write Corrupted Fenmother section**

Complex boss — 3 modes (Surface, Dive, Cleansing), counter (untargetable dive). Multi-row: Surface/Dive phase + Cleansing phase. Boss type, Lv 12, 18,000 HP.

Copy stat rows from act-i.md (two rows if they exist, or create the split).

AI Script:
- Phase 1 (18,000–9,000 HP): Alternates Surface/Dive modes
  - Surface: Tail Sweep (AoE physical), Water Jet (single magic)
  - Dive: Untargetable. Spawns poisoned water pools. Auto-returns to Surface after 2 turns.
- Phase 2 (at 9,000 HP): Summons 2 Corrupted Spawn. Dive/surface continues with increased aggression.
- Phase 3 (at 0 HP): Cleansing Sequence (separate encounter). Torren channels while party defends. 4 waves:
  - Wave 1: 4 Marsh Serpents + 2 Polluted Elementals
  - Wave 2: 3 Ley Jellyfish + 2 Drowned Bones + 1 Polluted Elemental
  - Wave 3: 2 Polluted Elementals + 3 Marsh Serpents + 1 Ley Jellyfish
  - Wave 4: 3 Corrupted Spawn (stronger, target Torren)
- Scripted events: Phase transitions (Spirit-Bound Spear is in F2 chest, not a boss drop)

- [ ] **Step 6: Verify Act I boss data**

Cross-check every stat value against act-i.md. Verify:
- HP, ATK, DEF, MAG, MDEF, SPD match act-i.md stat rows exactly
- Elemental profiles (Weak, Resists, Absorbs) match
- Status immunities match (including type defaults from README.md)
- Gold/Exp values are within Act I guidelines (200–1,500 Gold, 500–3,000 Exp)
- Ability names match dungeons-world.md descriptions

- [ ] **Step 7: Commit**

```bash
git add docs/story/bestiary/bosses.md
git commit -F /tmp/commit-msg.txt
# Message: "docs(shared): add Act I boss AI scripts (Ember Drake, Vein Guardian, Drowned Sentinel, Corrupted Fenmother)"
```

---

### Task 3: Act II Bosses (3)

**Files:**
- Modify: `docs/story/bestiary/bosses.md`

**Context:** 3 bosses — Ley Colossus, Forge Warden, Ashen Ram. These introduce complex mechanics (magic immunity, character interactions, siege warfare). Source data in `act-ii.md` Boss Notes and `dungeons-world.md` / `dungeons-city.md`.

- [ ] **Step 1: Read source files**

Read `docs/story/bestiary/act-ii.md` (Boss Notes section) and search dungeon files for Ley Line Depths F3, Ashmark Factory Depths, and Valdris Siege encounters.

- [ ] **Step 2: Write Ley Colossus (Mini-Boss) section**

Two-mode boss (Whole, Shattered), with counter (absorbs all magic). Elemental type, Lv 22, 7,000 HP.

Copy stat row from act-ii.md.

AI Script:
- 2 Modes: Whole (7,000–3,500 HP), Shattered (below 3,500 HP)
- Whole mode priority: Crystal Fists (heavy single physical) → Ley Pulse (AoE magic, 1-turn charge, chest glow tell)
- Counter: If hit by ANY magic → Absorb (heal 100% of damage dealt). All 7 elements absorbed per Elemental type.
- Shattered mode: Gains Prism Beam (single-target high magic, 1-turn warning beam). Loses Ley Pulse. Physical vulnerability increases.
- Scripted event at 50%: Shatters and reforms smaller/faster (visual, mode transition)

- [ ] **Step 3: Write The Forge Warden section**

Two-mode boss (Programmed, Corrupted), no counters. Boss type, Lv 24, 8,500 HP.

Copy stat row from act-ii.md.

AI Script per dungeons-city.md (Ashmark Factory Depths):
- Phase 1 (Programmed Defense, 8,500–4,250 HP):
  - Priority: Ley Bolt (350–400 single) → Shield Protocol (1,000 absorb, 4-turn CD) → Containment Pulse (250–300 AoE + pushback + zone) → Pipeline Drain (heal 500 HP, Lira Forgewright disables)
- Phase 2 (Corrupted Logic, below 4,250 HP):
  - All Phase 1 with semi-random targeting
  - Priority additions: Overload Beam (500–600 line AoE, 2-turn charge, interruptible with 800+ physical) → System Failure (random 1-turn freeze)
  - Scripted event below 20%: Emergency Protocol (3-turn self-destruct, Lira Override aborts)
- Character interactions: Lira Forgewright deals 150% damage, can disable Pipeline Drain and abort Emergency Protocol

- [ ] **Step 4: Write The Ashen Ram section**

Three-mode boss (Ranged, Breach, Core), no counters. Boss type, Lv 22, 25,000 HP.

Copy stat row from act-ii.md.

AI Script per dungeons-world.md (Valdris Siege):
- Pre-fight gauntlet waves (scripted events, not AI):
  - Wave 1: 4 Compact Soldiers + 2 Engineers
  - Wave 2: 3 Soldiers + 2 Siege Ballista
  - Wave 3: 2 Gyrocopters + 2 Soldiers → breather → Ram breaches wall
- Mode 1 (Ranged, 25,000–15,000 HP):
  - Battering Advance, Despair Pulse (passive MP drain), Compact Escalade (soldier reinforcements), Lord Haren's Orders (conditional)
- Mode 2 (Breach, 15,000–7,500 HP):
  - Drill Arm, Pallor Shrapnel, Engine Surge (knockback)
- Mode 3 (Core, below 7,500 HP):
  - Despair Pulse (active), Core Overload (interruptible charge). Core vulnerable to Flame.
- NPC: Dame Cordwyn (5,000 HP) fights alongside throughout.

- [ ] **Step 5: Verify Act II boss data**

Same verification as Task 2 Step 6 but for Act II. Gold/Exp within Act II guidelines (1,500–4,000 Gold, 3,000–8,000 Exp).

- [ ] **Step 6: Commit**

```bash
git add docs/story/bestiary/bosses.md
git commit -F /tmp/commit-msg.txt
# Message: "docs(shared): add Act II boss AI scripts (Ley Colossus, Forge Warden, Ashen Ram)"
```

---

### Task 4: Interlude Bosses (5)

**Files:**
- Modify: `docs/story/bestiary/bosses.md`

**Context:** 5 bosses — Corrupted Boring Engine, The Ironbound, The Undying Warden, Pallor Nest Mother, General Vassar Kole. Mix of war machines, optional bosses, and the Interlude's climax. Sources: `interlude.md`, `dungeons-world.md`, `dungeons-city.md`.

- [ ] **Step 1: Read source files**

Read `docs/story/bestiary/interlude.md` (Boss Notes section) and dungeon files for Rail Tunnels, Valdris Crown Catacombs, Caldera Undercity, and Axis Tower/Ironmark encounters.

- [ ] **Step 2: Write Corrupted Boring Engine (Mini-Boss) section**

Two-mode boss (Drilling, Exposed), no counters. Construct type, Lv 22, 6,000 HP.

Copy stat row from interlude.md.

AI Script:
- 2 Modes: Drilling (default), Exposed (after back attack or every 5th turn for 1 turn)
- Drilling mode: Charge (line AoE, telegraphed), Area Slam (party-wide)
- Exposed mode: Arcanite core targetable. Physical attacks deal +50% damage. Boss only uses weak melee.
- No counters. Construct immunities.

- [ ] **Step 3: Write The Ironbound section**

Two-mode boss (Relentless, Hesitant), no counters. Boss type, Lv 24, 22,000 HP.

Copy stat row from interlude.md.

AI Script per dungeons-world.md (Rail Tunnels):
- Mode 1 (Relentless, 22,000–11,000 HP):
  - Priority: Drill Charge (400–500, 1-turn wind-up, positional) → Steam Vent (cone AoE, 200–250 + Burn 3 turns) → Tunnel Collapse (300 + Slow, zone rearrange) → Bore Forward (push party, 150 bonus if against wall)
- Mode 2 (Hesitant, below 11,000 HP):
  - All Phase 1 attacks with random hesitation windows (1-turn pauses)
  - Desperate Bore (double charge, no wind-up) when operator's voice is strongest
- Character interactions:
  - Lira: Recognizes Drayce-series frame. Forgewright deals bonus 500 during hesitation windows.
  - Torren: Spiritcall during hesitation deals 400 bonus + reduces next attack damage 50%.
- Scripted event at 0 HP: Operator's spirit speaks partner's name, goes still.

- [ ] **Step 4: Write The Undying Warden (Optional) section**

Two-mode boss (Spectral, Eruption), no counters. Boss type, Lv 25, 8,000 HP.

Copy stat row from interlude.md.

AI Script per dungeons-city.md (Valdris Crown Catacombs):
- Mode 1 (Spectral, 100–50% HP):
  - Physical attacks with spectral swords + ley-crystal shards
- Mode 2 (Eruption, below 50% HP):
  - Ley-Crystal Eruptions (AoE magic from floor), erratic movement
- Scripted event: If Torren in party, "Calm" command available. Changes defeat dialogue from rage to gratitude.
- Defeat: "Finally. Rest." (calmed) or "You... are not... the enemy..." (not calmed)

- [ ] **Step 5: Write Pallor Nest Mother (Optional) section**

Single-mode boss, no counters. Boss type, Lv 25, 6,000 HP.

Copy stat row from interlude.md.

AI Script per dungeons-city.md (Caldera Undercity):
- 1 Mode: Normal (spawn-focused)
- Priority: Brood Pulse (AoE 200–250 + 20% Despair + spawn 2 Grey Crawlers) → Tendril Lash (2-target, 300 each) → Corruption Surge (3 contaminated zones, 100/turn) → Default: Tendril Lash
- Turn counter: Every 4th turn → Spawn Brood (3 Pallor Mites, 100 HP each)
- Passive: Nest Defense (+50% DEF while any spawn alive)
- Scripted event below 25%: Desperate Contraction (3-turn charge, 600 AoE, interruptible with 1,000+ damage)
- NPC: Kerra (ATK 18, DEF 14, HP 800). If Kerra falls, incapacitated but survives.

- [ ] **Step 6: Write General Vassar Kole section**

Two-mode boss (Commander, Channeling), no counters. Boss type, Lv 28, 30,000 HP.

Copy stat row from interlude.md.

AI Script per dungeons-world.md (Axis Tower/Ironmark):
- Mode 1 (Commander, 100–50% HP):
  - Arcanite sword attacks (single physical, high damage)
  - Turn counter: Every 3rd turn → Summon 2 Pallor Soldiers
  - Scripted event: At 50%, commands 4 Compact Officers: "Let them in" — they willingly corrupt
- Mode 2 (Channeling, below 50% HP):
  - Channels Ironmark conduits: Grey Shockwave (party AoE)
  - Despair Aura (party Despair each turn while conduit crystals active)
  - 2 conduit crystals on arena edges — destroy to remove aura
- Scripted event at 0 HP: Commissar Brant watches silently. Narrative payoff.

- [ ] **Step 7: Verify Interlude boss data**

Cross-check all 5 bosses against interlude.md stat rows and dungeon files. Gold/Exp within Interlude guidelines (2,000–5,000 Gold, 4,000–10,000 Exp). Verify Undying Warden HP (8,000 per bestiary — note if dungeons-city.md says differently).

**Note on General Kole HP discrepancy:** dungeons-world.md prose says 12,000 HP but encounter table says 30,000. The bestiary canonizes 30,000 — verify this is what interlude.md shows and use it.

- [ ] **Step 8: Commit**

```bash
git add docs/story/bestiary/bosses.md
git commit -F /tmp/commit-msg.txt
# Message: "docs(shared): add Interlude boss AI scripts (Boring Engine, Ironbound, Undying Warden, Pallor Nest Mother, General Kole)"
```

---

### Task 5: Act III Trial Bosses (4)

**Files:**
- Modify: `docs/story/bestiary/bosses.md`

**Context:** 4 trial bosses — The Crowned Hollow, The Perfect Machine, The Last Voice, The Index. These are puzzle-bosses with unique resolution mechanics. Source: `act-iii.md`, `dungeons-world.md`.

- [ ] **Step 1: Read source files**

Read `docs/story/bestiary/act-iii.md` (Boss Notes for trial bosses) and search `dungeons-world.md` for Pallor Wastes trial encounters.

- [ ] **Step 2: Write The Crowned Hollow (Edren's Trial) section**

Two-mode boss (Assault, Invulnerable), counter (Royal Guard). Boss type, Lv 30, 8,000 HP.

Copy stat row from act-iii.md.

AI Script:
- Mode 1 (Assault, 8,000–2,000 HP):
  - Priority: Mirror Strike (copies Edren's equipped weapon attack) → Crown's Burden (AoE + ATK reduction)
  - Turn counter: Every 4th turn → Formation Call (summon 2 Hollow Knights, 1,000 HP each, max 2 active)
  - Counter: If hit by physical → Royal Guard (counterattack, 150% ATK)
- Mode 2 (Invulnerable, below 2,000 HP):
  - Weight of Command (500 damage/turn party-wide)
  - Every Name They Carried (Despair on all party)
  - Boss is invulnerable — cannot be killed by damage
- Resolution: Edren must use Defend for 3 consecutive turns to stagger, then defeat.
- Scripted event: Ability unlock — Steadfast Resolve (party-wide defensive buff, cleanses Pallor status effects)

- [ ] **Step 3: Write The Perfect Machine (Lira's Trial) section**

Single-mode boss (Passive), no counters. Boss type, Lv 30, 7,000 HP.

Copy stat row from act-iii.md.

AI Script:
- 1 Mode: Passive (does NOT attack unprovoked)
- No priority list — entirely scripted event chain
- Machine stands in center asking Lira to repair it
- Scripted sequence:
  - If "Repair" selected: adds 1,500 HP + Hopeful Spark (400 damage + dialogue) → False Promise (heals to current HP + 1,500, party-wide 200 damage)
  - High DEF (halves physical)
- Resolution: Lira uses Forgewright → select "Dismantle" (3,500 damage each). Two Dismantles end fight.
- Scripted event: Ability unlock — Latent ability (prerequisite for Cael's weapon manifestation)

- [ ] **Step 4: Write The Last Voice (Torren's Trial) section**

Two-phase boss (Normal, The Request), no counters. Boss type, Lv 32, 6,000 HP.

Copy stat row from act-iii.md.

AI Script:
- Phase 1 (6,000–1,500 HP):
  - Priority: Stone Grasp (350 + Slow) → Silent Scream (AoE 250 + Silence)
  - Passive: Crumbling Form (loses 100 HP/turn — dying regardless)
- Phase 2 (below 1,500 HP — The Request):
  - Speaks clearly: "Let me go."
  - Standard attacks deal reduced damage (50%)
- Resolution: Torren uses Spiritcall → select "Release" (replaces "Call"). One Release ends fight. Spirit dies peacefully — green shoot appears.
- Scripted event: Ability unlock — Rootsong (healing ability restoring HP and MP from ley network)

- [ ] **Step 5: Write The Index (Maren's Trial) section**

Single-mode boss (Catalogue), no counters. Boss type, Lv 32, 7,000 HP.

Copy stat row from act-iii.md.

AI Script:
- 1 Mode: Catalogue (dialogue-based)
- No standard priority list — dialogue-driven
- Scripted sequence:
  - Presents binary choice: Absorb (massive INT buff but 90% max HP damage + permanent Despair) or Destroy (instant party defeat). Neither is correct.
  - If Absorb: Party takes damage, Despair applied, fight continues with weakened party
  - If Destroy: TPK — game over, retry
- Resolution: Select "Read One Entry" (hidden third option, appears when examining Index). Maren reads one person's entry and grieves individually. Index shatters.
- Scripted event: Ability unlock — Pallor Sight (see corruption levels, revealing hidden weaknesses)

- [ ] **Step 6: Verify trial boss data**

Cross-check all 4 trial bosses against act-iii.md and dungeons-world.md. These are puzzle-bosses so verify:
- Resolution mechanics match dungeons-world.md exactly
- Unlock abilities match dungeons-world.md exactly
- HP thresholds are consistent
- Stat values match act-iii.md

- [ ] **Step 7: Commit**

```bash
git add docs/story/bestiary/bosses.md
git commit -F /tmp/commit-msg.txt
# Message: "docs(shared): add Act III trial boss AI scripts (Crowned Hollow, Perfect Machine, Last Voice, Index)"
```

---

## Chunk 2: Act III Story + Post-Game + Cleanup

### Task 6: Act III Story Bosses — Part 1 (5)

**Files:**
- Modify: `docs/story/bestiary/bosses.md`

**Context:** Vaelith, Ley Titan, Archive Keeper, Wellspring Guardian, The Architect + Grey Cleaver Unbound (two-stage fight counted as 2 separate bosses but written together). Sources: `act-iii.md`, `dungeons-world.md`.

- [ ] **Step 1: Read source files**

Read `docs/story/bestiary/act-iii.md` (Boss Notes for these bosses) and search `dungeons-world.md` for Pallor Wastes Section 5, Ley Line Depths F5, Dry Well, and Forgotten Forge encounters.

- [ ] **Step 2: Write Vaelith, the Ashen Shepherd section**

Three-mode boss (Invulnerable, Scholar, Shepherd), no counters. Boss type, **Lv 34**, 50,000 HP. Single stat row.

Copy stat row from act-iii.md (the Lv 34 row, NOT the Lv 150 siege row).

AI Script:
- Pre-Fight Phase (Invulnerable mode):
  - All party attacks deal 0 damage
  - Vaelith attacks 10 times with taunting dialogue
  - Scripted event after 10th attack: Lira's weapon-forging cutscene. Cael's connection manifests. All party can now damage.
  - Mode transition → Scholar
- Mode 2 (Scholar, 50,000–25,000 HP):
  - Priority: Epoch's End (500–600 party AoE) → Grey Archive (700–800 + Silence 3 turns, targets Despair'd member) → Cycle's Weight (stacking ATK/DEF debuff, -10%/stack)
  - Turn counter: Every 4th turn → Temporal Cascade (acts twice this turn)
  - Scripted event at 37,500 HP: Dialogue
- Mode 3 (Shepherd, below 25,000 HP):
  - All Phase 1 attacks + Despair Pulse (400 + Despair, every 3 turns) + Reality Warp (corrupts ley lines, Lira must re-forge weapon — timed input) + Unraveling (targets Lira, 600 damage; below 25% HP reduces party damage 25%)
  - Scripted events: Dialogue at 12,500 HP, dialogue at 5,000 HP
- Character interactions:
  - Lira: Re-forges during Reality Warp
  - Torren: Spiritcall reveals next attack (Phase 2)
  - Maren: Pallor Sight doubles crit rate
  - Sable: Unbreakable Thread prevents forced removal

- [ ] **Step 3: Write Ley Titan section**

Three-mode boss (Whole, Fractured, Condensed), counter in Phase 3 (Resonance). Boss type, Lv 28, 18,000 HP.

Copy stat row from act-iii.md.

AI Script:
- Mode 1 (Whole, 100–60% HP):
  - Priority: Crystal Fist (heavy single physical) → Ley Pulse (AoE magic, 1-turn charge, chest brightening tell) → Confluence Tide (wave across platform, 1-turn telegraph by river brightening, positional)
- Mode 2 (Fractured, 60–30% HP):
  - Fractures into 3 Ley Aspects (Strength, Precision, Endurance) sharing HP pool
  - Kill order matters: Endurance first prevents healing, Precision first prevents burst
  - Each Aspect has its own simple priority list
- Mode 3 (Condensed, 30–0% HP):
  - Reforms human-sized, dense, fast
  - Gains Nexus Flare (party-wide, mitigated near edges)
  - Counter: Resonance — reflects portion of damage on hit. Sustained DPS beats burst.
  - Loses Confluence Tide
- Scripted event at 0 HP: Dims to sphere of light. Touching grants Titan's Core.

- [ ] **Step 4: Write Archive Keeper (Mini-Boss) section**

Single-mode (Puzzle), counter (wrong answer = heal). Boss type, Lv 32, 12,000 HP (variable, see spec Section 2.5).

Copy stat row from act-iii.md.

AI Script:
- 1 Mode: Puzzle
- Pre-combat: Floating geometric form projects 3 pictographic questions
  - Each correct answer reduces HP by 2,000 (minimum 3,000 with all correct + combat reduction)
  - Each wrong answer restores 1,000 HP (maximum 12,000 with all wrong)
  - Counter: Wrong answer → ley blast attack between questions
- Combat priority (after puzzle): Ley Blast (magic, single target)
- Note: HP in stat table = 12,000 (worst case). Variable HP explained in script.

- [ ] **Step 5: Write Wellspring Guardian section**

Three-mode boss (Arms, Knowledge, Resolve), counter (wrong answer = Nexus Pulse). Boss type, Lv 36, 28,000 HP.

Copy stat row from act-iii.md.

AI Script:
- Mode 1 (Arms, 100–60% HP):
  - Priority: Stone Fist (heavy physical) → Geometric Cleave (AoE physical) → Nexus Bolt (single magic)
- Mode 2 (Knowledge, 60–30% HP):
  - Projects 3 pictographic challenges
  - Each correct answer reduces HP by 2,800
  - Counter: Wrong answer → Nexus Pulse (heavy AoE)
  - Does not attack during this mode
- Mode 3 (Resolve, 30–0% HP):
  - Combines physical + magical attacks
  - Splits into geometric form
  - Builder's Weight (Pallor-type attack — heavy Despair-element damage + stacking stat debuff, 5 stacks = Faint)
- Scripted event at 0 HP: Kneels, hand on nexus crystal. "The water flows. The builders rest." Goes dormant.

- [ ] **Step 6: Write The Architect (Stage 1) + Grey Cleaver Unbound (Stage 2) sections**

Two separate bosses in a continuous fight.

**The Architect:** Two-mode (Shielded, Unshielded), no counters. Boss type, Lv 34, 20,000 HP.
**Grey Cleaver Unbound:** Three-mode (Greatsword, Whip, Shield), counter (Shield reflects). Boss type, Lv 36, 25,000 HP.

Copy stat rows from act-iii.md.

The Architect AI Script:
- 3 Ley Anvils (2,000 HP each) act as shields, each absorbing one element (Flame, Storm, Frost)
- Mode 1 (Shielded — while any Anvil alive):
  - 50% damage reduction
  - Priority: Hammer Strike (heavy single) → Molten Spray (party-wide Flame) → Precision Cut (high crit) → Summon Forge Construct adds
  - Attack Anvil with matching element to overload/destroy
- Mode 2 (Unshielded — all Anvils destroyed):
  - Full damage, enraged. Faster attacks, no more summons.

Grey Cleaver Unbound AI Script:
- Cycles between 3 stances every 3 turns:
  - Greatsword: Heavy single-target physical. Highest ATK.
  - Whip: Party-wide attacks. Lower damage + Despair chance.
  - Shield: Counter mode. Reflects all damage. BUT party members with Despair deal +50% bonus damage during this stance.
- Turn counter: Periodically → Weight of Ages (party-wide Despair)
- Counter (Shield stance only): All damage reflected back at attacker
- Strategy note: Do NOT cure Despair during Shield stance — attack through it for massive damage window.

- [ ] **Step 7: Verify all 5 (6 counting both stages) bosses**

Cross-check against act-iii.md and dungeons-world.md. Special attention to:
- Vaelith is Lv 34 (not 150)
- Archive Keeper variable HP notation
- Architect/Grey Cleaver are separate bosses with separate stat rows
- Ley Titan spans Acts II–III dungeon

- [ ] **Step 8: Commit**

```bash
git add docs/story/bestiary/bosses.md
git commit -F /tmp/commit-msg.txt
# Message: "docs(shared): add Act III story boss AI scripts (Vaelith, Ley Titan, Archive Keeper, Wellspring Guardian, Architect, Grey Cleaver)"
```

---

### Task 7: Act III Story Bosses — Part 2 (3) + Appendix

**Files:**
- Modify: `docs/story/bestiary/bosses.md`

**Context:** Pallor Echo, Cael (multi-row), Pallor Incarnate, plus the Vaelith (Siege) appendix entry. These are the Convergence bosses — the game's climax. Source: `act-iii.md`, `dungeons-world.md`.

- [ ] **Step 1: Read source files**

Read `docs/story/bestiary/act-iii.md` (Boss Notes for Convergence bosses) and search `dungeons-world.md` for Convergence encounters.

- [ ] **Step 2: Write Pallor Echo (Mini-Boss) section**

Single-mode boss (Shadow), no counters. Boss type, Lv 34, 5,000 HP.

Copy stat row from act-iii.md.

AI Script:
- 1 Mode: Shadow (reduced version of Cael Phase 1)
- Priority: Uses Cael's Phase 1 moveset at reduced power
- Context: Part of Convergence Phase 4 gauntlet (Wave 4 of Door survival):
  - Wave 1: 6 Hollow Walkers
  - Wave 2: 4 Despair Clouds + 2 Pallor Knights
  - Wave 3: 3 Grief Shades (mimic party members)
  - Wave 4: Pallor Echo
- Scripted event: Cael's shadow — complete identity consumed by Grey

- [ ] **Step 3: Write Cael, Knight of Despair section (multi-row)**

Two stat rows. Counter in Phase 1 (last-attacker). Boss type.

Copy BOTH stat rows from act-iii.md:
- Phase 1: Lv 36, 45,000 HP
- Phase 2: Lv 38, 35,000 HP

Phase 1 (Calculated mode, 45,000 HP):
- Uses enhanced versions of party abilities
- Counter: Counters whoever attacked last (reactive targeting)
- Scripted events at HP thresholds:
  - At 75%: Despair Pulse
  - At 50%: Shadow Step (disappears, reappears behind random member, critical strike)
  - At 25%: Invulnerability + dialogue "I'm doing this for you."
  - At 0%: Staggers, Pallor surges through him → phase transition

Phase 2 (Pallor mode, 35,000 HP):
- Full Pallor aggression. No more calculated counters.
- Priority: Pallor Rend (600–700, ignores 25% DEF) → Grey Tide (AoE 400–500 + Despair)
- Scripted event at 50%: "I can still hear you. That makes it worse."
- Scripted event at 0%: Cael falls. Machine activates. Anchor destruction phase begins.

- [ ] **Step 4: Write The Pallor Incarnate section**

Two-mode boss (Conduit, Exposed), counter (conduit regen). Boss type, Lv 40, 70,000 HP.

Copy stat row from act-iii.md.

AI Script:
- Mode 1 (Conduit — while any conduit crystal active):
  - 4 conduit crystals (3,000 HP each, 500 HP/turn regen each)
  - Boss regenerates 2,000 HP/turn total while conduits active
  - Priority: Grey Cascade (party-wide heavy magic) → Hollow Voice (targets one member with personalized despair dialogue, inflicts Despair) → Reality Tear (removes one member from battle 2 turns)
- Mode 2 (Exposed — all conduits destroyed):
  - Regen stops, defense drops 50%
  - Same attacks, more aggressive
- Scripted event at 50%: Despair Tide (arena shrinks, less room)
- Scripted event at 25%: Cael briefly speaks: "Lira..." (emotional moment, not attack)
- Scripted event at 0%: Pallor weakened but not destroyed. Cael partially freed. Story continues.
- "What the Stars Said" bonus: If all 4 trials complete → ley line resonance activates. Defense drops additional 25%, Hollow Voice fails vs. trial Resolve-buffed members.

- [ ] **Step 5: Write Appendix — Vaelith (Siege) entry**

Copy the Lv 150 / 999,999 HP stat row from act-iii.md.

Note: Not a real combat encounter. Scripted loss after ~5 turns. 0 Gold, 0 Exp. Party attacks deal 0–1 damage. After ~5 party turns, cutscene triggers.

- [ ] **Step 6: Verify Convergence bosses + appendix**

Cross-check against act-iii.md. Special attention to:
- Cael has TWO stat rows with different levels, HP, and resistances
- Pallor Incarnate conduit crystal HP and regen rates match dungeons-world.md
- Vaelith (Siege) stat row matches the existing row in act-iii.md exactly
- "What the Stars Said" bonus mechanic matches dungeons-world.md

- [ ] **Step 7: Commit**

```bash
git add docs/story/bestiary/bosses.md
git commit -F /tmp/commit-msg.txt
# Message: "docs(shared): add Convergence boss AI scripts (Pallor Echo, Cael, Pallor Incarnate) and Vaelith Siege appendix"
```

---

### Task 8: Post-Game Echo Bosses (4)

**Files:**
- Modify: `docs/story/bestiary/bosses.md`

**Context:** 4 Echo Bosses — The First Scholar, The Crystal Queen, The Rootking, The Iron Warden. Each tests a combat discipline. Source: `optional.md`.

- [ ] **Step 1: Read source files**

Read `docs/story/bestiary/optional.md` (Echo Boss Notes section).

- [ ] **Step 2: Write The First Scholar (Echo Boss) section**

Two-mode boss (Pattern, Accelerated), no counters. Boss type, Lv 50, 40,000 HP.

Copy stat row from optional.md.

AI Script:
- Mode 1 (Pattern, 40,000–20,000 HP):
  - Fixed spell rotation (4-spell cycle): Glyph of Flame → Glyph of Frost → Glyph of Storm → Glyph of Void
  - Each glyph telegraphs 1 turn in advance
  - Moderate damage per glyph
- Mode 2 (Accelerated, below 20,000 HP):
  - Same rotation, 2 spells per turn (rotation doubles speed)
- Strategy: Pattern recognition test. Pre-buff against next element.

- [ ] **Step 3: Write The Crystal Queen (Echo Boss) section**

Two-mode boss (Unified, Shattered), no counters (reflection is a mode mechanic, not a counter). Boss type, Lv 60, 60,000 HP.

Copy stat row from optional.md.

AI Script:
- Mode 1 (Unified, 60,000–30,000 HP):
  - Crystal Shards (physical, single target) → Prismatic Beam (magic, single target)
  - Scripted event at 50%: Reflection activates — all single-target damage reflected back. Only AoE and multi-target bypass. Healing the Queen damages her (reversed).
- Mode 2 (Shattered, below 30,000 HP):
  - Shatters into 4 Crystal Aspects (15,000 HP shared? or each?). Per optional.md: "15,000 HP each"
  - Each Aspect reflects a different element. Kill all 4 to end.
- Strategy: Party composition and AoE strategy test.

- [ ] **Step 4: Write The Rootking (Echo Boss) section**

Two-mode boss (Rooted, Desperate), no counters. Boss type, Lv 72, 80,000 HP.

Copy stat row from optional.md.

AI Script:
- Mode 1 (Rooted, 80,000–40,000 HP):
  - Regenerates 2,000 HP/turn
  - Turn counter: Every 3rd turn → Summon Root Weavers
  - Turn counter: Every 5th turn → Root Anchor appears for 2 turns (10,000 HP). Destroying it stops regen for that window.
  - Priority: Root Crush (heavy physical) → Bark Shield (DEF buff) → Vine Lash (multi-target)
- Mode 2 (Desperate, below 40,000 HP):
  - Regen doubles to 4,000 HP/turn
  - Summons every 2 turns, Root Anchor every 4 turns
  - More aggressive priority
- Strategy: Sustained DPS and add management. Destroy Root Anchor during its brief appearance.

- [ ] **Step 5: Write The Iron Warden (Echo Boss) — True Final Boss section**

Three-mode boss (Disciplined, Reinforced, Overclocked), counter (strict pattern). Boss type, Lv 86, 100,000 HP.

Copy stat row from optional.md.

AI Script:
- Mode 1 (Disciplined, 100,000–50,000 HP):
  - Strict counter pattern: Physical attacks → countered. Magic → triggers shield absorbing next magic.
  - Rewards disciplined alternation between physical and magic.
  - Priority: Piston Strike (heavy physical) → Arc Discharge (single magic) → Calibrated Sweep (AoE physical)
- Mode 2 (Reinforced, 50,000–25,000 HP):
  - Summons 2 Gear Wraiths
  - Counter pattern applies to summons too — wrong target triggers party-wide counterattack
  - Priority adds: Gear Grind (AoE from summons) → Overclock Pulse (self-buff, SPD +50%)
- Mode 3 (Overclocked, below 25,000 HP):
  - 2 actions per turn
  - Counter window shrinks (less time between counter-eligible actions)
  - Machine failing — sparking, overheating visual effects
  - Priority: Emergency Protocol (heavy AoE, 1-turn charge) → all previous attacks at increased speed
- Strategy: Tactical discipline under escalating pressure. THE true final boss.

- [ ] **Step 6: Verify Echo Boss data**

Cross-check against optional.md. Special attention to:
- Gold ≤ 10,000, Exp ≤ 30,000 hard ceilings
- HP values match optional.md (40K, 60K, 80K, 100K)
- Levels match optional.md (50, 60, 72, 86)
- Stats computed correctly from boss formulas

- [ ] **Step 7: Commit**

```bash
git add docs/story/bestiary/bosses.md
git commit -F /tmp/commit-msg.txt
# Message: "docs(shared): add Post-game Echo Boss AI scripts (First Scholar, Crystal Queen, Rootking, Iron Warden)"
```

---

### Task 9: README Update + Act File Stub Migration

**Files:**
- Modify: `docs/story/bestiary/README.md`
- Modify: `docs/story/bestiary/act-i.md`
- Modify: `docs/story/bestiary/act-ii.md`
- Modify: `docs/story/bestiary/interlude.md`
- Modify: `docs/story/bestiary/act-iii.md`
- Modify: `docs/story/bestiary/optional.md`

- [ ] **Step 1: Update README.md boss HP range**

Change the HP description from `6,000-70,000` to `1,500–100,000` to reflect mini-boss floors and post-game ceilings. Also update the bosses.md index entry if not already present.

- [ ] **Step 2: Add bosses.md to README.md Index table**

The Index table already has a row for `bosses.md` (from the README read earlier: `| [bosses.md](bosses.md) | All Bosses & Mini-Bosses with AI Scripts (TBD) |`). Update to remove "(TBD)":

```markdown
| [bosses.md](bosses.md) | All Bosses & Mini-Bosses with AI Scripts (29 combat + 1 siege) |
```

- [ ] **Step 3: Trim act-i.md Boss Notes**

Replace the full Boss Notes section with stub format per spec Section 3.2:
```markdown
### Boss Notes

For full AI scripts, phase mechanics, and scripted events, see
[bosses.md](bosses.md).

- **Ember Drake** (Mini-Boss) — Lv 8, 1,500 HP, Beast. 1 phase.
- **Vein Guardian** — Lv 12, 6,000 HP, Boss. 2 phases.
- **Drowned Sentinel** (Mini-Boss) — Lv 10, 4,000 HP, Construct. 1 phase.
- **Corrupted Fenmother** — Lv 12, 18,000 HP, Boss. 3 phases.
```

**IMPORTANT:** Keep the boss stat table ROWS in the act file. Only remove the Boss Notes prose sections (the `####` subsections with phase descriptions, ability lists, etc.).

- [ ] **Step 4: Trim act-ii.md Boss Notes**

Same pattern. 3 bosses:
- **Ley Colossus** (Mini-Boss) — Lv 22, 7,000 HP, Elemental. 2 phases.
- **The Forge Warden** — Lv 24, 8,500 HP, Boss. 2 phases.
- **The Ashen Ram** — Lv 22, 25,000 HP, Boss. 3 phases.

- [ ] **Step 5: Trim interlude.md Boss Notes**

Same pattern. 5 bosses:
- **Corrupted Boring Engine** (Mini-Boss) — Lv 22, 6,000 HP, Construct. 1 phase.
- **The Ironbound** — Lv 24, 22,000 HP, Boss. 2 phases.
- **The Undying Warden** (Optional) — Lv 25, 8,000 HP, Boss. 2 phases.
- **Pallor Nest Mother** (Optional) — Lv 25, 6,000 HP, Boss. 1 phase.
- **General Vassar Kole** — Lv 28, 30,000 HP, Boss. 2 phases.

- [ ] **Step 6: Trim act-iii.md Boss Notes**

Same pattern. 13 bosses (longest list). Include the Vaelith (Siege) note since that stat row is in act-iii.md too:
- List all 13 combat bosses + note about Vaelith (Siege) appendix entry

**Special attention:** act-iii.md has the most extensive Boss Notes (trial bosses, Vaelith, Convergence). Read the ENTIRE Boss Notes section before editing to ensure nothing is lost that should be preserved.

- [ ] **Step 7: Trim optional.md Boss Notes**

Same pattern. 4 Echo Bosses:
- **The First Scholar** (Echo Boss) — Lv 50, 40,000 HP, Boss. 2 phases.
- **The Crystal Queen** (Echo Boss) — Lv 60, 60,000 HP, Boss. 2 phases.
- **The Rootking** (Echo Boss) — Lv 72, 80,000 HP, Boss. 2 phases.
- **The Iron Warden** (Echo Boss) — Lv 86, 100,000 HP, Boss. 3 phases.

- [ ] **Step 8: Verify stub migration**

For each act file:
- Boss stat table ROWS still present in the file (not deleted)
- Boss Notes section is now a stub with cross-reference link
- No orphaned markdown headers or dangling references
- All boss names in stubs match exactly the names in bosses.md

- [ ] **Step 9: Commit**

```bash
git add docs/story/bestiary/README.md docs/story/bestiary/act-i.md docs/story/bestiary/act-ii.md docs/story/bestiary/interlude.md docs/story/bestiary/act-iii.md docs/story/bestiary/optional.md
git commit -F /tmp/commit-msg.txt
# Message: "docs(shared): update README HP range, trim act file Boss Notes to stubs referencing bosses.md"
```

---

### Task 10: Gap Analysis + CONTINUATION.md + Adversarial Verification

**Files:**
- Modify: `docs/analysis/game-design-gaps.md`
- Modify: `docs/story/bestiary/CONTINUATION.md`

- [ ] **Step 1: Run adversarial verification on bosses.md**

Full verification pass per spec Section 7 (Cross-Reference Sources):

1. **Stat consistency:** For every boss, verify ATK/DEF/MAG/MDEF/SPD match the formula: base_stat(level) × boss_multiplier. Use the verification table in spec Section 5.
2. **HP consistency:** Every boss HP matches dungeons-world.md or dungeons-city.md (authoritative). If any mismatch, dungeon file wins.
3. **Elemental profiles:** Weak/Resists/Absorbs match act file stat rows exactly.
4. **Status immunities:** Include type defaults (e.g., Construct = Poison/Sleep/Confusion/Berserk/Despair) plus Boss defaults (Death/Petrify/Stop/Sleep/Confusion).
5. **Gold/Exp:** All within guidelines. Gold ≤ 10,000, Exp ≤ 30,000 hard ceiling.
6. **Name uniqueness:** No duplicate boss names across all bestiary files.
7. **Phase mechanics:** HP thresholds are arithmetically consistent (e.g., if Phase 2 starts at 50% of 18,000, that's 9,000 — verify this is what the script says).
8. **Ability names:** Every ability referenced in AI scripts exists in dungeons-world.md or dungeons-city.md.
9. **Quick Reference table:** Every row matches the detailed section below it.
10. **Act file stubs:** Each stub line matches the corresponding boss's actual stats.

- [ ] **Step 2: Fix any issues found**

Fix discrepancies. Re-read the entire section around each fix (full-section re-read, not just ±10 lines).

- [ ] **Step 3: Update CONTINUATION.md**

Update Sub-project 4 status to COMPLETE. Update "Last updated" date to 2026-03-23.

- [ ] **Step 4: Update gap analysis**

In `docs/analysis/game-design-gaps.md`, update Gap 1.3:
- Check off remaining checklist items (Boss stat sheets, AI behavior scripts, HP thresholds, phase-specific ability sets, immunity lists, scripted events)
- Update status from PARTIAL to COMPLETE (if all items are done)
- Add completion date and commit reference
- Update the "Files" field to include `bosses.md`
- Check if this completion unblocks any downstream gaps

- [ ] **Step 5: Commit**

```bash
git add docs/story/bestiary/bosses.md docs/analysis/game-design-gaps.md docs/story/bestiary/CONTINUATION.md
git commit -F /tmp/commit-msg.txt
# Message: "docs(shared): complete adversarial verification, update Gap 1.3 to COMPLETE"
```

- [ ] **Step 6: Run lint and tests**

```bash
pnpm lint && pnpm test
```

Must pass before creating PR.
