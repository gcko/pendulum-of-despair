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
| **GitHub Issue** | [#232](https://github.com/gcko/pendulum-of-despair/issues/232) |
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

- game/scripts/autoload/save_manager.gd — `_validate()`


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** save_manager.gd:214-237 _validate: checks all 10 required keys exist (229-231) but type-asserts ONLY data['meta'] (233) and data['world'] (236). party/formation/inventory/owned_equipment/crafting/ley_crystals/quests/completion types are unchecked — a save with party as a String passes.
- **Notes:** Confirmed partial-impl. Fix itself is small but stricter validation risks rejecting existing minimal GUT save fixtures (exact expected per-group types must be confirmed against fixtures first) and the acceptance criteria requires a new rejection test. Not a clearly safe bounded change against the 916-test suite. fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
