# Bestiary Act III Implementation Plan (Gap 1.3, Sub-project 3a)

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Populate act-iii.md with ~65 Act III enemies across 8 areas,
update palette-families.md with Tier 3/4 entries, and include Vaelith's
full combat arc and the Grey Cleaver cursed weapon quest.

**Architecture:** Pure documentation pass — rewrite act-iii.md from TBD
placeholder to full stat tables with trial boss mechanics, Forgotten
Forge secret dungeon, and Convergence final dungeon. Update
palette-families.md, CONTINUATION.md, and gap tracker.

**Tech Stack:** Markdown, git, pnpm (for lint/test verification)

**Spec:** `docs/superpowers/specs/2026-03-22-bestiary-act-iii-design.md`

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `docs/story/bestiary/act-iii.md` | Rewrite | Full Act III enemy stat tables (~65 entries) + trial mechanics + Forgotten Forge + Grey Cleaver |
| `docs/story/bestiary/palette-families.md` | Modify | Add ~21 Tier 3 + ~10 Tier 4 entries for existing families |
| `docs/story/bestiary/CONTINUATION.md` | Modify | Update Sub-project 3a status |
| `docs/story/bestiary/README.md` | Modify | Update index row for act-iii.md |
| `docs/analysis/game-design-gaps.md` | Modify | Check off Act III items in Gap 1.3 |

---

## Chunk 1: Act III Stat Tables

### Task 1: Populate act-iii.md with all ~65 enemies

**Files:**
- Rewrite: `docs/story/bestiary/act-iii.md`
- Reference: `docs/story/bestiary/README.md` (formulas, types)
- Reference: `docs/story/dungeons-world.md` (Pallor Wastes, Convergence, Ley Depths F5, Dry Well F5–7 bosses)
- Reference: `docs/superpowers/specs/2026-03-22-bestiary-act-iii-design.md`

- [ ] **Step 1: Write the file header and Pallor Wastes outer section (8 enemies)**

Replace the TBD content of `act-iii.md` with:

```markdown
# Act III Bestiary

Enemies encountered during Act III: Pallor Wastes, The Convergence,
Ley Line Depths Floor 5, Dry Well of Aelhart Floors 5–7, the
Forgotten Forge (secret dungeon), and the Act III Overworld.
See [README.md](README.md) for type rules, stat formulas, and
reward calculations.

**Total:** ~65 enemies across 8 areas

---

## Pallor Wastes — Outer Sections (Lv 28–30)

Ashen Approach and early clearings. The corrupted familiar — things
players fought before, now deformed by despair. Corruption is
visible: bodies twisted, joints bent wrong, forms losing coherence.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| ... |
```

For each enemy in the spec Section 4.1, compute stats using README
formulas at the listed level with role adjustments. Apply type rules:

- **Pallor enemies:** Weak=Spirit, Immune=Despair+Death, 2% HP regen
  while party has Despair
- **Undead enemies:** Immune=Poison+Death
- **Spirit enemies:** Immune=Poison+Petrify, 50% physical reduction
- **Beast enemies:** No inherent immunities

Use the logistic reward formulas × threat multiplier for Gold/Exp.
Pallor Boar uses Rare threat (×1.5) per palette-families.md.

Enemies for this section (from spec Section 4.1):

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Pallor Boar | Boar | 3 | 28 | Pallor | Rare | Tank |
| Shadow Wolf | Wolf | 3 | 28 | Beast | Standard | Glass cannon |
| Pallor Vermin | Vermin | 4 | 30 | Pallor | Standard | Swarm |
| Wraith Shade | Shade | 3 | 30 | Spirit | Standard | Caster |
| Hollow Walker | — (unique) | — | 28 | Pallor | Standard | Balanced |
| Despair Cloud | — (unique) | — | 28 | Pallor | Low | Caster |
| Petrified Beast | — (unique) | — | 30 | Pallor | Standard | Tank |
| Dread Warden | Warden | 3 | 30 | Undead | Standard | Tank |

- [ ] **Step 2: Write Pallor Wastes inner + trial clearings section (5 + 5 enemies)**

Add a new `##` section for the inner Wastes:

```markdown
## Pallor Wastes — Inner Sections + Trial Clearings (Lv 30–32)

The shift toward Pallor-born. Things that never existed before the
Grey. The deeper you go, the less recognizable things become.
```

Inner regular enemies (spec Section 4.2):

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Pallor Knight | — (unique) | — | 32 | Pallor | Dangerous | Balanced |
| Grief Shade | — (unique) | — | 32 | Pallor | Dangerous | Caster |
| Void Wisp | Wisp | 3 | 30 | Elemental | Standard | Caster |
| Pallor Treant | Treant | 3 | 30 | Pallor | Standard | Tank |
| Marauder Captain | Bandit | 3 | 30 | Humanoid | Standard | Balanced |

Then a subsection for trial-specific enemies (spec Section 4.3):

