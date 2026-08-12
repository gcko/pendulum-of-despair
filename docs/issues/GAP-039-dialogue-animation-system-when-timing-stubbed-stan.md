# GAP-039: Dialogue animation system: when-timing stubbed, standalone routing unconnected, clear/hold-reset missing

| Field | Value |
|-------|-------|
| **ID** | GAP-039 |
| **Area** | Dialogue |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#191](https://github.com/gcko/pendulum-of-despair/issues/191) |
| **Source domains** | dialogue |

## Summary

_fire_animations ignores the when field (fires all at entry start); animation_requested is unconnected for standalone dialogue; cutscene_player collapses per-line timing to per-entry; and the clear control command + hold/reset rule are unimplemented (play_animation no-ops on 'clear').

## Current state (implementation)

Sprite emotion only animates inside embedded cutscenes; after_line_0 vs after_line_1 cannot be distinguished; cry can never be cleared; held anims never reset at sequence end.

## Desired state (per design)

Animations fire at the correct before_line/after_line index and route to the speaking entity in standalone dialogue; clear cancels looping/held anims to idle; held anims auto-reset at sequence end.

## Proposed approach

Implement per-box when filtering in DialogueBox, drive cutscenes box-by-box, connect animation_requested in the standalone wiring helper (GAP-037), and special-case anim=='clear' + sequence-end reset. Add cry-then-clear and held-reset tests.

## Acceptance criteria

- [ ] Animations fire at the correct line index
- [ ] Standalone NPC dialogue routes emotion to the entity
- [ ] clear returns the sprite to idle and held anims reset at sequence end

**Re-verified by behavior search 2026-08-12 (#413): 0 of 3 met, nothing has
moved.** Searched `game/scripts/` and `game/tests/` for `animation_requested`,
`_fire_animations`, `_fire_entry_animations` and `play_animation`, and for the
`"when"` key. `dialogue_box.gd` `_fire_animations()` still names its timing
argument `_timing_filter` — a leading underscore, i.e. deliberately unread — and
fires every entry animation from the single `before_line_0` call site.
`cutscene_player.gd` `_fire_entry_animations()` does read `when`, but only via
`when.begins_with(prefix)` against the two per-entry phases `before_line` and
`after_line`, so `after_line_0` and `after_line_1` remain indistinguishable.
`exploration_interactions.gd` `connect_dialogue_signals()` connects
`sfx_requested` and the consequence hooks and still does not connect
`animation_requested`, so the standalone path drops the signal on the floor.
`npc.gd` `play_animation()` has no `clear` case: it looks `clear` up on the
`AnimationPlayer`, fails `has_animation()` and returns, which is the no-op the
finding recorded.

## Design references

- docs/story/dialogue-system.md §2.1/§2.2/§2.3/§3.5/§4.5

## Code references

- game/scripts/ui/dialogue_box.gd — `_fire_animations()` (ignores the when field)
- game/scripts/core/cutscene_player.gd — `_fire_entry_animations()` (collapses per-line timing to per-entry)
- game/scripts/entities/npc.gd — `play_animation()` (no-ops on clear)
- game/scripts/core/exploration_interactions.gd — `connect_dialogue_signals()` (the standalone-dialogue wiring, moved out of exploration.gd by PR #357; it wires consequences and sfx, not `animation_requested`)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** dialogue_box.gd:304-318 _fire_animations takes _timing_filter (underscore-prefixed = unused) and the docstring/comment (304-306) admits 'Timing filter is stubbed — all animations fire at entry start regardless of when field'; it loops and emits every animation immediately. animation_requested is unconnected for standalone dialogue (exploration only wires sfx, see GAP-037 evidence). cutscene_player.gd:216-228 _fire_entry_animations filters by when prefix (before_line/after_line) but only at entry boundaries — it calls show_dialogue([entry]) for the whole multi-line entry (line 194), so after_line_0 vs after_line_1 within one entry cannot be distinguished. npc.gd:236-245 play_animation no-ops on 'clear' (has_animation('clear') is false -> warns and returns), and there is no sequence-end held-anim reset anywhere. Design dialogue-system.md §2.2 (73-91) specifies per-line timing, cry-loop-until-clear, and hold/reset-at-sequence-end.
- **Notes:** All four sub-claims confirmed against §2.1/2.2. Fix requires per-box when filtering, box-by-box cutscene driving, standalone animation wiring (shared with GAP-037), and clear/hold-reset special-casing + tests. Not bounded.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
