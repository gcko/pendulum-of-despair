# GAP-081: enter_pallor() / Pallor Wastes audio transition unimplemented — CROSSFADE_PALLOR constants are dead code

| Field | Value |
|-------|-------|
| **ID** | GAP-081 |
| **Area** | Audio |
| **Severity** | LOW |
| **Type** | partial-impl |
| **Effort** | S |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#234](https://github.com/gcko/pendulum-of-despair/issues/234) |
| **Source domains** | audio |

## Summary

CROSSFADE_PALLOR_MUSIC=5.0 and CROSSFADE_PALLOR_AMBIENT=3.0 are declared 'reserved for the gap 4.5 enter_pallor()' but no such method exists, so the constants are dead.

## Current state (implementation)

The constants are referenced only in their own declaration comment; Pallor Wastes is Act III so the slice is not blocked.

## Desired state (per design)

An enter_pallor() that hard-cuts music to silence, fades a Pallor drone in over 5s, and crossfades ambient over 3s, consuming the reserved constants.

## Proposed approach

Implement enter_pallor() using the constants (silence music, fade-in sub-bass drone, crossfade ambient) and add a GUT test.

## Acceptance criteria

- [ ] enter_pallor cuts music and fades in the drone
- [ ] Ambient crossfades over 3s
- [ ] Reserved constants are consumed

## Design references

- docs/story/audio.md:261
- docs/story/music.md:451

## Code references

- game/scripts/autoload/audio_manager.gd


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** audio_manager.gd:42-43 declares CROSSFADE_PALLOR_MUSIC=5.0 and CROSSFADE_PALLOR_AMBIENT=3.0. grep 'CROSSFADE_PALLOR' across scripts/tests finds only the two declarations (no consumers). grep 'enter_pallor' finds only the comment at line 40 — no method definition. Constants are genuinely dead code.
- **Notes:** Accurate. Although effort S, implementing enter_pallor() requires new audio transition logic + a GUT test (a feature, not a doc/data tweak), and Pallor Wastes is Act III so it's non-blocking. Per the fixNow safety rule this is FALSE — implementing it touches the audio suite. Removing the dead constants instead would contradict the documented design intent, so no safe no-op fix exists.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Always verify against current code before acting._
