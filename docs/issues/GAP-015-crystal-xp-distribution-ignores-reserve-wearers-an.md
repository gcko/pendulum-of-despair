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

## Design references

- docs/story/progression.md:226-229

## Code references

- game/scripts/core/exploration.gd:700-713


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** exploration.gd:700-713 distribute_crystal_xp iterates only PartyState.formation.active indices and adds `int(xp_per_member * 0.3)` for any equipped crystal with no KO check; reserve members are never iterated. Called at exploration.gd:226 and cleansing_sequence.gd:79,126 with the full battle XP (rewards.xp). Member XP rules (inventory_helpers.gd:239-253: active-alive full, active-KO'd 0, reserve half) are NOT mirrored here. Design progression.md:228/309 ties crystal XP to 30% of the wearer's actual XP.
- **Notes:** Confirmed: KO'd active wearers over-credited (should get 0), reserve wearers under-credited (should get 30% of their 50% share). Real but LOW impact. fixNow=false: correcting it requires restructuring the loop to walk active (0 if current_hp<=0, full if alive) and reserve (half) members and should land with GUT coverage — more than a trivial one-liner. Good small follow-up for game-designer. No existing test asserts current distribute_crystal_xp behavior, so it is unblocked.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The durable, maintained anchors are the file-plus-symbol bullets under **Code references**: those must name a file that exists and a symbol that file actually defines, and `scripts/quality-gates/check_stale_counts.py` fails the build if they do not. Always verify against current code before acting._
