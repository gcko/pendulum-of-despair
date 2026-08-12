# GAP-023: Equipment data counts exceed and diverge from stale tracker figures

| Field | Value |
|-------|-------|
| **ID** | GAP-023 |
| **Area** | Items/Economy |
| **Severity** | LOW |
| **Type** | doc-inconsistency |
| **Effort** | S |
| **Epic** | No |
| **Status** | RESOLVED — fixed in commit d06a566 |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | items |

## Summary

Tracker claims 58/49/47 but live data has 61 weapons / 50 armor / 60 accessories (no dup ids); the '+13/+1/+13' additions are unverified against the canonical catalog.

## Current state (implementation)

Counts have grown past the tracker; the '[x] verified against equipment.md' claim is stale.

## Desired state (per design)

Tracker counts match data and each entry is re-verified against equipment.md (stats/tier/price/equippable_by).

## Proposed approach

Run an adversarial data-vs-doc diff for the three equipment JSONs and update game-dev-gaps.md counts.

## Acceptance criteria

- [ ] Tracker counts match actual data
- [ ] Added items are confirmed canonical or removed
- [ ] Diff is recorded

## Design references

- docs/story/equipment.md § Weapon Summary by Tier
- docs/story/equipment.md § Body Armor Summary
- docs/story/equipment.md § Accessory Summary

## Code references

- game/data/equipment/weapons.json|armor.json|accessories.json
- docs/analysis/game-dev-gaps.md


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** yes (doc)
- **Evidence:** python count: weapons count=61 unique=61 dups=[]; armor count=50 unique=50 dups=[]; accessories count=60 unique=60 dups=[]. Tracker game-dev-gaps.md:161-163 still reads 58 weapons / 49 armor / 47 accessories, each with a stale '[x]' verified mark (lines 164-166).
- **Notes:** Confirmed divergence. The issue's own delta label '+13/+1/+13' is slightly wrong for weapons (actual +3, i.e. 58->61), but the core claim (data exceeds tracker; no dup ids) is accurate. Safe doc-only correction.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
