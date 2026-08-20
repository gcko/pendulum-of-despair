extends GutTest
## Loot-shape guards for the shipped enemy tables (issues #309, #342).
##
## Two halves that must not drift apart: the DATA half pins that every record
## ships a steal/drop shape the engine can read, and the ENGINE half pins that
## Enemy.roll_steal()/roll_drop() actually survive every shipped record. Both
## assert a floor on records INSPECTED, so a rotted act list cannot report
## "clean" and "never ran" identically.

const ACT_TABLES: Array[String] = ["act_i", "act_ii", "act_iii", "interlude", "optional"]
## The act tables ship 209 enemies; a scan that sees far fewer has lost its reach.
const MIN_ENEMIES: int = 200


func before_each() -> void:
	DataManager.clear_cache()


func after_each() -> void:
	DataManager.clear_cache()


## The canon steal shapes, per the enemy-data spec's Steal Mapping Rules:
## a whole-record `null` (Rule 3), or an object carrying BOTH tier keys, each
## of which is `null` (Rule 4) or a `{item_id, rate}` pair (Rules 1/2/5/6).
## `{}` is none of these — it is what compact_patrol/compact_scout shipped
## until #309, and it reads at runtime as "carries nothing" without ever
## saying so. Anything the shapes below do not cover makes roll_steal()
## silently unstealable, so the shape is guarded rather than trusted.
func _steal_shape_error(record: Dictionary) -> String:
	var eid: String = str(record.get("id", "?"))
	if not record.has("steal"):
		return "%s has no steal field" % eid
	var steal: Variant = record.get("steal")
	if steal == null:
		return ""
	if not steal is Dictionary:
		return "%s steal is %s, not an object or null" % [eid, type_string(typeof(steal))]
	var tiers: Dictionary = steal as Dictionary
	for tier: String in ["common", "rare"]:
		if not tiers.has(tier):
			return "%s steal is missing the %s tier (empty/partial object)" % [eid, tier]
		var entry: Variant = tiers.get(tier)
		if entry == null:
			continue
		if not entry is Dictionary:
			return "%s steal.%s is neither null nor an object" % [eid, tier]
		var pair: Dictionary = entry as Dictionary
		if not pair.has("item_id") or str(pair.get("item_id", "")).is_empty():
			return "%s steal.%s has no item_id" % [eid, tier]
		if not pair.has("rate"):
			return "%s steal.%s has no rate" % [eid, tier]
	return ""


## Drop is `null` (leaves nothing) or a `{item_id, rate}` pair. roll_drop()
## reads it the same way roll_steal() reads a tier.
func _drop_shape_error(record: Dictionary) -> String:
	var eid: String = str(record.get("id", "?"))
	if not record.has("drop"):
		return "%s has no drop field" % eid
	var drop: Variant = record.get("drop")
	if drop == null:
		return ""
	if not drop is Dictionary:
		return "%s drop is %s, not an object or null" % [eid, type_string(typeof(drop))]
	var pair: Dictionary = drop as Dictionary
	if not pair.has("item_id") or str(pair.get("item_id", "")).is_empty():
		return "%s drop has no item_id" % eid
	if not pair.has("rate"):
		return "%s drop has no rate" % eid
	return ""


func test_every_shipped_enemy_ships_a_readable_loot_shape() -> void:
	var problems: Array[String] = []
	var inspected: int = 0
	for act: String in ACT_TABLES:
		for entry: Variant in DataManager.load_enemies(act):
			if not entry is Dictionary:
				continue
			inspected += 1
			var record: Dictionary = entry as Dictionary
			var steal_problem: String = _steal_shape_error(record)
			if not steal_problem.is_empty():
				problems.append(steal_problem)
			var drop_problem: String = _drop_shape_error(record)
			if not drop_problem.is_empty():
				problems.append(drop_problem)
	# Floor on what was LOOKED AT, not just on what was found: a scan whose
	# act list rots reports "clean" and "never ran" identically. Repair the
	# act list if this trips — do not lower the floor.
	assert_gte(
		inspected, MIN_ENEMIES, "the act tables should carry 200+ enemies, saw %d" % inspected
	)
	assert_eq(problems, [] as Array[String], "enemy records with unreadable loot shapes")


## The guard above pins the DATA; this pins the ENGINE against the same
## shapes, so the two cannot drift apart. Every shipped record must survive
## a steal and a drop roll and hand back the declared dictionary.
func test_every_shipped_enemy_survives_a_loot_roll() -> void:
	var enemy: Enemy = preload("res://scenes/entities/enemy.tscn").instantiate()
	add_child_autofree(enemy)
	var rolled: int = 0
	for act: String in ACT_TABLES:
		for entry: Variant in DataManager.load_enemies(act):
			if not entry is Dictionary:
				continue
			enemy.enemy_data = entry as Dictionary
			rolled += 1
			for tier: String in ["common", "rare"]:
				var steal: Variant = enemy.roll_steal(tier)
				if not steal is Dictionary or not (steal as Dictionary).has("success"):
					fail_test(
						(
							"roll_steal('%s') on %s returned %s"
							% [tier, str(enemy.enemy_data.get("id", "?")), str(steal)]
						)
					)
					return
			var drop: Variant = enemy.roll_drop()
			if not drop is Dictionary or not (drop as Dictionary).has("success"):
				fail_test(
					(
						"roll_drop() on %s returned %s"
						% [str(enemy.enemy_data.get("id", "?")), str(drop)]
					)
				)
				return
	assert_gte(rolled, MIN_ENEMIES, "the act tables should carry 200+ enemies, rolled %d" % rolled)
