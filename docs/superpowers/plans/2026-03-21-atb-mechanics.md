# ATB Gauge Mechanics Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add ATB gauge mechanics to `docs/story/combat-formulas.md` —
fill rate formula, battle speed config, Active/Wait mode, status effect
interactions, turn order resolution, and party size rules.

**Architecture:** Pure documentation pass — add a new ATB section to
combat-formulas.md, update magic.md (Stop duration, Berserk modifier),
and update the gap tracker. Three files modified.

**Tech Stack:** Markdown, git, pnpm (for lint/test verification)

**Spec:** `docs/superpowers/specs/2026-03-21-atb-mechanics-design.md`

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `docs/story/combat-formulas.md` | Modify | Add ATB Gauge System section |
| `docs/story/magic.md` | Modify | Update Stop duration, add Berserk ATB modifier |
| `docs/analysis/game-design-gaps.md` | Modify | Gap 2.2 status update |

**Note:** The spec lists `.claude/skills/pod-dev/SKILL.md` as "Modify
(add ATB reference if needed)." No change is needed — pod-dev already
references combat-formulas.md in its story docs list, and the ATB
section is added to that file. No separate ATB reference required.

---

## Chunk 1: Add ATB Section to combat-formulas.md

### Task 1: Add ATB Gauge System section

**Files:**
- Modify: `docs/story/combat-formulas.md` (insert before "## Integration Notes", currently line 439)
- Reference: `docs/superpowers/specs/2026-03-21-atb-mechanics-design.md`

- [ ] **Step 1: Read combat-formulas.md to find insertion point**

Read the file. The new ATB section should be inserted BEFORE the
"## Integration Notes" section (the last section). This keeps ATB
as part of the combat system, with Integration Notes as the closing
section.

- [ ] **Step 2: Add the ATB Gauge System section**

Insert the following new section before "## Integration Notes":

