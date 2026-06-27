# GAP-086: inventory_helpers.gd placed in scripts/autoload/ but is a static helper, not an autoload

| Field | Value |
|-------|-------|
| **ID** | GAP-086 |
| **Area** | Code structure |
| **Severity** | LOW |
| **Type** | design-divergence |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | arch |

## Summary

inventory_helpers.gd is a static RefCounted utility preloaded as Helpers in ~7 files but lives in scripts/autoload/ alongside the 6 real singletons, against the documented layout (scripts/util/ for utilities).

## Current state (implementation)

project.godot lists exactly 6 autoloads; the file is not registered and is consumed via preload.

## Desired state (per design)

Relocate it (and similar static helpers) to scripts/util/.

## Proposed approach

Move the file to scripts/util/ and update the ~7 preload paths and .uid references.

## Acceptance criteria

- [ ] File moved to scripts/util/
- [ ] All preload paths updated
- [ ] scripts/autoload/ contains only registered singletons

## Design references

- docs/plans/technical-architecture.md §1.1/§1.3

## Code references

- game/scripts/autoload/inventory_helpers.gd:1
- game/scripts/autoload/party_state.gd:7
- game/project.godot:18-25

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
