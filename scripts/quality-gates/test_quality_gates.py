#!/usr/bin/env python3
"""Quality Gate I: tests for the quality gate scripts themselves.

Gates D-G are scans, and a broken scan reports "nothing found", which reads
exactly like "nothing wrong". This gate runs first in pre-push so that a gate
which has stopped detecting fails loudly instead of passing silently (#365).

Run: python3 -m unittest discover -s scripts/quality-gates -p 'test_*.py'
Or:  python3 scripts/quality-gates/test_quality_gates.py
"""
import contextlib
import io
import json
import os
import shutil
import tempfile
import unittest
from unittest.mock import patch

# Import the modules under test
import sys
sys.path.insert(0, os.path.dirname(__file__))
import check_id_uniqueness
import check_stale_counts
import check_scene_refs
import check_doc_citations


class TestCheckIdUniqueness(unittest.TestCase):
    """Tests for Gate D: Cross-file ID uniqueness."""

    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()

    def _write_json(self, path: str, data: dict) -> str:
        full = os.path.join(self.tmpdir, path)
        os.makedirs(os.path.dirname(full), exist_ok=True)
        with open(full, "w") as f:
            json.dump(data, f)
        return full

    def test_no_duplicates(self):
        f = self._write_json("items.json", {
            "items": [{"id": "potion"}, {"id": "ether"}]
        })
        errors = check_id_uniqueness.check_ids(f, ["items"], "item")
        self.assertEqual(errors, [])

    def test_detects_duplicate_within_file(self):
        f = self._write_json("items.json", {
            "items": [{"id": "potion"}, {"id": "potion"}]
        })
        errors = check_id_uniqueness.check_ids(f, ["items"], "item")
        self.assertEqual(len(errors), 1)
        self.assertIn("DUPLICATE", errors[0])
        self.assertIn("potion", errors[0])

    def test_handles_missing_key(self):
        f = self._write_json("items.json", {"other": []})
        errors = check_id_uniqueness.check_ids(f, ["items"], "item")
        self.assertEqual(errors, [])

    def test_handles_invalid_json(self):
        full = os.path.join(self.tmpdir, "bad.json")
        os.makedirs(os.path.dirname(full), exist_ok=True)
        with open(full, "w") as f:
            f.write("{invalid json")
        errors = check_id_uniqueness.check_ids(full, ["items"], "item")
        self.assertEqual(errors, [])

    def test_handles_missing_file(self):
        errors = check_id_uniqueness.check_ids(
            "/nonexistent/path/*.json", ["items"], "item"
        )
        self.assertEqual(errors, [])

    def test_detects_cross_file_duplicates(self):
        """Verify shared existing_ids catches duplicates across files."""
        f1 = self._write_json("a.json", {
            "items": [{"id": "potion"}, {"id": "ether"}]
        })
        f2 = self._write_json("b.json", {
            "items": [{"id": "potion"}]  # duplicate of f1
        })
        shared_ids: dict[str, str] = {}
        errors = check_id_uniqueness.check_ids(f1, ["items"], "item", shared_ids)
        self.assertEqual(errors, [])
        errors = check_id_uniqueness.check_ids(f2, ["items"], "item", shared_ids)
        self.assertEqual(len(errors), 1)
        self.assertIn("DUPLICATE", errors[0])
        self.assertIn("potion", errors[0])

    def test_dialogue_ids_no_duplicates(self):
        """Verify check_dialogue_ids works with actual project data."""
        # This test runs against real data if available
        if not os.path.exists("game/data/dialogue"):
            self.skipTest("No dialogue data available")
        errors = check_id_uniqueness.check_dialogue_ids()
        self.assertEqual(errors, [], f"Found duplicates: {errors}")


class TestCheckStaleCounts(unittest.TestCase):
    """Tests for Gate E: Stale-count scan."""

    def test_count_actual_data_returns_dict(self):
        """Verify count function returns expected keys."""
        counts = check_stale_counts.count_actual_data()
        self.assertIsInstance(counts, dict)
        # These keys should always exist (directories exist)
        self.assertIn("encounter_files", counts)
        self.assertIn("shop_files", counts)

    def test_count_matches_filesystem(self):
        """Verify encounter file count matches glob."""
        import glob
        counts = check_stale_counts.count_actual_data()
        actual = len(glob.glob("game/data/encounters/*.json"))
        self.assertEqual(counts.get("encounter_files", 0), actual)

    def test_check_gap_tracker_no_stale(self):
        """Run against real gap tracker — should pass if data is current."""
        if not os.path.exists("docs/analysis/game-dev-gaps.md"):
            self.skipTest("No gap tracker available")
        counts = check_stale_counts.count_actual_data()
        errors = check_stale_counts.check_gap_tracker(counts)
        self.assertEqual(errors, [], f"Stale counts: {errors}")

    def test_detects_stale_count(self):
        """Verify detection of mismatched counts."""
        counts = {"encounter_files": 99}  # wrong count
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".md", delete=False
        ) as f:
            f.write("There are 27 encounter files in the project.\n")
            f.flush()
            errors = check_stale_counts.check_gap_tracker(counts, f.name)
        os.unlink(f.name)
        self.assertEqual(len(errors), 1)
        self.assertIn("STALE COUNT", errors[0])
        self.assertIn("27", errors[0])
        self.assertIn("99", errors[0])


class TestCheckSceneRefs(unittest.TestCase):
    """Tests for Gate F: Scene reference validation."""

    def test_valid_scene_passes(self):
        """Run against real scene files — should pass."""
        if not os.path.exists("game/scenes"):
            self.skipTest("No scene files available")
        errors = check_scene_refs.check_scene_references()
        self.assertEqual(errors, [], f"Missing refs: {errors}")

    def test_detects_missing_reference(self):
        """Verify detection of broken resource path."""
        tmpdir = tempfile.mkdtemp()
        scenes_dir = os.path.join(tmpdir, "game", "scenes", "test")
        os.makedirs(scenes_dir)

        tscn = os.path.join(scenes_dir, "test.tscn")
        with open(tscn, "w") as f:
            f.write('[ext_resource path="res://nonexistent.gd" id="1"]\n')

        # Patch glob to find our test scene
        with patch("check_scene_refs.glob.glob", return_value=[tscn]):
            errors = check_scene_refs.check_scene_references()
            self.assertEqual(len(errors), 1)
            self.assertIn("missing resource", errors[0])


MAGIC_FIXTURE = """# Magic System

## Status Effect Reference

| Status | Effect |
|--------|--------|
| Poison | Lose 8% max HP per turn |
| Burn | Lose 5% max HP per turn |

## Spell Count Summary

Eighty-nine spells, and nothing else worth saying.

## Physical Elemental Attacks

The pipeline that lets a physical hit carry an element.

## Physical Attack Resolution

Calculate base damage, then apply the row modifier.
"""

# Mirrors the shape of docs/plans/technical-architecture.md, where a
# letter-suffixed section sits directly under the section it extends. That
# adjacency is what a digits-only matcher gets wrong.
#
# It also carries the two shapes the id matcher has to keep apart: a nested
# "### 1.3" ahead of a top-level "## 3." in the file (a bag-of-words matcher
# returns the nested one for "§ 3", #391), and a section whose body names
# something a citation may point at without naming the heading ("§ 2.1 Enemy
# Data Field Budget", modeled on the live "audio.md § 3.1 SFX budget", #389).
NUMBERED_FIXTURE = """# Technical Architecture

## 1. Project Setup

### 1.1 Directory Structure

Where each kind of file lives.

### 1.2 Naming Conventions

snake_case files, PascalCase classes.

### 1.2a Script Size Budget

Aim 400 lines, hard maximum 600.

### 1.3 Autoload Singletons

Six singletons, registered here and nowhere else.

## 2. Data Formats

### 2.1 Enemy Data

Every enemy record. The Field Budget row caps one at twelve keys.

### 2.3 Equipment Data

## 3. Game State Machine

Exploration, battle and menu, and the transitions between them.
"""

# The numbered-list heading shape, as dungeons-world.md writes it: the
# number is part of the title, not a dotted id. It is the case where a
# citation can run on into a *second* number, and where the check for a
# capitalised word cannot see the invention — "21." has no case.
DUNGEON_FIXTURE = """# Dungeons

## 19. Ley Nexus Hollow

A leech feeds on the ley line here.

## 20. Highcairn Monastery

Pallor waits on the top floor.
"""

# combat-formulas.md reduced to the two headings that made #404's exemplar
# resolve to the wrong one. There is no "Act scaling" heading — that is the
# point — and "Regular Enemy HP by Act" ends on the word the citation opens
# with, so a one-word shortening reaches it from the wrong end. The real fix
# was to repoint the citation at Danger Counter, whose body carries the term.
ACT_SCALING_FIXTURE = """# Combat Formulas

## Danger Counter

The counter drives the encounter rate. Act scaling multiplies the increment:
Act I x1.0, Act II x1.1, Act III x1.1.

## Regular Enemy HP by Act

The HP table a one-word citation used to land on.
"""

# The house style in one file: a heading named by its last word
# (``§ Caden``), a heading named by a plural of its first (``§ Inns``), a
# heading named by its breadcrumb path (``§ Interlude The World Changes``),
# and — the shape #367 is about — a real section with a real subsection
# under it, so a citation can be tested for running on past both.
HOUSE_STYLE_FIXTURE = """# NPC Directory

## Duskfen

### Spirit-speaker Caden

Caden reads the ley currents for anyone who asks twice.

## Inn Costs

Twenty gil a night, everywhere but Canopy Reach.

## The Interlude: The Unraveling

### The World Changes

The map redraws itself while the party sleeps.

## Encounter System

### Danger Counter

The counter increments once per step and resets on a battle.
"""


