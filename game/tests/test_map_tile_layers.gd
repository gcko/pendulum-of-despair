extends GutTest
## Every map's tile layer loads, and the walls it loads leave the map playable.
##
## #449: all 22 TileMapLayer nodes stored tile_map_data in the legacy TileMap
## int layout, which TileMapLayer rejects, so every map loaded with zero cells
## and nothing collided. Once the tiles load, wall tiles (atlas 1, 7, 12, 17 in
## placeholder_dungeon.tres) start blocking the player, so these tests also pin
## that no entry marker stands inside a wall and that every exit and trigger can
## still be reached by walking.
##
## THE LIMIT: reachability models TILE collision only. StaticBody2D props
## (water zones, ember crystals, spirit plants) and NPC bodies are not
## obstacles here, and the flood fill is 4-connected over whole cells, which is
## exact only while the player's body fits inside one cell, which both
## reachability tests assert before they trust the fill. (#466: the Ember Vein
## F3 puzzle blockers are such props, and the tiles alone do not gate them.)
## Cells outside a layer's used rect are treated as not walkable, so an exit
## reachable only by walking off the painted map counts as unreachable.
## An exit counts only where exploration_entity_manager.gd connects it: a
## direct child of Transitions with target_map, or of Entities with
## target_map_id. Any other area carrying that metadata fails the test.

const MAPS_DIR: String = "res://scenes/maps"
const PLAYER_SCENE: String = "res://scenes/entities/player_character.tscn"
## Cutscene stages park the player off-screen and walk actors by tween; their
## markers and actors are not meant to be reachable on foot.
const CUTSCENE_DIR: String = "res://scenes/maps/cutscenes/"
## Floor on TileMapLayer nodes inspected. A walk that stops descending into
## maps/dungeons and maps/towns finds 1, not 22. If that happens, repair the
## walk. Lower this only in the commit that deliberately removes a map.
const MIN_TILE_LAYERS: int = 22
const PLAYER_BIT: int = 2
const INTERACTABLE_BIT: int = 4
## Metadata keys whose value names the Marker2D the player is placed at.
const SPAWN_META_KEYS: Array[String] = ["target_spawn", "cutscene_return_spawn"]

## Marker names some transition places the player at; built once per run.
var _entry_names_cache: Dictionary = {}
## The player body's collision_mask; read once per run.
var _player_mask_cache: int = -1


func test_every_map_tile_layer_loads_its_painted_cells() -> void:
	var tiled: int = 0
	var solid_total: int = 0
	for path: String in _map_scenes():
		var root: Node = _instance(path)
		for layer: TileMapLayer in _layers(root):
			tiled += 1
			if not path.begins_with(CUTSCENE_DIR):
				assert_true(
					layer.enabled and layer.collision_enabled,
					(
						"%s:%s has tile collision switched off; walls would not block (#449)"
						% [path, layer.name]
					)
				)
				for cell: Vector2i in layer.get_used_cells():
					if _is_solid(layer, cell):
						solid_total += 1
			assert_gt(
				layer.get_used_cells().size(),
				0,
				(
					"%s:%s loads no cells (tile_map_data rejected or missing, #449)"
					% [path, layer.name]
				)
			)
		root.free()
	assert_gt(
		solid_total, 0, "no painted tile collides with the player; walls would not block (#449)"
	)
	assert_gte(
		tiled,
		MIN_TILE_LAYERS,
		(
			(
				"found %d tile layers; the map walk stopped descending (repair it; lower the floor"
				+ " only in the commit that deliberately removes a map)"
			)
			% tiled
		)
	)


func test_every_painted_cell_is_a_tile_the_tileset_defines() -> void:
	for path: String in _map_scenes():
		var root: Node = _instance(path)
		for layer: TileMapLayer in _layers(root):
			var bad: Array[Vector2i] = []
			for cell: Vector2i in layer.get_used_cells():
				if layer.get_cell_tile_data(cell) == null:
					bad.append(cell)
			assert_eq(
				bad.size(),
				0,
				"%s:%s paints undefined tiles at %s" % [path, layer.name, bad.slice(0, 5)]
			)
		root.free()


func test_no_entry_marker_stands_inside_a_wall() -> void:
	var half: Vector2 = _player_body_size() / 2.0
	for path: String in _map_scenes():
		if path.begins_with(CUTSCENE_DIR):
			continue
		var root: Node = _instance(path)
		var markers: Array[Marker2D] = _entry_markers(root)
		assert_false(markers.is_empty(), "%s has no player entry marker; nothing to judge" % path)
		for layer: TileMapLayer in _layers(root):
			for marker: Marker2D in markers:
				var at: Vector2 = _in_layer(layer, marker).round()
				var body: Rect2 = Rect2(at - half, half * 2.0)
				var hit: Array[Vector2i] = _solid_cells_under(layer, body)
				assert_eq(
					hit.size(),
					0,
					"%s: marker %s at %s overlaps wall cells %s" % [path, marker.name, at, hit]
				)
		root.free()


