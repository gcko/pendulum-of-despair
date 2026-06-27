# GAP-076: Corruption-detection save validation only type-checks meta and world

| Field | Value |
|-------|-------|
| **ID** | GAP-076 |
| **Area** | Save |
| **Severity** | LOW |
| **Type** | partial-impl |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | save |

## Summary

_validate checks the 10 required keys exist but type-checks only meta and world; a save with right keys but wrong-typed values (e.g. party as a string) passes and can crash downstream.

## Current state (implementation)

Only data['meta'] and data['world'] are asserted to be Dictionaries.

## Desired state (per design)

Validate the type of each required group per the schema before accepting the save.

## Proposed approach

Extend _validate with per-group type assertions (party Array, formation/inventory Dictionary, etc.).

## Acceptance criteria

- [ ] Each required group is type-checked
- [ ] Malformed saves are flagged corrupted
- [ ] A test feeds a wrong-typed group and asserts rejection

## Design references

- docs/story/save-system.md §11

## Code references

- game/scripts/autoload/save_manager.gd:214-237

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
