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
   **9.7.0**). Source: `bitwes/Gut` on GitHub.
2. **gdtoolkit** — the Python package providing `gdlint` and `gdformat`
   (the lint/format gates). Installed via `pip`/`pipx`, not the repo.
3. **husky + @commitlint/cli + @commitlint/config-conventional** — the only
   npm `devDependencies` in `package.json`. Used **purely for git hooks**.
   `pnpm` exists solely for these.

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
grep '^version=' game/addons/gut/plugin.cfg          # -> 9.7.0

# gdtoolkit (provides gdlint + gdformat)
gdformat --version
gdlint --version
pipx list 2>/dev/null | grep -i gdtoolkit || pip show gdtoolkit

# npm hook tooling
cat package.json                                     # devDependencies block
pnpm --version
```

### Phase 2: Check Upstream for Newer

- **GUT:** check the latest release tag.
  ```bash
  gh release view --repo bitwes/Gut --json tagName,name,publishedAt
  # or: gh api repos/bitwes/Gut/releases/latest --jq '.tag_name'
  ```
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
  (`gh release view <tag> --repo bitwes/Gut`). Watch for renamed asserts,
  changed `gut_cmdln.gd` flags, or `.gutconfig`/runner changes. Note that
  these 55 `test_*.gd` files use the project's existing assert conventions
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
GUT:        9.7.0 -> <tag>   [major? notes]   APPROVE / DEFER / SKIP
gdtoolkit:  <cur> -> <new>   (reformats game/scripts/)   APPROVE / DEFER / SKIP
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
release's `addons/gut/` and overwrite `game/addons/gut/`, preserving the path.
Then let Godot re-import:
```bash
GODOT="$(command -v godot || echo /Applications/Godot.app/Contents/MacOS/Godot)"
"$GODOT" --headless --path game/ --import
```

**gdtoolkit**:
```bash
pipx upgrade gdtoolkit   # or: pip install -U gdtoolkit
```
If the formatter changed, reformat and review the diff before committing:
```bash
gdformat game/scripts/
git diff --stat game/scripts/   # review what the new formatter touched
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

# Lint + format (pre-commit gates)
gdlint game/scripts/
gdformat --check game/scripts/

# Import (must pass before tests)
"$GODOT" --headless --path game/ --import

# Full GUT suite (pre-push gate)
"$GODOT" --headless --path game/ -s addons/gut/gut_cmdln.gd
```

**GUT gotcha:** Godot 4.7 / GUT 9.7.0 **silently skip** test files that have
parse errors — a green run can hide them. After a GUT bump especially, check
the **Scripts/Tests counts** in the summary against the 55 `test_*.gd` files;
a dropped count means a file failed to parse, not that it passed.

If a step fails, fix it (or revert that one tool and offer the user the
choice to defer it). Do not push with a failing or wedged gate. If
`--import` wedges in macOS U-state (0% CPU), a reboot clears it — and a
wedged hook means the GUT suite did NOT run, so treat the suite as unproven.

### Phase 7: Issues + Chore PR

File a tracking Issue (GitHub Issues via `gh`, **not** beads/bd) for the
work, and for anything deferred:
```bash
gh issue create --label chore \
  --title "chore: update <tool> <cur> -> <new>" \
  --body "Tooling bump. Breaking changes: <summary>. Refs upstream notes: <url>"
```
Close it from the PR with `Closes #N`.

Commit per tool (or one combined commit), Conventional Commits format,
scope `deps` or `ci`:
```bash
git add -A
git commit -m "chore(deps): update GUT to <tag>, gdtoolkit to <ver>, commit hooks

GUT: 9.7.0 -> <tag>
gdtoolkit: <cur> -> <new>
husky/commitlint: <details>

Closes #<n>

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
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
  *only* husky + the two commitlint packages.
- **Verify with the real gates** (`gdlint`, `gdformat --check`, Godot
  `--import`, GUT suite) — not `pnpm test`/`pnpm lint`, which don't exist here.
- **Research before bumping.** GUT can rename asserts/flags; gdformat can
  rewrite formatting; husky/commitlint majors can change hook layout or config.
- **Confirm majors** with the user before applying.
- **One chore PR** for all approved updates on `chore/tooling-updates`.
- **Never `--no-verify`.** Fix the root cause.
- If nothing is outdated, say so and stop.
