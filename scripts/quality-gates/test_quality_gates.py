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
NUMBERED_FIXTURE = """# Technical Architecture

## 1. Project Setup

### 1.1 Directory Structure

Where each kind of file lives.

### 1.2 Naming Conventions

snake_case files, PascalCase classes.

### 1.2a Script Size Budget

Aim 400 lines, hard maximum 600.

## 2. Data Formats

### 2.1 Enemy Data

### 2.3 Equipment Data
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

        wrapped = check_doc_citations.citation_tail(
            " Physical Attack\n## Resolution).\n", markdown=False
        )
        hit = check_doc_citations.match_heading(
            index, "docs/story/magic.md", wrapped
        )
        self.assertEqual(hit[2], "Physical Attack Resolution")

        self._write(
            "game/scripts/a.gd",
            "## Base damage (magic.md § Physical Attack\n"
            "## Resolution > 'row modifier').\n",
        )
        self.assertEqual(self._errors(), [])

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
        with patch.dict(
            check_doc_citations.KNOWN_UNRESOLVED, known, clear=True
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
