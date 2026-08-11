# GAP-079: EPIC: Corruption Evolution System (music + ambient) unimplemented in AudioManager

| Field | Value |
|-------|-------|
| **ID** | GAP-079 |
| **Area** | Audio |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | Yes |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#215](https://github.com/gcko/pendulum-of-despair/issues/215) |
| **Source domains** | audio |

## Summary

AudioManager has no corruption-stage concept or DSP path for detuning, drone, tempo drop, ambient volume scaling, or Pallor-motif substitution; no call site references staging.

## Current state (implementation)

Only play/enter/exit/mix APIs exist. Act-I is Stage 0 so not blocked, but the system (music.md Rule #4) is required Act II+ and untracked beyond the COMPLETE-marked gap 3.8.

## Desired state (per design)

set_corruption_stage(stage) applies Stages 0-4 to current music/ambient (detune, drone, tempo, volume scaling, motif substitution) per the doc tables.

## Proposed approach

Add a corruption API routing music/ambient buses through AudioEffect chains (pitch-shift, low-sine drone, volume scaling) and optionally swapping to corruption-variant stems; file as its own engine gap.

## Acceptance criteria

- [ ] set_corruption_stage applies the documented per-stage effects
- [ ] Ambient volume/sub-bass scale by stage
- [ ] A GUT test asserts stage effects apply

## Design references

- docs/story/music.md:370-413
- docs/story/audio.md:204-213

## Code references

- game/scripts/autoload/audio_manager.gd (no corruption/stage API)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** grep for 'corruption_stage|set_corruption' across game/scripts and game/tests returns ZERO matches. audio_manager.gd has no stage/detune/drone/tempo API — only the documented play/enter/exit/mix constants and MIX_* dictionaries (lines 51-71). No call site references staging.
- **Notes:** Confirmed absent. Act-I is Stage 0 so the slice isn't blocked. This is an L-effort engine feature (AudioEffect chains + new GUT test) — not a safe bounded fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Always verify against current code before acting._
