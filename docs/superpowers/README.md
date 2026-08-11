# docs/superpowers/ — Dated Execution Records

This directory holds the dated specs (`specs/`) and implementation plans
(`plans/`) that the `story-designer` and `game-designer` workflows produce
before work starts. Every file is named `YYYY-MM-DD-<slug>.md`.

**These are point-in-time execution records. They are not maintained.**

## The policy

A dated artefact under `docs/superpowers/` is a record of what was known,
planned and true **on the date in its filename**. Once the work it describes
has merged, the artefact is frozen:

- **Everything concrete in it is accurate as of its date only.** File paths,
  line numbers, function signatures, file manifests, estimated line counts,
  test counts, spell costs, HP values, act labels — all of it was true when
  written and none of it is updated when the code or the canon moves.
- **It is not corrected when canon changes.** A dated record that disagrees
  with `docs/story/` is not a bug. It is the earlier draft that produced the
  canon, preserved so the reasoning behind a decision stays legible.
- **It is not a citation source.** Do not quote a number out of here as
  current, and do not link to it as evidence for a live claim.

## Where the live answers are

| You want | Read |
|----------|------|
| Canonical game design (stats, spells, economy, acts, bestiary) | `docs/story/` |
| Architecture decisions and implementation plans still in force | `docs/plans/` |
| What a script or scene actually does today | the file itself, under `game/` |
| Outstanding work | GitHub Issues (`gh issue list`) |

The split is the one AGENTS.md § Repository Layout already states:
`docs/story/` holds the canonical design documents, `docs/superpowers/` holds
the specs and plans that produced them.

## How you know, from inside the file

Every dated artefact carries a standing banner immediately under its title:

```markdown
> **Dated record (2026-03-26) — not maintained.** Paths, line numbers, counts
> and canon values below were accurate on that date only; the code and the
> canon have moved since. Canon lives in `docs/story/`, architecture in
> `docs/plans/`, and the shipped code is the authority on itself. Policy:
> [docs/superpowers/README.md](../README.md).
```

The banner is on the file rather than only in this README because agents open
specs directly — from a grep hit, from a link in an issue, from a plan's
"Files" list — and never see the directory they came from.

**New artefacts must carry it.** When `story-designer` or `game-designer`
writes a new spec or plan, add the banner as the second block of the file with
the date from the filename.

## Consequences

- **The citation checker skips this directory.**
  `scripts/quality-gates/check_doc_citations.py` excludes
  `docs/superpowers/` by design. Stale paths and stale line numbers in here
  are expected output of the policy, not findings. Do not "fix" the checker to
  cover this directory; that would re-open a question this policy closed.
- **Review agents should not raise drift here.** A dated artefact disagreeing
  with current canon is not a review finding. If the *canon* is wrong, fix
  `docs/story/`.
- **A plan is live only while its PR is open.** During execution, tick its
  checkboxes and correct it freely. After the PR merges it is history.

## The one exception: active traps

Immutability protects claims about the past. It does not protect content that
*breaks something* when an agent uses it as intended. Two shapes qualify:

1. **Copy-pasteable code that no longer resolves** — e.g. a `preload()` of a
   path that has since moved. Pasted as-is it is a hard parse error, not a
   stale footnote.
2. **A layout claim that sends a reader to a path that does not exist.**

For these, add a one-line inline note next to the offending text naming the
current location and the issue or PR that moved it. **Annotate; do not
rewrite.** The historical text stays as written — including past-tense command
records (`git add …`, `gdformat …`), which are honest history and must never
be touched — and the note carries the correction.

Existing annotations of this kind cite the `inventory_helpers.gd` relocation
in #236 (`game/scripts/autoload/` → `game/scripts/util/`).

## History

This policy generalises a carve-out that already existed. `docs/story/progression.md`
§ XP Pacing Targets previously named three dated records left as written after
the act-boundary correction (#287); that list went stale the moment a fourth
record disagreed with canon (#352). The rule now covers the whole directory, so
nothing has to be enumerated.

Closes the question raised in #317, #335, #344 and #352.
