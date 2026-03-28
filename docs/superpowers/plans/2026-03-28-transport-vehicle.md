# Transport & Vehicle System Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Write the canonical transport mechanics document (`docs/story/transport.md`), apply design changes to existing docs (overworld.md, geography.md, city-carradan.md, economy.md), and update the gap tracker.

**Architecture:** This is a game design documentation task. The deliverable is a story doc consolidating all transport/vehicle rules, plus targeted updates to existing docs that currently defer to Gap 3.1. Content that already exists (rail tunnel dungeon, Linewalk spell, encounter formulas) is referenced, not duplicated.

**Tech Stack:** Markdown documentation, git

---

## Chunk 1: Core Document & Cross-Reference Updates

### Task 1: Write Transport Document — Sections 1–3

Write the first half of `docs/story/transport.md`: overview, vehicle types, and progression timeline.

**Files:**
- Create: `docs/story/transport.md`

**Reference:**
- Spec: `docs/superpowers/specs/2026-03-28-transport-vehicle-design.md` (Sections 1–3)
- Format reference: `docs/story/overworld.md` (follow same header/blockquote style)
- Cross-reference: `docs/story/city-carradan.md` (rail terminals, Rail Conductor NPC, network diagram)
- Cross-reference: `docs/story/locations.md` (Bellhaven docks, rail stations)
- Cross-reference: `docs/story/magic.md` (Linewalk: spell #74, Maren Lv 20, 12 MP)
- Cross-reference: `docs/story/geography.md` (sea routes, rail cart, Gael's Span bridge)
- Cross-reference: `docs/story/overworld.md` (passability, speed tiers, encounter system)
- Cross-reference: `docs/story/dynamic-world.md` (Interlude disruptions, Bellhaven state)
- Cross-reference: `docs/story/characters.md` (Torren trust arc)
- SNES reference: `docs/references/overworld-traversal-mechanics.md` (Section 10)

- [ ] **Step 1: Write the document header and overview**

Follow the same style as overworld.md — blockquote intro with related docs, core philosophy, then sections. The overview should:
- State "Grounded FF6" philosophy — no airship, terrestrial + coastal transport only
- Explain the consolidation purpose (mechanics doc, references other files for data)
- Note the transport progression mirrors SNES convention without flight
- List related docs with links (overworld.md, city-carradan.md, geography.md, economy.md, magic.md, dynamic-world.md, combat-formulas.md, characters.md)
- Cross-links: dungeons-world.md, locations.md, events.md

- [ ] **Step 2: Write Section 1 — Vehicle Types**

Cover all four vehicle subsections from spec Section 2:
- Compact Rail Network (routes, mechanic, speed, encounters, cost 100g, terminals, NPC, unlock trigger)
- Ley Stag Mount (source, mechanic, speed 2x, encounters none, terrain restrictions, Act III Pallor restriction with message "The Stag shies away. The ley energy here is wrong.", summon restriction message "The Stag cannot navigate this terrain.", unlock trigger `torren_joined` + Thornmere milestone TBD)
- Coastal Ferry (routes, mechanic, speed, encounters, cost 200g, unlock trigger, NPC)
- Linewalk Spell (reference only — per magic.md, 12 MP, Maren Lv 20, towns not save points)

- [ ] **Step 3: Write Section 2 — Transport Progression Timeline**

Cover spec Section 3:
- Timeline table (Act I on foot → Act II full transport → Interlude collapse → Act III partial recovery → Epilogue restoration)
- SNES parallel column (FF6 chocobo, FF6 Nikeah ferry, Earthbound Teleport, FF6 WoB→WoR)
- Note on Act II unlock window (~30–45%) mapping to SNES fast-travel range

- [ ] **Step 4: Verify cross-references**

Check against canonical sources:
- Rail routes match city-carradan.md network diagram (Corrund↔Ashmark↔Caldera, Corrund↔Kettleworks)
- Rail Conductor NPC exists at Corrund (building #28) and Ashmark (building #1) per city-carradan.md
- Note Caldera and Kettleworks lack formal building entries — file a GitHub issue for adding Rail Station building directory entries to city-carradan.md
- Linewalk: 12 MP, Maren Lv 20, "any previously visited town" per magic.md line 994
- Bellhaven docks exist in locations.md
- Gael's Span is described as a bridge-town in geography.md

- [ ] **Step 5: Commit**

```bash
git add docs/story/transport.md
git commit -m "docs(shared): add transport system mechanics doc — sections 1-2

Vehicle types (rail 100g, Ley Stag 2x mount, ferry 200g, Linewalk
reference), transport progression timeline Act I-Epilogue."
```

---

### Task 2: Write Transport Document — Sections 3–5

Add transport state per act, speed/encounter rules, and bridge tiles.

**Files:**
- Modify: `docs/story/transport.md`

**Reference:**
- Spec: `docs/superpowers/specs/2026-03-28-transport-vehicle-design.md` (Sections 4–6)
- Cross-reference: `docs/story/dynamic-world.md` (Interlude disruptions — rail collapse, Bellhaven disruption)
- Cross-reference: `docs/story/combat-formulas.md` (danger counter, encounter modifiers)
- Cross-reference: `docs/story/overworld.md` (speed tiers, encounter rules, Sacred sites zone)
- Cross-reference: `docs/story/geography.md` (Gael's Span, river crossings)

- [ ] **Step 1: Write Section 3 — Transport State Per Act**

Cover all five act states from spec Section 4:
- Act I: on foot only, Valdris territory, walking sufficient
- Act II: all four systems unlock (rail, Stag, ferry, Linewalk), "golden age" of mobility
- Interlude: transport collapse (rail suspended, Stag lost, ferry disrupted, Linewalk sole survivor). Include NPC dialogue quotes for rail ("Service suspended. The tunnels aren't safe.") and ferry ("The waters aren't safe. Something's in the strait."). Note Stag dissolves during Interlude transition cutscene.
- Act III: partial recovery (rail broken, Stag returns grey-tinged with Pallor restriction, ferry at Ashport only, Linewalk works)
- Epilogue: full restoration (rail repair in progress but not functional, Stag fully restored, ferry both ports, Linewalk works)

- [ ] **Step 2: Write Section 4 — Speed Tiers & Encounter Rules**

Cover spec Section 5:
- Speed tiers table (on foot 1x, Stag 2x, menu transport instant)
- Encounter rules table (on foot normal, Stag 0 increment + counter reset on dismount, menu none)
- Cost summary table (on foot free, Stag free, rail 100g, ferry 200g, Linewalk 12 MP)
- Note on-foot modifiers (Veilstep, Ward Talisman) apply only to on-foot travel

- [ ] **Step 3: Write Section 5 — Bridge Tiles**

Cover spec Section 6:
- Rivers impassable except at bridge tiles (named crossing points)
- Bridge tile rules (standard passable, both foot and Stag, encounter zone matches surrounding terrain)
- Named bridge crossings (Gael's Span, Valdris Crown bridges, Thornwatch area, Valdris-to-Duskfen route)
- Note additional bridges are implementation-placed based on tilemap

- [ ] **Step 4: Verify against canonical sources**

Check:
- Danger counter reset to 0 behavior matches combat-formulas.md
- Sacred sites 0 increment matches geography.md encounter zones table
- Bellhaven disruption matches dynamic-world.md (economic/environmental, not siege)
- Rail collapse "three collapse points" matches dynamic-world.md
- Gael's Span is a bridge-town per geography.md
- Speed ~2 tiles/second baseline matches overworld.md Implementation Notes

- [ ] **Step 5: Commit**

```bash
git add docs/story/transport.md
git commit -m "docs(shared): add transport state per act, speed rules, bridge tiles

Interlude collapse (rail/Stag/ferry lost, Linewalk survives), Act III
partial recovery. Speed tiers (1x foot, 2x Stag, instant menu).
Bridge tiles at named river crossings."
```

---

### Task 3: Apply Design Changes to Existing Docs

Update overworld.md, geography.md, city-carradan.md, and economy.md per the spec's "Design Changes" section.

**Files:**
- Modify: `docs/story/overworld.md` (resolve Gap 3.1 deferrals, add bridge note, remove airship refs)
- Modify: `docs/story/geography.md` (remove "deferred" qualifiers, add bridge crossings note)
- Modify: `docs/story/city-carradan.md` (add rail fare and mechanic cross-reference)
- Modify (if needed): `docs/story/economy.md` (add transport costs)

**Reference:**
- Spec Section 7 (Design Changes to Existing Docs)

- [ ] **Step 1: Update overworld.md — resolve vehicle-conditional deferral**

Search overworld.md for "Gap 3.1" to find all three deferral references. Replace each:
1. Search "Vehicle-based transport is deferred to Gap 3.1" → Replace with "Vehicle transport mechanics defined in [transport.md](transport.md)"
2. Search "mounts, airship, route mechanics" → Replace with "Ley Stag mount (2x speed), rail, and ferry defined in [transport.md](transport.md). No airship in PoD."
3. Search "Vehicle-conditional tiles" → Replace with "PoD's transport systems are menu-driven (rail, ferry) or use existing passability with restrictions (Ley Stag per [transport.md](transport.md)). No sixth tile category needed."

- [ ] **Step 2: Update overworld.md — add bridge tile note**

In the Passability Categories table, update the Impassable row or add a note below the table:
"Rivers are impassable except at bridge tiles — named crossing points where passable tiles span the water. See [transport.md](transport.md) Section 5 for bridge locations."

- [ ] **Step 3: Update overworld.md — add transport.md to related docs**

Add `[transport.md](transport.md)` to the Related docs line in the intro blockquote.

- [ ] **Step 4: Update geography.md — remove "deferred" qualifiers**

Search for "deferred to Gap 3.1" in geography.md. Replace:
- Sea routes entry (~line 206): "transport mechanics deferred to Gap 3.1 per overworld.md" → "ferry service per [transport.md](transport.md)"
- Rail cart entry (~line 547): "transport mechanics deferred to Gap 3.1 per overworld.md" → "rail fast-travel per [transport.md](transport.md)"

- [ ] **Step 5: Update geography.md — add bridge crossings note**

In the distance table appendix or river descriptions section, add a brief note listing key bridge crossings that appear on the overworld tilemap, referencing transport.md Section 5.

- [ ] **Step 6: Update city-carradan.md — add rail fare**

Find the Rail Network section in city-carradan.md. Add a note: "Fare: 100g per trip. See [transport.md](transport.md) for full rail fast-travel mechanics."

- [ ] **Step 7: Verify economy.md transport costs**

Check if economy.md already lists transport costs. If not, add rail (100g) and ferry (200g) to the appropriate expenditure section. Cross-reference transport.md.

- [ ] **Step 8: Verify changes are consistent**

- overworld.md no longer references "airship" in Gap 3.1 deferrals
- overworld.md no longer defers vehicle-conditional tiles
- geography.md no longer says "deferred to Gap 3.1"
- All new cross-references to transport.md resolve correctly
- Bridge tile note is consistent between overworld.md and transport.md

- [ ] **Step 9: Commit**

```bash
git add docs/story/overworld.md docs/story/geography.md docs/story/city-carradan.md docs/story/economy.md
git commit -m "docs(shared): apply transport design changes to existing docs

Resolve Gap 3.1 deferrals in overworld.md (no sixth tile category,
no airship, cross-ref transport.md). Remove 'deferred' qualifiers
from geography.md. Add rail fare to city-carradan.md. Add bridge
tile note."
```

---

### Task 4: Update Gap Tracker

Mark Gap 3.1 as COMPLETE and add progress tracking row.

**Files:**
- Modify: `docs/analysis/game-design-gaps.md` (search for "### 3.1 Transport")
- Modify: `docs/analysis/game-design-gaps.md` (search for "## Progress Tracking")

- [ ] **Step 1: Update Gap 3.1 section**

- Status: MISSING → COMPLETE
- Files: add `docs/story/transport.md` as primary file; note modified docs
- Completed date: 2026-03-28
- Check off all "What's Needed" items with resolution descriptions:
  - [x] Decision: Does this game have an airship? — No. "Grounded FF6" philosophy. Transport stays terrestrial + coastal.
  - [x] Rail system mechanics — Formalized: 4 routes between Compact cities, 100g fare, Rail Conductor NPC, encounter-free instant travel. Interlude collapse (3 tunnel collapses, service suspended). Act III stays broken. Epilogue repair in progress.
  - [x] Fast travel mechanics — Linewalk spell (Maren Lv 20, towns only, per magic.md) + rail + ferry provide full fast-travel coverage
  - [x] Mount/chocobo equivalent — Ley Stag mount: spirit-bonded, 2x speed, no encounters, terrain restricted (no dense Thornmere/water/mountains/towns), unlocked mid-Act II at Roothollow
  - [x] Boat/ship travel — Coastal ferry (Bellhaven ↔ Ashport), NPC-operated, 200g, unlocked Act II. No player-controlled boat.
  - [x] Vehicle encounter rate modifiers — Ley Stag suppresses encounters (0 increment). All menu transport is encounter-free.

- [ ] **Step 2: Add progress tracking row**

```
| 2026-03-28 | 3.1 Transport & Vehicle | MISSING → COMPLETE. "Grounded FF6" (no airship). Rail (100g, Compact cities), Ley Stag mount (2x speed, no encounters), Coastal ferry (200g, Bellhaven-Ashport), Linewalk (reference). Interlude transport collapse + Act III partial recovery. Bridge tiles at river crossings. Design changes applied to overworld.md, geography.md, city-carradan.md. | — |
```

- [ ] **Step 3: Commit**

```bash
git add docs/analysis/game-design-gaps.md
git commit -m "docs(shared): mark Gap 3.1 complete

Update gap tracker: 3.1 MISSING -> COMPLETE. Transport system
consolidated in transport.md with design changes to overworld.md,
geography.md, and city-carradan.md."
```

---

### Task 5: Adversarial Verification

Run verification pass on all changed files.

**Files:**
- Read: `docs/story/transport.md` (new document)
- Read: `docs/story/overworld.md` (modified)
- Read: `docs/story/geography.md` (modified)
- Read: `docs/story/city-carradan.md` (modified)
- Read: `docs/story/economy.md` (modified if changed)
- Read: `docs/story/magic.md` (cross-reference)
- Read: `docs/story/combat-formulas.md` (cross-reference)
- Read: `docs/analysis/game-design-gaps.md` (updated tracker)

- [ ] **Step 1: Numeric consistency checks**

- Rail fare 100g is affordable in Act II economy (check economy.md gold pacing)
- Ferry fare 200g is affordable but premium (check economy.md)
- Ley Stag 2x speed with overworld.md ~2 tiles/second baseline = ~4 tiles/second mounted
- Linewalk 12 MP matches magic.md
- Danger counter 0 increment for Stag matches Sacred sites zone in geography.md

- [ ] **Step 2: Cross-reference checks**

- Rail routes match city-carradan.md network diagram exactly
- Every terminal location named in transport.md exists in city-carradan.md
- Bellhaven docks exist in locations.md
- Torren trust event referenced in transport.md exists in events.md or characters.md
- Bridge crossing Gael's Span exists in geography.md
- Linewalk details match magic.md exactly (spell #74, 12 MP, Maren Lv 20)
- Interlude rail collapse details match dynamic-world.md

- [ ] **Step 3: Existing doc consistency**

- overworld.md no longer references "airship" or "vehicle-conditional tiles" as deferred
- overworld.md bridge tile note is consistent with transport.md Section 5
- geography.md no longer says "deferred to Gap 3.1"
- transport.md doesn't contradict overworld.md passability rules
- transport.md encounter suppression for Stag is consistent with combat-formulas.md danger counter model
- Gap 3.1 file list includes transport.md

- [ ] **Step 4: Fix any issues found**

If verification finds problems, fix and commit.

- [ ] **Step 5: Final commit (if fixes needed)**

```bash
git add docs/story/transport.md
git commit -m "docs(shared): fix transport system verification issues"
```

---

### Task 6: Push and Handoff

- [ ] **Step 1: Run final quality check**

```bash
pnpm lint
git status
```

- [ ] **Step 2: Push to remote**

```bash
git pull --rebase
command -v bd >/dev/null && bd sync
git push
git status
```

- [ ] **Step 3: Handoff**

Gap 3.1 is complete. Next steps:
- Run `/create-pr` to open a PR targeting main
- Then `/story-review-loop-cope <PR#> 5` to run antagonistic review
- Remaining gaps: 3.6 (NG+), 3.7 (Full Dialogue Script)