```markdown
### Trial-Specific Enemies

Each trial has unique enemies reflecting that trial's despair theme.
These appear ONLY within their trial clearing.
```

| Name | Trial | Lv | Type | Threat | Notes |
|------|-------|----|------|--------|-------|
| Hollow Knight | 1 (Crowned Hollow) | 30 | Pallor | Standard | 1,000 HP each. Formation fighters. |
| Unfinished Construct | 2 (Perfect Machine) | 30 | Construct | Low | Beg to be repaired. Healing spawns more. |
| Stone Spirit | 3 (Last Voice) | 30 | Spirit | Standard | Petrified. Silence-based attacks. |
| Shadow of Sable | 4 (Open Door) | — | Pallor | — | Non-combat trial. No stat block needed. |
| Archived | 5 (The Index) | 32 | Pallor | Standard | Compressed page figures. |

**IMPORTANT:** Hollow Knights use a fixed 1,000 HP per
dungeons-world.md — not the formula. Unfinished Constructs must
have MP=0 and 5 immunities (Construct type).

- [ ] **Step 3: Write trial boss sections (5 bosses + Vaelith)**

Add `### Trial Bosses` after the trial-specific enemies table.

For each trial boss, create a boss notes section following the
pattern established in interlude.md — stat table row (italicized
name) plus a narrative section below with phases, abilities, and
the special resolution mechanic.

Trial bosses (spec Section 4.4):

| Name | Lv | HP | Type | Weakness | Resistance |
|------|----|----|------|----------|------------|
| *The Crowned Hollow* | 30 | 8,000 | Boss | Spirit (150%) | Physical (75%) |
| *The Perfect Machine* | 30 | 7,000 | Boss | Void (150%) | Flame (75%) |
| *The Last Voice* | 32 | 6,000 | Boss | Flame (150%) | Spirit (50%) |
| *The Open Door* | — | — | — | — | — |
| *The Index* | 32 | 7,000 | Boss | Spirit (150%) | Void (50%) |

For each boss, include:
- The special resolution mechanic (the "hope" key):
  - Crowned Hollow: Edren Defend 3 consecutive turns
  - Perfect Machine: Lira's Dismantle command
  - Last Voice: Torren's Spiritcall Release
  - Open Door: non-combat — walk back
  - Index: Maren's Read One Entry
- Phase descriptions from dungeons-world.md
- Boss immunities: Death, Petrify, Stop, Sleep, Confusion
- Drops from dungeons-world.md

Then add `### Vaelith, the Ashen Shepherd` section:

Vaelith stat table and boss notes per spec Section 4.4:
- Pre-fight phase (invulnerable, 10 attacks)
- Phase 1: 50,000–25,000 HP, Lv 34, Spirit (125%), Void (50%),
  Frost (75%), Immune Despair+Death
- Phase 2: 25,000–0 HP, Spirit (125%), Void (50%)
- Lira weapon-forging cutscene breaks invulnerability

Also add `### Vaelith — Unwinnable Siege Encounter (Act II)` section:
- Lv 99, 999,999 HP, all immunities
- Scripted loss — for completeness

**Cross-reference:** Read dungeons-world.md Section 5 "Plateau's
Edge" (lines ~1833–1890) for Vaelith's exact phase abilities and
the 10-attack threshold script. Read trial boss sections (lines
~1600–1832) for each trial's exact mechanics. Do NOT invent details
not in dungeons-world.md. Use "See dungeons-world.md" references
for detailed ability scripts.

- [ ] **Step 4: Verify Pallor Wastes section**

Run: `pnpm lint && pnpm test`
Expected: All pass (docs-only changes)

Manually verify:
1. Count stat table rows: should be 8 (outer) + 5 (inner) + 5
   (trial) + 5 (trial bosses) + 1 (Vaelith) + 1 (Vaelith Siege)
   = 25 entries
2. All Pallor enemies: Weak=Spirit, Immune=Despair+Death
3. All Construct enemies: MP=0, 5 immunities
4. All Spirit enemies: Immune=Poison+Petrify
5. Boss immunities: Death+Petrify+Stop+Sleep+Confusion
6. Trial boss HP values match dungeons-world.md
7. Vaelith HP=50,000 matches dungeons-world.md encounter table

- [ ] **Step 5: Commit**

```bash
git add docs/story/bestiary/act-iii.md
git commit -s -m "docs(shared): populate Act III Pallor Wastes enemies (24 entries)"
```

---

### Task 2: Ley Line Depths F5 + Dry Well F5–7 sections

**Files:**
- Modify: `docs/story/bestiary/act-iii.md`
- Reference: `docs/story/dungeons-world.md` (Ley Depths F5, Dry Well F5–7)
- Reference: `docs/superpowers/specs/2026-03-22-bestiary-act-iii-design.md`

- [ ] **Step 1: Write Ley Line Depths F5 section (3 regular + 1 boss)**

