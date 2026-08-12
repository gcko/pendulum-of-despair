# GAP-088: Resolution/accessibility doc divergence: impl on 1280x720 native + 4x zoom, docs still assume 320x180 integer scaling

| Field | Value |
|-------|-------|
| **ID** | GAP-088 |
| **Area** | Docs |
| **Severity** | LOW |
| **Type** | doc-inconsistency |
| **Effort** | S |
| **Epic** | No |
| **Status** | RESOLVED — fixed in commit d06a566 |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | tracker |

## Summary

The accessibility High-Res-Text and integer-scaling rationale rests on a 320x180 base, but the implementation moved to 1280x720 native with 4x camera zoom (2026-04-08); the design-gaps 4.4 entry was never reconciled.

## Current state (implementation)

design-gaps:703 still cites 320x180 as the accessibility foundation; the change is documented only in the dev tracker.

## Desired state (per design)

accessibility.md, visual-style.md, and design-gaps 4.4 describe the 1280x720/4x-zoom model; confirm whether High-Res Text is still meaningful.

## Proposed approach

Reconcile the resolution model across the docs and re-justify or drop the High-Res Text toggle.

## Acceptance criteria

- [ ] Docs describe the 1280x720/4x model
- [ ] High-Res Text relevance decided
- [ ] design-gaps 4.4 updated

## Design references

- docs/analysis/game-design-gaps.md:703
- docs/analysis/game-dev-gaps.md:11
- docs/story/accessibility.md

## Code references

- game/project.godot (1280x720 viewport, 4x zoom)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** OVERSTATED
- **Verified severity:** LOW
- **Safe to fix immediately:** yes (doc)
- **Evidence:** The issue claims accessibility.md/visual-style.md still assume 320x180 — FALSE. accessibility.md:26-28 already states '1280x720 viewport with 4x camera zoom (effective 320x180 game world)... This replaces the original spec', and :59 repeats it; visual-style.md:30 '...viewport is 1280x720 with 4x camera zoom (effective 320x180 game world), integer-sc...'. The only residual stale reference is game-design-gaps.md:703 which still cites '320×180 base resolution' as the accessibility foundation.
- **Notes:** Two of three named docs are already reconciled; only one tracker line lags, and it is arguably still accurate since the effective game world remains 320x180. Minor doc clarification at most.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383); write what the file does hold instead. Always verify against current code before acting._
