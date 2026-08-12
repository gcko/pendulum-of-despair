#!/usr/bin/env python3
"""Tests for Quality Gate K: American-English spelling.

Gate K is a scan, and a scan that has stopped detecting reports "nothing
found", which reads exactly like "nothing wrong" (#365). These tests run
under Gate I's discovery, so a gate that has stopped detecting fails at
pre-push rather than passing silently.

Two properties get more attention here than the rest, because both have
already failed in production in this repo:

1. **The families detect inflections nobody enumerated.** `catalogue` and
   `catalogued` were once listed as whole words, which could not match
   *cataloguing*, and three shipped player-facing strings hid behind that.
   So the family tests assert on inflected forms, not on the citation form.
2. **The walk descends.** #400 recorded that `game/scripts/*.gd` matches
   zero files because all 89 live one level down. A test therefore plants a
   violation two directories deep, and another asserts the real corpus is
   large enough that a walk which stopped descending would breach the floor
   rather than report clean.

Run: python3 -m unittest discover -s scripts/quality-gates -p 'test_*.py'
Or:  python3 scripts/quality-gates/test_spelling.py
"""
import os
import re
import shutil
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import check_spelling  # noqa: E402

REPO_ROOT = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..")
)

# The phrase the gate's success line and docs/story/README.md both carry.
# Kept in one place so the doc-claim test and the gate cannot drift apart.
PINNED_CLAIM_RE = re.compile(r"(\d+) occurrences are pinned")


class SpellingFixture(unittest.TestCase):
    """A miniature six-tree corpus, with floors low enough to scan it."""

    def setUp(self) -> None:
        self.tmpdir = tempfile.mkdtemp()
        self.trees = tuple(
            os.path.join(self.tmpdir, f"tree{i}").replace(os.sep, "/")
            for i in range(1, 7)
        )
        for tree in self.trees:
            os.makedirs(tree)
        # Every tree gets a clean file so the per-tree floor is satisfied by
        # default and a test only has to add the thing under test.
        for i, tree in enumerate(self.trees):
            self.write(f"tree{i + 1}/filler_a.md", "Nothing to see.")
            self.write(f"tree{i + 1}/filler_b.md", "Nothing here either.")

    def tearDown(self) -> None:
        shutil.rmtree(self.tmpdir, ignore_errors=True)

    def write(self, rel: str, text: str) -> str:
        path = os.path.join(self.tmpdir, rel)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as handle:
            handle.write(text)
        return path.replace(os.sep, "/")

    def run_check(self, pins=None, **kwargs) -> list[str]:
        options = {
            "trees": self.trees,
            "known_violations": {} if pins is None else pins,
            "min_files": 1,
            "min_chars": 1,
            "min_files_per_tree": 1,
        }
        options.update(kwargs)
        return check_spelling.check_spelling(**options)

    def assertClean(self, text: str) -> None:
        self.write("tree1/subject.md", text)
        self.assertEqual(self.run_check(), [], f"{text!r} should be clean")

    def assertFlagged(self, text: str, word: str, family: str) -> None:
        self.write("tree1/subject.md", text)
        errors = self.run_check()
        self.assertEqual(len(errors), 1, f"{text!r} -> {errors}")
        self.assertIn(repr(word), errors[0])
        self.assertIn(family, errors[0])


class TestOurFamily(SpellingFixture):
    """Stem + `ou` + an r-suffix, minus the words English spells that way."""

    def test_behaviour_is_flagged(self) -> None:
        self.assertFlagged("crossfade behaviour is unchanged", "behaviour", "-our")

    def test_the_family_catches_words_it_was_never_told_about(self) -> None:
        for word in (
            "colour",
            "colours",
            "coloured",
            "colourful",
            "behaviours",
            "honoured",
            "honours",
            "harbour",
            "flavour",
            "neighbouring",
            "rumours",
            "vapour",
            "endeavour",
            "splendour",
            "armour",
            "favourite",
            "odourless",
            "honourable",
        ):
            with self.subTest(word=word):
                self.write("tree1/subject.md", f"the {word} here")
                self.assertEqual(len(self.run_check()), 1, word)

    def test_correct_ou_words_are_not_flagged(self) -> None:
        self.assertClean(
            "four hours of your pouring, sour tours, flour, scouring, "
            "devoured contours, detours, velour, dour amour, paramour, "
            "troubadours, glamour, courage, journey, mourning, flourish, "
            "tournament, yours"
        )