Add after Pallor Wastes sections:

```markdown
## Ley Line Depths — Floor 5: The Ley Confluence (Lv 26–28)

The deepest ley chamber. Raw energy crystallized into living forms.
Ley energy resists the Pallor — less corrupted than the surface.
Requires the Archivist's Codex (from Archive of Ages) to access.
```

Regular enemies (spec Section 4.7):

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Ley Construct | — (existing) | — | 26 | Construct | Standard | Balanced |
| Vein Stalker | — (unique) | — | 28 | Humanoid | Rare | Glass cannon |
| Confluence Elemental | Elemental | 3 | 28 | Elemental | Standard | Caster |

**Confluence Elemental special note:** Include a design note below
the table explaining the rotating element cycle mechanic
(Flame→Frost→Storm→Earth, absorbs element just cast, weak to NEXT).

Boss: Ley Titan (18,000 HP, Lv 28). Three-phase per dungeons-world.md.
Include boss notes referencing the Ley Aspects (Strength, Precision,
Endurance) and kill order significance.

- [ ] **Step 2: Write Dry Well F5–7 section (5 regular + 2 bosses)**

```markdown
## Dry Well of Aelhart — Floors 5–7 (Lv 30–36)

Ancient builder chambers. Ley experiments gone wrong — Constructs
running corrupted programs, ley energy warping reality. Accessed
via Dry Well Floor 4 (Interlude content).
```

Regular enemies (spec Section 4.8):

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Crystal Warden (Deep) | Guardian | 3 | 30 | Construct | Standard | Tank |
| Pictograph Wisp | Wisp | 3 | 30 | Elemental | Standard | Caster |
| Ley-Warped Construct | Automata | 3 | 32 | Construct | Standard | Balanced |
| Warp Sentinel | Sentry | 3 | 32 | Construct | Standard | Balanced |
| Ley-Born Echo | — (unique) | — | 34 | Spirit | Standard | Caster |

Bosses:
- Archive Keeper: variable HP (3,000–12,000), Lv 32. Include
  note about HP scaling inversely with Builder Tablets collected.
- Wellspring Guardian: 28,000 HP, Lv 36. Three-phase per
  dungeons-world.md (Test of Arms, Knowledge, Resolve).

**Type checks:**
- Crystal Warden (Deep): Construct — MP=0, 5 immunities
- Pictograph Wisp: Elemental — absorbs own element
- Ley-Warped Construct: Construct — MP=0, 5 immunities
- Warp Sentinel: Construct — MP=0, 5 immunities
- Ley-Born Echo: Spirit — Immune Poison+Petrify

- [ ] **Step 3: Verify and commit**

Run: `pnpm lint && pnpm test`

Verify:
1. Ley Construct stats at Lv 26 match formula
2. Ley Titan HP=18,000 matches dungeons-world.md
3. Wellspring Guardian HP=28,000 matches dungeons-world.md
4. All 4 Construct enemies have MP=0 and 5 immunities
5. Count: 3 + 1 boss + 5 + 2 bosses = 11 entries

```bash
git add docs/story/bestiary/act-iii.md
git commit -s -m "docs(shared): populate Ley Confluence and Dry Well F5-7 enemies (11 entries)"
```

---

### Task 3: Forgotten Forge + Grey Cleaver section

**Files:**
- Modify: `docs/story/bestiary/act-iii.md`
- Reference: `docs/superpowers/specs/2026-03-22-bestiary-act-iii-design.md` (Sections 3, 4.9)

- [ ] **Step 1: Write Forgotten Forge section (5 regular + 2-stage boss)**

```markdown
## The Forgotten Forge — Secret Dungeon (Lv 32–36)

Five floors beneath the Dry Well of Aelhart. Ancient ley-forging
facility where pre-Pallor builders experimented with weaponized
despair. The Grey Cleaver was their greatest failure — a weapon
that absorbed despair instead of channeling ley energy.

**Access:** Hidden builder's seal on Dry Well Floor 7. Requires
the Archivist's Codex to decipher.
```

Regular enemies (spec Section 4.9):

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Forge Sentinel | Sentry | 3 | 32 | Construct | Standard | Tank |
| Tempered Construct | Guardian | 3 | 34 | Construct | Standard | Balanced |
| Slag Elemental | Elemental | 3 | 34 | Elemental | Standard | Caster |
| Grief Residue | — (unique) | — | 34 | Pallor | Standard | Caster |
| Hollow Smith | — (unique) | — | 34 | Pallor | Standard | Balanced |

**Type checks:**
- Forge Sentinel: Construct — MP=0, 5 immunities
- Tempered Construct: Construct — MP=0, 5 immunities
- Slag Elemental: Elemental — absorbs Flame, weak to Frost
- Grief Residue: Pallor — Weak Spirit, Immune Despair+Death
- Hollow Smith: Pallor — Weak Spirit, Immune Despair+Death

