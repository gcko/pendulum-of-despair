class_name AudioMixContext
extends RefCounted
## The mixing model: how loud music and ambient sit relative to each other in
## each place the game can be (audio.md § 2.2), and the bus volumes that
## follow from a context plus the player's volume sliders.
##
## Extracted from audio_manager.gd (GAP-087) — this is the "what should the mix
## be" half; the manager keeps the "make the players do it" half.

## Percentage multipliers applied to the player's config volume.
const MIX_OVERWORLD: Dictionary = {"music": 1.0, "ambient": 0.35}
const MIX_TOWN: Dictionary = {"music": 1.0, "ambient": 0.25}
const MIX_DUNGEON: Dictionary = {"music": 0.55, "ambient": 0.9}
const MIX_NARRATIVE_DUNGEON: Dictionary = {"music": 1.0, "ambient": 0.35}
const MIX_PALLOR: Dictionary = {"music": 0.0, "ambient": 0.4}
const MIX_BATTLE: Dictionary = {"music": 1.0, "ambient": 0.0}
## Cutscene mixing is "per scene direction" (audio.md § 2.2). Default to
## overworld-equivalent; cutscene scripts can override via set_mix_context.
const MIX_CUTSCENE: Dictionary = {"music": 1.0, "ambient": 0.35}

## Maps context string names to their MIX_* constant dictionaries.
const MIX_CONTEXTS: Dictionary = {
	"overworld": MIX_OVERWORLD,
	"town": MIX_TOWN,
	"dungeon": MIX_DUNGEON,
	"narrative_dungeon": MIX_NARRATIVE_DUNGEON,
	"pallor": MIX_PALLOR,
	"battle": MIX_BATTLE,
	"cutscene": MIX_CUTSCENE,
}

## The context a fresh session and a cleared pre-battle snapshot fall back to.
const DEFAULT_CONTEXT: String = "overworld"
## Volume sliders run 0..10 (ui-design.md § Config).
const SLIDER_MAX: float = 10.0


static func has_context(context: String) -> bool:
	return MIX_CONTEXTS.has(context)


## Linear bus volumes for [param context] under the player's [param config],
## as {"music": float, "ambient": float, "sfx": float}.
##
## Ambient is intentionally governed by the SFX Volume slider: audio.md § 2.2
## defines only Music and SFX player sliders, so ambient (an environmental SFX
## bed) scales off SFX rather than introducing a third, undocumented slider.
static func bus_volumes(context: String, config: Dictionary) -> Dictionary:
	var mix: Dictionary = MIX_CONTEXTS.get(context, MIX_OVERWORLD)
	var music_vol: float = float(config.get("music_volume", 8)) / SLIDER_MAX
	var sfx_vol: float = float(config.get("sfx_volume", 8)) / SLIDER_MAX
	return {
		"music": music_vol * float(mix.get("music", 1.0)),
		"ambient": sfx_vol * float(mix.get("ambient", 0.35)),
		"sfx": sfx_vol,
	}
