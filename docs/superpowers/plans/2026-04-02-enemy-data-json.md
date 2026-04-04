# Gap 1.2: Enemy Data JSON — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert all enemy data from bestiary markdown tables into runtime JSON files in `game/data/enemies/`.

**Architecture:** 6 parallel agents transcribe one JSON file each from their source bestiary file. A verification pass audits every value against source docs. Gap tracker updated on completion.

**Tech Stack:** JSON data files, no GDScript

**Spec:** `docs/superpowers/specs/2026-04-02-enemy-data-json-design.md`

---

## File Structure

| Action | File |
|--------|------|
| Create | `game/data/enemies/act_i.json` (25 enemies) |
| Create | `game/data/enemies/act_ii.json` (33 enemies) |
| Create | `game/data/enemies/interlude.json` (52 enemies) |
| Create | `game/data/enemies/act_iii.json` (69 enemies) |
| Create | `game/data/enemies/optional.json` (25 enemies) |
| Create | `game/data/enemies/bosses.json` (~35 boss entries) |
| Modify | `docs/analysis/game-dev-gaps.md` (update gap 1.2 status) |

---

## Chunk 1: Parallel Transcription (6 agents)

### Task 1: Transcribe Act I enemies

**Files:**
- Create: `game/data/enemies/act_i.json`
- Read: `docs/story/bestiary/act-i.md`
- Read: `docs/story/bestiary/palette-families.md` (threat levels)
- Read: `docs/story/economy.md` (steal tiers)
- Read: `docs/superpowers/specs/2026-04-02-enemy-data-json-design.md`

**Agent instructions:** Transcribe all 25 enemies from act-i.md into JSON following the spec schema exactly. For each enemy:
1. Copy every stat value from the markdown table verbatim
2. Set `threat` from palette-families.md (or act summary: Trivial(4), Low(10), Standard(6), Dangerous(3), Boss(2))
3. Set `steal.common` from the bestiary "Steal" column
4. Set `steal.rare` from economy.md type-based patterns (Beast→tier2 material, etc.)
5. Set `drop` from the bestiary "Drop" column
6. Derive `id` as snake_case of name
7. Derive `locations` per spec derivation rules
8. Set `ko_sound` as `ko_{type}`
9. Parse `weaknesses`, `resistances`, `absorb`, `status_immunities` into arrays
10. For bosses (Ember Drake mini-boss, Vein Guardian, Drowned Sentinel mini-boss, Corrupted Fenmother): include inline with `is_boss`/`is_mini_boss` fields

**Threat assignments for Act I:**
- Trivial: Ley Vermin, Tomb Mite, Plains Hare, Restless Dead (Lv 3, Dead family Tier 1)
- Low: Unstable Crystal, Mine Shade, Bone Warden, Ember Wisp, Marsh Serpent, Bog Leech, Drowned Bones, Thornback Beetle, Road Bandit, Forest Sprite
- Standard: Swamp Lurker, Ley Jellyfish, Polluted Elemental, Corrupted Spawn, Wild Boar, Wayward Wolf
- Dangerous: The Flickering (unique), Ember Drake (mini-boss)
- Boss: Vein Guardian, Corrupted Fenmother
- Note: Drowned Sentinel is a Construct mini-boss → dangerous threat

- [ ] **Step 1:** Read act-i.md, palette-families.md, economy.md, and spec
- [ ] **Step 2:** Create `game/data/enemies/act_i.json` with all 25 enemies
- [ ] **Step 3:** Self-verify: count enemies (must be 25), check all IDs unique, all stats match source

---

### Task 2: Transcribe Act II enemies

**Files:**
- Create: `game/data/enemies/act_ii.json`
- Read: `docs/story/bestiary/act-ii.md`
- Read: `docs/story/bestiary/palette-families.md`
- Read: `docs/story/economy.md`
- Read: `docs/superpowers/specs/2026-04-02-enemy-data-json-design.md`

**Agent instructions:** Same process as Task 1 for all 33 enemies.

**Key notes:**
- Pallor-Touched Worker: `"non_lethal": true, "gold": 0, "exp": 0, "steal": { "common": { "item_id": "potion", "rate": 75 }, "rare": null }`
- Downed Pilot: spawned enemy, location = parent encounter location
- Compact Gyrocopter: has spawn-on-death mechanic (data note only, not encoded)
- The Ashen Ram: boss with 3 phases

