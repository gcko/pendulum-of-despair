# GAP-055: Ironmouth implemented as an escape corridor, diverging from the designed Carradan port city

| Field | Value |
|-------|-------|
| **ID** | GAP-055 |
| **Area** | World |
| **Severity** | MEDIUM |
| **Type** | design-divergence |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#201](https://github.com/gcko/pendulum-of-despair/issues/201) |
| **Source domains** | world |

## Summary

ironmouth_docks.tscn is a linear Scene-3 escape corridor (forced combat, 3 crates, party-join dialogue) reusing the Ironmouth name, with no shops/buildings/city layout from the canonical port-city design.

## Current state (implementation)

A deliberate Act-I narrative stub that collides with the future full Ironmouth city under the same name.

## Desired state (per design)

Keep the corridor for Act I but namespace it (e.g. ironmouth_escape) and track the real city under the Carradan epic.

## Proposed approach

Rename/namespace the corridor; update design docs if Ironmouth-as-city is being cut.

## Acceptance criteria

- [ ] Corridor renamed to avoid name collision
- [ ] Full Ironmouth city tracked under the cities epic
- [ ] Docs reconciled

## Design references

- docs/story/city-carradan.md:1168-1270

## Code references

- game/scenes/maps/towns/ironmouth_docks.tscn


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/scenes/maps/towns/ironmouth_docks.tscn (location_name 'Ironmouth Docks', encounter_enabled=false) is a linear corridor: LiraDialogue, three crate chests (ironmouth_crate_1/2/3), SableDialogue, BossTrigger, PostCombatDialogue (ironmouth_post_combat), and from_overworld/from_ember_vein markers. No shops/buildings/city layout. Design city-carradan.md:1168-1270 defines Ironmouth as a full Carradan port city.
- **Notes:** Accurate design-divergence. Renaming/namespacing the scene (e.g. ironmouth_escape) is the suggested fix but would require updating all res:// path references and load_map targets, so not a safe bounded change without verifying every reference; fixNow false. Full city tracked under GAP-049.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
