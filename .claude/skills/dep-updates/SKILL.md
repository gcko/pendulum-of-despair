---
name: dep-updates
description: >
  Analyze and update project dependencies. Checks pnpm outdated across all
  workspace packages, categorizes updates by severity (patch/minor/major),
  researches breaking changes for major bumps, confirms with user before
  applying, and creates a PR with all updates on chore/dependency-updates.
  Trigger when user asks to update deps, check for outdated packages, or
  do dependency maintenance.
---

# Dependency Updates Skill

Systematically analyze, categorize, and apply dependency updates for pnpm
workspace monorepos. Produces a single PR with all approved changes.

---

## Workflow

### Phase 1: Environment Check

1. **Verify pnpm is latest** via corepack:
   ```bash
   corepack up
   ```
   Report if pnpm was updated and what version it moved to.

2. **Check Node.js version** meets project requirements (>= 24.0.0).

### Phase 2: Audit Current State

1. Run `pnpm outdated --recursive` to get all outdated packages across the
   monorepo.

2. Also run `pnpm outdated` at the workspace root for root-level devDependencies.

3. Parse and categorize every outdated package into three buckets:

   | Category | Semver Change | Risk Level |
   |----------|--------------|------------|
   | **Patch** | `x.y.Z` bump | Low -- bugfixes only |
   | **Minor** | `x.Y.0` bump | Medium -- new features, usually backwards-compatible |
   | **Major** | `X.0.0` bump | High -- breaking changes likely |

4. Present a **summary table** to the user showing:
   - Package name
   - Current version -> Latest version
   - Category (patch/minor/major)
   - Which workspace package(s) use it

### Phase 3: Major Update Deep Analysis

For each **major** version bump:

1. **Search the web** for the package's changelog, migration guide, or release
   notes (e.g., search `"<package> v<major> migration guide"` or
   `"<package> changelog"`).

2. Summarize:
   - What breaking changes were introduced
   - Whether a migration/codemod is available
   - Impact on this project specifically (check how the package is used in the
     codebase with Grep/Read)
   - Recommendation: update now, defer, or skip

3. Present findings to the user and **ask for approval** before including each
   major update. The user may choose to:
   - Include the major update in this PR
   - Defer it (create a separate issue/PR later)
   - Skip it entirely

### Phase 4: User Confirmation

Before applying any changes, present the final update plan:

```
=== Dependency Update Plan ===

PATCH updates (auto-approved):
  - express: 5.0.1 -> 5.0.3
  - ...

MINOR updates (auto-approved):
  - vitest: 3.1.0 -> 3.2.0
  - ...

MAJOR updates (user-approved):
  - phaser: 3.x -> 4.x  [APPROVED / DEFERRED / SKIPPED]
  - ...

Proceed? [y/n]
```

Ask the user to confirm the plan. Patch and minor updates are auto-approved
unless the user objects. Major updates require explicit approval from Phase 3.

### Phase 5: Apply Updates

1. **Create branch** `chore/dependency-updates` from the current branch:
   ```bash
   git checkout -b chore/dependency-updates
   ```

2. **Apply patch updates**:
   ```bash
   pnpm update --recursive  # Updates within semver range
   ```

3. **Apply minor updates** (if any need explicit bumps beyond the range):
   ```bash
   pnpm update <pkg>@^<minor-version> --recursive
   ```

4. **Apply approved major updates** one at a time:
   ```bash
   pnpm update <pkg>@<major-version> --recursive
   ```
   After each major update, run `pnpm lint && pnpm test` to catch breakage
   early. If tests fail, investigate and fix before proceeding.

5. **Update pnpm lockfile**:
   ```bash
   pnpm install
   ```

### Phase 6: Validate

1. **Build**: `pnpm build`
2. **Lint**: `pnpm lint`
3. **Test**: `pnpm test`

If any step fails, fix the issue before proceeding. For major updates that
cause failures, offer the user the choice to revert that specific update.

### Phase 7: Commit & PR

1. **Stage and commit** all changes:
   ```bash
   git add pnpm-lock.yaml package.json packages/*/package.json
   git commit -m "chore(deps): update dependencies

   Patch: <count> packages
   Minor: <count> packages
   Major: <count> packages (list them)

   Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
   ```

2. **Push** the branch:
   ```bash
   git push -u origin chore/dependency-updates
   ```

3. **Create PR** targeting `main` using the repo's PR template:
   ```bash
   gh pr create --title "chore(deps): update project dependencies" \
     --body-file <tmpfile>
   ```

   The PR body must follow the repo's `.github/pull_request_template.md` and
   include:
   - Summary of all updates by category
   - Details on major updates with migration notes
   - Test results confirmation

### Phase 8: Deferred Work

For any major updates that were **deferred**, create beads issues:
```bash
bd create --title="Upgrade <pkg> to v<X>" \
  --description="Major version upgrade deferred from dependency update session. Breaking changes: <summary>. Migration guide: <url>" \
  --type=chore --priority=3
```

---

## Rules

- **Never force-update** without user confirmation on majors.
- **Always run tests** after applying updates, especially major ones.
- **Use pnpm exclusively** -- no npm/yarn/npx.
- **One PR** for all approved updates -- don't split patch/minor/major into
  separate PRs unless the user requests it.
- **Web search** is mandatory for major updates -- don't guess at breaking
  changes.
- If `pnpm outdated` shows nothing, report that all dependencies are current
  and skip the rest of the workflow.
