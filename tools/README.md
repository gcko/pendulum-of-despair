# tools/

Standalone developer scripts. Nothing here runs in a git hook, in CI, or at
game runtime — each one is invoked by hand, and each one is expected to work
when it is.

| Script | Status | What it does |
|--------|--------|--------------|
| `generate_placeholder_audio.py` | Live | Writes silent `.ogg` placeholders for the audio assets listed in `docs/story/audio.md`. Run it, then check it wrote non-empty files — an earlier version produced zero files while reporting success. |

## Retired

### `dialogue_parser.py` — deleted 2026-08-11 (#364)

It generated `game/data/dialogue/*.json` from `docs/story/script/*.md`. It no
longer did either half of that, and running it destroyed shipped content, so it
was deleted rather than repaired. Two versions are worth pulling out of git —
the final content, and the last one that could finish a run:

```bash
git show 8cbd6ebe:tools/dialogue_parser.py  # final content, deleted by #364
git show d8386e47:tools/dialogue_parser.py  # last version that ran to completion
```

The three facts that decided it:

1. **It had not completed a run since 2026-04-05.** `3b2bcc49` added
   `if who and who not in valid_speakers` to `validate_all()` with no
   `valid_speakers` in scope — the name occurs exactly once in that file, at
   the use. Every run after it raised
   `NameError: name 'valid_speakers' is not defined` — *after* writing output,
   so a run failed loudly and mangled the tree anyway. That was not the last
   commit to touch the script: `05d3fe0a` and `8cbd6ebe` edited its hardcoded
   system-text list four months later, in 2026-08, and each of those commits
   hand-edited the matching line in `battle_status_effect_notifications.json`
   in the same breath. Both copies were being maintained by hand; nobody ran
   the script to reconcile them. `dialogue_validation_report.md`, its other
   output, was frozen at `d8386e47`, the commit before the crash landed, and
   was deleted with the script: it described 109 files and 1034 entries
   against a tree that ships 139.

2. **A re-run deleted 31 shipped files.** `__main__` unlinked every
   `game/data/dialogue/*.json` before parsing, and the parse no longer produced
   most of them. The 31 files a re-run deleted are *exactly* the 31 files added
   to that directory since the crash was introduced — every Scene 7 beat, the
   Ember Vein beats, the Fenmother and Duskfen scenes, the Valdris shop NPCs.
   They are referenced by name from `game/scenes/`, `game/scripts/` and
   `game/tests/`, so the regenerate would also have broken the game. Scene 7
   shows how the tree drifted past the parser: the parser's own coarse output,
   `scene_7_the_capital.json`, landed with the parser itself in `6bb6ca8d` and
   still ships, and the six finer-grained files the game actually reads —
   `scene_7a_the_gates.json` through `scene_7d_evening.json` — were authored by
   hand two weeks later in `bae748c5`. Nothing in `game/` references the coarse
   file. The parser never produced the six, so they are six of the 31 a re-run
   deleted.

3. **121 shipped lines have no source to generate from.** Scanning every
   `lines[]` string in `game/data/dialogue/*.json` for a verbatim match anywhere
   in `docs/story/script/*.md` leaves 121 unmatched across 29 files. No parser
   could have emitted them, because the markdown does not contain them (#380).

So `game/data/dialogue/*.json` is **authored, not derived**. It and the script
markdown are two hand-maintained copies of the same player-facing strings, and
the rule that keeps them in step is written down in `docs/story/README.md`
§ Writing Conventions. Nothing enforces it yet — #379 tracks the gate.