func test_every_entry_marker_can_walk_to_an_exit() -> void:
	for path: String in _map_scenes():
		if path.begins_with(CUTSCENE_DIR):
			continue
		var root: Node = _instance(path)
		var markers: Array[Marker2D] = _entry_markers(root)
		assert_false(markers.is_empty(), "%s has no player entry marker; nothing to judge" % path)
		for layer: TileMapLayer in _layers(root):
			_assert_body_fits_one_cell(layer, path)
			var exits: Array[Rect2] = _target_rects(root, layer, true)
			assert_false(
				exits.is_empty(), "%s has no exit Area2D, so every entry is a softlock" % path
			)
			if exits.is_empty():
				continue
			for marker: Marker2D in markers:
				var reach: Dictionary = _flood(layer, _in_layer(layer, marker))
				var any_exit: bool = false
				for r: Rect2 in exits:
					any_exit = any_exit or _touches(reach, layer, r)
				assert_true(
					any_exit,
					"%s: no exit is reachable on foot from %s (softlock)" % [path, marker.name]
				)
		root.free()


func test_every_exit_and_trigger_is_reachable_from_some_entry() -> void:
	# The player's center stays body_half away from a wall face, so its
	# InteractionArea reaches only (radius - body_half) past a reachable cell.
	var interact_pad: float = _player_interact_radius() - _player_body_size().x / 2.0
	for path: String in _map_scenes():
		if path.begins_with(CUTSCENE_DIR):
			continue
		var root: Node = _instance(path)
		var markers: Array[Marker2D] = _entry_markers(root)
		assert_false(markers.is_empty(), "%s has no player entry marker; nothing to judge" % path)
		for layer: TileMapLayer in _layers(root):
			_assert_body_fits_one_cell(layer, path)
			var reach: Dictionary = {}
			for marker: Marker2D in markers:
				reach.merge(_flood(layer, _in_layer(layer, marker)))
			for area: Area2D in _areas(root):
				var pad: float = 0.0 if (area.collision_mask & PLAYER_BIT) else interact_pad
				if (
					not (area.collision_mask & PLAYER_BIT)
					and not (area.collision_layer & INTERACTABLE_BIT)
				):
					continue
				var rects: Array[Rect2] = _area_rects(area, layer)
				assert_false(
					rects.is_empty(),
					"%s: %s has no measurable shape" % [path, root.get_path_to(area)]
				)
				for r: Rect2 in rects:
					assert_true(
						_touches(reach, layer, r.grow(pad)),
						"%s: %s is sealed off by wall tiles" % [path, root.get_path_to(area)]
					)
		root.free()


# --- helpers -----------------------------------------------------------------


func _map_scenes() -> Array[String]:
	var out: Array[String] = []
	_collect(MAPS_DIR, out)
	out.sort()
	return out


func _collect(dir_path: String, out: Array[String]) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	assert_not_null(dir, "cannot open %s" % dir_path)
	if dir == null:
		return
	for f: String in dir.get_files():
		if f.ends_with(".tscn"):
			out.append(dir_path.path_join(f))
	for sub: String in dir.get_directories():
		_collect(dir_path.path_join(sub), out)


func _instance(path: String) -> Node:
	var packed: PackedScene = load(path)
	return packed.instantiate()


func _layers(root: Node) -> Array[TileMapLayer]:
	var out: Array[TileMapLayer] = []
	for n: Node in root.find_children("*", "TileMapLayer", true, false):
		out.append(n as TileMapLayer)
	return out


## Markers the player can be placed at: PlayerSpawn (exploration.gd's
## default), any from_* entry, and any name a transition's metadata targets.
## Actor marks such as CadenSpawnPoint are not player entries. An entry must be
## a direct child of the map root: one nested deeper fails the test.
func _entry_markers(root: Node) -> Array[Marker2D]:
	if _entry_names_cache.is_empty():
		_entry_names_cache["PlayerSpawn"] = true
		for path: String in _map_scenes():
			var scene: Node = _instance(path)
			for n: Node in scene.find_children("*", "", true, false):
				for key: String in SPAWN_META_KEYS:
					if n.has_meta(key):
						_entry_names_cache[str(n.get_meta(key))] = true
			scene.free()
	# exploration.gd resolves an entry with get_node_or_null(name) on the map
	# root, so only direct children are reachable; a nested one silently drops
	# the player at the (80, 90) fallback instead.
	var out: Array[Marker2D] = []
	for n: Node in root.find_children("*", "Marker2D", true, false):
		if not (_entry_names_cache.has(n.name) or n.name.begins_with("from_")):
			continue
		if n.get_parent() != root:
			fail_test(
				(
					(
						"%s: entry marker %s is not a direct child of the map root;"
						+ " exploration.gd cannot reach it"
					)
					% [root.scene_file_path, root.get_path_to(n)]
				)
			)
			continue
		out.append(n as Marker2D)
	return out


