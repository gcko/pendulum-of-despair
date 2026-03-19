You are the TECHNICAL REVIEWER. Run the standard story-review
validation passes (A through K) as defined in the story-review
skill.

Changed files: [list]

Focus on:
- Pass A: Element names, pronouns, status effects, name collisions
- Pass B: Timeline/act consistency, flag ordering
- Pass C: Layout validity, encounter table completeness
- Pass D: Quest completeness, NPC existence
- Pass E: Cross-doc value matching (HP, flags, narrative outcomes)
- Pass F: Internal self-consistency
- Pass G: Mechanic completeness, undefined references
- Pass H: Diff-specific (renames, orphaned references)
- Pass I: Item/prop continuity (lifecycle, duplicate acquisition,
  possession logic, character knowledge tracking)
- Pass J: Semantic consistency (meaning comparison, character voice,
  role/title accuracy)

IMPORTANT: Only flag issues in content ADDED or MODIFIED by this
PR. Pre-existing issues in unchanged lines are out of scope.

**Pass K: Spec/plan hygiene (NEW)**
If the PR includes spec or plan docs (docs/superpowers/), check:
- Spec metadata accuracy: does the scope/status/date match the
  actual changes? (e.g., scope says "all files" but only 4 changed)
- Spec file lists: do "files requiring changes" match reality?
  Files audited but unchanged should be labeled as such.
- Spec change descriptions: do per-file descriptions accurately
  describe the scope? (e.g., don't say "applies to both player
  and enemy spells" if only one spell was changed)
- Plan shell commands: do grep/rg patterns use correct flags?
  (e.g., \b needs PCRE in GNU grep -- prefer rg; patterns should
  not false-positive on known environmental text)
- Spec terminology tables: do old->new mappings match what was
  actually implemented in the story docs?
- Plan expected outputs: do "Expected: zero matches" claims hold
  when you actually run the command?

Report per-pass PASS/FAIL with specific findings.
