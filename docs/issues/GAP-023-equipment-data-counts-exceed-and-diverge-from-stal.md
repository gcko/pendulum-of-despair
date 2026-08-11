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

- docs/story/equipment.md §Weapon/Armor/Accessory Summaries

## Code references

- game/data/equipment/weapons.json|armor.json|accessories.json
- docs/analysis/game-dev-gaps.md:161-163


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** yes (doc)
- **Evidence:** python count: weapons count=61 unique=61 dups=[]; armor count=50 unique=50 dups=[]; accessories count=60 unique=60 dups=[]. Tracker game-dev-gaps.md:161-163 still reads 58 weapons / 49 armor / 47 accessories, each with a stale '[x]' verified mark (lines 164-166).
- **Notes:** Confirmed divergence. The issue's own delta label '+13/+1/+13' is slightly wrong for weapons (actual +3, i.e. 58->61), but the core claim (data exceeds tracker; no dup ids) is accurate. Safe doc-only correction.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The durable, maintained anchors are the file-plus-symbol bullets under **Code references**: those must name a file that exists and a symbol that file actually defines, and `scripts/quality-gates/check_stale_counts.py` fails the build if they do not. Always verify against current code before acting._
