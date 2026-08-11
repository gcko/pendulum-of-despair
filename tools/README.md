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
was deleted rather than repaired. The last version that ran at all is in git:

```bash
git show 3b2bcc49:tools/dialogue_parser.py
```

The three facts that decided it:

1. **It had not completed a run since 2026-04-05.** Its own last commit,
   `3b2bcc49`, added `if who and who not in valid_speakers` to `validate_all()`
   with no `valid_speakers` in scope. Every run since raised
   `NameError: name 'valid_speakers' is not defined` — *after* writing output,
   so a run failed loudly and mangled the tree anyway. `dialogue_validation_report.md`,
   its other output, was frozen at the commit before that one and was deleted
   with it: it described 109 files and 1034 entries against a tree that ships 139.

2. **A re-run deleted 31 shipped files.** `__main__` unlinked every
   `game/data/dialogue/*.json` before parsing, and the parse no longer produced
   most of them. The 31 files a re-run deleted are *exactly* the 31 files added
   to that directory since the crash was introduced — every Scene 7 beat, the
   Ember Vein beats, the Fenmother and Duskfen scenes, the Valdris shop NPCs.
   They are referenced by name from `game/scenes/`, `game/scripts/` and
   `game/tests/`, so the regenerate would also have broken the game. The parser
   had also re-split and renamed what it did produce (`scene_7_the_capital.json`
   where the tree ships `scene_7a_the_gates.json` and its siblings).

3. **121 shipped lines have no source to generate from.** Scanning every
   `lines[]` string in `game/data/dialogue/*.json` for a verbatim match anywhere
   in `docs/story/script/*.md` leaves 121 unmatched across 29 files. No parser
   could have emitted them, because the markdown does not contain them (#380).

So `game/data/dialogue/*.json` is **authored, not derived**. It and the script
markdown are two hand-maintained copies of the same player-facing strings, and
the rule that keeps them in step is written down in `docs/story/README.md`
§ Writing Conventions. Nothing enforces it yet — #379 tracks the gate.
