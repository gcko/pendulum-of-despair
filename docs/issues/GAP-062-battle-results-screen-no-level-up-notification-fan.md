# GAP-062: Battle Results screen: no level-up notification/fanfare, no per-section advance, raw item_id shown

| Field | Value |
|-------|-------|
| **ID** | GAP-062 |
| **Area** | UI |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#208](https://github.com/gcko/pendulum-of-despair/issues/208) |
| **Source domains** | ui, progression |

## Summary

_show_results dumps a static block (EXP/Gold/'Found: <item_id>' raw id) with no per-section confirm, no drop icon/name resolution, and no level-up notification; distribute_battle_rewards' level_ups return value is discarded by every caller.

## Current state (implementation)

No level-up branch exists; item_id is shown verbatim; level_ups data is computed but ignored.

## Desired state (per design)

Results advance section-by-section, show drops with icon + resolved name, and present a level-up panel (name, new level, stat deltas, newly-learned abilities) with fanfare per design.

## Proposed approach

Consume the distribute_battle_rewards return; resolve item_id->name via DataManager; add a sectioned results state machine and a level-up sub-panel diffing stats and listing abilities learned in (old,new].

## Acceptance criteria

- [ ] Drops show resolved names (and icons when available)
- [ ] Results advance on confirm per section
- [ ] A level-up panel shows new level, stat deltas, and new abilities

## Design references

- docs/story/ui-design.md §2.8
- docs/story/progression.md:240

## Code references

- game/scripts/ui/battle_ui.gd — `_show_results()`
- game/scripts/util/progression_helpers.gd — `distribute_rewards()`
- game/scripts/core/exploration.gd — `_initialize_from_transition_data()` (the return-from-battle path that distributes rewards)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** battle_ui.gd:229-243 _show_results dumps a single static block: 'EXP: %d', 'Gold: %d', and 'Found: %s' % drop.get('item_id') — raw item_id, no name/icon resolution, no per-section advance, no level-up branch (dismissed by single ui_accept at 247-253). progression_helpers.gd `distribute_rewards()` computes and returns level_ups, but the caller chain `PartyState.distribute_battle_rewards()` -> `exploration.gd` discards the returned Dictionary (line 'PartyState.distribute_battle_rewards(rewards)' with no assignment). Design ui-design.md:2.8 and progression.md:240.
- **Notes:** Confirmed. Minor naming note: the issue says 'distribute_battle_rewards' (the PartyState wrapper) while the helper is distribute_rewards/apply_battle_rewards — substance is correct, level_ups is genuinely discarded. Sectioned state machine + level-up panel = significant new logic + tests; not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
