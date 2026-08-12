# GAP-077: Config persistence is owned by PartyState/inventory_helpers, not SaveManager (responsibility split)

| Field | Value |
|-------|-------|
| **ID** | GAP-077 |
| **Area** | Architecture |
| **Severity** | LOW |
| **Type** | design-divergence |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#233](https://github.com/gcko/pendulum-of-despair/issues/233) |
| **Source domains** | arch |

## Summary

SaveManager declares CONFIG_PATH but never reads/writes it; config I/O lives in PartyState.save_config/_load_config and inventory_helpers.load_config_from_disk, splitting persistence across three files outside the designated manager.

## Current state (implementation)

Only the constant declaration is in SaveManager; functional config I/O is elsewhere.

## Desired state (per design)

Either move config save/load into SaveManager (where CONFIG_PATH lives) or move CONFIG_PATH out so ownership is coherent.

## Proposed approach

Add SaveManager.save_config/load_config delegating to the JSON helper; have PartyState call SaveManager.

## Acceptance criteria

- [ ] Config ownership is coherent with the architecture
- [ ] CONFIG_PATH lives with the code that uses it
- [ ] Callers updated

## Design references

- docs/plans/technical-architecture.md §1.3/§6.3/§6.6

## Code references

- game/scripts/autoload/save_manager.gd
- game/scripts/autoload/party_state.gd — `save_config()`, `_load_config()` (config I/O outside SaveManager)
- game/scripts/util/save_data_helpers.gd — `load_config_from_disk()`


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** save_manager.gd:14 declares CONFIG_PATH but SaveManager never reads/writes it (grep shows it's referenced only externally). Config I/O lives in `party_state.gd` `save_config()` (writes SaveManager.CONFIG_PATH) and `save_data_helpers.gd` `load_config_from_disk()` (reads SaveManager.CONFIG_PATH). Persistence is split across three files.
- **Notes:** Confirmed responsibility split / design-divergence (LOW). Resolving it means moving config I/O into SaveManager and updating PartyState/inventory_helpers callers + tests — a refactor touching 3 autoloads. Not bounded. fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