- [ ] **Step 1:** Read act-ii.md, palette-families.md, economy.md, and spec
- [ ] **Step 2:** Create `game/data/enemies/act_ii.json` with all 33 enemies
- [ ] **Step 3:** Self-verify: count (33), unique IDs, stats match

---

### Task 3: Transcribe Interlude enemies

**Files:**
- Create: `game/data/enemies/interlude.json`
- Read: `docs/story/bestiary/interlude.md`
- Read: `docs/story/bestiary/palette-families.md`
- Read: `docs/story/economy.md`
- Read: `docs/superpowers/specs/2026-04-02-enemy-data-json-design.md`

**Agent instructions:** Same process for all 52 enemies across 6 dungeons.

**Key notes:**
- Multiple instances of same enemy name at different levels (e.g., Pallor Wisp appears at Lv 20, 22, 24, 26 in different dungeons). Each gets a SEPARATE entry with a unique ID: `pallor_wisp_rail_tunnels`, `pallor_wisp_valdris_catacombs`, etc.
- Grey Mite appears at different levels (Lv 18, 20, 22, 24) — separate entries per dungeon
- Pallor Seep appears at Lv 20 and Lv 22 — separate entries
- Restless Dead (Lv 20, Catacombs escape) is a different entry than Act I's Lv 3 version
- Pallor-Touched Soldier: Humanoid type (NOT Pallor), pre-existing corruption
- The Ironbound boss, Corrupted Boring Engine mini-boss, Undying Warden, Pallor Nest Mother, General Vassar Kole

- [ ] **Step 1:** Read interlude.md, palette-families.md, economy.md, and spec
- [ ] **Step 2:** Create `game/data/enemies/interlude.json` with all 52 enemies
- [ ] **Step 3:** Self-verify: count (52), unique IDs, stats match, duplicate names have location suffixes

---

### Task 4: Transcribe Act III enemies

**Files:**
- Create: `game/data/enemies/act_iii.json`
- Read: `docs/story/bestiary/act-iii.md`
- Read: `docs/story/bestiary/palette-families.md`
- Read: `docs/story/economy.md`
- Read: `docs/superpowers/specs/2026-04-02-enemy-data-json-design.md`

**Agent instructions:** Same process for all 69 enemies across 10 areas. This is the largest file.

**Key notes:**
- Enemies reappearing at different levels across areas need location-suffixed IDs (Pallor Soldier at Lv 26 in Axis Tower vs Lv 34 in Convergence)
- Pallor Revenant, Pallor Wolf, Pallor Shade appear in both Ironmark (Interlude) and Act III — the Act III entries are separate enemies at different levels
- Trial-specific enemies (Hollow Knight, Unfinished Construct, Stone Spirit, Archived) have unique locations
- Confluence Elemental: `"weaknesses": ["cycle"], "absorb": ["cycle"]`
- Archive Keeper: `"hp": 3000, "hp_max_variable": 12000`
- Vaelith Siege: `"scripted_loss": true, "hp": 999999`
- Cael has 2 phase entries, Pallor Incarnate is single entry
- Ley Abomination: Boss type despite appearing in regular encounter list
- The Forge Warden boss has explicit multiplier weaknesses: Storm (150%), Spirit (125%)
- The Grey Keeper: `"gold": 0` (tragedy, not reward)

- [ ] **Step 1:** Read act-iii.md, palette-families.md, economy.md, and spec
- [ ] **Step 2:** Create `game/data/enemies/act_iii.json` with all 69 enemies
- [ ] **Step 3:** Self-verify: count (69), unique IDs, stats match, duplicate names resolved

---

### Task 5: Transcribe Optional (Dreamer's Fault) enemies

**Files:**
- Create: `game/data/enemies/optional.json`
- Read: `docs/story/bestiary/optional.md`
- Read: `docs/story/bestiary/palette-families.md`
- Read: `docs/story/economy.md`
- Read: `docs/superpowers/specs/2026-04-02-enemy-data-json-design.md`

**Agent instructions:** Same process for all 25 enemies across 5 ages.