```markdown
---

## ATB Gauge System

The Active Time Battle gauge determines when each combatant acts.
The gauge fills continuously based on SPD; when it reaches maximum,
the combatant takes a turn. See [progression.md](progression.md)
for SPD stat values and growth rates.

### Fill Rate Formula

```
fill_rate = floor((effective_SPD + 25) * battle_speed_factor * status_modifier_product)
```

**Full pipeline (order of operations):**

1. `effective_SPD = floor(base_SPD * crystal_modifier)` (e.g., Frost
   Veil: crystal_modifier = 0.85)
2. `base_fill = (effective_SPD + 25) * battle_speed_factor`
3. `fill_rate = floor(base_fill * status_modifier_product)` (e.g.,
   Haste × Despair = 1.5 × 0.75 = 1.125)

All intermediate values use real-number arithmetic. The final
fill_rate is floored to an integer. Each tick (60/second), the gauge
increases by exactly fill_rate.

**Constants:**

| Constant | Value | Purpose |
|----------|-------|---------|
| Base speed | 25 | Floor ensures even SPD 1 is playable |
| Gauge max | 16,000 | Total gauge capacity |
| Tick rate | 60/second | Fixed frame rate for gauge updates |

**Time to fill:** `seconds = 16000 / fill_rate / 60`

### Battle Speed Config

Player-configurable (1-6, default 3). Default matches FF6.

| Setting | Factor | Maren Lv1 (SPD 8) | Sable Lv1 (SPD 18) |
|---------|--------|-------------------|-------------------|
| 1 (Fastest) | 6 | 1.3s | 1.0s |
| 2 | 5 | 1.6s | 1.2s |
| **3 (Default)** | **3** | **2.7s** | **2.1s** |
| 4 | 2 | 4.0s | 3.1s |
| 5 | 1.5 | 5.4s | 4.1s |
| 6 (Slowest) | 1 | 8.1s | 6.2s |

### Active/Wait Mode

- **Active (default):** All gauges fill continuously. Enemy gauges
  fill while browsing spell/item menus. Time pressure on every
  decision.
- **Wait:** Gauges pause for ALL combatants while any command
  sub-menu is open (Magic, Item, Ability lists, target selection).
  Real-time status timers (e.g., Stop countdown) also pause during
  Wait sub-menus. Top-level command selection
  (Attack/Magic/Ability/Item/Defend/Flee) still runs in real-time.

Both settings in Config menu. Defaults: Active mode, Battle Speed 3.

### ATB Pacing at Key Milestones (Battle Speed 3)

| Scenario | SPD | Fill Rate | Seconds/Turn |
|----------|-----|-----------|-------------|
| Maren Lv1 | 8 | 99 | 2.7s |
| Sable Lv1 | 18 | 129 | 2.1s |
| Maren Lv70 | 49 | 222 | 1.20s |
| Edren Lv70 | 65 | 270 | 0.99s |
| Sable Lv70 | 128 | 459 | 0.58s |
| Sable Lv70 + Haste | 128 | 688 | 0.39s |
| Typical Lv70 enemy (SPD 60) | 60 | 255 | 1.0s |

### Fill Rate Modifiers (Status Effects)

Multiple modifiers stack multiplicatively:

| Status | Modifier | Notes |
|--------|----------|-------|
| Haste (Quickstep) | × 1.5 | 5 turns. See [magic.md](magic.md). |
| Slow (Leaden Step) | × 0.5 | 5 turns. |
| Despair | × 0.75 | 4 turns. Also -20% damage dealt. |
| Grounded | × 0.75 | 3 turns. Flying enemies only. |
| Berserk | × 1.25 | Until cured. Also +50% basic attack damage. |

Stacking example: Haste + Despair = 1.5 × 0.75 = 1.125 (net +12.5%).

### Status Effect ATB Interactions

| Status | Gauge Behavior | When Fills | Duration | Notes |
|--------|---------------|-----------|----------|-------|
| Haste | × 1.5 | Normal turn | 5 turns | |
| Slow | × 0.5 | Normal turn | 5 turns | |
| Stop | Frozen (0) | Cannot act | 3 real-time seconds | Not turn-based — clock time |
| Sleep | Frozen at current value | Cannot act | Until cured or damaged | Resumes from frozen point |
| Confusion | × 1.0 | Auto-attack random target | 3 turns or until damaged | |
| Berserk | × 1.25 | Auto-attack random enemy (+50% basic attack damage) | Until cured | Tradeoff |
| Despair | × 0.75 | Normal turn (-20% damage) | 4 turns | Pallor signature |
| Grounded | × 0.75 | Normal turn (lose evasion) | 3 turns | Flying only |
| Petrify | Frozen (0) | Removed from battle | Until cured | Gauge resets to 0 on cure |

**Key rules:**
- **Frozen gauge retains value.** Sleep and Stop freeze at current
  position. Gauge resumes from that point when status ends.
- **Petrify resets to 0.** Most severe status — recovery starts fresh.
- **Stop uses real-time.** 3 seconds of clock time regardless of
  battle speed. Proportionally more punishing at slow speeds.
- **Berserk is a tradeoff.** Faster (+25%) and stronger (+50% basic
  attack) but uncontrollable. Almost a buff on physical fighters.

### Turn Order Resolution

When multiple combatants fill on the same tick:

1. Higher effective SPD acts first
2. Party before enemies (if SPD tied)
3. Left-to-right slot order (if still tied)

Fully deterministic — no RNG.

**Gauge overflow:** Excess discarded. Gauge resets to 0 after acting.
No banking extra speed.

### Party & Enemy Size

- **4 active party members** (FF6 standard). Swap at save points.
- **Guest NPCs** (Cordwyn, Kerra) take a temporary 5th slot.
- **Up to 6 enemies** per encounter.
- **Interlude:** Party scales from 1 (Sable alone) to 4.
```

- [ ] **Step 3: Verify the new section**

After inserting:
1. Recompute 3 fill rate values from the formula:
   - Maren Lv1: floor((8+25)*3*1.0) = 99. Time: 16000/99/60 = 2.69s ≈ 2.7s
   - Sable Lv1: floor((18+25)*3*1.0) = 129. Time: 16000/129/60 = 2.07s ≈ 2.1s
   - Sable Lv70+Haste: floor((128+25)*3*1.5) = floor(688.5) = 688. Time: 16000/688/60 = 0.387s ≈ 0.39s
2. Verify the status effect percentages match magic.md:
   - Quickstep/Haste: +50% (magic.md line 812)
   - Slow: -50% (magic.md line 705)
   - Despair: -25% ATB, -20% damage (magic.md line 1078)
3. Verify SPD values match progression.md base stats (line 126):
   Maren 8, Sable 18, Edren 10

- [ ] **Step 4: Commit**

```bash
git add docs/story/combat-formulas.md
cat > /tmp/commit-msg.txt << 'EOF'
docs(shared): add ATB gauge system to combat formulas (Gap 2.2)

Fill rate formula (SPD+25)*battle_speed_factor, gauge max 16000,
Active/Wait mode (default Active), battle speed 1-6 (default 3),
status effect ATB interactions, 4-party FF6-standard, deterministic
turn order resolution.
EOF
git commit -F /tmp/commit-msg.txt
```