func _areas(root: Node) -> Array[Area2D]:
	var out: Array[Area2D] = []
	for n: Node in root.find_children("*", "Area2D", true, false):
		out.append(n as Area2D)
	return out


## Transform of `n` relative to `layer`, composed by hand: the scene is never
## added to the tree, so no _ready() runs and no autoload is touched.
func _xf_to(n: Node, stop: Node) -> Transform2D:
	var t: Transform2D = Transform2D.IDENTITY
	var cur: Node = n
	while cur != null and cur != stop:
		if cur is Node2D:
			t = (cur as Node2D).transform * t
		cur = cur.get_parent()
	return t


func _in_layer(layer: TileMapLayer, n: Node2D) -> Vector2:
	var root: Node = layer.owner if layer.owner != null else layer.get_parent()
	return _xf_to(layer, root).affine_inverse() * _xf_to(n, root).origin


func _area_rects(area: Area2D, layer: TileMapLayer) -> Array[Rect2]:
	var out: Array[Rect2] = []
	var root: Node = layer.owner if layer.owner != null else layer.get_parent()
	var to_layer: Transform2D = _xf_to(layer, root).affine_inverse()
	for c: Node in area.get_children():
		if c is CollisionPolygon2D:
			fail_test("%s: %s is a CollisionPolygon2D; extend _area_rects" % [area.name, c.name])
			continue
		var cs: CollisionShape2D = c as CollisionShape2D
		if cs == null or cs.disabled or cs.shape == null:
			continue
		var size: Vector2 = Vector2.ZERO
		if cs.shape is RectangleShape2D:
			size = (cs.shape as RectangleShape2D).size
		elif cs.shape is CircleShape2D:
			size = Vector2.ONE * (cs.shape as CircleShape2D).radius * 2.0
		else:
			fail_test(
				(
					"%s: %s uses unsupported shape %s; extend _area_rects"
					% [area.name, cs.name, cs.shape.get_class()]
				)
			)
			continue
		# Transform2D * Rect2 is the AABB, so a scaled or rotated shape still counts.
		out.append((to_layer * _xf_to(cs, root)) * Rect2(-size / 2.0, size))
	return out


## Exits as exploration_entity_manager.gd wires them: a direct child of
## Transitions with target_map (transition), or a direct child of Entities with
## target_map_id (pitfall). An exit anywhere else is never connected, so it is
## not credited, and the test fails.
func _target_rects(root: Node, layer: TileMapLayer, exits_only: bool) -> Array[Rect2]:
	var out: Array[Rect2] = []
	var transitions: Node = root.get_node_or_null("Transitions")
	var entities: Node = root.get_node_or_null("Entities")
	for area: Area2D in _areas(root):
		var has_exit_meta: bool = area.has_meta("target_map") or area.has_meta("target_map_id")
		var wired_exit: bool = (
			(
				transitions != null
				and area.get_parent() == transitions
				and area.has_meta("target_map")
			)
			or (
				entities != null
				and area.get_parent() == entities
				and area.has_meta("target_map_id")
			)
		)
		if has_exit_meta and not wired_exit:
			fail_test(
				(
					(
						"%s: exit %s is not a direct child of Transitions/Entities;"
						+ " exploration_entity_manager.gd never connects it"
					)
					% [root.scene_file_path, root.get_path_to(area)]
				)
			)
			continue
		if (area.collision_mask & PLAYER_BIT) and (wired_exit or not exits_only):
			out.append_array(_area_rects(area, layer))
	return out


func _is_solid(layer: TileMapLayer, cell: Vector2i) -> bool:
	if not layer.enabled or not layer.collision_enabled:
		return false
	var td: TileData = layer.get_cell_tile_data(cell)
	if td == null:
		return false
	for pl: int in layer.tile_set.get_physics_layers_count():
		if not (layer.tile_set.get_physics_layer_collision_layer(pl) & _player_mask()):
			continue
		if td.get_collision_polygons_count(pl) > 0:
			return true
	return false


func _cell_rect(layer: TileMapLayer, cell: Vector2i) -> Rect2:
	var ts: Vector2 = Vector2(layer.tile_set.tile_size)
	return Rect2(layer.map_to_local(cell) - ts / 2.0, ts)


func _solid_cells_under(layer: TileMapLayer, body: Rect2) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var a: Vector2i = layer.local_to_map(body.position)
	var b: Vector2i = layer.local_to_map(body.end)
	for x: int in range(a.x, b.x + 1):
		for y: int in range(a.y, b.y + 1):
			var cell: Vector2i = Vector2i(x, y)
			if _is_solid(layer, cell) and _cell_rect(layer, cell).intersects(body):
				out.append(cell)
	return out


