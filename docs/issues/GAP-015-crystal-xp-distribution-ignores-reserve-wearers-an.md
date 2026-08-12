# GAP-015: Crystal XP distribution ignores reserve wearers and KO status

| Field | Value |
|-------|-------|
| **ID** | GAP-015 |
| **Area** | Progression |
| **Severity** | LOW |
| **Type** | partial-impl |
| **Effort** | S |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#220](https://github.com/gcko/pendulum-of-despair/issues/220) |
| **Source domains** | progression |

## Summary

distribute_crystal_xp credits only active members' crystals at a flat 30% of full battle XP regardless of KO, and gives reserve crystals nothing.

## Current state (implementation)

KO'd active wearers are over-credited; reserve wearers are under-credited; design ties crystal XP to the wearer's actual XP (0 if KO'd, 50% if reserve).

## Desired state (per design)

Each crystal gains 30% of its wearer's actual awarded XP across active and reserve members.

## Proposed approach

Compute each member's awarded XP (0 KO'd-active, full active-alive, half reserve) and grant 30% of that to their crystal; iterate all members.

## Acceptance criteria

- [ ] KO'd active wearer's crystal gains 0
- [ ] Reserve wearer's crystal gains 30% of the 50% share
- [ ] Active-alive wearer's crystal gains 30% of full

**Re-verified by behavior search 2026-08-12 (#413): 0 of 3 met, nothing has
moved.** Searched `game/scripts/` and `game/tests/` for `distribute_crystal_xp`
and `add_crystal_xp`. The function is still the one the finding measured and
still lives in `exploration.gd`: it walks `PartyState.formation["active"]` only,
and calls `PartyState.add_crystal_xp(cid, int(xp_per_member * 0.3))` with no KO
check, so a KO'd active wearer is credited in full and a reserve wearer is
credited nothing. Its two other callers, both in `cleansing_sequence.gd`, route
through the same function (`start()`, `continue_sequence()`) and inherit the
same behavior. Note the criteria list
three cases while the finding is four-way (active/reserve × alive/KO); a reserve
KO'd wearer is unstated and should be settled when this is implemented.

## Design references

- docs/story/progression.md § XP Distribution Rules

## Code references

- game/scripts/core/exploration.gd — `distribute_crystal_xp()`
- game/scripts/autoload/party_state.gd — `add_crystal_xp()` (the credit call the
  distribution makes; the wearer's own KO/reserve state is never passed to it)
- game/scripts/core/cleansing_sequence.gd — `start()` and `continue_sequence()`,
  the two other callers of `distribute_crystal_xp()`, which inherit the same rule


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** exploration.gd:700-713 distribute_crystal_xp iterates only PartyState.formation.active indices and adds `int(xp_per_member * 0.3)` for any equipped crystal with no KO check; reserve members are never iterated. Called at exploration.gd:226 and cleansing_sequence.gd:79,126 with the full battle XP (rewards.xp). Member XP rules (inventory_helpers.gd:239-253: active-alive full, active-KO'd 0, reserve half) are NOT mirrored here. Design progression.md:228/309 ties crystal XP to 30% of the wearer's actual XP.
- **Notes:** Confirmed: KO'd active wearers over-credited (should get 0), reserve wearers under-credited (should get 30% of their 50% share). Real but LOW impact. fixNow=false: correcting it requires restructuring the loop to walk active (0 if current_hp<=0, full if alive) and reserve (half) members and should land with GUT coverage — more than a trivial one-liner. Good small follow-up for game-designer. No existing test asserts current distribute_crystal_xp behavior, so it is unblocked.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
