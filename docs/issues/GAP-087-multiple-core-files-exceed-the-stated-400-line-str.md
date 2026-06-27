# GAP-087: Multiple core files exceed the stated ~400-line structure target

| Field | Value |
|-------|-------|
| **ID** | GAP-087 |
| **Area** | Code structure |
| **Severity** | LOW |
| **Type** | partial-impl |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | arch |

## Summary

Several core scripts exceed the guideline (party_state 751, exploration 719, audio_manager 710, battle_manager 550, inventory_helpers 453, menu_ley_crystal 451, cutscene_player 429); inventory_helpers was extracted to keep files under 400 yet both it and PartyState exceed it.

## Current state (implementation)

Non-urgent maintainability debt.

## Desired state (per design)

Large autoloads/scenes decomposed into cohesive sub-modules under the size budget.

## Proposed approach

Continue the extraction pattern: split PartyState into composition/stats/inventory facets and AudioManager into mixing-context vs playback modules.

## Acceptance criteria

- [ ] The largest files are decomposed toward the budget
- [ ] Responsibilities are cohesively grouped
- [ ] No behavior change

## Design references

- game/scripts/autoload/inventory_helpers.gd:3 (self-stated 400-line goal)

## Code references

- game/scripts/autoload/party_state.gd (751)
- game/scripts/core/exploration.gd (719)
- game/scripts/autoload/audio_manager.gd (710)
- game/scripts/combat/battle_manager.gd (550)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** wc -l confirms exact figures: party_state.gd 751, exploration.gd 719, audio_manager.gd 710, battle_manager.gd 550, inventory_helpers.gd 453, menu_ley_crystal.gd 451, cutscene_player.gd 429. The 400-line goal is self-stated in inventory_helpers.gd:3 ('to keep files under 400 lines'), yet inventory_helpers.gd itself (453) and PartyState (751) exceed it.
- **Notes:** Facts accurate; this is genuine maintainability debt requiring a multi-module refactor (Effort L). fixNow=FALSE — decomposing core autoloads is exactly the kind of large change that risks the test suite.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
