class_name CleansingSequence
extends RefCounted

const RITUAL_METER_PATH: String = "res://scenes/ui/ritual_meter.tscn"
const DAMAGE_ZONE_PATH: String = "res://scenes/entities/damage_zone.tscn"
const WAVE_TURN_THRESHOLDS: Array[int] = [6, 8, 8, 5]
const BOSS_ARENA_CENTER: Vector2 = Vector2(272, 208)
const BOSS_ARENA_RADIUS: float = 80.0
const CLEANSING_WAVES: Array = [
	[
		"marsh_serpent",
		"marsh_serpent",
		"marsh_serpent",
		"marsh_serpent",
		"polluted_elemental",
		"polluted_elemental",
	],
	[
		"ley_jellyfish",
		"ley_jellyfish",
		"ley_jellyfish",
		"drowned_bones",
		"drowned_bones",
		"polluted_elemental",
	],
	[
		"polluted_elemental",
		"polluted_elemental",
		"marsh_serpent",
		"marsh_serpent",
		"marsh_serpent",
		"ley_jellyfish",
	],
	[
		"corrupted_spawn",
		"corrupted_spawn",
		"corrupted_spawn",
	],
]

var _exploration: Exploration
var _ritual_meter: Node = null
var _spawned_pool_count: int = 0


func _init(exploration: Exploration) -> void:
	_exploration = exploration


func start(data: Dictionary) -> void:
	var rewards: Dictionary = {
		"xp": data.get("earned_xp", 0),
		"gold": data.get("earned_gold", 0),
		"drops": data.get("earned_drops", []),
	}
	PartyState.distribute_battle_rewards(rewards)
	_exploration.distribute_crystal_xp(rewards.get("xp", 0))
	EventFlags.set_flag("fenmother_boss_defeated", true)
	_exploration.reset_danger_counter()
	_exploration.load_map(data.get("map_id", "dungeons/fenmothers_hollow_f3"))
	if _exploration.get_player() != null:
		var pos: Variant = data.get("position", Vector2(80, 90))
		_exploration.get_player().position = pos.round() if pos is Vector2 else Vector2(80, 90)
	_move_torren_to_reserve()
	if _ritual_meter != null:
		_ritual_meter.queue_free()
	if not ResourceLoader.exists(RITUAL_METER_PATH):
		push_error("CleansingSequence: Ritual meter resource missing: %s" % RITUAL_METER_PATH)
		return
	var meter_res: Resource = load(RITUAL_METER_PATH)
	if not meter_res is PackedScene:
		push_error("CleansingSequence: Failed to load ritual meter: %s" % RITUAL_METER_PATH)
		return
	_ritual_meter = (meter_res as PackedScene).instantiate()
	_exploration.add_child(_ritual_meter)
	_ritual_meter.show_meter()
	_spawned_pool_count = 0
	var scene_data: Dictionary = DataManager.load_dialogue("fenmother_cleansing")
	var entries: Array = scene_data.get("entries", [])
	if entries.is_empty():
		_launch_wave(0, data)
		return
	var dialogue: Array = [entries[0]]
	if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		GameManager.overlay_node.show_dialogue(dialogue)
		GameManager.overlay_state_changed.connect(
			_on_dialogue_closed.bind(0, data), CONNECT_ONE_SHOT
		)
	else:
		_launch_wave(0, data)


