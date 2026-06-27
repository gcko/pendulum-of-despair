# GAP-085: Godot engine version mismatch: project on 4.7, all docs say 4.6

| Field | Value |
|-------|-------|
| **ID** | GAP-085 |
| **Area** | Docs |
| **Severity** | LOW |
| **Type** | doc-inconsistency |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
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

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
