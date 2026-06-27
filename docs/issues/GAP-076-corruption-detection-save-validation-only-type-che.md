# GAP-076: Corruption-detection save validation only type-checks meta and world

| Field | Value |
|-------|-------|
| **ID** | GAP-076 |
| **Area** | Save |
| **Severity** | LOW |
| **Type** | partial-impl |
| **Effort** | S |
| **Epic** | No |
| **Status** | open — CONFIRMED |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** save_manager.gd:214-237 _validate: checks all 10 required keys exist (229-231) but type-asserts ONLY data['meta'] (233) and data['world'] (236). party/formation/inventory/owned_equipment/crafting/ley_crystals/quests/completion types are unchecked — a save with party as a String passes.
- **Notes:** Confirmed partial-impl. Fix itself is small but stricter validation risks rejecting existing minimal GUT save fixtures (exact expected per-group types must be confirmed against fixtures first) and the acceptance criteria requires a new rejection test. Not a clearly safe bounded change against the 916-test suite. fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