class TestIseFamily(SpellingFixture):
    """The family #400 found missing entirely."""

    def test_organisation_is_flagged(self) -> None:
        self.assertFlagged(
            "the organisation of the file", "organisation", "-ise"
        )

    def test_the_isation_and_ise_families_are_both_covered(self) -> None:
        for word in (
            "organise",
            "organised",
            "organising",
            "organisation",
            "organisations",
            "organisational",
            "optimise",
            "optimises",
            "normalised",
            "specialising",
            "prioritise",
            "summarised",
            "utilisation",
            "minimise",
            "maximised",
            "criticised",
            "apologise",
            "standardisation",
            "visualise",
            "emphasised",
            "realise",
            "recognises",
            "synthesised",
            "generalisation",
            "materialising",
        ):
            with self.subTest(word=word):
                self.write("tree1/subject.md", f"we {word} it")
                self.assertEqual(len(self.run_check()), 1, word)

    def test_correct_ise_words_are_not_flagged(self) -> None:
        self.assertClean(
            "rise rises rising sunrise raise raises raised raising "
            "otherwise likewise clockwise streetwise wise "
            "precise concise promise promised promises promising "
            "noise poise praise appraising bruised cruise "
            "surprise surprised surprises surprising "
            "expertise exercise exercises exercised exercising "
            "improvise improvised compromise compromised "
            "disguise disguised guise premise paradise irises "
            "advise revised supervise devise despise arise demise "
            "franchise merchandise enterprise treatise tortoise "
            "turquoise malaise reraise televise advertising"
        )

    def test_words_where_is_is_not_a_suffix_are_not_flagged(self) -> None:
        self.assertClean("analysis paralysis emphasis basis crisis this his")

    def test_the_six_words_413_found_falsely_accused(self) -> None:
        """The regression, verbatim.

        The allow-list was expanded over suffixes while the pattern matched
        any prefix, so these six ordinary American words were reported as
        British spellings and the author was told to "write the American
        spelling" of a word already spelled correctly.
        """
        self.assertClean(
            "an imprecise estimate left us unsurprised by the unpromising "
            "and undisguised result; he stood with upraised hands rather "
            "than overpromise"
        )


class TestPrefixRule(SpellingFixture):
    """`ALLOWED_PREFIXES`: an allow-list lemma answers for its prefixed forms.

    English builds on the front as well as the back. Enumerating prefixed
    forms would repeat the `cataloguing` mistake at the other end of the
    word, so the prefix half is a rule — and a rule has to be shown both to
    admit correct words and to refuse British ones.
    """

    def test_prefixed_forms_of_allowed_lemmas_are_clean(self) -> None:
        for word in (
            "imprecise",
            "unsurprised",
            "unpromising",
            "upraised",
            "undisguised",
            "overpromise",
            "reappraised",
            "unadvised",
            "disenfranchised",
            "overexercising",
            "outpouring",
            "recontoured",
            "afterhours",
        ):
            with self.subTest(word=word):
                self.write("tree1/subject.md", f"it was {word} today")
                self.assertEqual(self.run_check(), [], word)

    def test_the_prefix_rule_cannot_launder_a_british_spelling(self) -> None:
        """The property that makes the rule safe, checked exhaustively.

        Stripping only ever removes a prefix and the remainder must still
        land in the allow-list, which holds no British form. So every
        British lemma stays flagged under every prefix — 28 prefixes over
        the lemmas below, plus the bare forms.
        """
        british = (
            "organise", "organisation", "realise", "recognise", "apologise",
            "optimise", "normalise", "specialise", "prioritise", "summarise",
            "utilise", "minimise", "maximise", "criticise", "standardise",
            "visualise", "emphasise", "synthesise", "materialise",
            "memorise", "categorise", "authorise", "customise", "finalise",
            "colour", "behaviour", "honour", "harbour", "flavour",
            "neighbour", "rumour", "vapour", "endeavour", "splendour",
            "armour", "favourite", "odourless", "honourable", "clamour",
            "saviour", "labour", "valour", "rigour", "humour", "parlour",
        )
        candidates = list(british) + [
            prefix + word
            for prefix in check_spelling.ALLOWED_PREFIXES
            for word in british
        ]
        self.assertGreater(
            len(candidates), 1_000, "corpus too small to mean much"
        )
        leaked = []
        for word in candidates:
            for family in check_spelling.FAMILIES:
                if family.pattern.fullmatch(word) and family.allowed(word):
                    leaked.append(word)
        self.assertEqual(
            leaked, [], "prefix rule laundered a British spelling"
        )

    def test_a_prefixed_british_spelling_is_still_reported(self) -> None:
        self.assertFlagged(
            "we deprioritise it", "deprioritise", "-ise"
        )

    def test_a_short_remainder_cannot_launder_a_word(self) -> None:
        """`MIN_STEM_AFTER_PREFIX` stops letters coinciding with a lemma."""
        self.assertFalse(
            check_spelling.allowed_with_prefixes(
                "coise", check_spelling.ALLOWED_ISE
            )
        )

    def test_the_failure_message_names_the_over_match_remedy(self) -> None:
        """A hit is not proof of a misspelling, so the message cannot say so.

        The old line read "write the American spelling", full stop. Against
        an over-matched correct word that instruction is wrong, and following
        it introduces the misspelling the gate exists to catch.
        """
        self.write("tree1/subject.md", "the organisation of the file")
        errors = self.run_check()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("If it is already correct American English", errors[0])
        self.assertIn("add its lemma", errors[0])
        self.assertIn("check_spelling.py", errors[0])