class TestCheckDocCitations(unittest.TestCase):
    """Tests for Gate G: doc citation integrity."""

    def setUp(self):
        self.cwd = os.getcwd()
        self.tmpdir = tempfile.mkdtemp()
        self._write("docs/story/magic.md", MAGIC_FIXTURE)
        os.chdir(self.tmpdir)

    def tearDown(self):
        os.chdir(self.cwd)
        shutil.rmtree(self.tmpdir, ignore_errors=True)

    def _write(self, rel: str, text: str) -> None:
        full = os.path.join(self.tmpdir, rel)
        os.makedirs(os.path.dirname(full), exist_ok=True)
        with open(full, "w") as f:
            f.write(text)

    def _errors(self, known: dict | None = None) -> list[str]:
        """Run the whole scan against the fixture repo."""
        with patch.dict(
            check_doc_citations.KNOWN_UNRESOLVED, known or {}, clear=True
        ):
            return check_doc_citations.check_citations()

    def test_bans_line_anchored_citation(self):
        self._write("game/scripts/a.gd", "# Poison 8%/turn (magic.md:1537).\n")
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("banned line-anchored citation", errors[0])
        self.assertIn("magic.md:1537", errors[0])

    def test_bans_line_anchored_gd_citation(self):
        self._write("docs/story/note.md", "See `status_effects.gd:25`.\n")
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("status_effects.gd:25", errors[0])

    def test_accepts_heading_citation_with_term(self):
        self._write(
            "game/scripts/a.gd",
            "# Poison (magic.md § Status Effect Reference > 'Poison').\n",
        )
        self.assertEqual(self._errors(), [])

    def test_rejects_unknown_heading(self):
        self._write(
            "game/scripts/a.gd", "# See magic.md § Nonexistent Heading.\n"
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    # ── Letter-suffixed section ids ────────────────────────────────────
    #
    # A digits-only section matcher truncated "1.2a" to "1.2", resolved it
    # against "### 1.2 Naming Conventions", and returned before the
    # word-prefix search could find the real heading. Live files cite
    # "technical-architecture.md § 1.2a", so deleting or renaming that
    # section left the gate reporting "passed" — a false green in the one
    # gate whose job is to notice.

    def test_letter_suffixed_section_resolves_to_its_own_heading(self):
        self._write("docs/plans/arch.md", NUMBERED_FIXTURE)
        hit = check_doc_citations.match_heading(
            check_doc_citations.DocIndex(),
            "docs/plans/arch.md",
            "1.2a Script Size Budget",
        )
        self.assertIsNotNone(hit, "§ 1.2a must resolve")
        self.assertEqual(hit[2], "1.2a Script Size Budget")

    def test_letter_suffixed_citation_survives_a_full_scan(self):
        self._write("docs/plans/arch.md", NUMBERED_FIXTURE)
        self._write("game/scripts/a.gd", "# Budget: arch.md § 1.2a.\n")
        self.assertEqual(self._errors(), [])

    def test_nonexistent_letter_suffix_does_not_borrow_its_parent(self):
        """§ 1.2b must fail even though § 1.2 exists."""
        self._write("docs/plans/arch.md", NUMBERED_FIXTURE)
        self._write("game/scripts/a.gd", "# Budget: arch.md § 1.2b.\n")
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    def test_a_long_invented_suffix_does_not_borrow_its_parent(self):
        """§ 1.2zzz must fail too — the truncation was the whole bug."""
        self._write("docs/plans/arch.md", NUMBERED_FIXTURE)
        self._write("game/scripts/a.gd", "# Budget: arch.md § 1.2zzz.\n")
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    def test_renaming_a_cited_letter_section_fails_the_gate(self):
        """End to end: the rot this gate exists to catch, on a suffixed id."""
        self._write(
            "docs/plans/arch.md",
            NUMBERED_FIXTURE.replace("### 1.2a ", "### 1.2q "),
        )
        self._write("game/scripts/a.gd", "# Budget: arch.md § 1.2a.\n")
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    def test_plain_numbered_sections_still_resolve(self):
        """The suffix support must not cost the ordinary numeric citation."""
        self._write("docs/plans/arch.md", NUMBERED_FIXTURE)
        self._write(
            "game/scripts/a.gd",
            "# See arch.md § 1.2 Naming Conventions and arch.md § 2.1/2.3.\n",
        )
        self.assertEqual(self._errors(), [])

    def test_rejects_term_absent_from_the_cited_section(self):
        """The term must sit under the cited heading, not merely in the file."""
        self._write(
            "game/scripts/a.gd",
            "# See magic.md § Spell Count Summary > 'Poison'.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("does not appear under", errors[0])

    def test_rejects_term_that_lives_in_a_later_section(self):
        """The search stops at the next heading, so a term below it fails."""
        self._write(
            "game/scripts/a.gd",
            "# See magic.md § Status Effect Reference > 'Eighty-nine'.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("does not appear under", errors[0])

    def test_a_citation_does_not_steal_the_next_ones_term(self):
        """`a.md § X; a.md § Y > 'z'` must not read 'z' as X's term."""
        self._write(
            "game/scripts/a.gd",
            "# magic.md § Spell Count Summary; "
            "magic.md § Status Effect Reference > 'Poison'.\n",
        )
        self.assertEqual(self._errors(), [])

    def test_rejects_unknown_target_file(self):
        self._write("game/scripts/a.gd", "# See nosuchdoc.md § Whatever.\n")
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("not a file in this repo", errors[0])

    def test_checks_every_citation_on_a_line(self):
        """A second citation on the same line is checked, not swallowed."""
        self._write(
            "game/scripts/a.gd",
            "# magic.md § Status Effect Reference > 'Poison'; "
            "magic.md § Spell Count Summary > 'Eighty-nine'.\n",
        )
        self.assertEqual(self._errors(), [])
        self._write(
            "game/scripts/a.gd",
            "# magic.md § Status Effect Reference > 'Poison'; "
            "magic.md § Spell Count Summary > 'Ninety-one'.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("Ninety-one", errors[0])

    # ── Decorated filenames: the markdown link and the code span ───────
    #
    # The house style writes a cross-document citation as a markdown link,
    # and prose elsewhere writes the filename as a code span. Both put a
    # character between the filename and the section sign, and the pattern
    # could cross neither, so 132 live citations — one in four — were read by
    # nobody and could rot in silence (#404).

    def test_a_markdown_link_citation_is_read(self):
        self._write(
            "docs/story/note.md",
            "See [magic.md](magic.md) § Status Effect Reference > 'Poison'.\n",
        )
        self.assertEqual(self._errors(), [])

    def test_a_rotted_markdown_link_citation_fails(self):
        """The proof that the link form is checked and not merely tolerated."""
        self._write(
            "docs/story/note.md",
            "See [magic.md](magic.md) § Nonexistent Heading.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    def test_a_markdown_link_citations_term_is_checked(self):
        self._write(
            "docs/story/note.md",
            "See [magic.md](magic.md) § Status Effect Reference > 'Rot'.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("does not appear under", errors[0])

    def test_a_link_citation_resolves_its_target_not_its_link_text(self):
        """The two filenames can disagree, and the target is the real path.

        ``docs/analysis/`` writes ``[magic.md](../story/magic.md)``. Resolving
        the link text would hand ``DocIndex`` every ``magic.md`` in the tree;
        here the wrong one carries the heading and the right one does not, so
        only a checker that follows the target reports it.
        """
        self._write("docs/story/decoy/magic.md", MAGIC_FIXTURE)
        self._write(
            "docs/analysis/note.md",
            "See [magic.md](../story/decoy/magic.md) § Spell Count Summary.\n",
        )
        self.assertEqual(self._errors(), [])
        self._write("docs/story/decoy/magic.md", "# Magic System\n\n## Moved\n")
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("docs/story/decoy/magic.md", errors[0])

    def test_a_link_with_a_dead_target_is_read_through_its_text(self):
        """A broken link is still a citation; report it as the one it names."""
        self._write(
            "docs/story/note.md",
            "See [magic.md](../gone/magic.md) § Nonexistent Heading.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    def test_a_link_citation_may_wrap_before_the_section_sign(self):
        """``[dungeons-world.md](...)`` / ``§ 2`` is one citation, not two."""
        self._write("docs/plans/arch.md", NUMBERED_FIXTURE)
        self._write(
            "docs/story/note.md",
            "See [arch.md](../plans/arch.md)\n§ 2.1 Enemy Data for the shape.\n",
        )
        self.assertEqual(self._errors(), [])
        self._write(
            "docs/story/note.md",
            "See [arch.md](../plans/arch.md)\n§ 9.9 Enemy Data for the shape.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    def test_a_code_span_citation_is_read(self):
        self._write(
            "docs/story/note.md",
            "See `magic.md` § Status Effect Reference > 'Poison'.\n",
        )
        self.assertEqual(self._errors(), [])

    def test_a_rotted_code_span_citation_fails(self):
        self._write("docs/story/note.md", "See `magic.md` § Ghost Section.\n")
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    def test_the_decorated_forms_are_counted_separately(self):
        """The count is what makes "nothing wrong" distinguishable later."""
        self._write(
            "docs/story/note.md",
            "See [magic.md](magic.md) § Spell Count Summary, "
            "`magic.md` § Physical Attack Resolution, and "
            "magic.md § Status Effect Reference.\n",
        )
        tally: dict = {}
        with patch.dict(
            check_doc_citations.KNOWN_UNRESOLVED, {}, clear=True
        ):
            self.assertEqual(check_doc_citations.check_citations(tally), [])
        self.assertEqual(tally["citations"], 3)
        self.assertEqual(tally["decorated"], 2)

    def test_ignores_dated_records(self):
        """docs/issues and docs/superpowers describe the tree as it was."""
        self._write("docs/issues/rot.md", "Broke at magic.md:1537.\n")
        self._write("docs/superpowers/plan.md", "Broke at magic.md:1537.\n")
        self.assertEqual(self._errors(), [])

    def test_ignores_fenced_examples_in_markdown(self):
        self._write(
            "docs/story/guide.md",
            "How to cite:\n\n```markdown\nrelevant_doc.md § Section Name\n```\n",
        )
        self.assertEqual(self._errors(), [])

    def test_known_unresolved_entry_suppresses_its_own_citation(self):
        self._write("game/scripts/a.gd", "# See magic.md § Ghost Section.\n")
        known = {
            ("game/scripts/a.gd", "magic.md § Ghost Section."): "#0 — pinned",
        }
        self.assertEqual(self._errors(known), [])

    def test_resolves_a_heading_that_wraps_to_the_next_line(self):
        """Prose wraps, and the heading it names wraps with it.

        Reading only the first line hands ``§ Physical Attack`` to the
        resolver, which matches the earlier *Physical Elemental Attacks* —
        ``attack`` is a subsequence of it. The citation means *Physical Attack
        Resolution*, and reading the continuation line is what gets it there.
        """
        index = check_doc_citations.DocIndex()
        truncated = check_doc_citations.match_heading(
            index, "docs/story/magic.md", "Physical Attack"
        )
        self.assertEqual(truncated[2], "Physical Elemental Attacks")

        # ``citation_tail`` returns a *character* length; ``match_heading``
        # takes a *word* count. ``check_citations`` converts between the two
        # (``own_words = len(heading_part[:own_len].split())``) and this test
        # must convert identically — a character length is several times the
        # word count, which switches the own-line bound off and lets the
        # assertion pass whatever the bounding logic does.
        wrapped, own_len = check_doc_citations.citation_tail(
            " Physical Attack\n## Resolution).\n", markdown=False
        )
        self.assertEqual(wrapped[:own_len], " Physical Attack")
        own_words = len(wrapped[:own_len].split())
        hit = check_doc_citations.match_heading(
            index, "docs/story/magic.md", wrapped, own_words
        )
        self.assertEqual(hit[2], "Physical Attack Resolution")

        self._write(
            "game/scripts/a.gd",
            "## Base damage (magic.md § Physical Attack\n"
            "## Resolution > 'row modifier').\n",
        )
        self.assertEqual(self._errors(), [])

    def test_the_wrapped_bound_is_counted_in_words_not_characters(self):
        """A wrap whose next line opens on a capital needs the bound exact.

        Above, the citation's own words and the joined ones together name one
        heading, so the invention check never reaches ``words[own]`` and any
        ``own`` at all resolves it. Here the heading ends on the citation's own
        line and the continuation opens on ``Eighty-nine`` — capitalised, and
        matching no heading. Only a bound of exactly three words stops that
        from reading as an invented subsection, so this case fails on a
        character length and fails again if the bound is dropped.
        """
        index = check_doc_citations.DocIndex()
        wrapped, own_len = check_doc_citations.citation_tail(
            " Spell Count Summary\n## Eighty-nine spells.\n", markdown=False
        )
        self.assertEqual(wrapped, " Spell Count Summary Eighty-nine spells.")
        own_words = len(wrapped[:own_len].split())
        self.assertEqual(own_words, 3)
        hit = check_doc_citations.match_heading(
            index, "docs/story/magic.md", wrapped, own_words
        )
        self.assertEqual(hit[2], "Spell Count Summary")

    def test_a_wrapped_citation_cannot_green_light_the_wrong_section(self):
        """The silent failure this gate exists to stop.

        ``row modifier`` is the term that belongs to *Physical Attack
        Resolution*; ``carry an element`` belongs to the section a truncated
        read lands on instead. Cited under the wrapped heading it must fail —
        and it must fail naming the section that was actually resolved, so the
        reader can see which one the citation reached.
        """
        self._write(
            "game/scripts/a.gd",
            "## Base damage (magic.md § Physical Attack\n"
            "## Resolution > 'carry an element').\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("does not appear under", errors[0])
        self.assertIn("§ Physical Attack Resolution", errors[0])

    def test_a_markdown_heading_does_not_continue_a_citation(self):
        """``#`` opens a section in prose; it is not comment furniture.

        In a ``.gd`` file the next line's ``##`` is a doc-comment marker to be
        stripped. In markdown it is the next section, and swallowing its title
        would rewrite the citation's identity — the pin below would come
        unstuck and the ratchet would fail on a document nobody touched.
        """
        self._write(
            "docs/story/note.md",
            "Poison ticks per magic.md § Ghost Section\n"
            "## Status Effect Reference\n",
        )
        known = {
            ("docs/story/note.md", "magic.md § Ghost Section"): "#0 — pinned",
        }
        self.assertEqual(self._errors(known), [])

    def test_citation_identity_stops_at_the_prose_around_it(self):
        """The ratchet keys on a citation, not on the code beside it.

        A pin whose signature carried the next token of prose would come
        unstuck the moment that prose changed, and a stale pin fails the gate.
        """
        self._write(
            "game/scripts/a.gd",
            "## (magic.md § Ghost Section). const POISON_PCT: float = 8.0\n"
            "## See also magic.md § Ghost Section. Prose follows here.\n"
            "<!-- magic.md § Ghost Section -->\n",
        )
        known = {
            ("game/scripts/a.gd", "magic.md § Ghost Section"): "#0 — pinned",
        }
        self.assertEqual(self._errors(known), [])

    def test_an_apostrophe_does_not_swallow_the_rest_of_a_citation(self):
        """``§ Cael's Edge -->`` ends at the arrow, not at the apostrophe."""
        self._write("docs/story/note.md", "<!-- magic.md § Cael's Ghost -->\n")
        known = {
            ("docs/story/note.md", "magic.md § Cael's Ghost"): "#0 — pinned",
        }
        self.assertEqual(self._errors(known), [])

    def test_pass_message_reports_how_many_citations_are_pinned(self):
        """The escape hatch has to announce its own size.

        The commit that introduced this list described it as five entries
        while adding twelve. A count printed by the gate cannot drift from
        the list it counts.
        """
        self._write("game/scripts/a.gd", "# See magic.md § Ghost Section.\n")
        known = {
            ("game/scripts/a.gd", "magic.md § Ghost Section."): "#0 — pinned",
        }
        buffer = io.StringIO()
        # The fixture repo has no docs/issues, so the Design-reference floors
        # (#403) would fire on a scan this test is not about. Dropping them
        # here rather than in the gate keeps them live everywhere else.
        with patch.dict(
            check_doc_citations.KNOWN_UNRESOLVED, known, clear=True
        ), patch.object(
            check_doc_citations, "MIN_GAP_DOCS", 0
        ), patch.object(
            check_doc_citations, "MIN_GAP_BULLETS", 0
        ), contextlib.redirect_stdout(buffer):
            self.assertEqual(check_doc_citations.main(), 0)
        self.assertIn("1 citation(s) pinned", buffer.getvalue())

    # ── Running on past the heading into invention (#367) ──────────────
    #
    # The resolver shortens a citation until some prefix matches, which is
    # what makes ``§ Caden`` reach ``### Spirit-speaker Caden``. Before
    # #367 the shortening had no floor: a citation could name a real
    # heading, keep going into a subsection nobody wrote, and still
    # resolve — to the shorter heading, silently, sending the reader to a
    # section that does not say what the citation claims it says. The two
    # halves below are inseparable: the rejection must bite, and the
    # shortening it is carved out of must survive it.

    def _house(self) -> None:
        self._write("docs/story/npcs.md", HOUSE_STYLE_FIXTURE)

    def _resolve(self, candidate: str):
        self._house()
        return check_doc_citations.match_heading(
            check_doc_citations.DocIndex(), "docs/story/npcs.md", candidate
        )

    def test_invented_subsection_under_a_real_section_resolves_to_nothing(
        self,
    ):
        """The reported defect, verbatim: § <real> <invented> must not pass."""
        self.assertIsNone(
            self._resolve("Encounter System Nonexistent Subsection")
        )

    def test_invented_words_after_a_real_subsection_resolve_to_nothing(self):
        """The second reported defect: invention after a *sub*section."""
        self.assertIsNone(self._resolve("Danger Counter That Nobody Wrote"))

    def test_an_invented_subsection_fails_the_whole_scan(self):
        """End to end, not just the resolver: the gate must report it."""
        self._house()
        self._write(
            "game/scripts/a.gd",
            "# See npcs.md § Encounter System Nonexistent Subsection.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    def test_shortening_to_a_later_word_of_the_heading_still_resolves(self):
        """``§ Caden`` -> ``### Spirit-speaker Caden``, the house style."""
        hit = self._resolve("Caden")
        self.assertIsNotNone(hit, "§ Caden must still resolve")
        self.assertEqual(hit[2], "Spirit-speaker Caden")

    def test_shortening_to_a_stemmed_first_word_still_resolves(self):
        """``§ Inns`` -> ``## Inn Costs``: plural, and short of the title."""
        hit = self._resolve("Inns")
        self.assertIsNotNone(hit, "§ Inns must still resolve")
        self.assertEqual(hit[2], "Inn Costs")

    def test_a_breadcrumb_path_citation_still_resolves(self):
        """Ancestor words may still be skipped: § Interlude <subsection>."""
        hit = self._resolve("Interlude The World Changes")
        self.assertIsNotNone(hit, "breadcrumb citations must still resolve")
        self.assertEqual(hit[2], "The World Changes")

    def test_lower_case_prose_may_still_run_on_past_the_heading(self):
        """Citations sit mid-sentence; the sentence keeps going."""
        hit = self._resolve("Danger Counter increments once per step")
        self.assertIsNotNone(hit, "run-on prose must not break a citation")
        self.assertEqual(hit[2], "Danger Counter")

    def test_a_parenthetical_gloss_may_still_follow_the_heading(self):
        """``§ 20. Highcairn Monastery (Pallor encounter)`` — a real one."""
        hit = self._resolve("Spirit-speaker Caden (Duskfen resident)")
        self.assertIsNotNone(hit, "a gloss must not break a citation")
        self.assertEqual(hit[2], "Spirit-speaker Caden")

    def test_a_quotation_may_still_follow_the_heading(self):
        """``§ Wolf Family, "all wolves"`` — also a real one."""
        hit = self._resolve('Inn Costs, "Twenty gil a night"')
        self.assertIsNotNone(hit, "a quotation must not break a citation")
        self.assertEqual(hit[2], "Inn Costs")

    def test_house_style_citations_survive_a_full_scan(self):
        """All four shortening forms, through the gate rather than around it."""
        self._house()
        self._write(
            "game/scripts/a.gd",
            "# npcs.md § Caden. npcs.md § Inns.\n"
            "# npcs.md § Interlude The World Changes.\n"
            "# npcs.md § Danger Counter increments once per step.\n",
        )
        self.assertEqual(self._errors(), [])

    # ── The floor under the shortening (#404) ──────────────────────────
    #
    # #404 was filed over a citation the gate could not read. Widening the
    # regex made it readable — and it still resolved, because the loop
    # shortened it to one word and ``match_words`` will take that word from
    # anywhere in a heading's breadcrumb. ``§ Act scaling`` landed on
    # ``### Regular Enemy HP by Act``: read, resolved, wrong. Only the hand
    # edit to geography.md removed it, which is not something a gate can
    # notice happening again. These tests are what notices.

    def test_a_one_word_match_buried_in_the_heading_resolves_to_nothing(self):
        """``§ Costs of travel`` must not land on ``## Inn Costs``."""
        self.assertIsNone(self._resolve("Costs of travel"))

    def test_a_one_word_match_on_the_headings_subject_still_resolves(self):
        """``§ Inns are twenty gil`` may: ``Inn`` is what the heading is."""
        hit = self._resolve("Inns are twenty gil")
        self.assertIsNotNone(hit, "a subject-word citation must still resolve")
        self.assertEqual(hit[2], "Inn Costs")

    def test_a_one_word_citation_that_names_nothing_more_still_resolves(self):
        """``npcs.md § Caden`` alone stays legal — it claims nothing else."""
        hit = self._resolve("Caden")
        self.assertIsNotNone(hit, "§ Caden must still resolve")
        self.assertEqual(hit[2], "Spirit-speaker Caden")

    def test_a_leading_section_id_is_not_the_headings_subject(self):
        """``§ Script sizes`` reaches ``### 1.2a Script Size Budget``.

        The subject of a numbered heading is what follows the number, so the
        id must be stripped before the first word is read — otherwise every
        numbered heading's subject would be a digit and every one-word
        citation of one would be refused.
        """
        self._write("docs/plans/arch.md", NUMBERED_FIXTURE)
        hit = check_doc_citations.match_heading(
            check_doc_citations.DocIndex(),
            "docs/plans/arch.md",
            "Script sizes are capped",
        )
        self.assertIsNotNone(hit)
        self.assertEqual(hit[2], "1.2a Script Size Budget")

    def test_the_refusal_stops_at_one_word(self):
        """Longer buried prefixes are still accepted, and #416 says so.

        ``World Changes`` is not the subject of ``### The World Changes``
        either, but two words is a claim the subject rule does not reach.
        Pinning the boundary here means the day #416 moves it, this test is
        the one that says the behavior changed on purpose.
        """
        hit = self._resolve("World Changes and the map redraws")
        self.assertIsNotNone(hit)
        self.assertEqual(hit[2], "The World Changes")

    def test_the_404_exemplar_fails_the_whole_scan(self):
        """The defect #404 was filed over, verbatim, end to end.

        ``docs/story/geography.md:556`` on ``main`` read exactly this line.
        Before this test the branch could delete the guard and the line would
        resolve again in silence.
        """
        self._write("docs/story/combat-formulas.md", ACT_SCALING_FIXTURE)
        self._write(
            "docs/story/geography.md",
            "Act IV and the Epilogue hold at Act III's value -- see\n"
            "[combat-formulas.md](combat-formulas.md) § Act scaling for why.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])
        self.assertIn("Act scaling", errors[0])

    def test_the_repointed_form_of_the_404_exemplar_passes(self):
        """And the fix that replaced it resolves, so the guard is not a wall."""
        self._write("docs/story/combat-formulas.md", ACT_SCALING_FIXTURE)
        self._write(
            "docs/story/geography.md",
            "see [combat-formulas.md](combat-formulas.md) "
            "§ Danger Counter > 'Act scaling'.\n",
        )
        self.assertEqual(self._errors(), [])

    # ── The same invention, under a numbered heading (#367) ────────────
    #
    # The first fix for #367 guarded only the word-prefix loop. A citation
    # that opens with a section id never reaches that loop — it resolves on
    # the id and returns — so no invention check ran at all, and numbered
    # headings are the common shape in ui-design.md,
    # technical-architecture.md and dungeons-world.md.
    #
    # What runs there reads the section-id shape: a leftover ``21.`` is as
    # loud a claim about the heading tree as ``Invented`` is, and ``isupper``
    # is blind to it because digits have no case. Capitalization on its own
    # still stays out — under an id it fails four correct live citations —
    # so the leftover words are checked against the cited section's own
    # vocabulary instead (#389); see the block after this one.

    def _arch(self):
        self._write("docs/plans/arch.md", NUMBERED_FIXTURE)
        return check_doc_citations.DocIndex()

    def _arch_resolve(self, candidate: str):
        return check_doc_citations.match_heading(
            self._arch(), "docs/plans/arch.md", candidate
        )

    def _dungeon_resolve(self, candidate: str):
        self._write("docs/story/dungeons.md", DUNGEON_FIXTURE)
        return check_doc_citations.match_heading(
            check_doc_citations.DocIndex(), "docs/story/dungeons.md", candidate
        )

    def test_a_second_section_id_is_invention_too(self):
        """``§ 19. <real> 21. <invented>`` — digits are not upper case.

        The whole heading resolves, so the capitalisation check never sees a
        capital: the first unaccounted-for word is ``21.``. Only the section
        id shape catches it.
        """
        self.assertIsNone(
            self._dungeon_resolve("19. Ley Nexus Hollow 21. Invented Chamber")
        )

    def test_a_numbered_list_heading_still_resolves_by_its_full_title(self):
        """The other half: ``§ 19. Ley Nexus Hollow`` must still land."""
        hit = self._dungeon_resolve("19. Ley Nexus Hollow")
        self.assertIsNotNone(hit, "§ 19. Ley Nexus Hollow must resolve")
        self.assertEqual(hit[2], "19. Ley Nexus Hollow")

    def test_a_gloss_after_a_numbered_list_heading_still_runs_on(self):
        """``§ 20. Highcairn Monastery (Pallor encounter)`` — a real one."""
        hit = self._dungeon_resolve("20. Highcairn Monastery (Pallor waits)")
        self.assertIsNotNone(hit, "a gloss must not break a citation")
        self.assertEqual(hit[2], "20. Highcairn Monastery")

    def test_a_numbered_invention_fails_the_whole_scan(self):
        """End to end, through the gate rather than around it.

        The dotted-id form. The ``19.`` list form now reaches the resolver
        too, since ``citation_extent`` stopped reading a heading number's
        period as a sentence ending (#390); it has its own end-to-end test
        below.
        """
        self._write("docs/plans/arch.md", NUMBERED_FIXTURE)
        self._write(
            "game/scripts/a.gd",
            "# See arch.md § 2.1 Enemy Data 2.3 Invented Section.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    # ── Invented words under a section id (#389) ───────────────────────
    #
    # The pair above left one shape resolving: ``§ 2.3 Nonexistent
    # Subsection``. Its syntax is identical to ``audio.md § 3.1 SFX budget``
    # and ``dungeons-world.md § 1 Ember Vein Floor 2``, two correct live
    # citations whose trailing words locate something *inside* the section,
    # so no rule reading capitalization alone can refuse one and keep the
    # others. The document decides instead: a locator names something the
    # section says, an invented subsection names something nowhere in it.

    def test_an_invented_subsection_under_a_section_id_is_refused(self):
        """The gap #389 was filed for. ``Nonexistent`` is not in § 2.3."""
        self.assertIsNone(self._arch_resolve("2.3 Nonexistent Subsection"))

    def test_a_locator_the_section_actually_names_is_still_allowed(self):
        """The half that must survive: § 2.1's body says "Field Budget"."""
        hit = self._arch_resolve("2.1 Enemy Data Field Budget")
        self.assertIsNotNone(hit, "a locator inside the section must resolve")
        self.assertEqual(hit[2], "2.1 Enemy Data")

    def test_a_locator_phrase_after_an_id_survives_a_full_scan(self):
        """The live shape end to end: § <id> <Capitalised locator>.

        Modelled on ``audio.md § 3.1 SFX budget``, which cites the channel
        table inside § 3.1 by what the citing line reads off it.
        """
        self._write("docs/plans/arch.md", NUMBERED_FIXTURE)
        self._write(
            "game/scripts/a.gd", "# arch.md § 2.1 Enemy Data Field Budget.\n"
        )
        self.assertEqual(self._errors(), [])

    def test_an_invented_subsection_under_an_id_fails_the_whole_scan(self):
        """End to end, through the gate rather than around it."""
        self._write("docs/plans/arch.md", NUMBERED_FIXTURE)
        self._write(
            "game/scripts/a.gd", "# arch.md § 2.1 Enemy Data Ghost Budget.\n"
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    def test_a_locator_that_the_section_stops_saying_fails(self):
        """The rot this closes: the section moves on, the citation does not."""
        self._write(
            "docs/plans/arch.md",
            NUMBERED_FIXTURE.replace("The Field Budget row", "The key cap"),
        )
        self._write(
            "game/scripts/a.gd", "# arch.md § 2.1 Enemy Data Field Budget.\n"
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    def test_lower_case_prose_after_an_id_is_still_free_to_run_on(self):
        """The check reads capitalized words only, and says so.

        House style writes citations mid-sentence, and the sentence carries
        on in lower case with words the cited section never uses. Holding
        *those* to the section's vocabulary would fail most numbered
        citations in the tree.
        """
        hit = self._arch_resolve("2.1 Enemy Data and the exit_battle rule")
        self.assertIsNotNone(hit, "run-on prose must not break a citation")
        self.assertEqual(hit[2], "2.1 Enemy Data")

    def test_a_word_from_the_headings_own_title_is_not_invention(self):
        """A citation may repeat the title out of order without failing."""
        hit = self._arch_resolve("1.2a Budget Script")
        self.assertIsNotNone(hit, "the heading's own words must be accepted")
        self.assertEqual(hit[2], "1.2a Script Size Budget")

    # ── A bare section id is positional, not a bag of words (#391) ─────
    #
    # Ids were matched with ``is_subsequence`` against a heading's normalized
    # breadcrumb, so ``3`` matched the trail of ``### 1.3 Autoload
    # Singletons`` (``... 1 3 autoload singletons``) and won by coming first
    # in the file. ``enemy-ability-conventions.md §3`` is cited twice in the
    # live tree and resolved that way to ``### 2.3 AoE elemental abilities``:
    # the gate reported passed while pointing the reader at the wrong
    # section, and renaming the real § 3 would not have failed it.

    def test_a_bare_id_reaches_its_own_top_level_heading(self):
        """``§ 3`` is ``## 3.``, even with a ``### 1.3`` earlier in the file."""
        hit = self._arch_resolve("3")
        self.assertIsNotNone(hit, "§ 3 must resolve")
        self.assertEqual(hit[2], "3. Game State Machine")

    def test_a_bare_id_does_not_borrow_a_nested_heading(self):
        """``§ 2`` is ``## 2.``, not the earlier ``### 1.2``."""
        hit = self._arch_resolve("2")
        self.assertIsNotNone(hit, "§ 2 must resolve")
        self.assertEqual(hit[2], "2. Data Formats")

    def test_a_nested_id_still_reaches_itself(self):
        """The other half: ``§ 1.3`` must still be the nested heading."""
        hit = self._arch_resolve("1.3")
        self.assertIsNotNone(hit, "§ 1.3 must resolve")
        self.assertEqual(hit[2], "1.3 Autoload Singletons")

    def test_a_digit_inside_a_title_is_not_a_section_id(self):
        """``dungeons-world.md § 2`` means ``## 2.``, not ``### Floor 2:``.

        Both cited sites of that citation resolved to ``Floor 2: Lower
        Mine`` before ids were anchored, which is a different dungeon from
        the one they meant.
        """
        self._write(
            "docs/story/dungeons.md",
            "# Dungeons\n\n## 1. Ember Vein\n\n### Floor 2: Lower Mine\n\n"
            "Ore carts.\n\n## 2. Fenmother's Hollow\n\nMarsh.\n",
        )
        hit = check_doc_citations.match_heading(
            check_doc_citations.DocIndex(), "docs/story/dungeons.md", "2"
        )
        self.assertIsNotNone(hit, "§ 2 must resolve")
        self.assertEqual(hit[2], "2. Fenmother's Hollow")

    def test_renaming_the_section_a_bare_id_names_fails_the_scan(self):
        """The rot the anchoring makes visible, end to end.

        Before it, deleting ``## 3.`` left ``§ 3`` resolving happily to
        ``### 1.3`` and the gate reporting passed.
        """
        self._write(
            "docs/plans/arch.md",
            NUMBERED_FIXTURE.replace("## 3. Game State Machine", "## Flow"),
        )
        self._write("game/scripts/a.gd", "# States: arch.md § 3.\n")
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    def test_a_bare_id_no_heading_numbers_fails_the_scan(self):
        """``§ 9`` names nothing, and must say so rather than shorten."""
        self._write("docs/plans/arch.md", NUMBERED_FIXTURE)
        self._write("game/scripts/a.gd", "# See arch.md § 9.\n")
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    # ── A document citing its own section (#386) ───────────────────────
    #
    # ``technical-architecture.md`` says "the six singletons listed in § 1.3".
    # Spelling its own filename out there is redundant to a reader, so the
    # reference carried no filename — and went unchecked entirely.

    def test_a_bare_section_reference_resolves_against_its_own_document(self):
        self._write(
            "docs/plans/arch.md",
            NUMBERED_FIXTURE + "\nThe singletons listed in § 1.3 and no more.\n",
        )
        self.assertEqual(self._errors(), [])

    def test_a_bare_reference_to_a_section_nobody_wrote_fails(self):
        self._write(
            "docs/plans/arch.md",
            NUMBERED_FIXTURE + "\nThe singletons listed in § 9.4 and no more.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    def test_a_self_reference_that_rots_fails_the_scan(self):
        """Rename the section and the same reference must stop passing."""
        self._write(
            "docs/plans/arch.md",
            NUMBERED_FIXTURE.replace("### 1.3 ", "### 1.4 ")
            + "\nThe singletons listed in § 1.3 and no more.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    def test_a_reference_after_a_named_document_is_not_read_as_self(self):
        """The house style wraps its markdown links, and the ``§`` lands
        on the next line with no filename in front of it. Reading that as a
        self-reference resolves it against the wrong document — silently,
        and in the direction this gate exists to prevent. ``arch.md`` has no
        § 5, so a self-reading would fail here.
        """
        self._write(
            "docs/story/dungeons.md", "# Dungeons\n\n## 5. Ley Nexus\n\nA leech.\n"
        )
        self._write(
            "docs/plans/arch.md",
            NUMBERED_FIXTURE
            + "\nThe party enters ([dungeons.md](../story/dungeons.md)\n"
            "§ 5, recommended level 12) before Act II.\n",
        )
        self.assertEqual(self._errors(), [])

    def test_a_bare_reference_in_code_has_no_document_to_resolve_against(self):
        """A ``.gd`` file is not a document, so ``§ 9`` there stays unread."""
        self._write("docs/plans/arch.md", NUMBERED_FIXTURE)
        self._write("game/scripts/a.gd", "# The rule in § 9.4 applies.\n")
        self.assertEqual(self._errors(), [])

    def test_a_number_that_is_not_a_section_id_is_not_a_self_reference(self):
        """``§ 3rd`` is prose; an id ends the token it starts."""
        self._write(
            "docs/plans/arch.md",
            NUMBERED_FIXTURE + "\nThe § 3rd rule of the tree.\n",
        )
        self.assertEqual(self._errors(), [])

    def test_a_self_reference_inside_a_fence_is_an_example(self):
        self._write(
            "docs/plans/arch.md",
            NUMBERED_FIXTURE + "\n```\nSee § 9.4 for the shape.\n```\n",
        )
        self.assertEqual(self._errors(), [])

    def test_a_numbered_citation_naming_its_own_title_still_resolves(self):
        """The check must not cost the citation that spells the heading out."""
        hit = self._arch_resolve("2.3 Equipment Data")
        self.assertIsNotNone(hit, "§ 2.3 Equipment Data must resolve")
        self.assertEqual(hit[2], "2.3 Equipment Data")

    def test_a_numbered_citation_may_still_run_on_into_prose(self):
        """Lower-case prose after a numbered id is a sentence, not a claim."""
        hit = self._arch_resolve("2.1 Enemy Data lists every field")
        self.assertIsNotNone(hit, "run-on prose must not break a citation")
        self.assertEqual(hit[2], "2.1 Enemy Data")

    def test_a_bare_number_after_a_heading_is_not_a_section_id(self):
        """``§ 1.1 Directory Structure 400 files`` — 400 is a count."""
        hit = self._arch_resolve("1.1 Directory Structure 400 files")
        self.assertIsNotNone(hit, "a bare number must not read as a section")
        self.assertEqual(hit[2], "1.1 Directory Structure")

    def test_a_section_list_citation_is_not_read_as_invention(self):
        """``§ 2.1/2.3`` normalises to words no one heading holds."""
        hit = self._arch_resolve("2.1/2.3")
        self.assertIsNotNone(hit, "a section list must still resolve")

    # ── The period in "§ 19." belongs to the heading (#390) ────────────
    #
    # dungeons-world.md numbers its headings as a list, so "§ 19. Ley Nexus
    # Hollow" spells one out. ``citation_extent`` read that period as the end
    # of a sentence and handed the resolver the bare "19" — which resolves on
    # the id alone, so neither the title nor the narrowing term was ever
    # looked at. The invention check above was refusing "§ 19. Ley Nexus
    # Hollow 21. Invented Chamber" when called directly while the gate passed
    # it, because the citation reaching the resolver had already lost
    # everything after the "19". These tests run through the gate, which is
    # the only place that gap was visible.

    def _dungeon_scan(self, citation: str) -> list[str]:
        self._write("docs/story/dungeons.md", DUNGEON_FIXTURE)
        self._write("game/scripts/a.gd", f"# See {citation}\n")
        return self._errors()

    def test_a_numbered_list_citation_keeps_its_title_and_term(self):
        """The good citation: heading spelled out, term that is really there."""
        errors = self._dungeon_scan(
            "dungeons.md § 19. Ley Nexus Hollow > 'A leech feeds'."
        )
        self.assertEqual(errors, [])

    def test_a_numbered_list_citations_term_is_actually_checked(self):
        """The term used to be discarded along with the title, unchecked."""
        errors = self._dungeon_scan(
            "dungeons.md § 19. Ley Nexus Hollow > 'nobody ever wrote this'."
        )
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("does not appear under", errors[0])

    def test_a_second_id_after_a_numbered_list_heading_fails_the_scan(self):
        """``match_heading``'s own documented example, through the gate."""
        errors = self._dungeon_scan(
            "dungeons.md § 19. Ley Nexus Hollow 21. Invented Chamber."
        )
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    def test_an_id_followed_by_code_still_ends_at_its_period(self):
        """Only a capitalized word opens a heading title.

        ``enemy.gd`` cites ``enemy-ability-conventions.md §2.4.`` with a
        GDScript signature wrapped onto the next line. Stepping over that
        period would pull the signature into the citation's identity, which
        is the thing ``citation_extent`` exists to prevent.
        """
        self.assertEqual(
            check_doc_citations.citation_extent(
                "2.4. func apply_buff(stat: String, mult: float) -> void:"
            ),
            "2.4.",
        )

    def test_a_sentence_ending_on_a_number_still_ends_the_citation(self):
        """``a stat cannot pass 255. Combat re-clamps.`` — one citation, not two.

        The period stays on the cut so ``255.`` keeps the section-id shape
        the resolver's invention check reads; what follows it is discarded
        exactly as before.
        """
        self.assertEqual(
            check_doc_citations.citation_extent(
                "Equipment and Buffs: a stat cannot pass 255. Combat re-clamps."
            ),
            "Equipment and Buffs: a stat cannot pass 255.",
        )

    # ── Over-reading a wrapped line must stay free (#367) ──────────────
    #
    # ``citation_tail`` joins the continuation line so a wrapped heading
    # still resolves. Its docstring promised that over-reading costs
    # nothing — true when the resolver only ever shortened, false once the
    # invention check could *refuse*. A continuation line is prose the
    # citation did not choose, and English sentences open on capitals, so a
    # correct citation could fail the gate purely for where it wrapped.
    # The check is bounded to the citation's own line to keep the promise.

    def test_a_continuation_line_may_open_on_a_capital(self):
        """The latent trap: a correct citation must not fail for wrapping."""
        self._house()
        self._write(
            "game/scripts/a.gd",
            "## The counter grows per npcs.md § Danger Counter\n"
            "## Maren banks weave when somebody else casts.\n",
        )
        self.assertEqual(self._errors(), [])

    def test_invention_on_the_citations_own_line_still_fails_when_wrapped(self):
        """The bound is the line, not the check: own-line invention still bites."""
        self._house()
        self._write(
            "game/scripts/a.gd",
            "## The counter grows per npcs.md § Danger Counter Nonexistent\n"
            "## Subsection is what it claims.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    # ── A narrowing term the checker cannot read (#366) ────────────────

    def test_a_term_whose_quote_never_closes_is_reported(self):
        """An unreadable term is a skipped check wearing a passed one's face.

        ``> 'Poison`` with no closing quote used to leave ``TERM_RE`` with no
        match, which is the same state as a citation that never narrowed —
        so the heading resolved, the term went unchecked, and the gate said
        nothing. The citation still reads as narrowed to anyone following it.
        """
        self._write(
            "game/scripts/a.gd",
            "# See magic.md § Status Effect Reference > 'Poison\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("never closes its quote", errors[0])

    def test_an_open_term_does_not_also_break_its_heading(self):
        """One complaint, about the term — the heading still resolved."""
        self._write(
            "game/scripts/a.gd",
            "# See magic.md § Spell Count Summary > 'Eighty\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertNotIn("names no heading", errors[0])

    def test_a_closed_term_is_not_reported_as_open(self):
        """The guard must not fire on the form it is protecting."""
        self._write(
            "game/scripts/a.gd",
            "# See magic.md § Status Effect Reference > 'Poison'.\n",
        )
        self.assertEqual(self._errors(), [])

    # ── A § whose file the citation before it named (#415) ─────────────
    #
    # The house style lists several sections of one document off a single
    # filename — ``combat-formulas.md § Danger Counter, § Battle Formations``
    # — and only the first ``§`` was ever checked. ``§ Battle Formations``
    # could be renamed out from under three call sites and this gate stayed
    # green, which is the exact failure it exists to prevent, one comma to
    # the right of where it was looking.

    def _chained(self, line: str) -> list[str]:
        self._house()
        self._write("game/scripts/a.gd", line)
        return self._errors()

    def test_a_chained_citation_is_read(self):
        """``npcs.md § A, § B`` — the second ``§`` inherits npcs.md."""
        self.assertEqual(
            self._chained("# Canon: npcs.md § Inn Costs, § Danger Counter.\n"),
            [],
        )

    def test_an_invented_heading_behind_a_chained_sign_fails(self):
        """The proof the chain is checked and not merely tolerated."""
        errors = self._chained(
            "# Canon: npcs.md § Inn Costs, § Chamber Nobody Wrote.\n"
        )
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])
        self.assertIn("Chamber Nobody Wrote", errors[0])

    def test_renaming_a_heading_only_a_chain_cites_fails_the_gate(self):
        """The #415 defect end to end: the rename used to cost nothing.

        Only the second ``§`` on the line names ``### Danger Counter``. Before
        the chain was read, renaming that heading left every citation of it
        passing, because nothing had ever resolved the citation.
        """
        self._write(
            "docs/story/npcs.md",
            HOUSE_STYLE_FIXTURE.replace(
                "### Danger Counter", "### Step Counter"
            ),
        )
        self._write(
            "game/scripts/a.gd",
            "# Canon: npcs.md § Inn Costs, § Danger Counter.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("Danger Counter", errors[0])

    def test_a_sentence_end_stops_the_chain(self):
        """``bosses.md`` cites act-i.md, then names *its own* § Quick
        Reference one sentence later. A chain that crossed the full stop
        would resolve that against act-i.md, which has no such section.
        Both halves are here: the chain must stop, and it must not stop for
        a comma.
        """
        self.assertEqual(
            self._chained(
                "# npcs.md § Inn Costs. See § Chamber Nobody Wrote.\n"
            ),
            [],
        )
        errors = self._chained(
            "# npcs.md § Inn Costs, see § Chamber Nobody Wrote.\n"
        )
        self.assertEqual(len(errors), 1, errors)

    def test_a_closed_parenthesis_stops_the_chain(self):
        """``progression.md`` writes, on one line with no full stop between,

            ... gains ([items.md](items.md) § Stat Capsules), plus whatever
            the equipped Ley Crystal contributes under § Ley Crystal System

        where § Ley Crystal System is progression.md's own heading. The
        citation's parenthesis closed before the second ``§``; the file it
        named went with it. Without this the chain resolved it against
        items.md and the gate failed a correct citation.
        """
        self.assertEqual(
            self._chained(
                "# gains (npcs.md § Inn Costs), plus what "
                "§ Chamber Nobody Wrote adds.\n"
            ),
            [],
        )
        errors = self._chained(
            "# gains (npcs.md § Inn Costs, plus what "
            "§ Chamber Nobody Wrote adds).\n"
        )
        self.assertEqual(len(errors), 1, errors)

    def test_a_chain_wraps_once_and_no_further(self):
        """One wrap is the tolerance every other join here gets."""
        errors = self._chained(
            "# npcs.md § Inn Costs,\n# § Chamber Nobody Wrote.\n"
        )
        self.assertEqual(len(errors), 1, errors)
        self.assertEqual(
            self._chained(
                "# npcs.md § Inn Costs,\n# and also,\n"
                "# § Chamber Nobody Wrote.\n"
            ),
            [],
        )

    def test_a_chain_outranks_the_same_document_reading(self):
        """``technical-architecture.md`` writes

            [bestiary/enemy-ability-conventions.md](...)
            §1 (ability schema) and §3 (boss-AI conventions).

        and numbers a ``## 3.`` of its own. Reading ``§3`` as a
        self-reference resolves it against the wrong document and passes,
        which is the silent wrong answer this gate exists to prevent. Here
        the citing file numbers a § 2.9 and ``arch.md`` does not, so the scan
        can only fail if the chain won.
        """
        self._write("docs/plans/arch.md", NUMBERED_FIXTURE)
        self._write(
            "docs/story/note.md",
            "# Note\n\n## 2.9 Local Section\n\nText.\n\n"
            "Defined in [arch.md](../plans/arch.md)\n"
            "§ 1.1 (layout) and § 2.9 (records).\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("2.9", errors[0])

    def test_a_broken_chain_falls_through_to_the_same_document_reading(self):
        """``enemy-ability-conventions.md`` writes

            (Tier 4 is exempt — magic.md
            § Tier 4 AoE Exemption; §2.3 only ever applies the rule ...

        where ``§2.3`` is one of *its own* sections and magic.md numbers no
        2.3 at all. The ``;`` ends the list, so the reading falls through to
        the same-document one — and that reading is still checked: rename the
        section and the scan fails.
        """
        self._write("docs/plans/arch.md", NUMBERED_FIXTURE)
        note = (
            "# Note\n\n## 2.9 Local Section\n\nText.\n\n"
            "Defined in [arch.md](../plans/arch.md)\n"
            "§ 1.1 (layout); § 2.9 only ever applies here.\n"
        )
        self._write("docs/story/note.md", note)
        self.assertEqual(self._errors(), [])
        self._write(
            "docs/story/note.md", note.replace("## 2.9 Local", "## 2.8 Local")
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    def test_a_chain_carries_the_link_destination_not_the_link_text(self):
        """What the first citation resolved to is what the second inherits."""
        self._write("docs/story/npcs.md", HOUSE_STYLE_FIXTURE)
        self._write("docs/story/other/npcs.md", "# Other\n\n## Inn Costs\n")
        self._write(
            "docs/analysis/note.md",
            "See [npcs.md](../story/other/npcs.md) § Inn Costs, "
            "§ Danger Counter.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("docs/story/other/npcs.md", errors[0])

    def test_the_chain_count_is_reported(self):
        """The tally is what stops the coverage silently returning to zero."""
        self._house()
        self._write(
            "game/scripts/a.gd", "# npcs.md § Inn Costs, § Danger Counter.\n"
        )
        tally: dict = {}
        self.assertEqual(check_doc_citations.check_citations(tally), [])
        self.assertEqual(tally["chained"], 1)

    def test_stale_known_unresolved_entry_fails(self):
        """The ratchet cannot rot either: a pin with nothing to pin fails."""
        known = {
            ("game/scripts/gone.gd", "magic.md § Ghost Section."): "#0 — pinned",
        }
        errors = self._errors(known)
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("stale entry in KNOWN_UNRESOLVED", errors[0])


class TestIntegration(unittest.TestCase):
    """Integration tests — run all gates against real project data."""

    def test_full_id_scan_passes(self):
        """Full ID uniqueness scan should pass on current data."""
        if not os.path.exists("game/data"):
            self.skipTest("No game data available")
        result = check_id_uniqueness.main()
        self.assertEqual(result, 0)

    def test_full_stale_scan_passes(self):
        """Full stale-count scan should pass on current data."""
        if not os.path.exists("docs/analysis/game-dev-gaps.md"):
            self.skipTest("No gap tracker available")
        result = check_stale_counts.main()
        self.assertEqual(result, 0)

    def test_full_scene_scan_passes(self):
        """Full scene reference scan should pass on current data."""
        if not os.path.exists("game/scenes"):
            self.skipTest("No scene files available")
        result = check_scene_refs.main()
        self.assertEqual(result, 0)

    def test_full_citation_scan_passes(self):
        """Full doc citation scan should pass on current data."""
        if not os.path.exists("docs/story"):
            self.skipTest("No design docs available")
        result = check_doc_citations.main()
        self.assertEqual(result, 0)

    def test_full_citation_scan_reads_a_non_trivial_corpus(self):
        """"No bad citations" and "no citations read" both print nothing.

        The floors are far below the live numbers (575 citations across 537
        files, 13 of them same-document, 134 written as a markdown link or
        code span and 16 inheriting their file from the citation before them)
        so ordinary editing does not trip them, but a scan that stopped
        descending cannot clear them.

        The ``decorated`` floor is the one #404 leaves behind and the
        ``chained`` floor the one #415 does. Both counts were zero for the
        gate's whole life — the pattern could cross neither the ``](...)`` a
        markdown link puts between the filename and the section sign nor the
        comma a list of sections puts between two of them — and a floor under
        each is what stops it silently returning there.
        """
        if not os.path.exists("docs/story"):
            self.skipTest("No design docs available")
        tally: dict = {}
        errors = check_doc_citations.check_citations(tally)
        self.assertEqual(errors, [])
        self.assertGreater(tally["files"], 300)
        self.assertGreater(tally["citations"], 400)
        self.assertGreater(tally["self_references"], 5)
        self.assertGreater(tally["decorated"], 60)
        self.assertGreater(tally["chained"], 8)

    def test_the_citation_counts_come_from_the_directory_walk(self):
        """Sever the walk's recursion and the counts must collapse.

        A floor is only evidence if the number under it is measured. This
        stops ``os.walk`` descending past each scan root — leaving the entry
        points intact and taking away everything below them — and the counts
        that pass the floors above must fall through them: no
        ``docs/story/script/``, no ``game/scripts/**``, no same-document
        reference anywhere, since all thirteen live ones sit in nested
        directories, and no link-form citation either — every one of the 134
        lives under a scan root rather than directly in it. Eleven of the
        sixteen chained citations go the same way; the five that survive are
        in ``game/tests/`` itself, which is a scan root, and five is under the
        floor above.
        """
        if not os.path.exists("docs/story"):
            self.skipTest("No design docs available")
        real_walk = os.walk

        def no_descent(top, *args, **kwargs):
            for dirpath, dirnames, filenames in real_walk(top, *args, **kwargs):
                dirnames[:] = []
                yield dirpath, dirnames, filenames

        tally: dict = {}
        with patch("check_doc_citations.os.walk", no_descent):
            check_doc_citations.check_citations(tally)
        self.assertLess(tally["files"], 300)
        self.assertLess(tally["citations"], 400)
        self.assertEqual(tally["self_references"], 0)
        self.assertEqual(tally["decorated"], 0)
        self.assertLess(tally["chained"], 8)


class TestDocLineCounts(unittest.TestCase):
    """Gate E, scan 2: canonical-source line-count claims (#336)."""

    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()
        self.story = os.path.join(self.tmpdir, "story")
        os.makedirs(os.path.join(self.story, "bestiary"))
        with open(os.path.join(self.story, "combat.md"), "w") as f:
            f.write("a\nb\nc\n")
        for n in ("one.md", "two.md"):
            with open(os.path.join(self.story, "bestiary", n), "w") as f:
                f.write("x\n")

    def _tracker(self, body: str) -> str:
        path = os.path.join(self.tmpdir, "gaps.md")
        with open(path, "w") as f:
            f.write(
                "| Category | Source Documents |\n"
                "|----------|----------------|\n" + body + "\n\nAfter the table.\n"
            )
        return path

    def test_accurate_counts_pass(self):
        p = self._tracker("| Combat | `combat.md` (3) |\n| Enemies | `bestiary/` (2 files) |")
        self.assertEqual(
            check_stale_counts.check_doc_line_counts(p, self.story), []
        )

    def test_detects_stale_line_count(self):
        p = self._tracker("| Combat | `combat.md` (933) |")
        errors = check_stale_counts.check_doc_line_counts(p, self.story)
        self.assertEqual(len(errors), 1)
        self.assertIn("claims 933 lines, actual 3", errors[0])

    def test_detects_stale_file_count(self):
        p = self._tracker("| Enemies | `bestiary/` (9 files) |")
        errors = check_stale_counts.check_doc_line_counts(p, self.story)
        self.assertEqual(len(errors), 1)
        self.assertIn("claims 9 files, actual 2", errors[0])

    def test_detects_missing_document(self):
        p = self._tracker("| Combat | `ghost.md` (10) |")
        errors = check_stale_counts.check_doc_line_counts(p, self.story)
        self.assertEqual(len(errors), 1)
        self.assertIn("does not exist", errors[0])

    def test_comma_formatted_counts_are_compared_numerically(self):
        with open(os.path.join(self.story, "big.md"), "w") as f:
            f.write("x\n" * 1234)
        p = self._tracker("| Big | `big.md` (1,234) |")
        self.assertEqual(
            check_stale_counts.check_doc_line_counts(p, self.story), []
        )

    def test_missing_table_is_reported(self):
        path = os.path.join(self.tmpdir, "no-table.md")
        with open(path, "w") as f:
            f.write("# Nothing here\n")
        errors = check_stale_counts.check_doc_line_counts(path, self.story)
        self.assertEqual(len(errors), 1)
        self.assertIn("table not found", errors[0])

    def test_real_tracker_is_current(self):
        if not os.path.exists("docs/analysis/game-dev-gaps.md"):
            self.skipTest("No gap tracker available")
        errors = check_stale_counts.check_doc_line_counts()
        self.assertEqual(errors, [], f"Stale doc line counts: {errors}")


class TestGapStatusConsistency(unittest.TestCase):
    """Gate E, scan 3: README rows vs linked GAP doc Status (#345)."""

    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()

    def _gap(self, gap_id: str, status: str) -> str:
        name = f"{gap_id}-thing.md"
        with open(os.path.join(self.tmpdir, name), "w") as f:
            f.write(f"| **ID** | {gap_id} |\n| **Status** | {status} |\n")
        return name

    def _readme(self, rows: list[str], tally: str) -> None:
        with open(os.path.join(self.tmpdir, "README.md"), "w") as f:
            f.write(tally + "\n\n| ID | Area | Severity | Effort | Status | Title |\n")
            f.write("|----|------|----------|--------|--------|-------|\n")
            f.write("\n".join(rows) + "\n")

    @staticmethod
    def _row(gap_id: str, link: str, status: str, epic: bool = False) -> str:
        marker = " 🏔️" if epic else ""
        return (
            f"| [{gap_id}]({link}){marker} | Combat | HIGH | M | {status} | Title |"
        )

    def test_agreeing_statuses_pass(self):
        a = self._gap("GAP-001", "open — CONFIRMED")
        b = self._gap("GAP-002", "resolved — #157")
        self._readme(
            [self._row("GAP-001", a, "open"), self._row("GAP-002", b, "✅ fixed")],
            "- **2 gap files** — **1 open**, **0 partial**, **1 resolved**.\n"
            "- **0 epics** (🏔️) among them.",
        )
        self.assertEqual(
            check_stale_counts.check_gap_status_consistency(self.tmpdir), []
        )

    def test_detects_row_disagreeing_with_doc(self):
        a = self._gap("GAP-001", "resolved — PR #268")
        self._readme(
            [self._row("GAP-001", a, "open")],
            "- **1 gap files** — **0 open**, **0 partial**, **1 resolved**.\n"
            "- **0 epics** (🏔️) among them.",
        )
        errors = check_stale_counts.check_gap_status_consistency(self.tmpdir)
        self.assertEqual(len(errors), 1)
        self.assertIn("GAP-001 row says 'open'", errors[0])
        self.assertIn("resolved", errors[0])

    def test_detects_stale_running_tally(self):
        a = self._gap("GAP-001", "open — CONFIRMED")
        self._readme(
            [self._row("GAP-001", a, "open")],
            "- **1 gap files** — **83 open**, **0 partial**, **0 resolved**.\n"
            "- **0 epics** (🏔️) among them.",
        )
        errors = check_stale_counts.check_gap_status_consistency(self.tmpdir)
        self.assertEqual(len(errors), 1)
        self.assertIn("claims 83 open, actual 1", errors[0])

    def test_detects_stale_epic_count(self):
        a = self._gap("GAP-001", "open — CONFIRMED")
        self._readme(
            [self._row("GAP-001", a, "open", epic=True)],
            "- **1 gap files** — **1 open**, **0 partial**, **0 resolved**.\n"
            "- **14 epics** (🏔️) among them.",
        )
        errors = check_stale_counts.check_gap_status_consistency(self.tmpdir)
        self.assertEqual(len(errors), 1)
        self.assertIn("claims 14 epics, actual 1", errors[0])

    def test_detects_broken_row_link(self):
        self._readme(
            [self._row("GAP-001", "GAP-001-gone.md", "open")],
            "- **1 gap files** — **0 open**, **0 partial**, **0 resolved**.\n"
            "- **0 epics** (🏔️) among them.",
        )
        errors = check_stale_counts.check_gap_status_consistency(self.tmpdir)
        self.assertTrue(any("links to missing" in e for e in errors))

    def test_unrecognised_status_is_reported_not_ignored(self):
        a = self._gap("GAP-001", "wibble — who knows")
        self._readme(
            [self._row("GAP-001", a, "open")],
            "- **1 gap files** — **0 open**, **0 partial**, **0 resolved**.\n"
            "- **0 epics** (🏔️) among them.",
        )
        errors = check_stale_counts.check_gap_status_consistency(self.tmpdir)
        self.assertTrue(any("unrecognised Status" in e for e in errors))

    def test_normalize_status_variants(self):
        for raw, expected in [
            ("open — CONFIRMED", "open"),
            ("open (overstated)", "open"),
            ("✅ fixed", "resolved"),
            ("✅ already done", "resolved"),
            ("RESOLVED — fixed in commit d06a566", "resolved"),
            ("resolved (PR #268)", "resolved"),
            ("partial (PR #275; guest row moved to #272)", "partial"),
        ]:
            self.assertEqual(
                check_stale_counts.normalize_status(raw), expected, raw
            )

    def test_real_readme_is_consistent(self):
        if not os.path.exists("docs/issues/README.md"):
            self.skipTest("No gap issue index available")
        errors = check_stale_counts.check_gap_status_consistency()
        self.assertEqual(errors, [], f"Status drift: {errors}")


class TestGapCodeReferences(unittest.TestCase):
    """Gate E, scan 4: symbol-anchored Code references bullets (#318)."""

    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()
        self.cwd = os.getcwd()
        os.makedirs(os.path.join(self.tmpdir, "game", "scripts", "util"))
        with open(
            os.path.join(self.tmpdir, "game/scripts/util/helpers.gd"), "w"
        ) as f:
            f.write("extends RefCounted\n\n\nstatic func distribute_rewards() -> void:\n\tpass\n")
        os.chdir(self.tmpdir)

    def tearDown(self):
        os.chdir(self.cwd)

    def _doc(self, body: str) -> None:
        os.makedirs("issues", exist_ok=True)
        with open("issues/GAP-001-thing.md", "w") as f:
            f.write("# GAP-001\n\n## Code references\n\n" + body + "\n")

    def test_valid_reference_passes(self):
        self._doc("- game/scripts/util/helpers.gd — `distribute_rewards()`")
        self.assertEqual(
            check_stale_counts.check_gap_code_references("issues"), []
        )

    def test_detects_symbol_that_moved_away(self):
        self._doc("- game/scripts/util/helpers.gd — `add_xp_to_member()`")
        errors = check_stale_counts.check_gap_code_references("issues")
        self.assertEqual(len(errors), 1)
        self.assertIn("does not define add_xp_to_member()", errors[0])

    def test_detects_missing_file(self):
        self._doc("- game/scripts/util/gone.gd — `distribute_rewards()`")
        errors = check_stale_counts.check_gap_code_references("issues")
        self.assertEqual(len(errors), 1)
        self.assertIn("does not exist", errors[0])

    def test_bullet_without_symbol_is_left_alone(self):
        """GAP-086 deliberately cites a pre-move path with no symbol."""
        self._doc("- game/scripts/autoload/helpers.gd:1 (pre-move location)")
        self.assertEqual(
            check_stale_counts.check_gap_code_references("issues"), []
        )

    def test_all_symbols_on_a_bullet_are_checked(self):
        self._doc(
            "- game/scripts/util/helpers.gd — `distribute_rewards()`, `nope()`"
        )
        errors = check_stale_counts.check_gap_code_references("issues")
        self.assertEqual(len(errors), 1)
        self.assertIn("nope()", errors[0])

    def test_only_the_code_references_section_is_scanned(self):
        os.makedirs("issues", exist_ok=True)
        with open("issues/GAP-001-thing.md", "w") as f:
            f.write(
                "# GAP-001\n\n## Code references\n\n"
                "- game/scripts/util/helpers.gd — `distribute_rewards()`\n\n"
                "## Verification\n\n"
                "- game/scripts/util/helpers.gd — `long_gone()`\n"
            )
        self.assertEqual(
            check_stale_counts.check_gap_code_references("issues"), []
        )

    def test_real_gap_docs_resolve(self):
        os.chdir(self.cwd)
        if not os.path.exists("docs/issues"):
            self.skipTest("No gap issue docs available")
        errors = check_stale_counts.check_gap_code_references()
        self.assertEqual(errors, [], f"Stale code references: {errors}")


class TestGapDesignReferences(unittest.TestCase):
    """Gate G, scan 2: the Design references section of the GAP docs (#403).

    #382/#383 hold the Code references bullets to live paths and ``symbol()``
    anchors. The Design references beside them were held to nothing and still
    carried the line anchors this milestone banned everywhere else — 37 of
    them across 28 docs, GAP-013's pointing 65 lines from the table it named.
    """

    def setUp(self):
        self.cwd = os.getcwd()
        self.tmpdir = tempfile.mkdtemp()
        os.makedirs(os.path.join(self.tmpdir, "docs/story"))
        os.makedirs(os.path.join(self.tmpdir, "issues"))
        with open(os.path.join(self.tmpdir, "docs/story/magic.md"), "w") as f:
            f.write(MAGIC_FIXTURE)
        os.chdir(self.tmpdir)

    def tearDown(self):
        os.chdir(self.cwd)
        shutil.rmtree(self.tmpdir, ignore_errors=True)

    def _errors(self, body: str, name: str = "GAP-001-thing.md") -> list:
        with open(os.path.join("issues", name), "w") as f:
            f.write(
                "# GAP-001\n\n## Summary\n\nBroke at magic.md:1537.\n\n"
                "## Design references\n\n" + body + "\n\n## Code references\n"
            )
        with patch.object(check_doc_citations, "MIN_GAP_DOCS", 1), patch.object(
            check_doc_citations, "MIN_GAP_BULLETS", 1
        ):
            return check_doc_citations.check_gap_design_references("issues")

    def test_a_heading_reference_resolves(self):
        self.assertEqual(
            self._errors("- docs/story/magic.md § Status Effect Reference"), []
        )

    def test_a_line_anchor_is_rejected(self):
        errors = self._errors("- docs/story/magic.md:1537")
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("banned line-anchored citation", errors[0])
        self.assertIn("docs/story/magic.md:1537", errors[0])

    def test_a_bare_line_anchor_is_rejected_too(self):
        errors = self._errors("- magic.md:1537 (status table)")
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("banned line-anchored citation", errors[0])

    def test_the_dated_prose_around_the_section_is_left_alone(self):
        """The Summary's ``magic.md:1537`` is a 2026-06-27 snapshot."""
        self.assertEqual(
            self._errors("- docs/story/magic.md § Spell Count Summary"), []
        )

    def test_a_heading_that_moved_is_reported(self):
        errors = self._errors("- docs/story/magic.md § Status Effects Table")
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    def test_a_narrowing_term_is_checked(self):
        errors = self._errors(
            "- docs/story/magic.md § Status Effect Reference > 'Petrify'"
        )
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("does not appear under", errors[0])

    def test_a_bullet_naming_a_missing_document_is_reported(self):
        errors = self._errors("- docs/story/gone.md (the whole thing)")
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("not a file in this repo", errors[0])

    def test_the_reported_line_points_into_the_doc_not_the_excerpt(self):
        errors = self._errors("- docs/story/magic.md § Ghost Section")
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("GAP-001-thing.md:9:", errors[0])

    def test_an_empty_scan_fails_its_floor(self):
        """Zero bullets read is not the same as zero bullets wrong."""
        errors = check_doc_citations.check_gap_design_references("issues")
        self.assertTrue(errors, "a scan that read nothing must say so")
        self.assertIn("read only 0", errors[0])

    def test_the_counts_come_from_the_glob(self):
        """Sever the walk and the floors must catch it.

        The scan's own numbers are what separates "nothing wrong" from
        "nothing read", so they have to be measured rather than assumed: with
        ``glob`` returning nothing, both counts collapse to zero and both
        floors fire.
        """
        self._errors("- docs/story/magic.md § Status Effect Reference")
        tally: dict = {}
        with patch("check_doc_citations.glob.glob", return_value=[]):
            errors = check_doc_citations.check_gap_design_references(
                "issues", tally=tally
            )
        self.assertEqual(tally, {"gap_docs": 0, "gap_bullets": 0})
        self.assertEqual(len(errors), 2, errors)

    def test_real_gap_docs_carry_no_line_anchors(self):
        os.chdir(self.cwd)
        if not os.path.exists("docs/issues"):
            self.skipTest("No gap issue docs available")
        tally: dict = {}
        errors = check_doc_citations.check_gap_design_references(tally=tally)
        self.assertEqual(errors, [], f"Stale design references: {errors}")
        self.assertGreater(tally["gap_docs"], 50)
        self.assertGreater(tally["gap_bullets"], 90)


class TestGapCodeReferencePaths(unittest.TestCase):
    """Gate E, scan 4: path and line-anchor rules on EVERY bullet (#318).

    The symbol rule only ever covered a handful of bullets; the rest named
    paths and line numbers that nothing measured, which is how GAP-036 came to
    cite an evaluator that had moved to another file.
    """

    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()
        self.cwd = os.getcwd()
        os.makedirs(os.path.join(self.tmpdir, "game/scripts/util"))
        os.makedirs(os.path.join(self.tmpdir, "game/data/crafting"))
        os.makedirs(os.path.join(self.tmpdir, "game/scenes/maps/towns"))
        for path in (
            "game/scripts/util/party_roster.gd",
            "game/scripts/util/party_vitals.gd",
            "game/data/crafting/devices.json",
            "game/data/crafting/recipes.json",
            "game/scenes/maps/towns/roothollow.tscn",
        ):
            with open(os.path.join(self.tmpdir, path), "w") as f:
                f.write("stub\n")
        os.chdir(self.tmpdir)

    def tearDown(self):
        os.chdir(self.cwd)

    def _errors(self, body: str) -> list:
        os.makedirs("issues", exist_ok=True)
        with open("issues/GAP-001-thing.md", "w") as f:
            f.write("# GAP-001\n\n## Code references\n\n" + body + "\n")
        return check_stale_counts.check_gap_code_references("issues")

    def test_path_only_bullet_is_verified_not_skipped(self):
        self.assertEqual(self._errors("- game/scripts/util/party_roster.gd"), [])
        errors = self._errors("- game/scripts/util/party_gone.gd")
        self.assertEqual(len(errors), 1)
        self.assertIn("party_gone.gd does not exist", errors[0])

    def test_line_anchor_is_rejected(self):
        errors = self._errors("- game/scripts/util/party_roster.gd:81-148")
        self.assertEqual(len(errors), 1)
        self.assertIn("line anchor", errors[0])

    def test_line_anchor_is_rejected_even_beside_a_valid_symbol(self):
        with open("game/scripts/util/party_roster.gd", "w") as f:
            f.write("func add_member() -> void:\n\tpass\n")
        errors = self._errors(
            "- game/scripts/util/party_roster.gd:81 — `add_member()`"
        )
        self.assertEqual(len(errors), 1)
        self.assertIn("line anchor", errors[0])

    def test_historical_bullets_are_exempt_from_both_rules(self):
        """GAP-046 and GAP-086 cite paths the fix deliberately removed."""
        self.assertEqual(
            self._errors(
                "- game/scripts/autoload/party_roster.gd:1 "
                "(pre-move location; now game/scripts/util/party_roster.gd)"
            ),
            [],
        )
        self.assertEqual(
            self._errors("- game/data/dialogue/dupe.json (historical — deleted)"),
            [],
        )

    def test_directory_bullets_are_verified(self):
        self.assertEqual(
            self._errors("- game/scenes/maps/towns/ (three built)"), []
        )
        errors = self._errors("- game/scenes/maps/cities/ (none built)")
        self.assertEqual(len(errors), 1)
        self.assertIn("does not exist", errors[0])

    def test_glob_bullets_must_match_something(self):
        self.assertEqual(self._errors("- game/scenes/maps/towns/*"), [])
        errors = self._errors("- game/scenes/maps/dungeons/*")
        self.assertEqual(len(errors), 1)
        self.assertIn("matches nothing", errors[0])

    def test_brace_shorthand_checks_every_member(self):
        self.assertEqual(
            self._errors("- game/scripts/util/party_{roster,vitals}.gd"), []
        )
        errors = self._errors("- game/scripts/util/party_{roster,ghost}.gd")
        self.assertEqual(len(errors), 1)
        self.assertIn("party_ghost.gd does not exist", errors[0])

    def test_alternation_shorthand_checks_every_member(self):
        self.assertEqual(
            self._errors("- game/data/crafting/devices.json|recipes.json"), []
        )
        errors = self._errors("- game/data/crafting/devices.json|missing.json")
        self.assertEqual(len(errors), 1)
        self.assertIn("crafting/missing.json does not exist", errors[0])

    def test_several_paths_on_one_bullet_are_all_checked(self):
        errors = self._errors(
            "- game/scripts/util/party_roster.gd, game/scripts/util/nope.gd"
        )
        self.assertEqual(len(errors), 1)
        self.assertIn("nope.gd", errors[0])

    def test_trailing_prose_is_not_mistaken_for_a_path(self):
        self.assertEqual(
            self._errors(
                "- game/scripts/util/party_roster.gd "
                "(no milestone/spike application)"
            ),
            [],
        )

    def test_bullet_with_no_path_at_all_is_ignored(self):
        self.assertEqual(self._errors("- (none — no post-game scenes)"), [])

    def test_real_gap_docs_carry_no_line_anchors(self):
        os.chdir(self.cwd)
        if not os.path.exists("docs/issues"):
            self.skipTest("No gap issue docs available")
        errors = check_stale_counts.check_gap_code_references()
        self.assertEqual(errors, [], f"Stale code references: {errors}")


class TestGapMeasuredTables(unittest.TestCase):
    """Gate E, scan 5: the 'current' column of GAP measured tables (#319)."""

    HEADER = (
        "| File | baseline | current (2026-08-12) |\n"
        "|------|----------|----------------------|\n"
    )

    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()
        self.cwd = os.getcwd()
        os.makedirs(os.path.join(self.tmpdir, "game", "scripts"))
        with open(os.path.join(self.tmpdir, "game/scripts/big.gd"), "w") as f:
            f.write("extends Node\n" * 4)
        os.chdir(self.tmpdir)

    def tearDown(self):
        os.chdir(self.cwd)

    def _doc(self, body: str) -> None:
        os.makedirs("issues", exist_ok=True)
        with open("issues/GAP-087-sizes.md", "w") as f:
            f.write("# GAP-087\n\n## Measured line counts\n\n" + body + "\n")

    def test_matching_count_passes(self):
        self._doc(self.HEADER + "| `game/scripts/big.gd` | 9 | 4 |")
        self.assertEqual(
            check_stale_counts.check_gap_measured_tables("issues"), []
        )

    def test_detects_a_count_that_drifted(self):
        self._doc(self.HEADER + "| `game/scripts/big.gd` | 9 | 5 |")
        errors = check_stale_counts.check_gap_measured_tables("issues")
        self.assertEqual(len(errors), 1)
        self.assertIn("claims 5 lines", errors[0])
        self.assertIn("actual 4", errors[0])

    def test_detects_a_file_that_moved_away(self):
        self._doc(self.HEADER + "| `game/scripts/gone.gd` | 9 | 4 |")
        errors = check_stale_counts.check_gap_measured_tables("issues")
        self.assertEqual(len(errors), 1)
        self.assertIn("does not exist", errors[0])

    def test_thousands_separators_are_understood(self):
        with open("game/scripts/big.gd", "w") as f:
            f.write("extends Node\n" * 1200)
        self._doc(self.HEADER + "| `game/scripts/big.gd` | 9 | 1,200 |")
        self.assertEqual(
            check_stale_counts.check_gap_measured_tables("issues"), []
        )

    def test_unmeasured_rows_are_skipped(self):
        self._doc(self.HEADER + "| `game/scripts/gone.gd` | 9 | — |")
        self.assertEqual(
            check_stale_counts.check_gap_measured_tables("issues"), []
        )

    def test_non_numeric_cell_is_reported_not_ignored(self):
        self._doc(self.HEADER + "| `game/scripts/big.gd` | 9 | about 4 |")
        errors = check_stale_counts.check_gap_measured_tables("issues")
        self.assertEqual(len(errors), 1)
        self.assertIn("not a line count", errors[0])

    def test_tables_without_a_current_column_are_ignored(self):
        self._doc(
            "| File | baseline | after decomposition |\n"
            "|------|----------|---------------------|\n"
            "| `game/scripts/big.gd` | 9 | 999 |"
        )
        self.assertEqual(
            check_stale_counts.check_gap_measured_tables("issues"), []
        )

    def test_the_field_table_at_the_top_of_a_gap_doc_is_ignored(self):
        """Two-column Field/Value tables must not be read as measurements."""
        self._doc(
            "| Field | Value |\n|-------|-------|\n"
            "| **ID** | GAP-087 |\n"
            + self.HEADER
            + "| `game/scripts/big.gd` | 9 | 4 |"
        )
        self.assertEqual(
            check_stale_counts.check_gap_measured_tables("issues"), []
        )

    def test_real_gap_docs_are_measured_correctly(self):
        os.chdir(self.cwd)
        if not os.path.exists("docs/issues"):
            self.skipTest("No gap issue docs available")
        errors = check_stale_counts.check_gap_measured_tables()
        self.assertEqual(errors, [], f"Stale measured counts: {errors}")


if __name__ == "__main__":
    unittest.main()
