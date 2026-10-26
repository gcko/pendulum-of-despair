extends GutTest
## Authored collision footprints of the water and damage zones placed on map
## scenes, at runtime and after an editor save. Sizes are the placement tables
## of docs/superpowers/specs/2026-04-11-fenmother-puzzles-a2b-design.md
## (Water Zone § Zone Placement, Damage Zone § Placement).
##
## Each zone instances a 16x16 prefab (water_zone.tscn / damage_zone.tscn) and
## the map scene overrides the prefab's CollisionShape2D. #450: those overrides
## lived inside instances with no [editable path=...] entry, so the editor's
## save dropped them and every zone shrank to the 16x16 prefab default.
##
## Both tests walk every map scene and judge every zone instance they find, so
## a zone placed on a new map without a footprint here fails rather than going
## unchecked, and a walk that stopped descending fails the floor. A map named
## here is judged even once its zones are gone, so a deleted zone fails, and a
## map named here that the walk never reaches fails too.

const MAPS_ROOT: String = "res://scenes/maps"
const ZONE_PREFABS: Array[String] = [
	"res://scenes/entities/water_zone.tscn",
	"res://scenes/entities/damage_zone.tscn",
]
const F1: String = "res://scenes/maps/dungeons/fenmothers_hollow_f1.tscn"
const F2: String = "res://scenes/maps/dungeons/fenmothers_hollow_f2.tscn"
const F3: String = "res://scenes/maps/dungeons/fenmothers_hollow_f3.tscn"
## Keyed by map scene, then by the zone's node path inside that map.
const AUTHORED_SIZES: Dictionary = {
	F1:
	{
		"Entities/DeepWaterBarrier": Vector2(64, 32),
		"Entities/AlcoveEntrance": Vector2(48, 48),
		"Entities/MidPassageFlood": Vector2(96, 32),
		"Entities/EastWingBlock": Vector2(48, 64),
	},
	F2:
	{
		"Entities/MosaicFlood1": Vector2(128, 64),
		"Entities/MosaicFlood2": Vector2(128, 64),
		"Entities/SecretRoom": Vector2(48, 48),
		"Entities/CorruptedPoolEast": Vector2(96, 48),
		"Entities/PollutedChannelSouth": Vector2(160, 32),
		"Entities/StagnantCorner": Vector2(64, 64),
	},
	F3:
	{
		"Entities/SeepageLeft": Vector2(48, 96),
		"Entities/SeepageRight": Vector2(48, 96),
	},
	# docs/story/building-palette.md: a hidden door is a 1x1 tile, so this one
	# keeps the 16x16 prefab footprint and overrides nothing.
	"res://scenes/maps/dungeons/ember_vein_f3.tscn": {"Entities/HiddenDoor1": Vector2(16, 16)},
}
## A walk that stopped descending would find no map scenes at all; one that
## stopped matching prefabs would find no zones. Either must fail, not pass.
const MIN_ZONES_FOUND: int = 13


func test_every_zone_on_a_map_has_its_spec_footprint_at_runtime() -> void:
	var found: int = 0
	var visited: Dictionary = {}
	for scene_path: String in _map_scenes(MAPS_ROOT):
		visited[scene_path] = true
		var map: Node = load(scene_path).instantiate()
		if _zones(map).is_empty() and not AUTHORED_SIZES.has(scene_path):
			map.free()
			continue
		# In the tree, so _ready runs: a footprint applied by script counts too.
		add_child_autofree(map)
		found += _assert_footprints(map, scene_path, "at runtime")
	_assert_every_authored_map_walked(visited)
	assert_gte(found, MIN_ZONES_FOUND, "zone walk found too few zones; repair the walk")


func test_every_zone_footprint_survives_an_editor_save() -> void:
	# EditorNode saves a scene by instancing it in edit state and packing it.
	# Doing the same in memory reproduces #450 without touching the file.
	var found: int = 0
	var visited: Dictionary = {}
	for scene_path: String in _map_scenes(MAPS_ROOT):
		visited[scene_path] = true
		var edited: Node = load(scene_path).instantiate(PackedScene.GEN_EDIT_STATE_MAIN)
		if _zones(edited).is_empty() and not AUTHORED_SIZES.has(scene_path):
			edited.free()
			continue
		var resaved: PackedScene = PackedScene.new()
		assert_eq(resaved.pack(edited), OK, "%s should pack" % scene_path)
		edited.free()
		var map: Node = resaved.instantiate()
		add_child_autofree(map)
		found += _assert_footprints(map, scene_path, "after an editor save")
	_assert_every_authored_map_walked(visited)
	assert_gte(found, MIN_ZONES_FOUND, "zone walk found too few zones; repair the walk")


## Asserts every zone on `map` has an authored footprint and matches it, and
## every authored zone is still on the map. Returns how many zones it judged.
func _assert_footprints(map: Node, scene_path: String, when: String) -> int:
	var authored: Dictionary = AUTHORED_SIZES.get(scene_path, {})
	var zones: Array[Node] = _zones(map)
	for zone_path: String in authored:
		assert_not_null(
			map.get_node_or_null(zone_path), "%s should place %s" % [scene_path, zone_path]
		)
	for zone: Node in zones:
		var zone_path: String = str(map.get_path_to(zone))
		if not authored.has(zone_path):
			fail_test(
				(
					"%s places zone %s with no entry in AUTHORED_SIZES; add its spec size"
					% [scene_path, zone_path]
				)
			)
			continue
		var shape: RectangleShape2D = (
			(zone.get_node("CollisionShape2D") as CollisionShape2D).shape as RectangleShape2D
		)
		assert_eq(
			shape.size,
			authored[zone_path],
			"%s %s footprint %s" % [scene_path.get_file(), zone_path, when]
		)
	return zones.size()


## A map named in AUTHORED_SIZES that the walk never reached was moved or
## deleted, and its zones would otherwise go unchecked.
func _assert_every_authored_map_walked(visited: Dictionary) -> void:
	for key: String in AUTHORED_SIZES:
		assert_true(
			visited.has(key), "AUTHORED_SIZES names %s, which the map walk never found" % key
		)


## Every instance of a zone prefab anywhere under `map`, not only under Entities.
func _zones(map: Node) -> Array[Node]:
	var out: Array[Node] = []
	for node: Node in map.find_children("*", "", true, false):
		if node.scene_file_path in ZONE_PREFABS:
			out.append(node)
	return out


func _map_scenes(dir_path: String) -> Array[String]:
	var out: Array[String] = []
	var dir: DirAccess = DirAccess.open(dir_path)
	assert_not_null(dir, "cannot open %s" % dir_path)
	if dir == null:
		return out
	for file: String in dir.get_files():
		if file.ends_with(".tscn"):
			out.append(dir_path.path_join(file))
	for sub: String in dir.get_directories():
		out.append_array(_map_scenes(dir_path.path_join(sub)))
	return out