class TestGreyFamily(SpellingFixture):
    """The one documented exception, encoded no wider and no narrower."""

    def test_the_inflected_color_word_is_flagged(self) -> None:
        for word in (
            "greyed",
            "greying",
            "greyer",
            "greyest",
            "greyish",
            "greys",
            "greyscale",
            "Greyed",
            "GREYING",
        ):
            with self.subTest(word=word):
                self.write("tree1/subject.md", f"the sky {word} over")
                self.assertEqual(len(self.run_check()), 1, word)

    def test_the_documented_proper_nouns_survive(self) -> None:
        """docs/story/README.md § Writing Conventions carves out exactly this.

        *Grey Remnant* is a shipped Ley Crystal name in
        `game/data/ley_crystals.json`; a sweep that "fixed" it would rename
        an item the player can read.
        """
        self.assertClean(
            "The Grey rose over Greyveil, Greyvale and Greywood. "
            "Equip the Grey Remnant; the Grey Cleaver waits, and the "
            "Grey Keeper guards grey_residue, grey_march_001, "
            "grey_mite_caldera and grey_crawler. The stone was grey, "
            "a grey light, greywood planks, greyveil banners."
        )


class TestStemFamily(SpellingFixture):
    """Stems with an open suffix — the fix for the `cataloguing` miss."""

    def test_cataloguing_is_flagged(self) -> None:
        """The exact inflection a whole-word list could not see (#387)."""
        self.assertFlagged("The Index is cataloguing it", "cataloguing", "stem")

    def test_every_inflection_of_every_stem_is_caught(self) -> None:
        for word in (
            "catalogue",
            "catalogues",
            "catalogued",
            "cataloguing",
            "defence",
            "defences",
            "defenceless",
            "travelled",
            "travelling",
            "traveller",
            "cancelled",
            "cancelling",
            "labelled",
            "labelling",
            "levelled",
            "levelling",
            "mould",
            "moulding",
        ):
            with self.subTest(word=word):
                self.write("tree1/subject.md", f"the {word} thing")
                self.assertEqual(len(self.run_check()), 1, word)

    def test_the_leading_boundary_keeps_identifiers_out(self) -> None:
        """`\\b` is load-bearing: drop it and `levell` eats `NextLevelLabel`.

        The same boundary is why `command_cancelled` is not swept — `_` is a
        word character. That omission is deliberate: renaming a signal is an
        API change with call sites in other files, not a prose fix.
        """
        self.assertClean(
            "var NextLevelLabel = 1\nsignal command_cancelled\n"
            "level travel cancel label defend mold"
        )