- [ ] **Step 2: Write The Architect's Regret boss section**

Two-stage boss per spec Section 3.2:

**Stage 1: The Architect (Lv 34, 20,000 HP, Construct)**
- Stat table row with Construct type rules (MP=0, 5 immunities)
- Boss notes: 3 Ley Anvils (2,000 HP each, element-matching to
  overload), 50% damage reduction while shielded, summons Forge
  Construct adds, enraged when unshielded
- Boss immunities: Death+Petrify+Stop+Sleep+Confusion

**Stage 2: The Grey Cleaver Unbound (Lv 36, 25,000 HP, Pallor)**
- Stat table row with Pallor type rules (Weak Spirit, Immune
  Despair+Death)
- Boss notes: 3 weapon stances (Greatsword/Whip/Shield), Weight
  of Ages (party-wide Despair), shield stance reflects damage BUT
  Despaired party members deal +50% bonus during shield stance
- Boss immunities: Death+Petrify+Stop+Sleep+Confusion+Despair

- [ ] **Step 3: Write Grey Cleaver reward section**

After the boss notes, add:

```markdown
### Grey Cleaver — Cursed Weapon Quest

**Reward:** Grey Cleaver (Torren-exclusive greatsword)

An homage to FF6's Cursed Shield. The weapon that absorbed
centuries of despair in the Forgotten Forge.

**Tainted form:**
- ATK +15, DEF -10, MDEF -10, SPD -10
- Inflicts Despair on Torren at battle start
- Weak to all elements while equipped
- Cannot be sold or discarded

**Purification:** Win 100 encounters against Pallor-type enemies
with Grey Cleaver equipped on Torren. Counter does NOT reset if
unequipped. Torren must be alive when battle is won.

**Purified — Pallor's End:**
- ATK +55 (best greatsword)
- Spirit element on all attacks
- +50% damage vs Pallor-type enemies
- Despair immunity for Torren
- Absorbs Spirit element
```

- [ ] **Step 4: Verify and commit**

Run: `pnpm lint && pnpm test`

Verify:
1. Both Construct enemies have MP=0 and 5 immunities
2. Both Pallor enemies have Weak=Spirit, Immune=Despair+Death
3. Stage 1 Architect HP=20,000, Stage 2 Grey Cleaver HP=25,000
4. Both boss stages have Boss-default immunities
5. Grey Cleaver stats documented completely
6. Count: 5 regular + 2 boss stages = 7 entries

```bash
git add docs/story/bestiary/act-iii.md
git commit -s -m "docs(shared): populate Forgotten Forge enemies and Grey Cleaver quest (7 entries)"
```

---

### Task 4: The Convergence section

**Files:**
- Modify: `docs/story/bestiary/act-iii.md`
- Reference: `docs/story/dungeons-world.md` (Convergence, lines ~1893–2137)
- Reference: `docs/superpowers/specs/2026-03-22-bestiary-act-iii-design.md` (Sections 4.5, 4.6)

- [ ] **Step 1: Write Convergence regular enemies (7 enemies)**

```markdown
## The Convergence (Lv 32–36)

Ground zero. The Grey at full power. The final dungeon —
4 phases: Outer Ring, Anchor Stations (×3, party split),
Central Platform, and The Door.
```

Regular enemies (spec Section 4.5):

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Pallor Soldier | Soldier | 4 | 34 | Pallor | Standard | Balanced |
| Pallor Drake | Drake | 4 | 36 | Pallor | Rare | Dangerous |
| Ley Construct | — (existing) | — | 34 | Construct | Standard | Balanced |
| Forgewright Automaton | Automata | 3 (biome variant) | 34 | Construct | Standard | Tank |
| Corrupted Spirit | — (unique) | — | 34 | Spirit | Standard | Caster |
| Ashen Serpent | Serpent | 4 | 34 | Pallor | Standard | Glass cannon |
| Pallor Lurker | Lurker | 4 | 36 | Pallor | Standard | Balanced |

**Note:** Pallor Soldier appears here at projected full-power Lv 34
(vs Interlude early deployment at Lv 26). Ley Construct reappears
from Ley Line Depths. Pallor Drake, Ashen Serpent, and Pallor Lurker
are bestiary expansions beyond dungeons-world.md's encounter table.

- [ ] **Step 2: Write Phase 4 survival gauntlet**

Add subsection:

```markdown
### Phase 4: The Door — Survival Gauntlet

The party approaches the Door. Waves of enemies attack in
sequence. No rest between waves.
```

Document the 4 waves per spec Section 4.5:
- Wave 1: 6 Hollow Walkers
- Wave 2: 4 Despair Clouds + 2 Pallor Knights
- Wave 3: 3 Grief Shades (mimicking Edren, Lira, Torren)
- Wave 4: 1 Pallor Echo (5,000 HP mini-boss)

Pallor Echo gets a stat table row + boss notes section.

- [ ] **Step 3: Write Convergence boss sections**

