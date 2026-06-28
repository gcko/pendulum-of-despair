# Bundling Guide — relatedness heuristics & example bundle map

Deep reference for `/issue-bundle` Step 1 (SELECT) and Step 2 (ANALYZE).
SKILL.md stays lean; the detail lives here.

## What "related" means

Bundle issues that share a real code touchpoint, so implementing them
together is cheaper and more coherent than separately. Rank candidates
by how strongly they overlap:

### Strong signals (bundle these)

1. **Same file.** Two issues both edit
   `game/scripts/combat/battle_actions.gd` or the same JSON in
   `game/data/`. The diff naturally lives in one place.
2. **Same function / signature.** Both feed the same call — e.g. the
   `damage_calculator.gd` resolve path that takes interaction, buff, and
   type-trait multipliers. Fixing one param while the others stay neutral
   is half a change; do them together.
3. **Same system / epic.** Shop buy-mode descriptions + shop sell-mode +
   employee-card discount are one shop surface. Ley-crystal XP
   distribution + negative-effect crystals + flat-while-equipped
   progression are one crystal system.
4. **Same canonical design doc.** Every issue traces (via its
   `docs/issues/GAP-*.md`) to the same file under `docs/story/`. Reading
   the doc once serves the whole bundle.

### Weak signals (do NOT bundle on these alone)

- "Both are combat" / "both are Act I" — area overlap is not code overlap.
- "Both are HIGH severity" — priority is not relatedness.
- "Both are small" — convenience is not coherence; small unrelated
  changes still produce a noisy, hard-to-review PR.

## Bundle sizing rules

- **2-4 issues.** One issue does not need this skill; 5+ makes the PR
  hard to review and the husky gate failures hard to localize.
- **One layer.** Combat math, shop UI, overworld maps, crafting, and
  save/load are different layers. Keep a bundle inside one.
- **Split epics.** Issues flagged `Epic: Yes` in their `GAP-*.md` are
  usually too large to bundle — they are their own PR (often their own
  series of PRs). Don't fold an epic into a bundle of small siblings.
- **Drop on doubt.** If a candidate forces the bundle across a layer
  boundary, drop it from this bundle and file it for the next one.

## Analyze checklist (per issue, Step 2)

For each issue you keep:

- [ ] Read issue body + `docs/issues/GAP-*.md` detail.
- [ ] Read the `docs/story/` doc(s) it traces to; note exact values/formulas.
- [ ] Re-verify the gap still exists against current `game/` (issues can
      go stale after other bundles land).
- [ ] List the files + functions this issue touches.
- [ ] Confirm those touchpoints overlap the rest of the bundle.

Then, for the bundle as a whole:

- [ ] Identify the shared touchpoint set (files every issue edits).
- [ ] Confirm a single layer.
- [ ] Name the branch after the bundle, not one issue
      (`feature/combat-resolution-bundle`, not `feature/gap-008`).

## Example bundle map

Illustrative groupings drawn from the `gap-analysis` issue set. Treat as
a starting point — always re-verify against `gh issue list` and the
`GAP-*.md` files, since landed bundles close issues and shift the map.

| Candidate bundle | Issues | Shared touchpoint | Layer |
|------------------|--------|-------------------|-------|
| Combat resolution | GAP-003, GAP-008, GAP-010 | `damage_calculator.gd` params + `battle_actions.gd` | Combat math |
| ATB tuning | GAP-006, GAP-007 | ATB speed factors / mode config | Combat timing |
| Shop UX | GAP-017, GAP-018, GAP-022 | shop buy/sell UI + discount at register | Shop UI |
| Ley-crystal system | GAP-011, GAP-014, GAP-015 | crystal progression / XP distribution / special rules | Progression |
| Encounter system | GAP-025, GAP-026, GAP-027 | encounter increment / per-tile zones / formation overrides | Overworld |

Each row is one feature branch and one PR. Rows do **not** combine —
combat math and overworld encounters are different layers even though
both are "gameplay."

## Why bundle at all (cost model)

Implementing N related issues separately costs, per issue: a branch, a
PR, a full `/pr-review-response` loop (with its review-loop agents and
Copilot gap analysis), and a full husky pre-push run (Godot import + the
GUT suite, which is the slow part). Worse, PR #2 rebases onto PR #1 when
they touch the same file, so you re-resolve the same code twice.

Bundling pays all of that **once** for the whole set, and the reviewer
sees the related changes as the single coherent unit they actually are.