class TestRecursion(SpellingFixture):
    """The walk must descend; #400 named this exact trap."""

    def test_a_violation_two_directories_down_is_found(self) -> None:
        self.write("tree1/ui/widgets/deep.gd", "## the colour of the bar")
        errors = self.run_check()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("tree1/ui/widgets/deep.gd", errors[0])

    def test_only_the_scanned_suffixes_are_read(self) -> None:
        self.write("tree1/notes.txt", "behaviour")
        self.write("tree1/data.json", '{"note": "behaviour"}')
        errors = self.run_check()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("tree1/data.json", errors[0])


class TestRatchet(SpellingFixture):
    """The pin fails at both ends, so the list can only shrink."""

    def test_a_pinned_violation_passes(self) -> None:
        self.write("tree1/subject.md", "greyed out\ngreyed again")
        pins = {f"{self.trees[0]}/subject.md": {"greyed": 2}}
        self.assertEqual(self.run_check(pins), [])

    def test_one_more_occurrence_than_pinned_fails(self) -> None:
        self.write("tree1/subject.md", "greyed out\ngreyed again\ngreyed once more")
        pins = {f"{self.trees[0]}/subject.md": {"greyed": 2}}
        errors = self.run_check(pins)
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("only 2 pinned", errors[0])

    def test_a_pin_that_is_no_longer_needed_fails(self) -> None:
        """A stale pin is a failure, not a shrug — that is the ratchet."""
        self.write("tree1/subject.md", "grayed out, all of it")
        pins = {f"{self.trees[0]}/subject.md": {"greyed": 2}}
        errors = self.run_check(pins)
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("outlived its reason", errors[0])
        self.assertIn("the file now holds 0", errors[0])

    def test_a_partially_fixed_pin_fails(self) -> None:
        self.write("tree1/subject.md", "greyed out\ngrayed again")
        pins = {f"{self.trees[0]}/subject.md": {"greyed": 2}}
        errors = self.run_check(pins)
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("the file now holds 1", errors[0])

    def test_a_pin_for_a_deleted_file_names_the_missing_file(self) -> None:
        pins = {f"{self.trees[0]}/gone.md": {"greyed": 1}}
        errors = self.run_check(pins)
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("no longer exists", errors[0])


class TestNonVacuity(SpellingFixture):
    """A scan that read nothing must say so, not report clean."""

    def test_a_scan_that_reads_zero_files_fails(self) -> None:
        empty = os.path.join(self.tmpdir, "empty").replace(os.sep, "/")
        os.makedirs(empty)
        errors = check_spelling.check_spelling(
            trees=(empty,),
            known_violations={},
            min_files=check_spelling.MIN_FILES,
            min_chars=check_spelling.MIN_CHARS,
            min_files_per_tree=check_spelling.MIN_FILES_PER_TREE,
        )
        self.assertTrue(errors)
        self.assertIn("scan read only 0 files", errors[0])
        self.assertIn("repair the walk rather than lowering the floor", errors[0])

    def test_a_tree_that_drops_out_fails_even_when_the_others_are_fat(
        self,
    ) -> None:
        """Per-tree floors: one empty tree cannot hide behind five full ones."""
        empty = os.path.join(self.tmpdir, "tree7").replace(os.sep, "/")
        os.makedirs(empty)
        errors = self.run_check(trees=self.trees + (empty,))
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("tree7", errors[0])

    def test_the_character_floor_fires_on_an_all_but_empty_corpus(
        self,
    ) -> None:
        errors = self.run_check(min_chars=10_000)
        self.assertTrue(errors)
        self.assertIn("characters of scanned text", errors[0])

    def test_vacuity_suppresses_the_spelling_report(self) -> None:
        """On a degenerate scan the findings would be noise over nothing."""
        self.write("tree1/subject.md", "behaviour")
        errors = self.run_check(min_files=10_000)
        self.assertTrue(errors)
        self.assertNotIn("behaviour", " ".join(errors))


