# GAP-054: Duskfen settlement unbuilt — only the spirit-shrine hub exists

| Field | Value |
|-------|-------|
| **ID** | GAP-054 |
| **Area** | World |
| **Severity** | MEDIUM (verified: LOW) |
| **Type** | partial-impl |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#226](https://github.com/gcko/pendulum-of-despair/issues/226) |
| **Source domains** | world |

## Summary

Only the small shrine hub (save + Caden event + overworld shortcut) exists; the full bog settlement (stilt structures, shops, NPCs) that is the Act-II Thornmere alliance hub is unbuilt and is filed under dungeons/ though it is a town.

## Current state (implementation)

Acceptable for the Act-I slice; the shrine is the only Act-I-relevant part.

## Desired state (per design)

Full Duskfen settlement built under the Act-II content epic.

## Proposed approach

Track the full settlement under GAP-049; note the misfiled dungeon path.

## Acceptance criteria

- [x] Full Duskfen settlement tracked under the cities epic (GAP-049 names "full
      Duskfen" in both its title and its Desired state, alongside the ten
      Carradan settlements and the four other Thornmere ones; it is live as
      [#196](https://github.com/gcko/pendulum-of-despair/issues/196) under the
      Phase 6 milestone with the `epic` label — re-measured 2026-08-12)
- [ ] Settlement has shops/NPCs/trade goods
- [ ] Path/classification corrected (town not dungeon)

**Re-verified by behavior search 2026-08-12 (#413): 1 of 3 met.** The tracking
criterion is a documentation claim and the tree meets it — GAP-049 / #196 owns
the full settlement, so this doc only has to keep the Act-I shrine honest. The
other two are unbuilt. Searched `game/scenes/maps/` for any second Duskfen
scene: there is one file, and it is still
`dungeons/duskfen_spirit_shrine.tscn`, holding `SavePoint`,
`CadenPostEvent` (`npc_id` `caden_duskfen`), one `OverworldExit` and three spawn
markers — no shop metadata, no stilt structures, no trade goods. The
classification criterion is unmet in the most literal way available: the scene
still lives under `maps/dungeons/`, and moving it is a `game/` change this doc
cannot make.

## Design references

- docs/story/city-thornmere.md § 2. Duskfen

## Code references

- game/scenes/maps/dungeons/duskfen_spirit_shrine.tscn — the whole of Duskfen in
  the tree: the save point, Caden's post-event NPC and the overworld exit. The
  path is itself the third criterion's evidence, since a town scene is sitting
  under `maps/dungeons/`.
- docs/issues/GAP-049-epic-faction-cities-settlements-largely-unbuilt-10.md — where
  the full settlement is tracked (issue #196), which is what satisfies the first
  criterion


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/scenes/maps/dungeons/duskfen_spirit_shrine.tscn contains only a SavePoint, CadenPostEvent NPC (auto_sequence 'caden_binding', visible_when_flag 'caden_binding_complete'), and OverworldExit/from_spirit_path/from_overworld markers — i.e. shrine hub only. It lives under dungeons/ though it is a settlement hub. Full bog settlement (stilt structures/shops/NPCs) per city-thornmere.md:207-350 is unbuilt.
- **Notes:** Confirmed and the issue itself notes this is acceptable for the Act-I slice (the shrine is the only Act-I-relevant part) — hence LOW. The 'misfiled under dungeons/' point is valid but cosmetic; moving the .tscn would break res:// path references used by exploration_auto_sequence.gd and load_map calls, so not a safe bounded fix. Full settlement correctly rolls up under GAP-049.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
