# GAP-056: Valdris Crown Act-I interiors deferred: Chapel, Cael's Quarters, Court interiors

| Field | Value |
|-------|-------|
| **ID** | GAP-056 |
| **Area** | World |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — OVERSTATED |
| **GitHub Issue** | [#202](https://github.com/gcko/pendulum-of-despair/issues/202) |
| **Source domains** | world |

## Summary

The Chapel is only an exterior save point and Cael's Quarters is absent; Court Quarter buildings (Haren's Estate, Council Chambers, Court Mage Tower, Noble Archive) have no interiors.

## Current state (implementation)

Lower Ward has no chapel-interior or Cael's-Quarters transition; an unexpected 'OldHarren' NPC is present that is not in the design directory.

## Desired state (per design)

Chapel of the Old Pacts interior (Thessa, spirit-pact tablets, save) and Cael's Quarters Act-I cutscene interior; remaining Court interiors under the Act-II epic.

## Proposed approach

Prioritize Chapel + Cael's Quarters for Act-I narrative completeness; verify/remove the unexpected OldHarren node.

## Acceptance criteria

- [ ] Chapel interior exists with Thessa and save point
- [ ] Cael's Quarters interior exists for the Act-I beat
- [x] Unexpected OldHarren node verified: `docs/story/npcs.md` § Old Harren
      places him in "Valdris Crown, Lower Ward (the Crown's Rest inn)" as the
      innkeeper, and `game/data/dialogue/npc_old_harren.json` gives the placed
      node its dialogue, so the `OldHarren` instance in
      `valdris_lower_ward.tscn` is designed content, not a stray. Keep it
      (re-measured 2026-08-12)

**Re-verified by behavior search 2026-08-12 (#413): 1 of 3 met.** The
OldHarren criterion resolves to "verified, keep" — the finding read the building
directory and concluded the node was undesigned, but the NPC directory places
him and the engine ships his dialogue file. The other two are unbuilt.
Searched `game/scenes/maps/towns/` for a chapel or quarters interior under any
name: the eight Valdris scenes are Lower Ward, Citizens' Walk, Court Quarter,
Throne Hall, Royal Library, Barracks and the two Anchor & Oar floors, and none
is an interior for either. In `valdris_lower_ward.tscn` the Chapel is still an
exterior `ChapelSave` save point with no transition behind it, and
`valdris_court_quarter.tscn` has exactly two transitions — `SouthRoad` to
Citizens' Walk and `NorthEntrance` to the Throne Hall — so Haren's Estate, the
Council Chambers, the Court Mage Tower and the Noble Archive still have no
interiors to enter.

## Design references

- docs/story/city-valdris.md § 1.3 Building Directory
- docs/story/dungeons-city.md § Valdris Crown: Cael's Quarters (Interior)
- docs/story/interiors.md § 2.1 Valdris Variants

## Code references

- game/scenes/maps/towns/valdris_lower_ward.tscn — holds `ChapelSave` (the
  exterior save point standing in for the Chapel) and the `OldHarren` node the
  third criterion was about
- game/scenes/maps/towns/valdris_court_quarter.tscn — its `Transitions` node is
  the measurement for the missing Court Quarter interiors: `SouthRoad` and
  `NorthEntrance` only
- game/data/dialogue/npc_old_harren.json — the dialogue that, with
  docs/story/npcs.md, verifies the OldHarren node


## Verification (fresh-eyes adversarial pass)

- **Verdict:** OVERSTATED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** TRUE parts: valdris_lower_ward.tscn has only ChapelSave (save_point_id 'valdris_chapel_save') with no chapel-interior transition, and no Cael's Quarters node/scene exists (no chapel/cael interior in towns/). FALSE part: the issue calls the 'OldHarren' node (npc_id 'old_harren') 'unexpected... not in the design directory', but the design explicitly places him there — docs/story/npcs.md:354 'Old Harren', events.md:986 'Old Harren | Valdris Crown (Lower Ward, Crown's Rest inn)', and script/npc-ambient.md:100 'Old Harren (Crown's Rest Inn)'.
- **Notes:** The core partial-impl gap (Chapel + Cael's Quarters interiors deferred) is real and MEDIUM. But the OldHarren accusation is factually wrong — the node correctly implements a designed Lower Ward NPC — so the issue is overstated and acceptance criterion #3 should be removed. Building the interiors is feature work; fixNow false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
