---
name: quality-gate-authoring
description: >
  Use when adding or changing anything that is supposed to CATCH something —
  a script under scripts/quality-gates/, a GUT guard, a regression test, a
  pre-push check, or a doc claim about what one of those enforces. Covers
  mutation verification (watch it fail or it does not exist), proving a scan
  is not vacuous by breaking its recursion, the shrink-only ratchet for
  switching on a gate that has pre-existing violations, and keeping a guard's
  unit the same as the rule it enforces.
---

# Authoring a quality gate

Every gate in `scripts/quality-gates/` exists because something rotted
silently. The failure they all guard against is the same one, and it is not
"the check said no": it is **the check said nothing, and nobody could tell
the difference between nothing-wrong and did-not-look.**

Real examples from this repo, all shipped and all green at the time:

- `check_doc_citations.py` resolved `§ 1.2a` to `### 1.2 Naming Conventions`
  by truncating the letter, so a citation to a section nobody wrote passed.
- A scan asserted "zero bare viewport calls" while returning early on an
  unreadable directory — it inspected nothing and reported clean.
- `test_script_layout.gd` counted lines with `split("\n").size()` while the
  docs and `check_stale_counts.py` used `wc -l`, so the 600-line ceiling was
  really 599.
- `§ 1.2a` justified a file's size with "the test suite asserts against these
  fields", long after the suite had stopped doing that. Nothing checks whether
  a stated reason is still true.
- `test_quality_gates.py` had 36 tests that no hook or workflow ever ran.

## 1. Mutation-verify, or the gate does not exist

**Break the thing the gate protects. Watch the gate fail. Revert. Report the
literal output.** A gate you have not seen fail is a gate you are guessing
about, and this repo has shipped several that never could have failed.

Do it against the REAL tree, not only a fixture — a fixture proves the
function works, the real tree proves the gate is wired to it. Both matter, and
they fail differently: `test_quality_gates.py` had 36 passing tests that no
hook or workflow ever ran, so every one of them was green and none of them
guarded anything.

Report it as literal terminal output in the PR body. "Mutation-verified" as a
claim, with no output, is exactly the kind of unbacked assertion these gates
exist to catch.

## 2. Prove the scan is not vacuous — break the RECURSION, not the entry

This is the one people get wrong, so it gets its own step.

A scan that walks a tree usually has its top-level entry already guarded
(`if dir == null: fail`). Severing that proves nothing. The vacuous case is a
walk that **enters every root, reads the files sitting directly in them, and
never descends** — which looks like work, returns a plausible number, and
misses everything.

Sever the descent (`dirnames[:] = []` inside the walk, or the equivalent) and
confirm the gate fails. In this repo that cut `check_spelling.py`'s corpus by
roughly two thirds while it still reported a plausible three-figure file count —
completely blind, because every script under `game/scripts/` lives at least one
level below the root the walk was still entering.

So:

- Assert a **floor on what was inspected**, not just on what was found.
  `assert scanned > 300`, per-root if the roots differ in size.
- **Print the corpus size on success.** "validation passed" and "validation
  passed, N citations resolved across M files" are different sentences, and only
  the second distinguishes a clean scan from a dead one. Run
  `python3 scripts/quality-gates/check_doc_citations.py` to see the shape the
  gates here use — and note that quoting its literal numbers into a doc is how
  they go stale, which is why this bullet does not.
- Make the floor's failure message say *repair the walk*, not *lower the floor*.

## 3. Turning on a gate that already has violations: the ratchet

A gate that fails on 121 pre-existing violations is a gate nobody can enable,
so it gets disabled or never landed. Pin the existing ones in a shrink-only
list — `KNOWN_UNRESOLVED`, `KNOWN_ORPHANS`, `KNOWN_VIOLATIONS`,
`UNDOCUMENTED_BAND_FILES` are the four in the tree today.

**A ratchet must fail at BOTH ends:**

| Condition | Must |
|---|---|
| a NEW violation appears | fail — "pinning a new hit is not the fix" |
| a pinned violation is FIXED | fail — the stale pin must be deleted |
| a pinned count shrinks | fail — lower the number |
| a pinned file is deleted | fail, saying the FILE is gone, not that the line resolved |

Only the first is obvious, and only the others make the list shrink. Without
them a pin outlives its reason and quietly becomes an amnesty. Both mutation
directions get verified, not just the new-violation one.

Say in the error message that pinning is not how you fix a new hit. Someone
will try.

## 4. Keep the guard's unit identical to the rule's

If the rule is stated in prose and checked in code, both sides must measure
the same way — ideally by sharing one implementation.

`split("\n").size()` and `wc -l` differ by one on any file ending in a
newline. The GDScript ceiling test used the first, the docs tables and the
Python gate used the second, so "600" meant 599 on one side of the repo and
600 on the other. The fix was `text.count("\n")`, chosen because it is
byte-identical to what `check_stale_counts.py` already did.

The same trap in tests: when a unit test calls the function production calls,
pass arguments of the same SHAPE. A test handing a character length where
production passes a word count is not exercising the bound it claims to.

## 5. Never write prose claiming more than the code checks

This defect shipped four separate times in one milestone, which is why it is a
numbered step rather than a footnote.

Before writing "enforced by `X`", open `X` and read what it enforces. Then
write only that.

- `test_script_layout.gd` checks a band file is **named** in § 1.2a. It does
  not check the stated reason is still true. Prose saying "justified in the
  doc" overclaims.
- `test_spell_balance.gd` holds the JSON to bands hardcoded in the test. It
  never parses `magic.md`. Prose saying it enforces the doc's rule is false.
- If a guarantee has a limit, state the limit in the same breath — and where
  you can, make the exposure a NUMBER the gate prints, so it can be watched
  shrink instead of being rediscovered.

## Checklist

- [ ] Mutated the protected thing, watched the gate fail, reverted, captured output
- [ ] Mutated against the real tree, not only a fixture
- [ ] Broke the walk's RECURSION and confirmed failure
- [ ] Asserts a floor on items inspected; prints corpus size on success
- [ ] Ratchet (if any) fails on new violation AND stale pin AND missing file
- [ ] Guard's unit matches the rule's, sharing an implementation where possible
- [ ] Wired into `.husky/pre-push` with its own letter, and the docstring agrees
- [ ] Every "enforced by" sentence checked against the code it names
- [ ] Self-tests are actually run by a hook (pre-push Gate I discovers the
      directory), not only by `scripts/gates.sh`, which nothing runs for you