func continue_sequence(data: Dictionary) -> void:
	var wave_num: int = data.get("wave_num", 0)
	var rewards: Dictionary = {
		"xp": data.get("earned_xp", 0),
		"gold": data.get("earned_gold", 0),
		"drops": data.get("earned_drops", []),
	}
	PartyState.distribute_battle_rewards(rewards)
	_exploration.distribute_crystal_xp(rewards.get("xp", 0))
	_exploration.reset_danger_counter()
	_exploration.load_map(data.get("map_id", "dungeons/fenmothers_hollow_f3"))
	_spawned_pool_count = 0
	if _exploration.get_player() != null:
		var fallback: Vector2 = data.get("position", Vector2(80, 90))
		var origin: Variant = data.get("cleansing_origin_position", null)
		var pos: Vector2 = origin if origin is Vector2 else fallback
		_exploration.get_player().position = pos.round()
	if _ritual_meter == null:
		if not ResourceLoader.exists(RITUAL_METER_PATH):
			push_error("CleansingSequence: Ritual meter resource missing: %s" % RITUAL_METER_PATH)
			return
		var meter_res: Resource = load(RITUAL_METER_PATH)
		if not meter_res is PackedScene:
			push_error("CleansingSequence: Failed to load ritual meter: %s" % RITUAL_METER_PATH)
			return
		_ritual_meter = (meter_res as PackedScene).instantiate()
		_exploration.add_child(_ritual_meter)
		var saved_val: float = data.get("ritual_meter_value", 100.0)
		_ritual_meter.set_value(saved_val)
		_ritual_meter.show_meter()
	var next_wave: int = wave_num + 1
	if next_wave > 3:
		_complete(data)
		return
	_revive_fallen_at_quarter_hp()
	if _ritual_meter != null:
		var turn_count: int = data.get("turn_count", 0)
		var ko_count: int = data.get("ko_count", 0)
		var threshold: int = (
			WAVE_TURN_THRESHOLDS[wave_num] if wave_num < WAVE_TURN_THRESHOLDS.size() else 6
		)
		var has_recovery: bool = wave_num == 1
		var drain_amount: float = _ritual_meter.calculate_drain(
			wave_num, ko_count, turn_count, threshold, has_recovery
		)
		_ritual_meter.drain(drain_amount)
		if _ritual_meter.is_failed():
			_ritual_meter.reset_for_retry()
			_exploration.flash_location_name("The corruption surges back!")
			_launch_wave(wave_num, data)
			return
	_spawn_poison_pools()
	var scene_data: Dictionary = DataManager.load_dialogue("fenmother_cleansing")
	var entries: Array = scene_data.get("entries", [])
	var entry_idx: int = next_wave
	if entry_idx >= entries.size():
		_launch_wave(next_wave, data)
		return
	var dialogue: Array = [entries[entry_idx]]
	if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		GameManager.overlay_node.show_dialogue(dialogue)
		GameManager.overlay_state_changed.connect(
			_on_dialogue_closed.bind(next_wave, data), CONNECT_ONE_SHOT
		)
	else:
		_launch_wave(next_wave, data)


func _launch_wave(wave_num: int, data: Dictionary) -> void:
	if wave_num < 0 or wave_num >= CLEANSING_WAVES.size():
		_complete(data)
		return
	var fb: Vector2 = data.get("position", Vector2(80, 90))
	var raw_origin: Variant = data.get("cleansing_origin_position", fb)
	var origin_pos: Vector2 = raw_origin if raw_origin is Vector2 else fb
	var player: Node2D = _exploration.get_player()
	var player_pos: Vector2 = player.position if player != null else origin_pos
	var meter_val: float = _ritual_meter.meter_value if _ritual_meter != null else 100.0
	var transition: Dictionary = {
		"encounter_group": CLEANSING_WAVES[wave_num],
		"formation_type": "normal",
		"return_map_id": "dungeons/fenmothers_hollow_f3",
		"return_position": player_pos,
		"enemy_act": "act_i",
		"encounter_source": "cleansing_wave",
		"wave_num": wave_num,
		"cleansing_origin_position": origin_pos,
		"ritual_meter_value": meter_val,
	}
	_exploration.set_transitioning(true)
	GameManager.change_core_state(GameManager.CoreState.BATTLE, transition)


func _complete(_data: Dictionary) -> void:
	_restore_torren_to_active()
	_revive_fallen_at_quarter_hp()
	EventFlags.set_flag("fenmother_cleansed", true)
	if _ritual_meter != null:
		_ritual_meter.hide_meter()
		_ritual_meter.queue_free()
		_ritual_meter = null
	var scene_data: Dictionary = DataManager.load_dialogue("fenmother_cleansing")
	var entries: Array = scene_data.get("entries", [])
	var final_idx: int = entries.size() - 1
	if final_idx < 0:
		return
	var dialogue: Array = [entries[final_idx]]
	if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		GameManager.overlay_node.show_dialogue(dialogue)
		GameManager.overlay_state_changed.connect(_on_complete_dialogue_closed, CONNECT_ONE_SHOT)
	else:
		_exploration.load_map("dungeons/fenmothers_hollow_spirit_path")


func _on_complete_dialogue_closed(state: GameManager.OverlayState) -> void:
	if state != GameManager.OverlayState.NONE:
		GameManager.overlay_state_changed.connect(_on_complete_dialogue_closed, CONNECT_ONE_SHOT)
		return
	_exploration.load_map("dungeons/fenmothers_hollow_spirit_path")


