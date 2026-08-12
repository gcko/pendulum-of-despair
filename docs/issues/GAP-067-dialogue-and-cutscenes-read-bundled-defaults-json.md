# GAP-067: Dialogue and cutscenes read bundled defaults.json instead of the player's saved config

| Field | Value |
|-------|-------|
| **ID** | GAP-067 |
| **Area** | Save |
| **Severity** | HIGH |
| **Type** | bug |
| **Effort** | S |
| **Epic** | No |
| **Status** | RESOLVED — fixed in commit d06a566 |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | save |

## Summary

dialogue_box._load_text_speed and cutscene_player._load_config read res://data/config/defaults.json directly, bypassing the path that merges user://config.json, so Text Speed / Reduce Motion / Flash Intensity changes have zero effect.

## Current state (implementation)

Both hardcode the read-only defaults path; the user config file is never read by them.

## Desired state (per design)

Both source settings from PartyState.get_config()/load_config_from_disk and refresh on open.

## Proposed approach

Replace the defaults.json loads with PartyState.get_config(); reload on open() so each dialogue/cutscene picks up current settings.

## Acceptance criteria

- [ ] Changing Text Speed affects the typewriter
- [ ] Reduce Motion/Flash changes affect cutscenes
- [ ] Settings read from the merged user config

## Design references

- docs/story/save-system.md §2
- docs/story/accessibility.md §5/§7

## Code references

- game/scripts/ui/dialogue_box.gd — `_load_text_speed()`
- game/scripts/core/cutscene_player.gd — `_load_config()`
- game/scripts/util/save_data_helpers.gd — `load_config_from_disk()`


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** yes (code)
- **Evidence:** dialogue_box.gd:336-341 reads res://data/config/defaults.json for text_speed; cutscene_player.gd:171-174 reads same path into _config, which then feeds reduce_motion (cutscene_player.gd:354) and flash_intensity (363). Meanwhile AudioManager._apply_bus_volumes (audio_manager.gd:653) and menu_config.open (90) correctly use PartyState.get_config(). So Text Speed / Reduce Motion / Flash Intensity changes never reach dialogue/cutscenes.
- **Notes:** Genuine bug: two consumers bypass the merged-config path. Fix is a 2-line source swap, isolated and obviously correct; grep found no tests asserting the defaults.json path (no test references text_speed/get_config/_load_config). Safe and bounded.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383); write what the file does hold instead. Always verify against current code before acting._
