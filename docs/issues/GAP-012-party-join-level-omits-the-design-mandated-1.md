# GAP-012: Party join level omits the design-mandated '-1'

| Field | Value |
|-------|-------|
| **ID** | GAP-012 |
| **Area** | Progression |
| **Severity** | MEDIUM |
| **Type** | bug |
| **Effort** | S |
| **Epic** | No |
| **Status** | RESOLVED — fixed in commit d06a566 |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | progression |

## Summary

_get_party_avg_level returns max(1, floor(avg)); the canonical formula is max(1, floor(avg) - 1), so every recruit joins one level higher than designed.

## Current state (implementation)

Lira/Sable/Torren/Maren join at the full party average level.

## Desired state (per design)

Recruits join at max(1, floor(party_average) - 1).

## Proposed approach

Change the return to maxi(1, floori(avg) - 1); add a unit test for a known average.

## Acceptance criteria

- [ ] Recruits join at floor(avg)-1 (min 1)
- [ ] A unit test asserts join level for a sample party average

## Design references

- docs/story/progression.md:154-156,248

## Code references

- game/scripts/core/exploration_party_joins.gd — `join_level()` (the recruit level, now `maxi(1, floori(avg) - 1)`; PR #357 moved this out of exploration.gd, where it was `_get_party_avg_level`)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** yes (code)
- **Evidence:** exploration.gd:444-450 `_get_party_avg_level()` returns `maxi(1, floori(float(total) / float(PartyState.members.size())))` with no -1. It is the level passed to PartyState.add_member at exploration.gd:425,428,437,440 for Lira/Sable/Torren/Maren. Design progression.md:156 and :248 mandate `join_level = max(1, floor(party_average_level) - 1)`.
- **Notes:** Bounded, safe. No GUT test asserts the resulting join level — test_ironmouth.gd:31-38 calls add_member with its own avg_level constant and never checks the returned level, so the change cannot break the suite. The -1 narrative rationale (catch-up feel) is documented at progression.md:168.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
