# GAP-048: EPIC: World dungeons 3-20 and all 6 city dungeons + ~20 secret passages unbuilt

| Field | Value |
|-------|-------|
| **ID** | GAP-048 |
| **Area** | World |
| **Severity** | HIGH (verified: MEDIUM) |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#195](https://github.com/gcko/pendulum-of-despair/issues/195) |
| **Source domains** | world |

## Summary

Only Ember Vein and Fenmother's Hollow exist; the other 18 world dungeons, all 6 city dungeons, and the ~20 designed secret passages have no scenes (encounter JSON exists but maps do not).

## Current state (implementation)

Tracker folds these into 4.5 with a generic '6 dungeons' bullet that undercounts the 18 world + 6 city dungeons and omits the secret-passage scope entirely.

## Desired state (per design)

All 20 world dungeons and 6 city dungeons built as tilemapped scenes with floor counts/puzzles/encounters/bosses, plus the ~20 secret passages, per the dungeon docs.

## Proposed approach

Single dungeon build-out epic; add an enumerated checklist (18 world + 6 city + ~20 passages by name/floor count) to the tracker so completion is measurable. Most are Act-II+ gated.

## Acceptance criteria

- [ ] Tracker enumerates the 18 world + 6 city dungeons + ~20 passages by name
- [ ] Dungeons build act-by-act with their bosses
- [ ] Secret passages are reachable interactables

## Design references

- docs/story/dungeons-world.md (20 dungeons)
- docs/story/dungeons-city.md (6 city dungeons + ~20 secret passages)

## Code references

- game/scenes/maps/dungeons/ (only ember_vein, fenmothers_hollow, duskfen_spirit_shrine)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/scenes/maps/dungeons/ contains only ember_vein_f1-f4, fenmothers_hollow_f1-f3 + spirit_path, and duskfen_spirit_shrine.tscn (a shrine hub, not a world dungeon). The design summary table in docs/story/dungeons-world.md:5325+ enumerates dungeons #1-21 (plus sub-letters 13a/b/c, 14a-e). docs/story/dungeons-city.md §1 (line 25) lists 6 city dungeons (Valdris Crown Catacombs, Corrund Undercity/Sewers, Caldera Undercity, Ashmark Factory Depths, Ironmark Citadel Dungeons, Bellhaven Smuggler Tunnels) and §2 (line 892) Secret Passages. Tracker docs/analysis/game-dev-gaps.md:269 confirms 'encounter files: 20 world dungeons + 6 city dungeons' exist while maps do not, and line 1103 folds them into a generic '4.5 Act II: 6 dungeons' bullet.
- **Notes:** Gap is real (epic). Issue's '20 world dungeons' is if anything an undercount (design table lists 21 numbered entries plus sub-areas). All this content is explicitly Act-II+ gated, so for an Act-I vertical slice it is expected/known scope rather than a HIGH-severity defect; refined to MEDIUM. XL epic — not a bounded fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
