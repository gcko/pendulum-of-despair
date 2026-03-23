# Verification Checklists

Reference for review agents (primarily Agent 1 and Agent 6).
Each item is a single check. Grows from Copilot gap analysis.

## Entity Property Verification

- Location act availability matches locations.md
- Dungeon act availability matches dungeons-world.md or dungeons-city.md
- Dungeon classification (world/city) matches canonical source doc
- Dungeon canonical name matches exactly (no parenthetical variants)
- Character pronouns match characters.md
- Corruption stages match dynamic-world.md / biomes.md
- Numeric properties (duration, timing, HP) match across all files
- Status duration text must match canonical source (magic.md) exactly

## Cross-Reference Format Verification

- Section citations use correct heading format from target doc
- Relative links point to files that exist
- "Per <doc>" claims reference real sections in that doc

## Mechanic Exception Tracking

- When a general rule is stated, verify no entity has a documented
  exception that contradicts it
- When an exception is documented, verify the general rule
  acknowledges it
- "Destroyed" locations should not be assigned corruption stages

## Internal Coherence (New Content)

- Section numbering is monotonic (no 5.5 before 5.4, no duplicate numbers)
- Diagram labels match the text they summarize (no hard-coded values that drift)
- Terms introduced in one paragraph are not contradicted by an adjacent
  paragraph in the same section (e.g., "first non-musical sound" vs palette
  that includes the same sound type)
- Multi-step workflow descriptions have unambiguous ordering (no "commit
  and push" in step 5 AND step 5b without clarifying which push is canonical)
- Template/example values must be generic or conditional on context (not
  hard-coded to one use case when multiple exist)

## Spec/Plan Mirror Checks

- When music.md changes, check spec sections 3-13 for mirrored content
- When events.md section 2c changes, check spec sections 4-5
- Plan "verbatim" instructions must match actual implementation
- Spec/plan notes saying a source doc "will be updated" must be resolved
  or removed when that update ships in the same PR
- Gap tracker checklist items must be updated when the canonical formula
  they reference changes

## Formula Precision (from Copilot gap analysis, PR #17-18)

- Verify stated numeric ranges (min/max percentages) match actual formula
  outputs (e.g., `255/256 = 0.996` not `1.0`)
- Canonical formulas must specify rounding behavior (floor/round) and
  application point (per-step vs end)
- Inline formula excerpts must include all terms from canonical source
  or be explicitly labeled as partial with a link to the full formula
- Resolution/pipeline steps must include all bounds (floor, cap) stated
  elsewhere in the same document

## Ambiguity Prevention (from Copilot gap analysis, PR #17-18)

- When a floor/cap/override rule is stated, verify all exception cases
  (immunity, absorb, multi-hit) are explicitly ordered
- Deterministic ordering rules must cover all entity types (party members
  AND enemies, not just one side)
- Multiplier notation must be consistent project-wide (use "+N%" not "Nx"
  when describing the same modifier in different locations)
- Real-time timers must specify behavior during pause states (Wait mode)

## Numeric Consistency (from Copilot gap analysis, PR #17-18)

- Boss phase HP thresholds must be arithmetically consistent with mechanic
  damage totals within the same encounter
- Numeric thresholds in encounters must be achievable given the damage
  output at the recommended progression level

## Mirror Propagation (from Copilot gap analysis, PR #19-20)

- When a canonical value is updated in README.md (e.g., role deviation
  limits), grep ALL project files for the old value and update every
  occurrence. Key mirrors: spec, plan, CONTINUATION.md, lessons learned.
- Boss notes in bestiary files must match dungeons-world.md /
  dungeons-city.md for NPC ability descriptions (name AND effect),
  phase mechanic details, and resistance values. Compare word-by-word,
  not just HP values.
- When a boss has a conditional weakness (e.g., "Flame only in Phase 3"),
  the stat table Weak column must include the condition qualifier
- Enemy counts in spec/plan/summary must match the actual table rows.
  Verify by counting, not by trusting the stated total.
- Elemental profiles in palette-families.md Tier 2+ Element Shift
  column must match the corresponding act file's stat table. act file
  is authoritative; palette-families shows the SHIFT from prior tier,
  not the absolute profile (use em dash if profile matches Tier 1).

## Family & Tier Integrity (from Copilot gap analysis, PR #22)

- Every enemy name must be unique across ALL bestiary files and
  palette-families.md. No two enemies may share a name even if in
  different families. Check before assigning names to new enemies.
- When a summary section lists "Tier N debuts," verify each enemy's
  tier matches palette-families.md. Do not trust the summary — count
  and verify against the family tables.
- When an enemy's threat level in the act file differs from
  palette-families.md, verify the Gold/Exp values match the act
  file's threat multiplier, not the family's projected threat.
- When act-file level is 5+ levels below palette-families projected
  level, palette-families MUST have an early deployment note in the
  family blockquote. Check ALL families with deployed enemies, not
  just Tier 4 Pallor variants.
- Before assigning a Tier N entry to a family, verify the family
  actually HAS that many tiers in palette-families.md. A 3-tier
  family cannot have a Tier 4 entry.

## Stat Table Clarity (from Copilot gap analysis, PR #22 round 3)

- When an enemy has a cycling or context-dependent elemental profile
  (e.g., Confluence Elemental's rotating cycle), use "Varies (cycle)"
  or "Varies (context)" in the stat table Weak/Absorbs columns. Em
  dash (—) reads as "none" and will mislead implementers.
- Design note descriptions of abilities must not contradict the stat
  table row. If the stat table says "Absorbs=Ley" (fixed baseline),
  the design note must not say "absorbs varies per encounter." Describe
  variable behavior as attack/cast element variation, not absorption
  variation.
- Stat table Drop/Steal columns must contain a single item per cell.
  Multiple guaranteed drops (e.g., bosses with 2 rewards) should list
  the primary drop in the stat table and the secondary in the boss
  notes section. Do not combine with "+" in the cell.
- Boss hand-tuned Gold must not exceed the logistic S-curve cap
  (10,000 Gold). Boss Exp must not exceed 30,000. These caps are
  hard ceilings even for hand-tuned values.
