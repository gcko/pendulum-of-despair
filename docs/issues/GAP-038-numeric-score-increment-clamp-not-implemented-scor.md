# GAP-038: Numeric score increment + clamp not implemented — score choices overwrite instead of accumulate

| Field | Value |
|-------|-------|
| **ID** | GAP-038 |
| **Area** | Dialogue |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | M |
| **Epic** | No |
| **Status** | resolved — #171 |
| **GitHub Issue** | [#171](https://github.com/gcko/pendulum-of-despair/issues/171) |
| **Source domains** | dialogue |

## Summary

DialogueBox emits the score delta and the only handler calls EventFlags.set_flag (overwrite); EventFlags has no increment/clamp, so multi-question approval scores (council_*_approval 0-3) never accumulate or clamp.

## Current state (implementation)

thornmere_council.json scores across questions 005/011/013/016 depend on accumulation; setting the flag to the delta loses prior totals.

## Desired state (per design)

Score deltas are added to the existing value and clamped to range per §3.3.

## Proposed approach

Add EventFlags.increment_score(name, delta, min, max) with clamp and a distinct score path; source min/max from events.md; add accumulation+clamp tests.

## Acceptance criteria

- [ ] Score choices accumulate across questions
- [ ] Scores clamp to their documented range
- [ ] Tests cover accumulation and clamp

## Design references

- docs/story/dialogue-system.md §3.3/§3.4

## Code references

- game/scripts/ui/dialogue_box.gd — `_select_choice()` (emits the score delta)
- game/scripts/core/cutscene_handler.gd — `_on_cutscene_score_increment()` (the sole handler)
- game/scripts/autoload/event_flags.gd — `increment_score()`


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** dialogue_box.gd:278-281 emits flag_set_requested(score_name, score_delta) for score choices. The only handler, cutscene_handler.gd:164-169 _on_cutscene_flag_set, calls EventFlags.set_flag(flag_name, value) — an overwrite. event_flags.gd:18-24 set_flag does _flags[name]=value with no add/clamp; the file has no increment/clamp method anywhere (only set/get/has/clear/load/check_required_flags). Design dialogue-system.md §3.3 (lines 197-202) requires 'Scores are clamped... the engine enforces clamp(score,min,max) after each increment' and §3.4 (215-220) describes additive increments. thornmere_council.json council_savanh_approval reaches 3 only via a base question (max +2) PLUS the Grandmother Seyth bonus option (+1) — impossible under overwrite.
- **Notes:** Confirmed missing feature. Even within cutscenes the score overwrites instead of accumulating. Fix needs new EventFlags.increment_score with clamp, min/max sourced from events.md, a distinct score signal path, plus accumulation+clamp tests — not bounded/safe now.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Always verify against current code before acting._
