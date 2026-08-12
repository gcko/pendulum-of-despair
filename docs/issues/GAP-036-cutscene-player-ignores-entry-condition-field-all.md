# GAP-036: Cutscene player ignores entry condition field — all scripted entries play unconditionally

| Field | Value |
|-------|-------|
| **ID** | GAP-036 |
| **Area** | Dialogue |
| **Severity** | HIGH (verified: MEDIUM) |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | resolved — #190 (verified severity OVERSTATED) |
| **GitHub Issue** | [#190](https://github.com/gcko/pendulum-of-despair/issues/190) |
| **Source domains** | dialogue |

## Summary

CutscenePlayer._process_entries never reads the condition field; the condition evaluator lives only in npc.gd and is not shared, so 135 conditioned entries (party_has, reunion_order, betrayal flags) play regardless.

## Current state (implementation)

grep for 'condition' in cutscene_player.gd returns 0. Party-aware Tier-1 scenes (cael_betrayal, scene_24, thornmere_council, Maren reunion) cannot vary.

## Desired state (per design)

Cutscene entries with a condition are filtered with the same priority-stack/first-match semantics used for NPCs.

## Proposed approach

Extract the condition evaluator + priority-stack logic into a shared helper and have cutscene_player skip false-condition entries; add tests for party_has and reunion_order comparisons.

## Acceptance criteria

- [ ] Conditioned cutscene entries are evaluated
- [ ] party_has and reunion_order comparisons work in cutscenes
- [ ] A test asserts a false-condition entry is skipped

## Design references

- docs/story/dialogue-system.md §3.2/§3.5/§4.5

## Code references

- game/scripts/core/cutscene_player.gd — `_process_entries()`
- game/scripts/util/dialogue_condition.gd — `should_play()`, `resolve_stack()` (the shared evaluator the fix extracted; it no longer lives in npc.gd)
- game/scripts/entities/npc.gd — `get_current_dialogue()`


## Verification (fresh-eyes adversarial pass)

- **Verdict:** OVERSTATED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** cutscene_player.gd has 0 occurrences of 'condition' (grep -c = 0); _process_entries (lines 178-214) and _fire_entry_animations never read entry['condition']. dialogue_box.gd _show_entry (143-169) also never evaluates condition. The condition evaluator only exists in npc.gd:81-148 and is used solely by get_current_dialogue (66-75) to pick ONE entry from an NPC's priority stack. So the CORE claim (sequence players ignore per-entry condition) is true. BUT the headline '135 conditioned entries play regardless' is inflated: of 135 non-null conditions across data/dialogue/, 75 live in npc_*.json and ARE evaluated by npc.gd; only ~60 live in scene files (thornmere_council 18, scene_19 6, cael_betrayal 2, scene_24 4, etc.) that are played as sequences and have their per-entry conditions ignored. Also the cutscene-flagged files (cutscene_id present: dawn_march, scene_7d_evening) contain ZERO non-null conditions, so framing it as a 'cutscene player' defect specifically is imprecise.
- **Notes:** Real infrastructure gap but materially overstated count (60 affected, not 135) and the 75 NPC-condition cases are already handled. Named scenes (thornmere_council, scene_24, cael_betrayal) genuinely affected. Fix needs a shared condition evaluator extracted from npc.gd applied in both cutscene_player and dialogue_box plus tests — not bounded/safe for now.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
