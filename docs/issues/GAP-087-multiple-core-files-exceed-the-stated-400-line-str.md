# GAP-087: Multiple core files exceed the stated ~400-line structure target

| Field | Value |
|-------|-------|
| **ID** | GAP-087 |
| **Area** | Code structure |
| **Severity** | LOW |
| **Type** | partial-impl |
| **Effort** | L |
| **Epic** | No |
| **Status** | resolved — #237 (decomposition landed); the residual band is sanctioned by tech-arch § 1.2a and enforced by `test_script_layout.gd` — closes #319 |
| **GitHub Issue** | [#237](https://github.com/gcko/pendulum-of-despair/issues/237) |
| **Source domains** | arch |

## Summary

Several core scripts exceeded the ~400-line guideline; inventory_helpers was itself extracted to keep files under 400 yet had grown past it. The decomposition pass has now run — see the measured table below.

## Current state (implementation)

Resolved. Every file named in the original finding shrank, and none of the extracted modules exceeds the budget. Four files sit between 400 and 600 — inside the band the budget explicitly allows for files that are intrinsically hard to break down. Which files may sit there is pinned by technical-architecture.md § 1.2a itself: `test_script_layout.gd` reads that section and fails on any band file the doc does not name, instead of keeping its own copy of the list.

## Desired state (per design)

Large autoloads/scenes decomposed into cohesive sub-modules under the size budget.

## Proposed approach

Continue the extraction pattern: split PartyState into composition/stats/inventory facets and AudioManager into mixing-context vs playback modules.

## Acceptance criteria

- [x] The largest files are decomposed toward the budget
- [x] Responsibilities are cohesively grouped
- [x] No behavior change

## Measured line counts (`wc -l`, all files re-measured in one pass)

Baseline column is `main` at merge-base 7c1b16b; "after decomposition" is the tip of `refactor/infra-decompose-oversized`; "current" is `wc -l` re-run over all eight files in a single pass on 2026-08-11 (#319). A half-refreshed list is less trustworthy than a fully stale one, so every row is re-measured together or none is.

The first three columns are historical measurements and stay as written. The **current** column is not hand-maintained: `check_gap_measured_tables()` in `scripts/quality-gates/check_stale_counts.py` re-runs `wc -l` over every path in it on each pre-push and fails with the corrected cell, so a one-line change to any of these actively-developed files breaks the build until the number is updated (#319).

This table supersedes the 2026-06-27 figures, which were up to 55% stale by the time the work started (#319, #343).

| File | 2026-06-27 (gap analysis) | main @ 7c1b16b | after decomposition | current (2026-08-11) |
|------|--------------------------|----------------|---------------------|----------------------|
| `game/scripts/autoload/party_state.gd` | 751 | 861 | 512 | 512 |
| `game/scripts/core/exploration.gd` | 719 | 728 | 590 | 590 |
| `game/scripts/autoload/audio_manager.gd` | 710 | 710 | 536 | 334 |
| `game/scripts/combat/battle_manager.gd` | 550 | 724 | 414 | 449 |
| `game/scripts/util/inventory_helpers.gd` | 453 | 705 | 386 | 386 |
| `game/scripts/ui/menu_ley_crystal.gd` | 451 | 451 | 341 | 341 |
| `game/scripts/core/cutscene_player.gd` | 429 | 464 | 339 | 339 |
| `game/scripts/ui/menu_overlay.gd` | — | 408 | 313 | 313 |

## Remaining

Nothing blocking. The rule this gap was written against no longer exists in the form it cites: the budget is now **aim 400 / hard maximum 600** (technical-architecture.md § 1.2a), enforced by `game/tests/test_script_layout.gd`, and every file the test scans complies. The scan is deliberately two-tiered (#374): the 600 hard ceiling walks `CEILING_ROOTS` — `res://scripts` **and** `res://tests` — while the 400 aim walks the narrower `AIM_ROOTS`, because § 1.2a exempts test suites from the aim but not from the ceiling. Only the vendored GUT addon sits outside both. The three test files that were over 600 when this gap was last edited were split under #374, and the largest suite file is now 559 lines. The original framing — "4 files still over 400" — described a violation of a single 400-line rule that has since been replaced.

Three files sit in the sanctioned 400-600 band (`exploration.gd` 590, `party_state.gd` 512, `battle_manager.gd` 449). All three are facades or scene roots: what is left is signal wiring, owned node references and one-line forwards to the extracted modules, so further splitting buys indirection rather than cohesion — exactly the case § 1.2a sanctions. Which files may sit in the band is pinned by § 1.2a itself: `test_script_layout.gd` parses that section rather than restating it, so the doc is the allowlist and each file's justification is written up there. § 1.2a works `party_state.gd`, `exploration.gd` and `battle_manager.gd` through as its facade, scene-controller and loop-plus-seam examples. `audio_manager.gd` was a fourth until #425: it was admitted on the coupling between its private fields and `test_audio_manager.gd`, and when #420 moved that suite off private state the reason lapsed, so the file was decomposed to 334 lines (AudioChannel, AudioBattleTransition, AudioAssets) rather than re-justified. `PartyState` in particular is capped by `max-public-methods: 65` in `.gdlintrc` rather than by line count — it sits at 64. Two guards keep this honest without a manual re-measure: `test_script_layout.gd` fails the suite on a regression past 600 or on an undocumented new arrival in the 400-600 band, and `check_gap_measured_tables()` fails pre-push the moment any figure in the current column stops matching `wc -l`.

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

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
