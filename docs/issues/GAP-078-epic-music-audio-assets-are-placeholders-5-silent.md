# GAP-078: EPIC: Music + audio assets are placeholders (5 silent tracks vs ~70-80 designed; ~51 SFX, 12 ambient missing)

| Field | Value |
|-------|-------|
| **ID** | GAP-078 |
| **Area** | Audio |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#175](https://github.com/gcko/pendulum-of-despair/issues/175) |
| **Source domains** | audio, tracker |

## Summary

game/assets/music has 5 ~0.1s silent placeholders (Title, Overworld, Standard/Boss Battle, Ember Vein); even the Act-I slice lacks Valdris Crown, Roothollow, and Fenmother's Hollow themes; the full ~70-80 tracks plus ~51 SFX and 12 ambient loops are unproduced. AudioManager is wired and verified.

## Current state (implementation)

Tracker marks gap 3.8 COMPLETE scoped to 'major contexts'. file(1) confirms placeholders are silent.

## Desired state (per design)

~70-80 unique tracks per music.md plus the SFX/ambient set per audio.md, dropped in via the existing {id}.ogg convention.

## Proposed approach

Content-production epic: first produce the Act-I-slice subset (Valdris Crown, Roothollow, Fenmother's Hollow themes) then backfill town/dungeon/narrative/battle-tier tracks and SFX/ambient.

## Acceptance criteria

- [ ] Act-I-slice locations have real themes
- [ ] Battle/boss tiers have real tracks
- [ ] ~51 SFX and 12 ambient loops are real audio
- [ ] No engine change needed to add tracks

## Design references

- docs/story/music.md:516-528,199-366,415-441
- docs/story/audio.md (~51 SFX, 12 ambient)

## Code references

- game/assets/music/ (5 silent .ogg)
- game/assets/sfx/, game/assets/ambient/ (silent placeholders)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/assets/music/ contains exactly 5 .ogg files (title_theme, overworld_act_i, battle_standard, battle_boss, ember_vein), all 0.100136s duration and ~0 bps per ffprobe/file(1) — confirmed silent placeholders. game/assets/sfx/ = 51 .ogg files, game/assets/ambient/ = 12 .ogg files, all 3.5K placeholders matching the silent-music size. Design (docs/story/music.md) calls for ~70-80 tracks; only 5 exist. Slice locations Valdris Crown/Roothollow/Fenmother's Hollow have no themes.
- **Notes:** Real gap. Title wording 'missing' is slightly imprecise — the 51 SFX + 12 ambient files DO exist on disk as silent placeholders rather than being absent; the actual gap is that none are real audio, which the acceptance criteria correctly capture. This is an XL content-production epic, not a safe bounded fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Always verify against current code before acting._
