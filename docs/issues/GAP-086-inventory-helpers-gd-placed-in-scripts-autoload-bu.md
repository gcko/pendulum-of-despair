# GAP-086: inventory_helpers.gd placed in scripts/autoload/ but is a static helper, not an autoload

| Field | Value |
|-------|-------|
| **ID** | GAP-086 |
| **Area** | Code structure |
| **Severity** | LOW |
| **Type** | design-divergence |
| **Effort** | S |
| **Epic** | No |
| **Status** | resolved — Issue #236 |
| **GitHub Issue** | [#236](https://github.com/gcko/pendulum-of-despair/issues/236) |
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

- [x] File moved to scripts/util/ (`game/scripts/util/inventory_helpers.gd`)
- [x] All preload paths updated (14 call sites)
- [x] scripts/autoload/ contains only registered singletons (guarded by `game/tests/test_script_layout.gd`)

## Design references

- docs/plans/technical-architecture.md §1.1/§1.3

## Code references

- game/scripts/autoload/inventory_helpers.gd (pre-move location; now `game/scripts/util/inventory_helpers.gd` — see Resolution below)
- game/scripts/autoload/party_state.gd
- game/project.godot


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/scripts/autoload/inventory_helpers.gd:1 'extends RefCounted' with static helpers ('Extracted from PartyState to keep files under 400 lines'), NOT registered in project.godot autoloads (only the 6 real singletons listed at lines 20-25). scripts/util/ already exists and holds a sibling static helper (input_util.gd), and the documented layout (technical-architecture.md:64 'util/  # Utility functions') confirms utilities belong there. Consumed via preload in 4 files: ui/save_load_display.gd, ui/menu_status.gd, ui/menu_equip.gd, autoload/party_state.gd.
- **Notes:** Real divergence, but '~7 files' is overstated — only 4 preload it. fixNow=FALSE: a Godot file move requires updating .uid references and resource paths (touches core party_state.gd) — exactly the kind of move that can disturb the 916-test suite; not a trivial bounded edit.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._

## Resolution (Issue #236, 2026-08-11)

`inventory_helpers.gd` moved to `game/scripts/util/`, so `scripts/autoload/`
now contains exactly the six scripts registered in the `[autoload]` block of
`project.godot`. All 14 `preload("res://scripts/autoload/inventory_helpers.gd")`
call sites were repointed at `res://scripts/util/inventory_helpers.gd` — 8
source files (`ui/save_load_display.gd`, `ui/menu_status.gd`, `ui/menu_items.gd`,
`ui/menu_equip.gd`, `ui/battle_command_menu.gd`, `combat/battle_state.gd`,
`autoload/save_manager.gd`, `autoload/party_state.gd`) and 6 test files. Pure
relocation: no behavior change, and `game/tests/test_script_layout.gd` now
guards the split against regression.

Two notes on the claims above.

Both file counts in the body above are off, in opposite directions. This doc was
generated on 2026-06-27 (commits 50ccf8d, c7e54a0, 381d38a); at all three,
`git grep -l autoload/inventory_helpers -- game/` returns 6 files — four source
(`autoload/party_state.gd`, `ui/menu_equip.gd`, `ui/menu_status.gd`,
`ui/save_load_display.gd`) and two tests (`test_battle_rewards.gd`,
`test_issue_fixes.gd`). So the summary's "~7 files" rounded 6 up, and the
verification note's "only 4 preload it" dropped the two test files. A seventh
consumer, `test_mechanical_tweaks.gd`, joined the next day in c737565
(2026-06-28); continued work on the inventory and combat systems took it from 6
at authoring to the 14 repointed here.

The "update the .uid references" step was a no-op, but not because sidecars do
not exist — every script in `game/scripts/` has one on disk. It was a no-op
because nothing pointed at this script by UID: no `inventory_helpers.gd.uid` is
tracked in git, and grepping the repo for the UIDs held by the old and new
sidecars returns no hits. Every consumer preloads a `res://` path, so the
untracked sidecar was free to be regenerated at the new location.

That reasoning does not generalise to the rest of the directory. `*.uid` is
gitignored (`.gitignore:7`), but the rule postdates 24 already-tracked sidecars
— gitignore does not untrack a tracked file — five of which sit in
`scripts/autoload/` (`audio_manager`, `data_manager`, `event_flags`,
`game_manager`, `save_manager`). Moving any of those would need a tracked `.uid`
rename, and `test_script_layout.gd` would not catch a miss: it inspects only
`.gd` files.

> **No longer current (#315).** All 24 of those sidecars — the five in
> `scripts/autoload/` included — were untracked in this milestone, so the
> generalisation the paragraph above withholds now holds for the whole tree:
> `git ls-files '*.uid' | wc -l` returns 0, and no script anywhere has a
> tracked `.uid`. Moving a script no longer needs a `.uid` rename, and the
> `test_script_layout.gd` blind spot the paragraph names is no longer
> reachable. The rationale, and the one condition that would force this
> decision to be revisited, is recorded in the comment above the `*.uid` rule
> in `.gitignore`.
