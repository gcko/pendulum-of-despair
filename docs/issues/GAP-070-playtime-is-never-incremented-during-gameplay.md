# GAP-070: Playtime is never incremented during gameplay

| Field | Value |
|-------|-------|
| **ID** | GAP-070 |
| **Area** | Save |
| **Severity** | MEDIUM |
| **Type** | bug |
| **Effort** | S |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#211](https://github.com/gcko/pendulum-of-despair/issues/211) |
| **Source domains** | save |

## Summary

PartyState.playtime is set to 0 on new game, loaded from save, and written back, but nothing advances it during play, so every slot displays 0:00 for a fresh playthrough.

## Current state (implementation)

No _process/timer accumulates elapsed seconds; grep finds only assignment and reset.

## Desired state (per design)

A running clock accumulates real played seconds (excluding paused menus) into playtime.

## Proposed approach

Add a _process(delta) accumulator in PartyState/GameManager that increments while in non-paused gameplay and folds into playtime on save.

## Acceptance criteria

- [ ] Playtime advances during gameplay
- [ ] Paused menus are excluded
- [ ] Saved/displayed playtime is accurate

## Design references

- docs/story/save-system.md §3.10/§5

## Code references

- game/scripts/autoload/party_state.gd
- game/scripts/autoload/save_manager.gd
- game/scripts/ui/save_load_display.gd


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** party_state.gd:44 `var playtime: int = 0`; reset to 0 at 77; loaded from save at 128; written via save_manager.gd:305-306. Repo-wide grep finds NO `playtime +=` and no _process accumulator in party_state.gd or game_manager.gd. menu_overlay.gd:362 and save_load_display.gd:159-165 only read/format it.
- **Notes:** Confirmed never incremented. A _process accumulator needs gameplay-vs-paused state gating + tests (excluding paused menus). Small but introduces runtime state logic; not a trivially safe doc/data change. fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
