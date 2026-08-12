# GAP-034: Per-biome weather/atmospheric effects and story overrides not implemented

| Field | Value |
|-------|-------|
| **ID** | GAP-034 |
| **Area** | Exploration |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#189](https://github.com/gcko/pendulum-of-despair/issues/189) |
| **Source domains** | exploration |

## Summary

No weather/atmospheric overlay system exists; maps render a single static palette with no particle/lighting atmospherics.

## Current state (implementation)

Only an audio-side biome crossfade constant exists.

## Desired state (per design)

Fixed per-biome atmospheric overlays (rain/snow/fog/ley shimmer) and story-triggered overrides per overworld.md §4 and biomes.md.

## Proposed approach

Add a reusable atmospheric overlay node (particles + CanvasModulate) configured per map biome meta, with a flag-driven override hook.

## Acceptance criteria

- [ ] Biomes show distinct atmospheric overlays
- [ ] A story flag can override a biome's atmosphere
- [ ] Effect is configurable per map meta

## Design references

- docs/story/overworld.md §4
- docs/story/biomes.md §Time of Day Effects

## Code references

- game/scripts/ (only audio_manager CROSSFADE_BIOME constant)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** Only an audio-side biome crossfade constant exists: audio_manager.gd:35 'const CROSSFADE_BIOME: float = 3.0'. No weather/particle/CanvasModulate atmosphere system in scripts. Design overworld.md §4 and biomes.md atmospheric/time-of-day effects.
- **Notes:** Confirmed. Effort M feature (overlay nodes + per-map meta + flag override). Not fixable now.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