---

## Chunk 2: Update magic.md and Gap Tracker

### Task 2: Update Stop duration and add Berserk in magic.md

**Files:**
- Modify: `docs/story/magic.md` (lines 716, 1400)

- [ ] **Step 1: Update Stop spell description**

Find the Stop spell description (line 716). Change:
Old: `55% chance to inflict Stop. Target's ATB gauge is frozen for 3 turns.`
New: `55% chance to inflict Stop. Target's ATB gauge is frozen for 3 real-time seconds (not turn-based — the target takes no turns while Stopped, so turn-based duration is meaningless). See [combat-formulas.md](combat-formulas.md).`

- [ ] **Step 2: Update Stop in status effect table**

Find the status effect summary table (line 1400). Change:
Old: `| Stop | Negative | ATB frozen | 3 turns (cannot be cured, must expire) | Wears off only |`
New: `| Stop | Negative | ATB frozen | 3 real-time seconds (not turn-based) | Wears off only |`

- [ ] **Step 3: Add Berserk ATB modifier to status table**

In the status effect summary table, find or add a Berserk row. If
Berserk does not exist in the table, add it near the other negative
statuses:

```markdown
| Berserk | Negative | ATB speed +25%, auto-attack random enemy with +50% basic attack damage | Until cured | Purge only |
```

Search the file first for "Berserk" to see if it already has an entry.

- [ ] **Step 4: Verify no other Stop references need updating**

Search magic.md for all instances of "Stop" to ensure no other
descriptions reference "3 turns" for Stop duration.

- [ ] **Step 5: Commit**

```bash
git add docs/story/magic.md
cat > /tmp/commit-msg.txt << 'EOF'
docs(shared): update Stop duration and add Berserk ATB modifier

Stop: 3 turns -> 3 real-time seconds (ATB gauge is frozen, so
turn-based duration is meaningless). Add Berserk status with
+25% ATB speed and +50% basic attack damage.
EOF
git commit -F /tmp/commit-msg.txt
```

---

### Task 3: Update gap tracker

**Files:**
- Modify: `docs/analysis/game-design-gaps.md`

- [ ] **Step 1: Update Gap 2.2 status**

Find Gap 2.2 (ATB Gauge Mechanics). Update:
- Status: PARTIAL -> MOSTLY COMPLETE
- Add `**Completed:** 2026-03-21`
- Add `**Files:** docs/story/combat-formulas.md (ATB section)`
- Check off all completed items in the checklist
- Leave the "ATB visual representation" item unchecked (deferred to
  Gap 2.3)
- Update the "Blocking" line

- [ ] **Step 2: Add progress tracking row**

Add to the Progress Tracking table:
```markdown
| 2026-03-21 | 2.2 ATB Gauge Mechanics | PARTIAL -> MOSTLY COMPLETE. Fill rate formula, Active/Wait, battle speed 1-6, status interactions, party size. Visual deferred to 2.3. | <commit-sha> |
```

- [ ] **Step 3: Commit**

```bash
git add docs/analysis/game-design-gaps.md
cat > /tmp/commit-msg.txt << 'EOF'
chore(shared): update gap tracker for ATB mechanics

Gap 2.2 (ATB Gauge Mechanics): PARTIAL -> MOSTLY COMPLETE.
Visual representation deferred to Gap 2.3 (UI Design).
EOF
git commit -F /tmp/commit-msg.txt
```

---

### Task 4: Final Verification and Push

- [ ] **Step 1: Adversarial verification**

1. **Numeric consistency:** Recompute 3 ATB fill rates from
   combat-formulas.md against the formula and verify they match.

2. **Cross-reference check:** Verify:
   - combat-formulas.md Haste modifier (+50%) matches magic.md
   - combat-formulas.md Stop duration (3 real-time seconds) matches
     the updated magic.md
   - combat-formulas.md SPD values match progression.md base stats
   - combat-formulas.md Berserk modifier matches the new magic.md entry

3. **Gap tracker check:** Verify gap 2.2 status is MOSTLY COMPLETE
   and only "ATB visual representation" remains unchecked.

- [ ] **Step 2: Run lint and tests**

```bash
pnpm lint && pnpm test
```

Expected: all pass (documentation-only changes).

- [ ] **Step 3: Push**

```bash
git push
```