Per spec Section 4.6 and dungeons-world.md:

**Cael, Knight of Despair (Phase 1)** — 45,000 HP, Lv 36
- Enhanced party abilities, counters last attacker
- Scripted thresholds: 75% Despair Pulse, 50% Shadow Step,
  25% dialogue invulnerability
- Boss immunities

**Cael, Knight of Despair (Phase 2)** — 35,000 HP, Lv 38
- Full Pallor aggression: Grey Shockwave, Pallor Surge, Void Crush
- Boss immunities

**The Pallor Incarnate** — 70,000 HP, Lv 40
- 4 conduit crystals (3,000 HP each, 500 HP/turn regen each)
- Attacks: Grey Tide, Convergence Beam, Despair Absolute, Void
  Collapse (at <25% HP)
- Boss immunities

**Cross-reference:** Read dungeons-world.md Convergence section
(lines ~1893–2137) for exact phase mechanics. Use "See
dungeons-world.md" for detailed ability scripts.

- [ ] **Step 4: Verify and commit**

Run: `pnpm lint && pnpm test`

Verify:
1. All Pallor enemies: Weak=Spirit, Immune=Despair+Death
2. Both Construct enemies: MP=0, 5 immunities
3. Corrupted Spirit: Immune=Poison+Petrify
4. Cael P1 HP=45,000, P2 HP=35,000 per dungeons-world.md
5. Pallor Incarnate HP=70,000 per dungeons-world.md
6. Conduit crystals documented (3,000 HP, 500 HP/turn regen)
7. Count: 7 regular + 4 bosses = 11 entries

```bash
git add docs/story/bestiary/act-iii.md
git commit -s -m "docs(shared): populate Convergence enemies and final bosses (11 entries)"
```

---

### Task 5: Overworld Act III section

**Files:**
- Modify: `docs/story/bestiary/act-iii.md`
- Reference: `docs/superpowers/specs/2026-03-22-bestiary-act-iii-design.md` (Sections 4.10, 4.11)

- [ ] **Step 1: Write Overworld safe zone section (6 enemies)**

```markdown
## Overworld Act III — Safe Zones (Lv 28–32)

Near surviving towns (Bellhaven, The Pendulum, Oases). Tier 3
family enemies displaced by the Grey — desperate, aggressive,
not yet corrupted. Encounter rate: normal.
```

Enemies (spec Section 4.10):

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Thunder Drake | Drake | 3 | 30 | Beast | Dangerous | Dangerous |
| Deserter Captain | Soldier | 3 | 30 | Humanoid | Standard | Balanced |
| Blight Leech | Leech | 3 | 30 | Beast | Dangerous | Caster |
| Void Moth | Moth | 3 | 30 | Elemental | Standard | Caster |
| Storm Wraith | Wraith | 3 | 30 | Spirit | Standard | Caster |
| Roc | Hawk | 3 | 32 | Beast | Rare | Dangerous |

**Notes:** Storm Wraith is Spirit — Immune Poison+Petrify. Thunder
Drake and Blight Leech use Dangerous threat (×1.0). Roc uses
Rare threat (×1.5).

- [ ] **Step 2: Write Overworld grey zone section (6 enemies)**

```markdown
## Overworld Act III — Grey Zones (Lv 32–35)

Approaching the Convergence. Pallor Tier 4 variants and Pallor-born.
The closer to the Convergence, the higher the encounter rate.
The Grey Cleaver purification counter progresses here.
```

Enemies (spec Section 4.11):

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Pallor Revenant | Dead | 4 | 34 | Pallor | Standard | Balanced |
| Pallor Wolf | Wolf | 4 | 34 | Pallor | Standard | Glass cannon |
| Pallor Crawler | Crawler | 4 | 34 | Pallor | Standard | Balanced |
| Pallor Wraith | Wraith | 4 | 34 | Pallor | Standard | Caster |
| Pallor Roc | Hawk | 4 | 34 | Pallor | Rare | Dangerous |
| Void Crystal | Crystal | 3 | 32 | Elemental | Standard | Caster |

**Notes:** All Pallor enemies Weak=Spirit, Immune=Despair+Death.
Void Crystal is Elemental — absorbs Void, weak to Spirit.

- [ ] **Step 3: Write Interlude summary**

Add at the end of act-iii.md:

```markdown
---

## Act III Summary

- **Total:** ~65 enemies across 8 areas
- **Type distribution:** Pallor (~55%), Construct (15%),
  Beast (10%), Spirit (10%), Elemental (5%), Undead (3%),
  Humanoid (2%)
- **Pallor gradient:** 20% (safe zones) → 90% (Convergence)
- **Tier 3 debuts:** [list from spec Section 5.1]
- **Tier 4 debuts:** [list from spec Section 5.2]
- **New mechanic:** Grey Cleaver cursed weapon quest
  (100 Pallor encounters to purify)
- **Secret dungeon:** Forgotten Forge (5 floors, 2-stage boss)
- **Trial bosses:** 5 (4 combat + 1 non-combat), each with
  a despair puzzle and hope-based resolution
```

