# GAP-037: Choice consequences (flag_set/score) not wired for standalone NPC/zone/auto-sequence dialogue

| Field | Value |
|-------|-------|
| **ID** | GAP-037 |
| **Area** | Dialogue |
| **Severity** | HIGH |
| **Type** | bug |
| **Effort** | M |
| **Epic** | No |
| **Status** | resolved — PR #283 (re-verified against the tree on 2026-08-12; see Resolution) |
| **GitHub Issue** | [#170](https://github.com/gcko/pendulum-of-despair/issues/170) |
| **Source domains** | dialogue |

## Summary

For standalone dialogue overlays only sfx_requested is connected; flag_set_requested and choice_made are emitted into the void, so the only choice data in the project (thornmere_council scores) is inert outside cutscenes.

## Current state (implementation)

exploration connects exactly one DialogueBox signal; flag_set_requested/animation_requested are never connected for NPC/zone/cleansing/auto-sequence dialogue.

## Desired state (per design)

Any dialogue presenting a choice applies its flag_set/score consequence whether shown in a cutscene or standalone.

## Proposed approach

Add a _connect_dialogue_signals() wiring flag_set_requested (and animation_requested) to EventFlags / a score handler, reused across NPC, zone, auto-sequence, and cleansing paths; add a regression test.

## Acceptance criteria

- [x] A standalone choice sets its flag/score — PR #283
- [x] Wiring is shared across all standalone dialogue paths — PR #283, moved into `exploration_interactions.gd` by PR #357
- [x] A test asserts a standalone choice mutates state — PR #283

## Resolution

Re-measured against the tree on 2026-08-12 rather than taken from the issue
text. All three criteria hold. The Summary, Current state and Verification
sections are the frozen 2026-06-27 record of the bug as it stood then, and are
left as written; this section is the live view.

**Criterion 1 — a standalone choice sets its flag/score.** `dialogue_box.gd`
emits `flag_set_requested` and `score_increment_requested` when a choice is
answered, and `DialogueConsequences.connect_overlay()` in
`game/scripts/util/dialogue_consequences.gd` routes them to
`EventFlags.set_flag` and `EventFlags.apply_score_choice`. The two travel on
separate signals because flags overwrite while scores accumulate and clamp
(dialogue-system.md §3.3), which is also why the score path lands on
`apply_score_choice` rather than `set_flag`.

**Criterion 2 — shared across all standalone paths.** Checked exhaustively,
not by sampling: every `push_overlay(GameManager.OverlayState.DIALOGUE)` site
under `game/scripts/` calls `connect_overlay()` on the overlay it just pushed.
There are six, across the four paths the gap named —
`exploration_interactions.gd` (NPC talk and dialogue trigger, both via
`connect_dialogue_signals()`), `exploration_zone_handler.gd`,
`exploration_auto_sequence.gd`, and `cleansing_sequence.gd` (three sites). The
CUTSCENE overlay is wired separately by `CutsceneHandler`, as before.

**Criterion 3 — a test asserts the state mutation.**
`game/tests/test_dialogue_scores.gd` has
`test_dialogue_consequences_apply_both_consequence_types()`, which connects a
real overlay through `connect_overlay()`, answers a choice carrying both a
`flag_set` and a `score_delta`, and asserts `EventFlags` state afterwards — not
that a signal fired. `test_two_questions_accumulate_through_the_overlay()`
covers the accumulate-don't-overwrite regression on the same path.

PR #283 (commit `25fcedfa`) landed all three in one change: it added
`dialogue_consequences.gd`, `EventFlags.apply_score_choice`, the call at every
standalone site, and `test_dialogue_scores.gd`. PR #357 later moved the
`exploration.gd` call site into `exploration_interactions.gd` without changing
the wiring.

**Still open, and not this gap.** `animation_requested` is connected only in
`cutscene_player.gd` and remains unwired on every standalone path. That
sub-claim appears in this gap's Summary but in none of its acceptance
criteria; GAP-039 owns it and cites it explicitly.

## Design references

- docs/story/dialogue-system.md §3.4/§4.3

## Code references

- game/scripts/ui/dialogue_box.gd
- game/scripts/core/exploration_interactions.gd — `connect_dialogue_signals()` (the standalone-dialogue wiring, moved out of exploration.gd by PR #357)
- game/scripts/util/dialogue_consequences.gd — `connect_overlay()` (the shared flag_set/score wiring the four standalone paths now call)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** DialogueBox emits flag_set_requested (dialogue_box.gd:277,281) and animation_requested (317) and choice_made (264). For standalone dialogue, exploration.gd only calls _connect_dialogue_sfx (lines 303,398), which connects ONLY sfx_requested (exploration.gd:529-532). flag_set_requested and animation_requested are never connected on the standalone NPC/dialogue-trigger paths. The cleansing (cleansing_sequence.gd:100,171,219), zone (exploration_zone_handler.gd:133) and auto-sequence (exploration_auto_sequence.gd:123) paths call show_dialogue with NO signal wiring at all (not even sfx). Only the cutscene path wires flag_set (cutscene_player.gd:55-58 -> cutscene_handler.gd:44/164-169). So standalone choice consequences are emitted into the void.
- **Notes:** Confirmed. thornmere_council.json (no cutscene_id, played standalone) carries the only choice/score data and its consequences are inert outside cutscenes. Fix spans 4 dialogue paths and needs a shared wiring helper + a score handler (coupled to GAP-038) + regression tests; not a small isolated change.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