class TestLiveRepo(unittest.TestCase):
    """The shipped configuration, against the real six trees."""

    def setUp(self) -> None:
        self.cwd = os.getcwd()
        os.chdir(REPO_ROOT)

    def tearDown(self) -> None:
        os.chdir(self.cwd)

    def test_the_repo_is_clean_under_the_shipped_pins(self) -> None:
        self.assertEqual(check_spelling.check_spelling(), [])

    def test_the_scan_reads_a_real_corpus(self) -> None:
        """The floors have headroom, so a clean result means something."""
        paths = check_spelling.iter_scanned_files()
        chars = 0
        for path in paths:
            with open(path, encoding="utf-8", errors="replace") as handle:
                chars += len(handle.read())
        self.assertGreater(len(paths), check_spelling.MIN_FILES)
        self.assertGreater(chars, check_spelling.MIN_CHARS)
        for tree in check_spelling.TREES:
            with self.subTest(tree=tree):
                count = sum(1 for p in paths if p.startswith(tree + "/"))
                self.assertGreaterEqual(
                    count, check_spelling.MIN_FILES_PER_TREE
                )

    def test_a_walk_that_stopped_descending_would_breach_the_floor(
        self,
    ) -> None:
        """The floor is what makes a broken recursion fail rather than pass.

        `game/scripts` holds 89 `.gd` files and not one of them is at the top
        level, so a scan that listed only each tree's own directory would
        read a fraction of the corpus. MIN_FILES sits above that fraction on
        purpose (#400).
        """
        paths = check_spelling.iter_scanned_files()
        top_level = [
            p
            for p in paths
            if any(
                p.count("/") == tree.count("/") + 1
                for tree in check_spelling.TREES
                if p.startswith(tree + "/")
            )
        ]
        self.assertLess(len(top_level), check_spelling.MIN_FILES)
        self.assertGreater(len(paths), len(top_level))

    def test_the_readme_is_excluded_and_would_otherwise_be_dirty(
        self,
    ) -> None:
        """The exclusion earns its keep: § Writing Conventions is full of
        the very words it forbids, so it must be out of scope, and it must be
        out of scope *because* of that, not by accident."""
        self.assertNotIn(
            "docs/story/README.md", check_spelling.iter_scanned_files()
        )
        with open("docs/story/README.md", encoding="utf-8") as handle:
            text = handle.read()
        self.assertTrue(
            check_spelling.scan_text(text, "docs/story/README.md"),
            "README no longer quotes any British spelling — if § Writing "
            "Conventions stopped naming them, drop the exclusion too",
        )

    def test_every_pin_names_a_real_file_that_still_holds_it(self) -> None:
        for path, words in check_spelling.KNOWN_VIOLATIONS.items():
            with self.subTest(path=path):
                self.assertTrue(os.path.isfile(path), path)
                with open(path, encoding="utf-8", errors="replace") as handle:
                    hits = check_spelling.scan_text(handle.read(), path)
                for word, count in words.items():
                    seen = sum(1 for h in hits if h.word == word)
                    self.assertEqual(seen, count, f"{path}: {word}")

    def test_the_readme_states_the_current_pin_count(self) -> None:
        """Prose that counts the pins must move when the ratchet moves."""
        pinned = sum(
            sum(v.values())
            for v in check_spelling.KNOWN_VIOLATIONS.values()
        )
        with open("docs/story/README.md", encoding="utf-8") as handle:
            text = handle.read()
        claims = PINNED_CLAIM_RE.findall(text)
        self.assertEqual(
            len(claims), 1, "README should state the pin count exactly once"
        )
        self.assertEqual(
            int(claims[0]),
            pinned,
            f"README claims {claims[0]} pinned occurrences; the gate pins "
            f"{pinned} — update the sentence",
        )

    def test_the_gate_letter_registry_and_the_hook_agree(self) -> None:
        """A letter names one gate for the life of the repo (.husky/pre-push)."""
        with open(".husky/pre-push", encoding="utf-8") as handle:
            hook = handle.read()
        self.assertIn("#   K  American-English spelling", hook)
        self.assertIn("check_spelling.py", hook)
        self.assertIn("QUALITY GATE K", hook)
        self.assertTrue(
            check_spelling.__doc__.startswith(
                "Quality Gate K: American-English spelling."
            )
        )


if __name__ == "__main__":
    unittest.main()
