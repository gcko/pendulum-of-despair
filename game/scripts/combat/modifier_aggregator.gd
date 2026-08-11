extends RefCounted
## Aggregates enemy type-trait combat multipliers (GAP-008, partial).
##
## Pure static functions — no instance state. Every value traces to
## docs/story/bestiary/README.md. Type-element bonuses stack MULTIPLICATIVELY
## with elemental weakness/resistance (README §Stacking Rule), so callers pass
## the returned value as `interaction_mult` into damage_calculator, where it is
## multiplied against `element_mod`.
##
## Scope note: this slice implements only the dependency-free type traits that
## are wired into a live path — type-element bonuses (magic) and Spirit pre-DEF
## (physical). Deferred (tracked on #178): physical-elemental routing of type
## bonuses; Undead heal->damage (needs a heal->enemy target path); buff/status
## interactions (Resonance, Frozen Shatter), Pallor regen, Boss overkill, and
## Elemental absorb-own-element — all depend on unbuilt systems.

## Type-element bonus multipliers (bestiary/README.md §Enemy Type Rules).
## Each value stacks MULTIPLICATIVELY with elemental weakness/resistance.
const TYPE_ELEMENT_BONUS: Dictionary = {
	"undead": {"spirit": 1.5},  # README:67
	"spirit": {"ley": 1.5},  # README:83
	"construct": {"storm": 1.25},  # README:75
	"pallor": {"spirit": 1.25},  # README:100
}


## Bonus multiplier for hitting [param enemy_type] with [param element].
## Returns 1.0 when the type has no special reaction (incl. empty element).
## Multiply this into interaction_mult so it stacks with element_mod.
static func type_element_multiplier(enemy_type: String, element: String) -> float:
	if element.is_empty():
		return 1.0
	var by_element: Dictionary = TYPE_ELEMENT_BONUS.get(enemy_type, {})
	return by_element.get(element, 1.0)


## Pre-DEF physical multiplier. Spirit takes 50% physical, applied BEFORE the
## DEF subtraction (bestiary/README.md § Spirit). Returns 1.0 for all other types.
static func physical_pre_def_mult(enemy_type: String) -> float:
	if enemy_type == "spirit":
		return 0.5
	return 1.0