- [ ] **Step 4: Verify and commit**

Run: `pnpm lint && pnpm test`

Verify:
1. All 6 Pallor enemies in grey zone: Weak=Spirit, Immune=Despair+Death
2. Storm Wraith (Spirit): Immune=Poison+Petrify
3. Void Crystal (Elemental): correct elemental profile
4. Thunder Drake and Blight Leech use Dangerous threat (×1.0)
5. Roc and Pallor Roc use Rare threat (×1.5)
6. Count: 6 + 6 = 12 entries

```bash
git add docs/story/bestiary/act-iii.md
git commit -s -m "docs(shared): populate Overworld Act III enemies and summary (12 entries)"
```

---

## Chunk 2: Palette Families + Metadata Updates

### Task 6: Update palette-families.md with Tier 3 entries

**Files:**
- Modify: `docs/story/bestiary/palette-families.md`
- Reference: `docs/superpowers/specs/2026-03-22-bestiary-act-iii-design.md` (Section 5.1)
- Reference: `docs/story/bestiary/act-iii.md` (for stat verification)

- [ ] **Step 1: Add ~21 Tier 3 entries to existing families**

For each family listed in spec Section 5.1, add a new row to the
family's tier table in palette-families.md. Follow the exact format
of existing Tier 2/3 entries:

```markdown
| Tier 3 Name | Level | Type | Element Shift | Abilities | Threat |
```

Families to update (organized by location):

**Overworld safe:**
- Drake: Thunder Drake | 30 | Beast | Weak→Frost→Weak→Storm | +Thunder Breath, +Dive Bomb | Dangerous
- Leech: Blight Leech | 30 | Beast | (per palette-families projection) | +Blight Drain, +Toxin Cloud | Dangerous
- Moth: Void Moth | 30 | Elemental | (per projection) | +Dark Spore, +Wing Scatter | Standard
- Wraith: Storm Wraith | 30 | Spirit | (per projection) | +Storm Bolt, +Wail | Standard
- Hawk: Roc | 32 | Beast | (per projection) | +Dive Strike, +Wing Gust | Rare
- Soldier: Deserter Captain | 30 | Humanoid | — | +Rally Cry, +Desperate Slash | Standard

**Pallor Wastes:**
- Shade: Wraith Shade | 30 | Spirit | (per projection) | +Phase Strike, +Despair Mist | Standard
- Warden: Dread Warden | 30 | Undead | (per projection) | +Shield Wall, +Bone Crush | Standard
- Wisp: Void Wisp | 30 | Elemental | (per projection) | +Void Pulse, +Light Drain | Standard
- Treant: Pallor Treant | 30 | Pallor | Weak→Spirit | +Root Tendril, +Ash Scatter | Standard
- Bandit: Marauder Captain | 30 | Humanoid | — | +Raider Command, +Ambush Strike | Standard
- Crystal: Void Crystal | 32 | Elemental | Absorb→Void, Weak→Spirit | +Void Pulse, +Crystal Shard | Standard

**Ley Confluence:**
- Elemental: Confluence Elemental | 28 | Elemental | Rotating cycle | +Cycle Cast | Standard

**Dry Well:**
- Wisp: Pictograph Wisp | 30 | Elemental | (biome variant) | +Script Read, +Text Bolt | Standard
- Guardian: Crystal Warden (Deep) | 30 | Construct | — | +Crystal Shield, +Regen Armor | Standard
- Automata: Ley-Warped Construct | 32 | Construct | — | +Glitch Strike, +Tool Flurry | Standard
- Sentry: Warp Sentinel | 32 | Construct | — | +Warp Blink, +Ley Beam | Standard

**Forgotten Forge:**
- Sentry: Forge Sentinel | 32 | Construct | — | +Element Shield, +Ley Pulse | Standard
- Guardian: Tempered Construct | 34 | Construct | — | +Heated Arms, +Forge Slam | Standard
- Elemental: Slag Elemental | 34 | Elemental | Absorb→Flame, Weak→Frost | +Molten Splash, +Slag Wave | Standard

**Convergence:**
- Automata: Forgewright Automaton | 34 | Construct | — (biome variant) | +War Protocol, +Armor Plate | Standard

**Tier 1 Element Shift = "—" for all base entries.** For Tier 3,
record the shift from Tier 2 if applicable, or "—" if unchanged.

For families with multiple biome variants at the same tier (Sentry,
Guardian, Wisp, Elemental, Automata), add a design note blockquote
explaining the variants, following the Interlude pattern.

**Early deployment notes for Tier 3:** Add blockquote notes for
families deployed below their projected level:
- Pallor Boar (Boar Tier 3): deployed at Lv 28, projected Lv 36.
  The Boar family has only 3 tiers — Tier 3 IS the Pallor endpoint.