## Open cells reachable from `from`, 4-connected, inside the painted rect.
func _flood(layer: TileMapLayer, from: Vector2) -> Dictionary:
	var used: Rect2i = layer.get_used_rect()
	var start: Vector2i = layer.local_to_map(from)
	var seen: Dictionary = {}
	if not used.has_point(start) or _is_solid(layer, start):
		return seen
	var queue: Array[Vector2i] = [start]
	seen[start] = true
	while not queue.is_empty():
		var c: Vector2i = queue.pop_back()
		for d: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = c + d
			if not seen.has(n) and used.has_point(n) and not _is_solid(layer, n):
				seen[n] = true
				queue.append(n)
	return seen


## True when `r` overlaps (with positive area) any reachable open cell. The
## body fits inside one cell, so any point of an open cell can be covered.
func _touches(reach: Dictionary, layer: TileMapLayer, r: Rect2) -> bool:
	var a: Vector2i = layer.local_to_map(r.position)
	var b: Vector2i = layer.local_to_map(r.end)
	for x: int in range(a.x, b.x + 1):
		for y: int in range(a.y, b.y + 1):
			var cell: Vector2i = Vector2i(x, y)
			if reach.has(cell) and _cell_rect(layer, cell).intersection(r).get_area() > 0.0:
				return true
	return false


func _player_body_size() -> Vector2:
	var player: Node = _instance(PLAYER_SCENE)
	var size: Vector2 = Vector2.ZERO
	var body_cs: CollisionShape2D = null
	for c: Node in player.get_children():
		if c is CollisionShape2D and (c as CollisionShape2D).shape is RectangleShape2D:
			body_cs = c as CollisionShape2D
			size = (body_cs.shape as RectangleShape2D).size
	# The marker rect, the flood start and the interaction pad all model the
	# body as an unscaled rect centered on the player origin.
	assert_eq(
		(player as Node2D).scale,
		Vector2.ONE,
		"player root is scaled in %s; the reachability model assumes scale 1" % PLAYER_SCENE
	)
	if body_cs != null:
		assert_eq(
			body_cs.position,
			Vector2.ZERO,
			(
				"player body is offset in %s; the reachability model assumes a centered body"
				% PLAYER_SCENE
			)
		)
		assert_eq(
			body_cs.scale,
			Vector2.ONE,
			"player body is scaled in %s; the reachability model assumes scale 1" % PLAYER_SCENE
		)
	player.free()
	assert_gt(size.x, 0.0, "player body shape not found in %s" % PLAYER_SCENE)
	return size


## The physics layers the player's body collides with; a wall tile blocks only
## when its tileset physics layer shares a bit with this mask.
func _player_mask() -> int:
	if _player_mask_cache < 0:
		var player: Node = _instance(PLAYER_SCENE)
		_player_mask_cache = (player as CollisionObject2D).collision_mask
		player.free()
		assert_gt(_player_mask_cache, 0, "player collision_mask is 0 in %s" % PLAYER_SCENE)
	return _player_mask_cache


func _player_interact_radius() -> float:
	var player: Node = _instance(PLAYER_SCENE)
	var r: float = 0.0
	var area: Node = player.get_node_or_null("InteractionArea")
	if area != null:
		# The pad (radius - body half-width) assumes the circle is centered on
		# the body.
		assert_eq(
			(area as Node2D).position,
			Vector2.ZERO,
			(
				"InteractionArea is offset in %s; the interaction pad assumes it is centered"
				% PLAYER_SCENE
			)
		)
		for c: Node in area.get_children():
			if c is CollisionShape2D and (c as CollisionShape2D).shape is CircleShape2D:
				r = ((c as CollisionShape2D).shape as CircleShape2D).radius
				assert_eq(
					(c as CollisionShape2D).position,
					Vector2.ZERO,
					(
						"InteractionArea circle is offset in %s; the interaction pad assumes it is centered"
						% PLAYER_SCENE
					)
				)
	player.free()
	assert_gt(r, 0.0, "player InteractionArea radius not found in %s" % PLAYER_SCENE)
	return r


## The cell flood fill is exact only while the player's body fits inside one
## cell; a bigger body could not pass a one-cell gap the fill calls open.
func _assert_body_fits_one_cell(layer: TileMapLayer, path: String) -> void:
	var body: Vector2 = _player_body_size()
	var cell: Vector2 = Vector2(layer.tile_set.tile_size)
	assert_true(
		body.x < cell.x and body.y < cell.y,
		(
			"%s: player body %s does not fit one %s cell; reachability needs a finer grid"
			% [path, body, cell]
		)
	)
