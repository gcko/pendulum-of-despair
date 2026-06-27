# GAP-085: Godot engine version mismatch: project on 4.7, all docs say 4.6

| Field | Value |
|-------|-------|
| **ID** | GAP-085 |
| **Area** | Docs |
| **Severity** | LOW |
| **Type** | doc-inconsistency |
| **Effort** | S |
| **Epic** | No |
| **Status** | RESOLVED — fixed in commit d06a566 |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | arch |

## Summary

project.godot declares feature version 4.7 while technical-architecture.md, game-dev-gaps.md, AGENTS.md, and CLAUDE.md all say 4.6.

## Current state (implementation)

config/features=PackedStringArray('4.7','GL Compatibility') vs docs' 'Godot 4.6+'.

## Desired state (per design)

Docs and project agree on the engine version.

## Proposed approach

One-line doc updates across the four references (or pin the project to 4.6 if intended).

## Acceptance criteria

- [ ] Docs state the same version as project.godot
- [ ] All four references updated

## Design references

- docs/plans/technical-architecture.md:3,7
- AGENTS.md / CLAUDE.md

## Code references

- game/project.godot:15


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** yes (doc)
- **Evidence:** game/project.godot:15 config/features=PackedStringArray("4.7", "GL Compatibility"). Docs say 4.6: technical-architecture.md:3,7; AGENTS.md:9,51,59; CLAUDE.md:23; game-design/dev-gaps game-dev-gaps.md:10 'Engine: Godot 4.6+'.
- **Notes:** Confirmed mismatch. Minor direction judgment (update docs to 4.7 vs pin project to 4.6); updating docs to match the actual project is the safe choice.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
