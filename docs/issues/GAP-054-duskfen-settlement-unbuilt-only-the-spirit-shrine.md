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

- [ ] Full Duskfen settlement tracked under the cities epic
- [ ] Settlement has shops/NPCs/trade goods
- [ ] Path/classification corrected (town not dungeon)

## Design references

- docs/story/city-thornmere.md § 2. Duskfen

## Code references

- game/scenes/maps/dungeons/duskfen_spirit_shrine.tscn


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/scenes/maps/dungeons/duskfen_spirit_shrine.tscn contains only a SavePoint, CadenPostEvent NPC (auto_sequence 'caden_binding', visible_when_flag 'caden_binding_complete'), and OverworldExit/from_spirit_path/from_overworld markers — i.e. shrine hub only. It lives under dungeons/ though it is a settlement hub. Full bog settlement (stilt structures/shops/NPCs) per city-thornmere.md:207-350 is unbuilt.
- **Notes:** Confirmed and the issue itself notes this is acceptable for the Act-I slice (the shrine is the only Act-I-relevant part) — hence LOW. The 'misfiled under dungeons/' point is valid but cosmetic; moving the .tscn would break res:// path references used by exploration_auto_sequence.gd and load_map calls, so not a safe bounded fix. Full settlement correctly rolls up under GAP-049.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
