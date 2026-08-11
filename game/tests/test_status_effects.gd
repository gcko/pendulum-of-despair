extends GutTest
## Tests for StatusEffects registry (GAP-003). Values trace to magic.md /
## combat-formulas.md.

const SE := preload("res://scripts/combat/status_effects.gd")


func test_known_statuses() -> void:
	for s: String in [
		"poison", "sleep", "petrify", "slow", "despair", "silence", "confusion", "blind"
	]:
		assert_true(SE.is_known(s), "%s should be a known status" % s)
	assert_false(SE.is_known("nonexistent_status"), "unknown status rejected")
	# Stop is deliberately deferred (realtime on enemies not supported in 2b).
	assert_false(SE.is_known("stop"), "stop is deferred in Bundle 2b")


func test_atb_frozen_statuses() -> void:
	assert_eq(SE.atb_effect("sleep"), "frozen")
	assert_eq(SE.atb_effect("petrify"), "frozen")
	assert_eq(SE.atb_effect("poison"), "none")


func test_display_adjective_reads_back_as_an_announcement() -> void:
	# battle_manager builds "%s is %s and can't move!" from this, so the value
	# has to be the adjective, never the raw status name (#260 review).
	assert_eq(SE.display_adjective("paralysis"), "paralyzed")
	assert_eq(SE.display_adjective("sleep"), "asleep")
	assert_eq(SE.display_adjective("petrify"), "petrified")
	assert_eq(
		SE.display_adjective("nonsense"),
		"nonsense",
		"an unlisted status reads back as itself rather than as another status"
	)


## The paralysis announcement exists in three places that must agree: the
## adjective in status_effects.gd, the canon line in battle-dialogue.md
## § Status Effect Notifications, and the shipped
## game/data/dialogue/battle_status_effect_notifications.json generated from
## it by tools/dialogue_parser.py. Nothing else compares the JSON against the
## engine, so a spelling drift in either one was previously silent (#301).
func test_shipped_notification_matches_the_engine_adjective() -> void:
	var data: Dictionary = DataManager.load_dialogue("battle_status_effect_notifications")
	var entries: Array = data.get("entries", [])
	if entries.is_empty():
		fail_test("battle_status_effect_notifications.json is missing or has no entries")
		return
	var shipped: String = ""
	for entry: Variant in entries:
		for line: Variant in (entry as Dictionary).get("lines", []):
			if String(line).contains("can't move"):
				shipped = String(line)
	if shipped.is_empty():
		fail_test('no "can\'t move" notification in battle_status_effect_notifications.json')
		return
	assert_eq(
		shipped,
		"[Character] is %s and can't move!" % SE.display_adjective("paralysis"),
		"shipped notification must read back exactly as battle_manager builds it"
	)


func test_atb_mod_statuses() -> void:
	assert_eq(SE.atb_effect("slow"), "mod")
	assert_almost_eq(SE.atb_mult("slow"), 0.5, 0.001)  # combat-formulas.md § Fill Rate Modifiers
	assert_eq(SE.atb_effect("despair"), "mod")
	assert_almost_eq(SE.atb_mult("despair"), 0.75, 0.001)  # combat-formulas.md § Fill Rate Modifiers
	assert_almost_eq(SE.atb_mult("poison"), 1.0, 0.001, "non-mod statuses default 1.0")


func test_tick_percentages() -> void:
	# Poison loses 8% max HP/turn (magic.md § Status Effect Reference > 'Poison').
	assert_almost_eq(SE.tick_pct("poison"), 0.08, 0.001)
	# Burn loses 5% max HP/turn (magic.md § Status Effect Reference > 'Burn').
	assert_almost_eq(SE.tick_pct("burn"), 0.05, 0.001)
	assert_almost_eq(SE.tick_pct("sleep"), 0.0, 0.001)


func test_wake_on_damage() -> void:
	assert_true(SE.wakes_on_damage("sleep"))
	assert_true(SE.wakes_on_damage("confusion"))
	assert_false(SE.wakes_on_damage("poison"))
	assert_false(SE.wakes_on_damage("slow"))


func test_durations() -> void:
	assert_eq(SE.default_duration("poison"), SE.UNTIL_CURED, "poison until cured")
	assert_eq(SE.default_duration("sleep"), SE.UNTIL_CURED, "sleep until cured")
	assert_eq(SE.default_duration("petrify"), SE.UNTIL_CURED)
	assert_eq(SE.default_duration("slow"), 5)  # combat-formulas.md § Status Effect ATB Interactions
	assert_eq(SE.default_duration("despair"), 4)
	assert_eq(SE.default_duration("silence"), 4)
	assert_eq(SE.default_duration("confusion"), 3)
	assert_eq(SE.default_duration("blind"), 4)


func test_resolve_duration_prefers_explicit() -> void:
	# A synthetic explicit value overrides the canonical default.
	assert_eq(SE.resolve_duration("despair", 99), 99, "explicit wins")
	# Null falls back to the canonical default.
	assert_eq(SE.resolve_duration("slow", null), 5)
	assert_eq(SE.resolve_duration("silence", null), 4, "canonical Silence")
	assert_eq(SE.resolve_duration("despair", null), 4, "canonical Despair")
	assert_eq(SE.resolve_duration("poison", null), SE.UNTIL_CURED)


func test_atb_state_frozen() -> void:
	var st: Dictionary = SE.atb_state([{"name": "sleep"}])
	assert_true(st["frozen"], "Sleep freezes the ATB gauge")
	assert_eq((st["mods"] as Array).size(), 0, "frozen status carries no fill mod")


func test_atb_state_petrify_frozen() -> void:
	assert_true(SE.atb_state([{"name": "petrify"}])["frozen"])


func test_atb_state_mods_stack_multiplicatively() -> void:
	var st: Dictionary = SE.atb_state([{"name": "slow"}, {"name": "despair"}])
	assert_false(st["frozen"], "Slow/Despair do not freeze")
	var product: float = 1.0
	for m: float in st["mods"]:
		product *= m
	assert_almost_eq(product, 0.375, 0.001, "Slow 0.5 x Despair 0.75")


func test_atb_state_empty_is_clear() -> void:
	var st: Dictionary = SE.atb_state([])
	assert_false(st["frozen"])
	assert_eq((st["mods"] as Array).size(), 0)


func test_atb_state_ignores_non_atb_statuses() -> void:
	var st: Dictionary = SE.atb_state([{"name": "poison"}, {"name": "blind"}])
	assert_false(st["frozen"])
	assert_eq((st["mods"] as Array).size(), 0)