func _on_dialogue_closed(state: GameManager.OverlayState, wave_num: int, data: Dictionary) -> void:
	if state != GameManager.OverlayState.NONE:
		GameManager.overlay_state_changed.connect(
			_on_dialogue_closed.bind(wave_num, data), CONNECT_ONE_SHOT
		)
		return
	_launch_wave(wave_num, data)


func _spawn_poison_pools() -> void:
	if _exploration.get_current_map() == null or _spawned_pool_count >= 4:
		return
	var entities: Node = _exploration.get_current_map().get_node_or_null("Entities")
	if entities == null:
		return
	if not ResourceLoader.exists(DAMAGE_ZONE_PATH):
		push_error("CleansingSequence: Damage zone resource missing: %s" % DAMAGE_ZONE_PATH)
		return
	var zone_scene: Resource = load(DAMAGE_ZONE_PATH)
	if not zone_scene is PackedScene:
		push_error("CleansingSequence: Failed to load damage zone: %s" % DAMAGE_ZONE_PATH)
		return
	var count: int = randi_range(1, 2)
	for i: int in range(count):
		if _spawned_pool_count >= 4:
			break
		var pool: Area2D = (zone_scene as PackedScene).instantiate()
		var pos: Vector2 = _random_arena_position()
		pool.position = pos
		entities.add_child(pool)
		pool.initialize("cleansing_pool_%d" % _spawned_pool_count, 10, 1.0, "")
		pool.zone_damage_dealt.connect(_exploration.get_zone_damage_callback())
		_spawned_pool_count += 1


func _random_arena_position() -> Vector2:
	var p: Node2D = _exploration.get_player()
	var player_pos: Vector2 = p.position if p != null else BOSS_ARENA_CENTER
	var pos: Vector2 = BOSS_ARENA_CENTER
	for _attempt: int in range(10):
		var x: float = randf_range(
			BOSS_ARENA_CENTER.x - BOSS_ARENA_RADIUS, BOSS_ARENA_CENTER.x + BOSS_ARENA_RADIUS
		)
		var y: float = randf_range(
			BOSS_ARENA_CENTER.y - BOSS_ARENA_RADIUS, BOSS_ARENA_CENTER.y + BOSS_ARENA_RADIUS
		)
		pos = Vector2(x, y).round()
		if pos.distance_to(player_pos) > 32.0:
			break
	return pos


func _move_torren_to_reserve() -> void:
	var torren_idx: int = _find_member_index("torren")
	if torren_idx < 0:
		return
	if not PartyState.formation.has("active") or not PartyState.formation.has("reserve"):
		push_warning("CleansingSequence: formation missing active/reserve keys")
		return
	var active: Array = PartyState.formation["active"]
	var reserve: Array = PartyState.formation["reserve"]
	var found: Variant = null
	for a: Variant in active:
		if (a is int or a is float) and int(a) == torren_idx:
			found = a
			break
	if found != null:
		active.erase(found)
		reserve.append(torren_idx)


func _restore_torren_to_active() -> void:
	var torren_idx: int = _find_member_index("torren")
	if torren_idx < 0:
		return
	if not PartyState.formation.has("active") or not PartyState.formation.has("reserve"):
		push_warning("CleansingSequence: formation missing active/reserve keys")
		return
	var active: Array = PartyState.formation["active"]
	var reserve: Array = PartyState.formation["reserve"]
	var found: Variant = null
	for r: Variant in reserve:
		if (r is int or r is float) and int(r) == torren_idx:
			found = r
			break
	if found != null:
		reserve.erase(found)
		if active.size() < 4:
			active.append(torren_idx)
		else:
			push_warning("CleansingSequence: cannot restore Torren — active party full")


func _find_member_index(character_id: String) -> int:
	for i: int in range(PartyState.members.size()):
		if PartyState.members[i].get("character_id", "") == character_id:
			return i
	return -1


func _revive_fallen_at_quarter_hp() -> void:
	var active_list: Array = []
	if PartyState.formation.has("active"):
		active_list = PartyState.formation["active"]
	for idx: Variant in active_list:
		if not (idx is int or idx is float):
			continue
		var mi: int = int(idx)
		if mi < 0 or mi >= PartyState.members.size():
			continue
		var m: Dictionary = PartyState.members[mi]
		if m.get("current_hp", 0) <= 0:
			m["current_hp"] = maxi(1, int(m.get("max_hp", 1)) / 4)
