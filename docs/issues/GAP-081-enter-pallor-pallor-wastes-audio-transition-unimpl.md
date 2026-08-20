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

**Re-verified by behavior search 2026-08-12 (#413): 0 of 3 met, nothing has
moved.** Searched all of `game/scripts/` and `game/tests/` for `enter_pallor`
and `CROSSFADE_PALLOR`. `enter_pallor` appears exactly once, inside the comment
above the constants; no method by that name is defined anywhere, in
`audio_manager.gd` or in the `audio_crossfade.gd` / `audio_mix_context.gd` /
`audio_sfx_policy.gd` helpers that were split out of it. `CROSSFADE_PALLOR_MUSIC`
and `CROSSFADE_PALLOR_AMBIENT` are declared and never read. The gap is unbuilt,
not relocated by the audio decomposition.

## Design references

- docs/story/audio.md § 3.3 Crossfade Rules
- docs/story/music.md § Special Audio Rules

## Code references

- game/scripts/autoload/audio_manager.gd — declares `CROSSFADE_PALLOR_MUSIC` and `CROSSFADE_PALLOR_AMBIENT`. The method they were reserved for is absent, so no symbol anchor is possible here and a green path check proves nothing about this gap; re-verify the absence by hand.
- game/scripts/util/audio_crossfade.gd — `swap_in()`, `fade_out()`: the existing fade machinery the Pallor transition would drive; searched and confirmed it holds no Pallor path


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** audio_manager.gd:42-43 declares CROSSFADE_PALLOR_MUSIC=5.0 and CROSSFADE_PALLOR_AMBIENT=3.0. grep 'CROSSFADE_PALLOR' across scripts/tests finds only the two declarations (no consumers). grep 'enter_pallor' finds only the comment at line 40 — no method definition. Constants are genuinely dead code.
- **Notes:** Accurate. Although effort S, implementing enter_pallor() requires new audio transition logic + a GUT test (a feature, not a doc/data tweak), and Pallor Wastes is Act III so it's non-blocking. Per the fixNow safety rule this is FALSE — implementing it touches the audio suite. Removing the dead constants instead would contradict the documented design intent, so no safe no-op fix exists.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
