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
## adjective in game/scripts/combat/status_effects.gd, the canon line in
## docs/story/script/battle-dialogue.md § Status Effect Notifications, and the
## shipped game/data/dialogue/battle_status_effect_notifications.json. That
## JSON is authored by hand, not generated from either of the other two — see
## tools/README.md for why the generator was retired. This test pins the JSON
## against the engine adjective and nothing else; it never opens the markdown,
## so only the JSON-versus-engine half of the drift is covered here (#301).
func test_shipped_notification_matches_the_engine_adjective() -> void:
	var shipped_lines: Array[String] = _shipped_notification_lines()
	if shipped_lines.is_empty():
		fail_test("battle_status_effect_notifications.json is missing or has no entries")
		return
	var shipped: String = ""
	for line: String in shipped_lines:
		if line.contains("can't move"):
			shipped = line
	if shipped.is_empty():
		fail_test('no "can\'t move" notification in battle_status_effect_notifications.json')
		return
	assert_eq(
		shipped,
		"[Character] is %s and can't move!" % SE.display_adjective("paralysis"),
		"shipped notification must read back exactly as battle_manager builds it"
	)


## Every line the shipped notification data carries, flattened.
func _shipped_notification_lines() -> Array[String]:
	var data: Dictionary = DataManager.load_dialogue("battle_status_effect_notifications")
	var lines: Array[String] = []
	for entry: Variant in data.get("entries", []):
		for line: Variant in (entry as Dictionary).get("lines", []):
			lines.append(String(line))
	return lines


## The other half of the same drift: the announcement the engine makes when a
## status LANDS. battle_manager speaks these through the registry, so each one
## must exist verbatim in the shipped data (and therefore, via Gate J, in
## battle-dialogue.md) with the "[Character]" placeholder the script uses (#299).
##
## Driven from RULES — every status the game can inflict — rather than from the
## notice table. Walking the notice table would only prove the entries that
## happen to exist are worded right; drop one and that status lands on a party
## member in total silence with every assertion still green, which is the very
## #299 symptom this pins. Empty the table entirely and the walk is vacuous.
func test_every_status_the_registry_can_inflict_announces_a_shipped_line() -> void:
	var shipped_lines: Array[String] = _shipped_notification_lines()
	if shipped_lines.is_empty():
		fail_test("battle_status_effect_notifications.json is missing or has no entries")
		return
	for status: String in SE.RULES:
		var line: String = SE.application_notice(status, "[Character]")
		assert_false(line.is_empty(), "%s can land on a member with nothing said" % status)
		assert_true(
			line in shipped_lines,
			'%s announces "%s", which is not a shipped notification' % [status, line]
		)


func test_a_status_with_no_canonical_line_announces_nothing() -> void:
	assert_eq(SE.application_notice("berserk", "Sable"), "", "unregistered statuses stay silent")
	assert_eq(SE.application_notice("paralysis", "Sable"), "Sable is Paralyzed!")


## Which status answers "why can this member not act" must be the registry's
## decision, not the order the statuses happened to land in: a gauge-frozen
## status outranks Paralysis, because the caller passes a frozen member over
## untouched but spends a paralyzed one's gauge (#300).
func test_blocking_status_prefers_a_frozen_gauge_whichever_landed_first() -> void:
	assert_eq(SE.blocking_status([{"name": "paralysis"}, {"name": "sleep"}]), "sleep")
	assert_eq(SE.blocking_status([{"name": "sleep"}, {"name": "paralysis"}]), "sleep")
	assert_eq(SE.blocking_status([{"name": "paralysis"}, {"name": "petrify"}]), "petrify")
	assert_eq(SE.blocking_status([{"name": "petrify"}, {"name": "paralysis"}]), "petrify")


func test_blocking_status_names_paralysis_when_it_is_the_only_denial() -> void:
	assert_eq(SE.blocking_status([{"name": "poison"}, {"name": "paralysis"}]), "paralysis")


func test_blocking_status_is_empty_when_the_member_can_still_act() -> void:
	assert_eq(SE.blocking_status([]), "", "no statuses, no denial")
	assert_eq(
		SE.blocking_status([{"name": "poison"}, {"name": "slow"}]),
		"",
		"Slow throttles the gauge but never denies the turn"
	)


## Petrify is the only status that keeps nothing: combat-formulas.md
## § Status Effect ATB Interactions gives its gauge as "Frozen (0)" and its cure
## as "recovery starts fresh", where Sleep resumes from the value it froze at.
func test_only_petrify_holds_the_gauge_at_zero() -> void:
	assert_true(SE.zeroes_gauge("petrify"))
	assert_false(SE.zeroes_gauge("sleep"), "Sleep keeps the value it froze at")
	assert_false(SE.zeroes_gauge("paralysis"), "Paralysis never freezes at all")
	assert_true(SE.atb_state([{"name": "petrify"}])["zeroed"])
	assert_false(SE.atb_state([{"name": "sleep"}])["zeroed"])
	assert_false(SE.atb_state([])["zeroed"])


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
