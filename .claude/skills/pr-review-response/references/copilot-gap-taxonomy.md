# Copilot Gap Taxonomy

Categories for classifying gaps between our story-review-loop agents
and Copilot findings. Used by the **mandatory** gap analysis step in
pr-review-response (Step 6).

## Categories

| Category | Description | Agent Responsible | Example |
|----------|-------------|-------------------|---------|
| Source verification | Value in PR doesn't match canonical source doc | Agent 6 (Canonical Verifier) | Act assignment wrong, status duration doesn't match magic.md |
| Classification | Entity type/category wrong | Agent 6 (Canonical Verifier) | World vs city dungeon mislabel |
| Numeric propagation | Number differs between files or doesn't match mechanic math | Agent 1 (Propagation) | Boss phase HP vs mechanic damage totals inconsistent |
| Exception tracking | General rule contradicted by specific exception | Agent 4 (Script Supervisor) | Stage 4 + Millhaven, immunity overriding floor |
| Reference format | Cross-file citation broken or incorrect | Agent 3 (Technical) | Section number wrong, broken link |
| Mirror staleness | Spec/plan copy diverged from story doc | Agent 1 (Propagation) | Plan says "will be updated" but update already shipped |
| Self-contradiction | Same doc contradicts itself | Agent 3 (Technical, Pass F) | Rule says X, example shows Y; summary contradicts table |
| Post-fix regression | A fix introduced a new problem | Fix step (full-section re-read) | Fixed timing but broke silence rule |
| Formula precision | Missing rounding rules, incomplete formula terms, stated ranges that don't match formula outputs | Agent 3 (Technical) | 255/256 != 1.0; floor vs round unspecified |
| Ambiguity | Unclear language, multiple interpretations, undefined edge cases | Agent 5 (Devil's Advocate) | "1.5x damage" vs "+50% damage"; timer behavior during pause |

## Agent Mapping

| Agent | Categories Caught | PR #17 Hits | PR #18 Hits | PR #22 Hits |
|-------|-------------------|------------|------------|------------|
| Agent 1 (Propagation) | Mirror staleness, Numeric propagation | 5 | 6 | 6 |
| Agent 3 (Technical) | Self-contradiction, Formula precision, Reference format | 10 | 1 | 1 |
| Agent 4 (Script Supervisor) | Exception tracking | 0 | 0 | 0 |
| Agent 5 (Devil's Advocate) | Ambiguity | 2 | 4 | 2 |
| Agent 6 (Canonical Verifier) | Source verification, Classification | 1 | 5 | 4 |

## How to Use

1. Filter Copilot comments (user.login == "Copilot")
2. For EACH comment:
   a. Match to the most specific category above
   b. Map to the responsible agent
   c. Check `story-review-loop/references/verification-checklists.md`
   d. If not covered, draft a one-line checklist item
3. Present new items to user for approval
4. Commit approved items to verification-checklists.md
5. Add entry to gap-analysis-log.md

## Gap Analysis Log

### PR #17 (2026-03-21) — 20 Copilot comments, 12 gaps

**Top patterns:**
- Formula precision (variance 100% vs 99.61%): 4 comments, same root cause
- Self-contradiction (floor omission, crit contradiction): 5 comments
- Mirror staleness (spec/plan copies stale): 3 comments

**Outcome:** 11 new checklist items proposed, all applied.

### PR #18 (2026-03-21) — 14 Copilot comments, 6 gaps

**Top patterns:**
- Mirror staleness (stale "will be updated" notes): 4 comments
- Source verification (Sleep/Petrify cures wrong): 3 comments
- Ambiguity (Berserk notation, Wait mode timers): 3 comments

**Outcome:** Checklist items from PR #17 would have caught 3 of 6.
Remaining 3 covered by new items.

### PR #19 (2026-03-22) — 30 Copilot comments across 4 rounds, ~20 gaps

**Top patterns:**
- Formatting (em dash vs double-hyphen, en dash for ranges): 8 comments
- Elemental profile mismatch (act file vs palette-families): 6 comments
- Self-contradiction (Vein Guardian type/phase, spec count): 5 comments
- Copyright/tooling (reference bestiaries, scraper): 4 comments
- Boss mechanic accuracy (Vein Guardian phases): 2 comments

**Outcome:** Story-review-loop caught 29% initially. Step 6b process
added. Verification checklists updated with role-based exception
documentation rule.

### PR #20 (2026-03-22) — 26 Copilot comments across 2 rounds, ~18 gaps

**Top patterns:**
- Mirror staleness (role bounds in spec/plan/CONTINUATION): 6 comments
- Boss mechanic divergence (Cordwyn abilities, Ashen Ram phases,
  Forge Warden resistance — details differ from dungeons-world.md): 5 comments
- Elemental profile mismatch (act-ii vs palette-families): 6 comments
- Count inconsistency (12 vs 11 families): 2 comments
- Conditional weakness not in stat table: 1 comment

**Outcome:** Story-review-loop caught 73% initially (up from 29% on
PR #19). 5 new checklist items added to "Mirror Propagation" section.
Root cause: propagation sweep after updating README.md role limits
did not grep ALL files for the old values. Boss mechanic notes need
word-by-word comparison with dungeon source, not just HP verification.

### PR #22 (2026-03-23) — 16 Copilot comments across 2 rounds, ~12 gaps

**Top patterns:**
- Classification (name collision, tier mislabel, tier cap): 4 comments
  - Pallor Regent name collision (Royal Wraith Tier 3 vs Hawk Tier 4)
  - Storm Wraith listed as Tier 3 (is Tier 2 in palette-families)
  - Hawk family only has 3 tiers — no Tier 4 exists
- Mirror staleness (type in spec/plan, elemental profiles): 6 comments
  - Void Moth type=Beast in spec/plan (should be Elemental)
  - Roc missing Weak=Storm per palette-families
  - Pictograph Wisp missing Absorbs=Ley per palette-families
  - Void Crystal weakness already fixed but Copilot reviewed old commit
- Numeric propagation (threat multiplier, level mismatch): 2 comments
  - Thunder Drake/Void Moth deployed at lower level+threat than projected
- Ambiguity (missing early deployment notes): 2 comments
  - Thunder Drake, Void Moth, Void Wisp all lacked notes

### PR #24 (2026-03-23) — 6 Copilot comments, 3 new gaps

**Top patterns:**
- Self-contradiction (formatting): 3 comments
  - Archive Keeper HP dash inconsistency (double-hyphen vs en dash)
  - Duplicate `### Boss Notes` headings in interlude.md and optional.md
- Ambiguity: 1 comment
  - Cael HP "45,000 + 35,000" reads as sum, not per-phase breakdown
- False positive: 1 comment
  - `.beads-credential-key` flagged as secret (it is not)

**Outcome:** 3 new checklist items added to "Formatting Consistency"
section: en dash for numeric ranges in stubs, per-phase HP notation
for multi-row bosses, unique heading names when repeated in one file.
- Reference format (naming inconsistency): 1 comment
  - "Crystal Warden Deep" vs "Crystal Warden (Deep)"

**Outcome:** Story-review-loop (Round 1, pre-Copilot) caught 15 issues.
Copilot then found 16 more across 2 rounds. 5 new checklist items
proposed. Root cause: agents don't verify tier labels in summaries,
don't check name uniqueness across families, and don't enforce early
deployment notes for all level gaps >5. PROCESS FAILURE: Step 6 (gap
analysis) and Step 6b (story-review-loop) were BOTH skipped on
Copilot Round 2. Root cause identified as system-reminder loading
incomplete skill version. Structural fix applied to AGENTS.md and
skill frontmatter.

### PR #22 Round 3 (2026-03-23) — 3 Copilot comments, 2 new gaps

**Patterns:**
- Mirror staleness (Shadow Wolf elemental profile): 1 comment — already
  covered by existing checklist item
- Self-contradiction (Pictograph Wisp note says variable absorption,
  stat table says fixed Ley): 1 comment — new pattern
- Ambiguity (Confluence Elemental "—" reads as "none" when profile
  actually varies by cycle): 1 comment — new pattern

**Outcome:** 2 new checklist items added to "Stat Table Clarity" section.
First round where Step 6 gap analysis was properly executed per the
structural fix. Process working as intended.

### PR #22 Round 6 (2026-03-23) — 2 Copilot comments, 1 new gap

**Patterns:**
- Reference format (Vaelith Drop column has two items combined with
  "+", breaking single-item convention): 1 comment — new pattern
- Post-fix regression (Pallor Regent early deployment note references
  enemy not in act-iii after rename to Pallor Roc): 1 comment —
  covered by existing propagation sweep rule

**Outcome:** 1 new checklist item added to "Stat Table Clarity"
(single item per Drop/Steal cell). Propagation sweep should have
caught the stale Pallor Regent note during the rename.

### PR #23 (2026-03-23) — 10 Copilot comments, 1 new gap

**Top patterns:**
- Numeric propagation (boss Gold exceeds 10K cap): 3 comments — new
- Reference format (double-hyphens in headers/table cells): 2 comments
- Mirror staleness (README stale text, CONTINUATION files column,
  gap tracker wording): 3 comments — all covered by existing checklists
- Self-contradiction (type distribution percentages): 1 comment —
  already fixed before Copilot reviewed
- Ambiguity (boss HP range vs README): 1 comment — already addressed
  in level classification note

**Outcome:** 1 new checklist item (boss Gold must respect 10K cap).
Story-review-loop caught the README stale text before Copilot.
6 of 10 issues were already covered by existing checklists.

### PR #27 (2026-03-24) — 14 Copilot comments, 7 new gaps

**Top patterns:**
- Self-contradiction (economy rules vs pre-existing story content): 8 comments
  - "No vendor trash" but items.md has sell-only items
  - "No financial services" but city-carradan.md has Moneylender
  - Cross-references rule says "don't duplicate" but economy.md has shop prices
  - Rest item stack 99 vs items.md default 199
  - Sell price rule doesn't address materials without buy prices
- Mirror staleness (gap tracker checklist wording): 2 comments
  - Scrip conversion rate still in checklist after single-currency design
  - Special services wording doesn't match implemented design
- Formula precision (Caldera inn pricing): 1 comment
  - Math unclear for standard vs inflated vs card prices
- Reference format (ASCII map bracket spacing): 1 comment
- Ambiguity (Sea Prince's Signet vague description): 1 comment
- Already fixed (Caldera Potion example): 1 comment

**New pattern identified:** Economy rule establishment. When a new doc
(economy.md) asserts a universal rule, pre-existing content in other
files may contradict it. Our agents check propagation of CHANGES but
not whether a NEW RULE contradicts OLD UNCHANGED content.

**Outcome:** 3 new checklist items added to "Economy Rule Consistency"
section. 6 of 14 already covered by existing checklists. 1 already
fixed by story-review-loop. Story-review-loop (pre-Copilot) caught the
moneylender issue partially — Round 1 acknowledged it but didn't
fully resolve the "no financial services" wording.

### PR #30 (2026-03-25) — 11 Copilot comments, 3 new gaps

**Top patterns:**
- Mirror staleness (Infiltrator's Cloak location, Tunnel Map scope): 4 comments
  - Spec/plan said "Ley Line Depths F2" (should be Axis Tower F2)
  - Tunnel Map was scoped to "Bellhaven only" but dungeons-city.md applied
    it to Corrund sewers too (fixed: now "Bellhaven Tunnels, Corrund Sewers")
- Source verification (Infiltrator's Cloak Act I vs Interlude): 1 comment
- Self-contradiction (Tier 1 + "fixed only", section intro scope): 2 comments
  - Catacombs escape: Tier 1 implies random encounters but text says fixed only
  - Combat Mechanic Accessories intro says "Interlude through Act III"
    but table has Act II entries
- Formula precision (random() vs random_int() notation): 1 comment
- Numeric consistency (8x Ley Moth exceeds enemy count limit): 1 comment
- Ambiguity (em dash consistency): 1 comment
- Already fixed by story-review-loop: 1 comment (Infiltrator's Cloak Act)

**New patterns identified:**
1. Function notation consistency within a document — agents don't check
   that new pseudocode matches the existing notation style
2. Section intro scope drift — agents don't verify that header/intro
   text still covers all entries after new rows are added to a table
3. Formation enemy count limits — agents don't verify enemy counts in
   formation tables against the documented per-encounter maximum

**Outcome:** 3 new checklist items added: notation consistency (Formula
Precision), section intro scope (Internal Coherence), formation enemy
count limit (Numeric Consistency). Story-review-loop caught 5 of 8
unique issues before Copilot. Copilot found 3 genuinely new gaps.

### PR #32 (2026-03-26) — 10 Copilot comments, 2 new gaps

**Top patterns:**
- Source verification (ASCII example non-canonical names): 5 comments
  - Item screen: "Echo Screen", "Fenix Down", "Dried Meat" (FF6 names)
  - Magic screen: "Fire", "Bolt", "Cure 2" (FF6 spell names)
  - Equipment screen: "Iron Sword" (not in equipment.md)
  - Ley Crystal screen: "Flame Crystal" (generic, not canonical)
  - Shop screen: "Iron Sword", "Steel Sword" (same pattern)
- Reference format (cross-ref section names): 3 comments
  - 2 already fixed by story-review-loop round 1 (Copilot reviewed old commit)
  - 1 in spec file (not fixed by story-review-loop which only fixed ui-design.md)
- Ambiguity (ATB diagram annotation vs prose): 1 comment
- Mirror staleness (spec cross-refs stale): 1 comment

**New pattern identified:** ASCII example canonical compliance. When
ASCII diagrams use entity names (equipment, items, spells, crystals),
those names must be verified against canonical source docs. Our agents
verified prose cross-references but not example data in diagrams.

**Outcome:** 2 new checklist items added to "ASCII Example Canonical
Compliance" section. Story-review-loop caught 3 of 10 issues before
Copilot (the cross-ref section name fixes). Copilot found 5 instances
of the same new pattern (non-canonical ASCII names). All 10 addressed.

### PR #33 (2026-03-26) — 52 Copilot comments across 6 rounds, 4 new gaps

**Top patterns:**
- Source verification (wrong boss names/acts/levels/HP): 12 comments
  - "Fenmother (14)" should be "Corrupted Fenmother (12), 18,000 HP"
  - "Siege Commander (18) Act I" should be "The Ashen Ram (22) Act II"
  - "Tide Wraith (26) boss" — Tide Wraith is Lv 19 regular, no boss
  - "~8,000 HP Fenmother" should be 18,000 HP
- Self-contradiction (pacing targets vs examples): 10 comments
  - Doc says "2-4 hits" but examples show 1-hit kills
  - "Party average" claim contradicts "from primary attacker" source
  - Vein Guardian "2-3 min target" didn't exist in own table
- Mirror staleness (spec/plan not updated): 10 comments
- Formula precision (duration math, healing_overhead units): 8 comments
  - 1500 DPS at 1.2s produced 29s base (absurd for 6-8 min fight)
  - healing_overhead defined as "20-30%" but added as seconds
- Exception tracking (flee + boss disable): 2 comments
- Reference format (Flee Formula, Faint-and-Fast-Reload hyphenation): 6 comments
- Item availability (missing "limited stock" qualifiers): 2 comments
- Ambiguity (Level Buffer column vs Lv explanation): 2 comments

**New patterns identified:**
1. Boss roster verification — agents don't verify boss name/act/level
   against bestiary/bosses.md when referenced in balance docs
2. Cross-doc pacing target alignment — agents don't check new pacing
   targets against existing targets in combat-formulas.md
3. Formula term units — agents don't verify variable definitions specify
   units (seconds vs multiplier vs percentage)
4. Item availability qualifiers — agents don't preserve "(limited stock)"
   qualifiers from items.md

**Outcome:** 5 new checklist items added to "Boss Roster & Pacing
Verification" section. Story-review-loop (pre-Copilot) caught only 2
of 52 issues (4% catch rate) — worst performance to date. Root cause:
balance docs reference boss facts and pacing targets that our agents
have never been instructed to verify. The new checklist items should
prevent this class of error on future balance/pacing PRs.

### PR #34 (2026-03-26) — 7 Copilot comments, 2 new gaps

**Top patterns:**
- Self-contradiction (code block identifier hygiene): 3 comments
  - `*` annotation markers inside `condition:` values in code blocks
  - Readers/parsers would treat `*` as part of the flag name
- Self-contradiction (rule vs example): 2 comments
  - "exactly one" consequence type vs Section 4.3 allowing both
  - `score_delta: 0` vs "must have at least one consequence"
- Ambiguity (scope claim mismatch): 1 comment
  - Flag note says "all flags match events.md" but 3 are new/pending
- Reference format (plain text cross-ref): 1 comment
  - `dialogue-system.md` as plain text instead of Markdown link

**New patterns identified:**
1. Code block identifier hygiene — annotation markers (`*`, `†`) must
   not appear inside code block identifiers/expressions. Annotations
   belong in surrounding prose, not inline in copy-pasteable syntax.
2. Scope claim accuracy — universal scope claims ("all X match Y")
   must account for exceptions or qualify the scope explicitly.

**Outcome:** 2 new checklist items added: "Code Block Identifier
Hygiene" (new section) and scope claim accuracy (added to "Ambiguity
Prevention"). 3 of 7 already partially covered by existing Internal
Coherence and Cross-Reference Format checklists. Story-review-loop
Round 1 found 7 additional issues (all fixed).

### PR #34 Round 2 (2026-03-26) — 2 Copilot comments, 1 new gap

**Patterns:**
- Ambiguity (bracket notation leaking between contexts): 1 comment
  - AND example used `[...]` priority-stack notation in condition context
- Ambiguity (terminology overload): 1 comment
  - `lines` array vs rendered text lines; `line_N` index ambiguous

**Outcome:** 1 new checklist item added to "Ambiguity Prevention":
terminology overload in data formats + notation consistency across
contexts. Both comments fixed with inline clarifications.

### PR #105 Round 3 (2026-04-01) — 9 Copilot comments, 4 new gaps

**Top patterns:**
- Defensive Coding / nested type safety: 2 comments
  - FFR `data["world"]["gold"]` without checking `world` is Dictionary
  - `_load_most_recent_save` `meta.get()` on potentially non-Dictionary
- Documentation Accuracy / spec drift: 3 comments
  - Spec status still says "pending implementation" after PR implements it
  - Spec says `scale_mode: 1 (integer)` but project.godot says `"integer"`
  - common-issues.md heading says "10 categories" but 12 exist (x2)
- Naming & Style / class_name on autoloads: 3 comments
  - DataManager, AudioManager, EventFlags class_name alignment
  - Already fixed in Round 2 commit — replies missed

**New patterns identified:**
1. Spec status field drift — spec documents not updated when implemented
2. Meta-document internal consistency — review reference docs with
   counts/headings that drift after additions
3. Nested dictionary type safety — chained `[]` access needs each
   level validated, not just top-level key existence
4. Spec-to-project-setting alignment — spec notation vs actual Godot
   project.godot string format

**Outcome:** 4 new checklist items added to godot-review
verification-checklists.md (1 Defensive Coding, 3 Documentation
Accuracy). 3 new items added to common-issues.md Category 12.
Pre-Copilot catch rate: 33% (3/9). Cumulative from PR #105: 25 new
checklist items across 3 Copilot rounds.
