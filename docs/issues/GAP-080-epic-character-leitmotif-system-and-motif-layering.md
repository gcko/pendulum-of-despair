# GAP-080: EPIC: Character Leitmotif System and motif-layering rules have no engine or asset support

| Field | Value |
|-------|-------|
| **ID** | GAP-080 |
| **Area** | Audio |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#216](https://github.com/gcko/pendulum-of-despair/issues/216) |
| **Source domains** | audio |

## Summary

No data model for character leitmotifs and no engine logic to layer a character's motif into a scene by narrative role; no motif stems exist. AudioManager plays whole pre-baked tracks only.

## Current state (implementation)

grep motif/leitmotif returns nothing; marquee beats (Sable reunion stacking, Final Battle six-motif unison, Vaelith progression) require runtime motif assembly.

## Desired state (per design)

When a character is narratively relevant their motif layers into the current track per the role->treatment matrix.

## Proposed approach

Composition + adaptive-audio epic: author per-character motif stems and a layering controller mixing stems on dedicated sub-channels keyed by active party/scene. Mostly Act II+.

## Acceptance criteria

- [ ] Per-character motif stems exist
- [ ] A layering controller mixes motifs by narrative role
- [ ] Sable's reunion order drives layering sequence

## Design references

- docs/story/music.md:116-183,340-350,434

## Code references

- game/scripts/autoload/audio_manager.gd (no motif/layering)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** grep -i for 'motif|leitmotif' across game/scripts returns nothing. AudioManager plays whole pre-baked .ogg tracks via play_music; no motif stems exist in game/assets/music (only the 5 full-track placeholders). No layering controller or per-character motif data model.
- **Notes:** Confirmed. XL adaptive-audio + composition epic, mostly Act II+. Not a bounded fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383); write what the file does hold instead. Always verify against current code before acting._