- Shadow Wolf (Wolf Tier 3): deployed at Lv 28, projected Lv 33.

- [ ] **Step 2: Verify Tier 3 entries**

For each new entry, verify:
1. Name matches act-iii.md stat table
2. Level matches act-iii.md
3. Type is correct per README.md rules
4. Element Shift is consistent with act-iii.md elemental profile
5. Threat matches act-iii.md Gold/Exp multiplier

- [ ] **Step 3: Commit**

```bash
git add docs/story/bestiary/palette-families.md
git commit -s -m "docs(shared): add ~21 Tier 3 entries to palette-families for Act III"
```

---

### Task 7: Add early deployment notes + update palette-families header

**Files:**
- Modify: `docs/story/bestiary/palette-families.md`
- Reference: `docs/superpowers/specs/2026-03-22-bestiary-act-iii-design.md` (Section 5.2)

- [ ] **Step 1: Verify all Tier 4 entries already exist**

**CRITICAL:** ALL Tier 4 Pallor entries for Act III already exist
in palette-families.md at their projected full-power levels. Do NOT
create new Tier 4 rows. The existing entries are:

| Family | Existing Tier 4 | Projected Lv | Act III Deploy Lv |
|--------|----------------|--------------|-------------------|
| Vermin | Pallor Vermin | 38 | 30 |
| Wolf | Pallor Wolf | 45 | 34 |
| Dead | Pallor Revenant | 40 | 34 |
| Crawler | Pallor Crawler | 46 | 34 |
| Wraith | Pallor Wraith | 44 | 34 |
| Hawk | Pallor Roc | 46 | 34 |
| Drake | Pallor Drake | 50 | 36 |
| Serpent | Ashen Serpent | 42 | 34 |
| Lurker | Pallor Lurker | 46 | 36 |

Also already exist from Interlude: Pallor Soldier (48→26),
Pallor Shade (42→26), Pallor Warden (44→26), Pallor Brigand
(44→26).

Act III deploys these at LOWER levels than projected (early
deployment rule). Stats in act-iii.md are computed from the
act-file level, not the palette-families projected level.

- [ ] **Step 2: Add early deployment notes to family blockquotes**

For each family whose Tier 4 is deployed in Act III at a lower
level than projected, add or update the blockquote note. Follow
the pattern established in the Interlude:

Families needing Act III early deployment notes:
- **Boar** (Tier 3 at Lv 28 vs projected Lv 36) — add note
- **Wolf** (Tier 3 Shadow Wolf at Lv 28 vs projected Lv 33) — add note
- **Vermin** (Tier 4 at Lv 30 vs projected Lv 38) — add note
- **Drake** (Tier 4 at Lv 36 vs projected Lv 50) — add note
- **Serpent** (Tier 4 at Lv 34 vs projected Lv 42) — add note
- **Lurker** (Tier 4 at Lv 36 vs projected Lv 46) — add note

Other families (Wolf Tier 4, Dead, Crawler, Wraith, Hawk) deploy
at Lv 34 in the overworld grey zone which is closer to their
projections. These are still early but the gap is smaller — add
brief notes where the gap exceeds 5 levels.

- [ ] **Step 3: Update palette-families.md header**

Update the status note at the top of the file:

```markdown
> **Status:** Act I + Act II + Interlude + Act III families populated.
> Tier 1–4 entries present. No new families added in Act III —
> existing families reach their Tier 3/4 endpoints.
```

- [ ] **Step 4: Verify and commit**

Verify:
1. ZERO new Tier 4 rows created (all already existed)
2. Early deployment notes added for families with >5 level gaps
3. Boar family note explains Tier 3 = Pallor endpoint (no Tier 4)

```bash
git add docs/story/bestiary/palette-families.md
git commit -s -m "docs(shared): add Act III early deployment notes to palette-families"
```

---

### Task 8: Update metadata files

**Files:**
- Modify: `docs/story/bestiary/CONTINUATION.md`
- Modify: `docs/story/bestiary/README.md`
- Modify: `docs/analysis/game-design-gaps.md`

- [ ] **Step 1: Update CONTINUATION.md**

Update the current state table:

```markdown
| **3a: Act III** | COMPLETE | — (pending PR) | ~65 | act-iii.md, palette-families.md |
```

Update the "Gap 1.3 status" line. Update the "What Has Been
Established" section if any new rules were added.

- [ ] **Step 2: Update README.md index**

Change the act-iii.md row from "(TBD)" to the actual content:

```markdown
| [act-iii.md](act-iii.md) | Pallor Wastes, Convergence, Ley F5, Dry Well F5–7, Forgotten Forge, Overworld (~65 enemies) |
```

Also update the level range for Act III if needed (26–45 to account
for transitional areas per spec Section 2 note).

- [ ] **Step 3: Update game-design-gaps.md**

Check off the Act III checklist item in Gap 1.3:

