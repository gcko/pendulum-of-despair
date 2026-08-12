# GAP-037: Choice consequences (flag_set/score) not wired for standalone NPC/zone/auto-sequence dialogue

| Field | Value |
|-------|-------|
| **ID** | GAP-037 |
| **Area** | Dialogue |
| **Severity** | HIGH |
| **Type** | bug |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
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

- [ ] A standalone choice sets its flag/score
- [ ] Wiring is shared across all standalone dialogue paths
- [ ] A test asserts a standalone choice mutates state

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

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383); write what the file does hold instead. Always verify against current code before acting._
