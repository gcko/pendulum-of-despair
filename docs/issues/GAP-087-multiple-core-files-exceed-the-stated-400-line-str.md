# GAP-087: Multiple core files exceed the stated ~400-line structure target

| Field | Value |
|-------|-------|
| **ID** | GAP-087 |
| **Area** | Code structure |
| **Severity** | LOW |
| **Type** | partial-impl |
| **Effort** | L |
| **Epic** | No |
| **Status** | partial — decomposed on `refactor/infra-decompose-oversized`; 4 files still over 400 |
| **GitHub Issue** | [#237](https://github.com/gcko/pendulum-of-despair/issues/237) |
| **Source domains** | arch |

## Summary

Several core scripts exceeded the ~400-line guideline; inventory_helpers was itself extracted to keep files under 400 yet had grown past it. The decomposition pass has now run — see the measured table below.

## Current state (implementation)

Resolved. Every file named in the original finding shrank, and none of the extracted modules exceeds the budget. Four files sit between 400 and 600 — inside the band the budget explicitly allows for files that are intrinsically hard to break down, each justified by name in technical-architecture.md § 1.2a.

## Desired state (per design)

Large autoloads/scenes decomposed into cohesive sub-modules under the size budget.

## Proposed approach

Continue the extraction pattern: split PartyState into composition/stats/inventory facets and AudioManager into mixing-context vs playback modules.

## Acceptance criteria

- [x] The largest files are decomposed toward the budget
- [x] Responsibilities are cohesively grouped
- [x] No behavior change

## Measured line counts (`wc -l`, re-run in one pass)

Baseline column is `main` at merge-base 7c1b16b; the "after" column is the tip of `refactor/infra-decompose-oversized`. This table supersedes the 2026-06-27 figures, which were up to 55% stale by the time the work started (#319, #343).

| File | 2026-06-27 (gap analysis) | main @ 7c1b16b | after |
|------|--------------------------|----------------|-------|
| `game/scripts/autoload/party_state.gd` | 751 | 861 | 512 |
| `game/scripts/core/exploration.gd` | 719 | 728 | 590 |
| `game/scripts/autoload/audio_manager.gd` | 710 | 710 | 536 |
| `game/scripts/combat/battle_manager.gd` | 550 | 724 | 414 |
| `game/scripts/util/inventory_helpers.gd` | 453 | 705 | 386 |
| `game/scripts/ui/menu_ley_crystal.gd` | 451 | 451 | 341 |
| `game/scripts/core/cutscene_player.gd` | 429 | 464 | 339 |
| `game/scripts/ui/menu_overlay.gd` | — | 408 | 313 |

## Remaining

Four files are still over 400 (`exploration.gd` 590, `audio_manager.gd` 536, `party_state.gd` 512, `battle_manager.gd` 414). All four are facades or scene roots: what is left is signal wiring, owned node references and one-line forwards to the extracted modules, so further splitting buys indirection rather than cohesion. `PartyState` in particular is capped by `max-public-methods: 65` in `.gdlintrc` rather than by line count — it sits at 64. Re-open or file a follow-up if the residual grows.

## Design references

- The budget now has a canonical home: technical-architecture.md § 1.2a (aim 400, hard maximum 600), enforced by test_script_layout.gd. It was previously stated only in a code comment.
- .claude/skills/pod-dev/references/tech-stack.md (util-vs-ui placement and the per-owner facet pattern)

## Code references

- game/scripts/util/party_{crystals,roster,vitals,inventory,equipment,persistence}.gd (PartyState facets)
- game/scripts/core/exploration_{screen,interactions,entity_manager,zone_handler,auto_sequence,party_joins}.gd
- game/scripts/util/audio_{crossfade,mix_context,sfx_policy}.gd
- game/scripts/combat/battle_{player_actions,magic_command,item_command}.gd
- game/scripts/core/cutscene_commands.gd, game/scripts/ui/menu_party_panel.gd, game/scripts/ui/crystal_display.gd


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence (as of 2026-06-27):** wc -l confirmed party_state.gd 751, exploration.gd 719, audio_manager.gd 710, battle_manager.gd 550, inventory_helpers.gd 453, menu_ley_crystal.gd 451, cutscene_player.gd 429. The 400-line goal was self-stated in inventory_helpers.gd:3 ('to keep files under 400 lines'). Those figures are superseded by the measured table above — do not cite them as current; inventory_helpers.gd had reached 705 by the time the work started, and its header comment was rewritten during the split, so the budget is now stated only in battle_actions.gd:4.
- **Notes:** Facts accurate; this was genuine maintainability debt requiring a multi-module refactor (Effort L). fixNow=FALSE — decomposing core autoloads is exactly the kind of large change that risks the test suite, so it was done as its own branch with the full GUT suite as the gate.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
