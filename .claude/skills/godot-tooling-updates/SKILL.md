---
name: godot-tooling-updates
description: >
  Check and update the versioned tooling in this Godot project: the GUT test
  addon (game/addons/gut/), gdtoolkit (gdlint/gdformat), and the husky +
  commitlint npm devDependencies used only for git hooks. Detects current
  versions, researches breaking changes, confirms with the user, applies
  updates, verifies via the real gates (gdlint, gdformat --check, Godot
  import, GUT suite), files chore Issues, and bundles everything into one
  chore PR. Trigger when the user asks to update tooling, bump GUT, refresh
  the linter/formatter, update commit hooks, or do tooling maintenance.
---

# Godot Tooling Updates

This project has **no npm runtime dependencies** and no monorepo. The only
things with versions are:

1. **GUT** — the test framework, vendored at `game/addons/gut/` (currently
   **9.7.1**, the release tag exactly, except `addons/gut/versions.json`,
   which is bitwes/Gut main's published copy — see Phase 5). Source:
   `bitwes/Gut` on GitHub.
2. **gdtoolkit** — the Python package providing `gdlint` and `gdformat`
   (the lint/format gates). Installed via `pip`/`pipx`, not the repo, but
   the version is pinned in `scripts/quality-gates/gdtoolkit-version.txt`:
   `.github/workflows/static-gates.yml` installs exactly that version and
   `.husky/pre-commit` fails a commit with staged `.gd` files when gdtoolkit
   is missing or at a version other than the pin, and quotes the pin.
3. **husky + @commitlint/cli + @commitlint/config-conventional** — the only
   npm `devDependencies` in `package.json`. Used for git hooks, and since
   #472 CI runs commitlint too: `.github/workflows/static-gates.yml` installs
   them with `pnpm/action-setup@v6` (pnpm from `packageManager`) on Node 24.
   `pnpm` exists solely for these. A commitlint or pnpm bump must re-check
   those minimums: pnpm 11 needs pnpm/action-setup v6 or later, and the
   `engines.node` of the new pnpm and @commitlint/cli must be at or below
   that Node (`pnpm view <pkg>@<ver> engines`).

There is no Phaser/TypeScript/Vitest/Express/SQLite/`packages/*`. Do not run
`pnpm outdated --recursive` against a workspace — there isn't one.

---

## Workflow

For each tool: **detect current version -> check upstream for newer ->
research breaking changes -> confirm with user -> apply -> verify via the
real gates**. Then file/close Issues and bundle into one chore PR.

### Phase 1: Detect Current Versions

```bash
# GUT (vendored addon)
grep '^version=' game/addons/gut/plugin.cfg          # -> 9.7.1

# gdtoolkit (provides gdlint + gdformat)
cat scripts/quality-gates/gdtoolkit-version.txt      # the pin CI installs
gdformat --version
gdlint --version
pipx list 2>/dev/null | grep -i gdtoolkit || pip show gdtoolkit

# npm hook tooling
cat package.json                                     # devDependencies block
pnpm --version
```

### Phase 2: Check Upstream for Newer

- **GUT:** find the highest released version by **semver sort**.
  ```bash
  gh api 'repos/bitwes/Gut/releases?per_page=20' \
    --jq '.[] | select(.prerelease | not) | select(.draft | not) | .tag_name' \
    | sed 's/^v//' | sort -V | tail -1
  ```
  Do NOT find the newest version with a bare `gh release view` (no tag) or
  `releases/latest`: GitHub's "Latest" flag is not a version sort. On
  2026-10-26 it pointed at v9.6.1 while v9.7.1 was already released, so
  trusting it reads a newer installed GUT as a downgrade.
- **gdtoolkit:** check PyPI for the newest version.
  ```bash
  pip index versions gdtoolkit 2>/dev/null \
    || curl -s https://pypi.org/pypi/gdtoolkit/json | python3 -c "import sys,json;print(json.load(sys.stdin)['info']['version'])"
  ```
- **husky / commitlint:** check the registry for these three packages only.
  ```bash
  pnpm outdated   # root package.json only — no -r/--recursive
  ```

If everything is current, report that and stop.

### Phase 3: Research Breaking Changes

For every tool with a newer version, **do not guess**. Research before
proposing the bump:

- **GUT:** read the release notes between current and target
  (`gh release view v<tag> --repo bitwes/Gut`). Watch for renamed asserts,
  changed `gut_cmdln.gd` flags, or `.gutconfig`/runner changes. Note that
  the `game/tests/test_*.gd` files use the project's existing assert conventions
  (`assert_lte`/`assert_gte`, never `assert_le`/`assert_ge`).
- **gdtoolkit:** read its changelog. **A `gdformat` bump can change
  formatting rules**, which would make `gdformat --check` fail across files
  that were previously clean — plan to reformat and review the diff.
- **husky / commitlint:** read changelogs for major bumps. husky majors have
  historically changed the hook directory layout (`core.hooksPath`); a
  commitlint major can change config schema or default rules. The repo
  pins types `feat|fix|docs|style|refactor|test|chore|build|perf|revert|ci`
  and scopes `engine|story|assets|ci|deps` — confirm a bump doesn't break them.

### Phase 4: Confirm With User

Present a plan and get explicit approval for **majors** (patch/minor for the
hook tooling can be auto-applied unless the user objects):

```
=== Tooling Update Plan ===
GUT:        <cur> -> <tag>   [major? notes]   APPROVE / DEFER / SKIP
gdtoolkit:  <cur> -> <new>   (reformats game/ outside addons/)   APPROVE / DEFER / SKIP
husky:      <cur> -> <new>
@commitlint/cli: <cur> -> <new>
@commitlint/config-conventional: <cur> -> <new>
```

### Phase 5: Apply

Work on a `chore/tooling-updates` branch (never commit to `main`).

```bash
git checkout -b chore/tooling-updates
```

**GUT** — replace the vendored addon with the new release. Download the
release tarball into a new, empty scratch directory, extract it, and mirror
its `addons/gut/` over `game/addons/gut/` (so files upstream deleted go too):
```bash
curl -sSL -o <scratch>/gut.tar.gz https://github.com/bitwes/Gut/archive/refs/tags/v<tag>.tar.gz
tar -xzf <scratch>/gut.tar.gz -C <scratch>
rsync -a --delete <scratch>/Gut-<tag>/addons/gut/ game/addons/gut/
git status --short game/addons/gut   # review every add/delete, not just M
```

**Then check the release's version data covers OUR engine.** Every GUT run
ends by asking `addons/gut/versions.json` which release suits the running
Godot and prints `GUT <x> is now available!` when that differs from the
installed GUT. A release tag can ship data that caps below the engine in
`project.godot` `config/features` and CI (9.7.0 and 9.7.1 cap at 4.7.999), and
on 4.8 every run then advertised a nonexistent `GUT 0.0.0`. GUT checks at
the end of every run that ran tests (`summary.gd` `log_end_run` ->
`log_version_update`) and no config or CLI option turns it off, so the only
repo-local cure is the data file. If the tag's data caps
below our engine, overlay **only** `addons/gut/versions.json` from bitwes/Gut
**main at a named commit SHA** — upstream's own published copy, the same file
GUT's update detector fetches — and record the SHA and its sha256 in the
commit body:
```bash
gh api 'repos/bitwes/Gut/contents/addons/gut/versions.json?ref=<sha>' \
  -H 'Accept: application/vnd.github.raw' > game/addons/gut/versions.json
shasum -a 256 game/addons/gut/versions.json
```
This is the ONE permitted difference from the release tag
(verification-checklists.md §10, #452). Every other vendored file stays
pristine. `game/tests/test_gut_version_data.gd` fails if the data does not
recommend the installed GUT for the running engine, so skipping this step
cannot pass silently; its message names which case it hit: `0.0.0` (no entry
covers the engine, or the file is missing or unreadable, which GUT reports the
same way: overlay main), an older release or a branch name (the
data lacks the installed GUT: overlay a newer main SHA, do not bump), or a
newer release (a newer GUT really exists: bump). Once a release tag's own data
covers our engine, vendor that tag pristine and drop the overlay (#460).

Then let Godot re-import, and check no sidecar came out poisoned (the count
proves the grep looked at something):
```bash
GODOT="$(command -v godot || echo /Applications/Godot.app/Contents/MacOS/Godot)"
"$GODOT" --headless --path game/ --import
find game/assets game/addons -name '*.import' | wc -l                       # > 0
grep -rl 'valid=false' game/assets game/addons --include='*.import' | wc -l  # 0
```

**gdtoolkit**: bump the pin, then install exactly what it names. CI installs
the pin, not the newest release, so a bump that skips the pin file leaves CI
on the old version.
```bash
echo "<new>" > scripts/quality-gates/gdtoolkit-version.txt
pip install "gdtoolkit==$(tr -d '[:space:]' < scripts/quality-gates/gdtoolkit-version.txt)"   # or pipx
gdlint --version                     # must print gdlint <new>
gdformat --version                   # must print gdformat <new>
```
If the formatter changed, reformat and review the diff before committing. Use
the file list CI checks (every tracked `.gd` under `game/`, `game/tests/`
included, outside `addons/`), not just `game/scripts/`:
```bash
git ls-files -- 'game/*.gd' | grep -Ev '(^|/)addons/' | tr '\n' '\0' | xargs -0 gdformat
git diff --stat game/   # review what the new formatter touched
```

**husky / commitlint** (pnpm only — no npm/yarn/npx):
```bash
pnpm update husky @commitlint/cli @commitlint/config-conventional
pnpm install                       # reinstalls husky hooks
git config core.hooksPath          # MUST print .husky/_
```

### Phase 6: Verify Via The Real Gates

These are the gates the hooks actually run. **Never `--no-verify`.**

```bash
GODOT="$(command -v godot || echo /Applications/Godot.app/Contents/MacOS/Godot)"

# Lint + format (pre-commit Gates A and C), over the list static-gates.yml checks
git ls-files -- 'game/*.gd' | grep -Ev '(^|/)addons/' | tr '\n' '\0' | xargs -0 gdlint
git ls-files -- 'game/*.gd' | grep -Ev '(^|/)addons/' | tr '\n' '\0' | xargs -0 gdformat --check

# Import (must pass before tests)
"$GODOT" --headless --path game/ --import

# Full GUT suite (pre-push gate), judged by the same floor gate the hook uses
"$GODOT" --headless --path game/ -s addons/gut/gut_cmdln.gd > <log> 2>&1
python3 scripts/quality-gates/check_gut_baseline.py --log <log>
grep -cE 'is now available|may not be compatible|does not have a release' <log>   # 0 only proves no GUT version notice; a user://gut_temp_directory/versions.json cache can hide a bad vendored file. test_gut_version_data.gd (in the suite above) is the machine-independent check (see Phase 5)

# Vendored copy vs the release tag: the ONLY permitted difference is
# versions.json. .import/.uid sidecars are gitignored and Godot regenerates them.
/usr/bin/diff -rq -x '*.import' -x '*.uid' <scratch>/Gut-<tag>/addons/gut game/addons/gut
```
Use `/usr/bin/diff`: the RTK hook rewrites a bare `diff` into
`git diff --no-index`, which rejects `-r`.

**GUT gotcha:** GUT 9.7.x (9.7.0 and 9.7.1; 9.7.1 re-verified on Godot
4.8-beta1 in #452) **silently skips** test files that have parse errors on
Godot 4.7 and 4.8 — a green run can hide them. After a GUT bump especially,
check the **Scripts/Tests counts** in the summary against the floors in
`scripts/quality-gates/gut-baseline.txt` (Gate L enforces them); a dropped
count means a file failed to parse, not that it passed.

If a step fails, fix it (or revert that one tool and offer the user the
choice to defer it). Do not push with a failing or wedged gate. If
`--import` wedges in macOS U-state (0% CPU), a reboot clears it — and a
wedged hook means the GUT suite did NOT run, so treat the suite as unproven.

### Phase 7: Issues + Chore PR

File a tracking Issue (GitHub Issues via `gh`, **not** beads/bd) for the
work, and for anything deferred:
```bash
gh issue create --label chore --milestone "<milestone>" \
  --title "chore: update <tool> <cur> -> <new>" \
  --body "Tooling bump. Breaking changes: <summary>. Refs upstream notes: <url>"
```
Close it from the PR with `Closes #N`.

Commit per tool (or one combined commit), Conventional Commits format,
scope `deps` or `ci`:
```bash
git add -A
git commit -m "chore(deps): update GUT to <tag>, gdtoolkit to <ver>, commit hooks

GUT: <cur> -> <tag>
versions.json: tag copy | bitwes/Gut main @ <sha> (sha256 <hash>)
gdtoolkit: <cur> -> <new>
husky/commitlint: <details>

Closes #<n>

<attribution line from the session's system reminder>"
```

Push and open ONE chore PR targeting `main` using the repo template
(`.github/pull_request_template.md` auto-populates — fill every section):
```bash
git push -u origin chore/tooling-updates
gh pr create --title "chore(deps): update Godot tooling" --body-file <tmpfile>
```

---

## Rules

- **Three things have versions here: GUT, gdtoolkit, and the husky/commitlint
  hook tooling.** Nothing else. No monorepo, no `packages/*`, no runtime deps.
- **pnpm only** for the npm tooling — never npm/yarn/npx — and it touches
  *only* husky + the two commitlint packages. CI runs commitlint with them
  (`static-gates.yml`: `pnpm/action-setup@v6`, Node 24), so a pnpm or
  commitlint bump re-checks that action version and Node against the new
  releases' requirements.
- **Verify with the real gates** (`gdlint`, `gdformat --check`, Godot
  `--import`, GUT suite) — not `pnpm test`/`pnpm lint`, which don't exist here.
- **Research before bumping.** GUT can rename asserts/flags; gdformat can
  rewrite formatting; husky/commitlint majors can change hook layout or config.
- **Confirm majors** with the user before applying.
- **One chore PR** for all approved updates on `chore/tooling-updates`.
- **Never `--no-verify`.** Fix the root cause.
- If nothing is outdated, say so and stop.
