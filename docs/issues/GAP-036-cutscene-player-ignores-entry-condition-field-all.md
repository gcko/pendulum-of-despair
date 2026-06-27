# GAP-036: Cutscene player ignores entry condition field — all scripted entries play unconditionally

| Field | Value |
|-------|-------|
| **ID** | GAP-036 |
| **Area** | Dialogue |
| **Severity** | HIGH (verified: MEDIUM) |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — OVERSTATED |
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

- game/scripts/core/cutscene_player.gd:178-214
- game/scripts/entities/npc.gd:81-148


## Verification (fresh-eyes adversarial pass)

- **Verdict:** OVERSTATED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** cutscene_player.gd has 0 occurrences of 'condition' (grep -c = 0); _process_entries (lines 178-214) and _fire_entry_animations never read entry['condition']. dialogue_box.gd _show_entry (143-169) also never evaluates condition. The condition evaluator only exists in npc.gd:81-148 and is used solely by get_current_dialogue (66-75) to pick ONE entry from an NPC's priority stack. So the CORE claim (sequence players ignore per-entry condition) is true. BUT the headline '135 conditioned entries play regardless' is inflated: of 135 non-null conditions across data/dialogue/, 75 live in npc_*.json and ARE evaluated by npc.gd; only ~60 live in scene files (thornmere_council 18, scene_19 6, cael_betrayal 2, scene_24 4, etc.) that are played as sequences and have their per-entry conditions ignored. Also the cutscene-flagged files (cutscene_id present: dawn_march, scene_7d_evening) contain ZERO non-null conditions, so framing it as a 'cutscene player' defect specifically is imprecise.
- **Notes:** Real infrastructure gap but materially overstated count (60 affected, not 135) and the 75 NPC-condition cases are already handled. Named scenes (thornmere_council, scene_24, cael_betrayal) genuinely affected. Fix needs a shared condition evaluator extracted from npc.gd applied in both cutscene_player and dialogue_box plus tests — not bounded/safe for now.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