**Key notes:**
- All Void enemies (Floors 17-20) are Pallor type with Spirit weakness
- Void Walker does NOT resist Void (unique — it IS the Void)
- Pallor Drake, Pallor Wolf, Pallor Lurker, Pallor Regent appear at much higher levels than Act III versions — these are separate entries with `_void` suffix IDs
- Echo bosses: The First Scholar, Crystal Queen, Rootking, Iron Warden
- Item names are Gap 1.4 placeholders but should be transcribed as-is

- [ ] **Step 1:** Read optional.md, palette-families.md, economy.md, and spec
- [ ] **Step 2:** Create `game/data/enemies/optional.json` with all 25 enemies
- [ ] **Step 3:** Self-verify: count (25), unique IDs, stats match

---

### Task 6: Transcribe Boss compendium

**Files:**
- Create: `game/data/enemies/bosses.json`
- Read: `docs/story/bestiary/bosses.md` (full file — very large, 57K+ tokens)
- Read: All per-act bestiary files (for boss stat rows already transcribed)
- Read: `docs/superpowers/specs/2026-04-02-enemy-data-json-design.md`

**Agent instructions:** Create the boss-specific JSON with additional metadata fields. For each boss:
1. Copy the stat block from the per-act bestiary file (or bosses.md quick reference)
2. Add boss-specific fields: `is_boss`, `is_mini_boss`, `phases`, `phase_hp_thresholds`, `boss_group`
3. Phase HP thresholds: read from bosses.md AI scripts (each boss has explicit phase transition HP%)
4. Multi-phase bosses with separate stat rows (Cael, The Lingering) get separate entries linked by `boss_group`

**Boss list (35 entries):**
Bosses 1-31 from quick reference table + Vaelith Siege + extra Cael Phase 2 entry + 2 extra Lingering phase entries = 35 total.

- [ ] **Step 1:** Read bosses.md (focus on quick reference + phase thresholds per boss), read spec
- [ ] **Step 2:** Create `game/data/enemies/bosses.json` with all 35 boss entries
- [ ] **Step 3:** Self-verify: count (35), phase counts match quick reference, HP values match

---

## Chunk 2: Verification & Completion

### Task 7: Adversarial verification pass

**Files:**
- Read: All 6 JSON files created in Tasks 1-6
- Read: All bestiary source files
- Read: `docs/story/bestiary/palette-families.md` (threat levels)

**Instructions:** Cross-reference every JSON file against its source bestiary file. Check:

- [ ] **Step 1:** Verify enemy counts per file match expected totals (25, 33, 52, 69, 25, 35)
- [ ] **Step 2:** Spot-check 5 random enemies per file — verify every stat value matches source
- [ ] **Step 3:** Verify all boss HP values match bosses.md quick reference exactly
- [ ] **Step 4:** Verify all IDs are globally unique across all 6 files
- [ ] **Step 5:** Verify element arrays: every weakness/resistance/absorb matches bestiary
- [ ] **Step 6:** Verify steal.common matches bestiary "Steal" column for 10 random enemies
- [ ] **Step 7:** Verify threat levels match palette-families.md for 10 random enemies
- [ ] **Step 8:** Verify special cases: Pallor-Touched Worker, Archive Keeper, Vaelith Siege, Confluence Elemental
- [ ] **Step 9:** Fix any errors found, re-verify fixed entries

---

### Task 8: Update gap tracker and commit

**Files:**
- Modify: `docs/analysis/game-dev-gaps.md`

- [ ] **Step 1:** Update gap 1.2 status to COMPLETE in game-dev-gaps.md
- [ ] **Step 2:** Check off all completed items in the "What's Needed" list
- [ ] **Step 3:** Add note about two-tier steal decision resolution
- [ ] **Step 4:** Check if this unblocks downstream gaps and note them
- [ ] **Step 5:** Stage and commit all files

```bash
git checkout -b feature/game-designer-1.2-enemy-data
git add game/data/enemies/ docs/analysis/game-dev-gaps.md docs/superpowers/specs/2026-04-02-enemy-data-json-design.md docs/superpowers/plans/2026-04-02-enemy-data-json.md
git commit -m "feat(engine): add enemy data JSON files (gap 1.2)"
```

- [ ] **Step 6:** Push and hand off to `/create-pr` → `/godot-review-loop`