```markdown
- [x] Act III enemies (enhanced variants, Pallor creatures)
```

- [ ] **Step 4: Verify and commit**

Run: `pnpm lint && pnpm test`

Verify:
1. CONTINUATION.md table is accurate
2. README.md index row updated
3. Gap 1.3 checklist item checked
4. No broken markdown links

```bash
git add docs/story/bestiary/CONTINUATION.md docs/story/bestiary/README.md docs/analysis/game-design-gaps.md
git commit -s -m "docs(shared): update metadata for Act III bestiary completion"
```

---

### Task 9: Cross-reference verification

**Files:**
- Read: All files modified in Tasks 1–8
- Reference: `docs/story/dungeons-world.md`
- Reference: `docs/story/bestiary/README.md`

- [ ] **Step 1: Boss HP verification**

Read dungeons-world.md and verify every boss HP in act-iii.md:

| Boss | Expected HP | Source |
|------|------------|--------|
| Crowned Hollow | 8,000 | dungeons-world.md |
| Perfect Machine | 7,000 | dungeons-world.md |
| Last Voice | 6,000 | dungeons-world.md |
| Index | 7,000 | dungeons-world.md |
| Vaelith | 50,000 | dungeons-world.md |
| Vaelith (Siege) | 999,999 | Scripted |
| Ley Titan | 18,000 | dungeons-world.md |
| Archive Keeper | 3,000–12,000 | dungeons-world.md |
| Wellspring Guardian | 28,000 | dungeons-world.md |
| The Architect (Stage 1) | 20,000 | Spec (new content) |
| Grey Cleaver Unbound (Stage 2) | 25,000 | Spec (new content) |
| Pallor Echo | 5,000 | dungeons-world.md |
| Cael Phase 1 | 45,000 | dungeons-world.md |
| Cael Phase 2 | 35,000 | dungeons-world.md |
| Pallor Incarnate | 70,000 | dungeons-world.md |

- [ ] **Step 2: Type rule verification**

Verify ALL enemies match their type rules:

1. All Construct enemies: MP=0, Immune Poison+Sleep+Confusion+Berserk+Despair
2. All Pallor enemies: Weak=Spirit, Immune Despair+Death
3. All Spirit enemies: Immune Poison+Petrify
4. All Undead enemies: Immune Poison+Death
5. All Boss enemies: Immune Death+Petrify+Stop+Sleep+Confusion

- [ ] **Step 3: Stat formula spot-checks**

Pick 5 enemies at random and verify stats match README formulas:
- One from Pallor Wastes
- One from Ley Confluence
- One from Forgotten Forge
- One from Convergence
- One from Overworld

For each: compute HP, ATK, DEF, MAG, MDEF, SPD from formulas.
Apply role adjustment. Verify Gold/Exp match logistic formula ×
threat multiplier.

- [ ] **Step 4: Palette-families cross-reference**

For each new Tier 3/4 entry in palette-families.md:
1. Name matches act-iii.md stat table exactly
2. Level matches act-iii.md
3. Type matches act-iii.md
4. Element Shift is consistent with act-iii.md Weak/Resists/Absorbs

- [ ] **Step 5: Enemy count verification**

Count every stat table row in act-iii.md. Verify total matches
the summary at the top of the file (~65).

- [ ] **Step 6: Final commit (if any fixes needed)**

If verification revealed issues, fix them and commit:

```bash
git add docs/story/bestiary/act-iii.md docs/story/bestiary/palette-families.md
git commit -s -m "docs(shared): fix cross-reference issues found during verification"
```

---

## Verification Checklist (Post-Implementation)

Before running `/create-pr`:

```markdown
- [ ] `pnpm test` passes
- [ ] `pnpm lint` passes
- [ ] Boss HP verified against dungeons-world.md (15 bosses)
- [ ] All Construct enemies: MP=0, 5 immunities
- [ ] All Pallor enemies: Weak=Spirit, Immune=Despair+Death
- [ ] All Spirit enemies: Immune=Poison+Petrify
- [ ] All Undead enemies: Immune=Poison+Death
- [ ] Boss immunities: Death+Petrify+Stop+Sleep+Confusion
- [ ] Trial boss mechanics match dungeons-world.md
- [ ] Vaelith HP=50,000 and phase thresholds match
- [ ] Grey Cleaver stats documented (tainted + purified)
- [ ] Pallor Incarnate conduit crystals documented (3,000 HP, 500 regen)
- [ ] palette-families.md updated (~21 Tier 3 + ~10 Tier 4)
- [ ] No duplicate Tier 4 entries for already-populated families
- [ ] CONTINUATION.md updated (Sub-project 3a complete)
- [ ] README.md index updated (act-iii.md no longer TBD)
- [ ] Gap 1.3 checklist updated
- [ ] Enemy count in summary matches actual table rows
- [ ] Stat formula spot-checks pass (5 random enemies)
```
