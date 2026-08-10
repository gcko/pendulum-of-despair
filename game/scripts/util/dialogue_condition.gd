class_name DialogueCondition
extends RefCounted
## Shared evaluator for the dialogue `condition` field.
##
## Single source of truth for condition semantics so every player of
## dialogue data — NPC priority stacks, the cutscene sequencer, and the
## dialogue box — resolves the same expression the same way.
## See docs/story/dialogue-system.md Sections 3.2 and 3.3.
##
## Supported forms: null/empty (always true), binary flags, numeric and
## string comparisons, `party_has(member)`, and ` AND ` combinations.
##
## Callers may pass a [param context] dictionary of scene-local pseudo-flags
## (e.g. `choice_1_selected`). Context entries shadow EventFlags and are
## never written to the save file.

## Comparison operators, longest-first so ">=" wins over ">".
const OPERATORS: Array[String] = [">=", "<=", "==", "!=", ">", "<"]

## Maximum choice options a dialogue entry may offer (ui-design.md 12.4).
## Also the number of `choice_N_selected` pseudo-flags [method choice_context]
## produces.
const MAX_CHOICES: int = 4

## Prefix that introduces a party-membership test.
const PARTY_HAS_PREFIX: String = "party_has("

## Separator for AND combinations (dialogue-system.md 3.3).
const AND_SEPARATOR: String = " AND "


## Evaluate a condition expression against current game state.
## Returns true for null/empty conditions (unconditioned entries).
static func evaluate(condition: Variant, context: Dictionary = {}) -> bool:
	if is_unconditioned(condition):
		return true
	if not (condition is String):
		return false

	var cond_str: String = condition

	# AND combinations: every part must hold.
	if AND_SEPARATOR in cond_str:
		for part: String in cond_str.split(AND_SEPARATOR):
			if not evaluate(part.strip_edges(), context):
				return false
		return true

	# party_has(member) — active party membership.
	if cond_str.begins_with(PARTY_HAS_PREFIX):
		var end_idx: int = cond_str.find(")")
		if end_idx < 0:
			return false
		var prefix_len: int = PARTY_HAS_PREFIX.length()
		var char_id: String = cond_str.substr(prefix_len, end_idx - prefix_len).strip_edges()
		return PartyState.has_member(char_id)

	# Numeric / string comparison.
	for op: String in OPERATORS:
		var op_idx: int = cond_str.find(op)
		if op_idx > 0:
			var flag_name: String = cond_str.substr(0, op_idx).strip_edges()
			var value_str: String = cond_str.substr(op_idx + op.length()).strip_edges()
			return _compare(flag_name, op, value_str, context)

	# Binary flag.
	return bool(value_of(cond_str, context))


## True when [param condition] is the "always plays" form — JSON null or an
## empty string. Type-checked before comparing to "" because Variant `==`
## between an int and a String raises "Invalid operands" instead of returning
## false.
static func is_unconditioned(condition: Variant) -> bool:
	if condition == null:
		return true
	return condition is String and (condition as String) == ""


## True when [param entry] has no condition or its condition holds.
static func should_play(entry: Dictionary, context: Dictionary = {}) -> bool:
	return evaluate(entry.get("condition"), context)


## Resolve a priority stack to the entries that may be served right now.
##
## Walks top-to-bottom and returns a single-element array holding the first
## conditioned entry whose condition holds — first-match-wins, per
## dialogue-system.md 3.2. When no condition holds, returns every
## unconditioned entry in authored order: an NPC may have several ambient
## defaults, and the caller decides which one to surface (npc.gd rotates
## through them). Returns an empty array when the stack has nothing to say.
static func resolve_stack(entries: Array, context: Dictionary = {}) -> Array:
	var defaults: Array = []
	for entry: Variant in entries:
		if not (entry is Dictionary):
			continue
		var condition: Variant = (entry as Dictionary).get("condition")
		if is_unconditioned(condition):
			defaults.append(entry)
			continue
		if evaluate(condition, context):
			return [entry]
	return defaults


## Build the scene-local context produced by selecting [param choice_index].
## Exactly one `choice_N_selected` pseudo-flag is true; the rest are false
## so a stale EventFlag can never satisfy a reaction entry. Reaction entries
## in the shipped scenes use 1-based names (`choice_1_selected` for the first
## option), so [param choice_index] is 0-based and shifted here.
static func choice_context(choice_index: int) -> Dictionary:
	var context: Dictionary = {}
	for i: int in range(MAX_CHOICES):
		context["choice_%d_selected" % (i + 1)] = i == choice_index
	return context


## Resolve a flag name, preferring scene-local context over EventFlags.
static func value_of(flag_name: String, context: Dictionary = {}) -> Variant:
	if context.has(flag_name):
		return context[flag_name]
	return EventFlags.get_flag(flag_name)


static func _compare(flag_name: String, op: String, value_str: String, context: Dictionary) -> bool:
	var flag_val: Variant = value_of(flag_name, context)
	var result: bool = false
	if value_str.is_valid_int():
		var expected: int = value_str.to_int()
		var actual: int = int(flag_val) if flag_val != null else 0
		match op:
			">=":
				result = actual >= expected
			"<=":
				result = actual <= expected
			"==":
				result = actual == expected
			"!=":
				result = actual != expected
			">":
				result = actual > expected
			"<":
				result = actual < expected
	else:
		var actual_str: String = str(flag_val) if flag_val != null else ""
		match op:
			"==":
				result = actual_str == value_str
			"!=":
				result = actual_str != value_str
	return result
