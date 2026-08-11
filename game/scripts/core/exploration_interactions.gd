class_name ExplorationInteractions
extends RefCounted
## What happens when the player touches something on a map: NPCs, shops, inns,
## chests, save points and dialogue triggers.
##
## Extracted from exploration.gd (GAP-087). The chest registries live here
## because the chest handler is the only thing that reads them.

## Fallback inn price when a map's inn node carries no `inn_cost` metadata
## (economy.md § Inns).
const DEFAULT_INN_COST: int = 150

var _exploration: Exploration
## Chest ids whose contents are key items / equipment rather than stackables.
var _key_item_chest_ids: Dictionary = {}
var _equipment_chest_ids: Dictionary = {}


func _init(exploration: Exploration) -> void:
	_exploration = exploration


func register_key_item_chest(chest_id: String) -> void:
	_key_item_chest_ids[chest_id] = true


func register_equipment_chest(chest_id: String) -> void:
	_equipment_chest_ids[chest_id] = true


## Forget the chest registries — called as a map is swapped out.
func clear_chest_registries() -> void:
	_key_item_chest_ids = {}
	_equipment_chest_ids = {}


## The player pressed the action button against something. Interactables that
## put their collision shape on a child node are resolved to their owner.
func on_interaction_requested(interactable: Node2D) -> void:
	if _exploration.is_transitioning() or _exploration.is_in_cutscene():
		return
	var target: Node2D = interactable
	if not target.has_method("interact"):
		var owner_node: Node = target.owner
		if owner_node is Node2D and owner_node.has_method("interact"):
			target = owner_node as Node2D
	if target.has_method("interact"):
		target.interact()


## Talking to an NPC. Shopkeepers open the shop and innkeepers charge for a
## rest; everyone else says their line.
func on_npc_interacted(npc_id: String, dialogue_data: Dictionary) -> void:
	var npc_node: Node = _find_entity_npc(npc_id)
	if npc_node != null:
		if npc_node.has_meta("shop_id"):
			GameManager.transition_data = {"shop_id": npc_node.get_meta("shop_id")}
			if GameManager.push_overlay(GameManager.OverlayState.SHOP):
				return
		if npc_node.has_meta("inn_id"):
			_handle_inn(npc_node)
			return
	if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		connect_dialogue_signals(GameManager.overlay_node)
		GameManager.overlay_node.show_dialogue([dialogue_data])


## A chest was opened. Which inventory the contents land in depends on how the
## chest registered itself when the map loaded.
func on_chest_opened(chest_id: String, item_id: String, quantity: int) -> void:
	if _key_item_chest_ids.get(chest_id, false):
		PartyState.add_key_item(item_id)
	elif _equipment_chest_ids.get(chest_id, false):
		PartyState.add_equipment(item_id)
	else:
		PartyState.add_item(item_id, quantity)
	_exploration.flash_location_name("Found %s!" % item_id)


func on_save_point_activated() -> void:
	if _exploration.is_transitioning() or _exploration.is_in_cutscene():
		return
	PartyState.is_at_save_point = true
	if GameManager.push_overlay(GameManager.OverlayState.SAVE_LOAD):
		GameManager.overlay_node.open_save_point()


func on_save_point_entered() -> void:
	if (
		_exploration.is_transitioning()
		or _exploration.is_in_cutscene()
		or _exploration.is_in_auto_walk()
	):
		return
	AudioManager.play_sfx("save_point_chime", AudioManager.Priority.EXPLORATION_SFX)


## Walking into a dialogue trigger area. Every gate — already-fired flag,
## required flags — is checked before the overlay opens.
func on_dialogue_trigger_entered(body: Node2D, area: Area2D) -> void:
	if not _is_player_free_to_trigger(body):
		return
	var flag: String = area.get_meta("flag", "")
	if not flag.is_empty() and EventFlags.get_flag(flag):
		return
	var required: String = area.get_meta("required_flag", "")
	if not required.is_empty() and not EventFlags.get_flag(required):
		return
	var required_multi: String = area.get_meta("required_flags", "")
	if not required_multi.is_empty() and not EventFlags.check_required_flags(required_multi):
		return
	var dialogue: Variant = area.get_meta("dialogue_data", [])
	var scene_id: String = area.get_meta("dialogue_scene_id", "")
	if scene_id != "":
		dialogue = DataManager.load_dialogue(scene_id).get("entries", [])
	if not (dialogue is Array) or (dialogue as Array).is_empty():
		return
	if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		connect_dialogue_signals(GameManager.overlay_node)
		GameManager.overlay_node.show_dialogue(dialogue as Array)
		if not flag.is_empty():
			EventFlags.set_flag(flag, true)
			GameManager.overlay_state_changed.connect(
				on_dialogue_closed_check_party, Object.CONNECT_ONE_SHOT
			)


## Once a flagged trigger dialogue closes, pick up anyone it recruited and
## break Edren's arcanite gear if the Ember Vein escape just finished.
func on_dialogue_closed_check_party(state: GameManager.OverlayState) -> void:
	if state != GameManager.OverlayState.NONE:
		GameManager.overlay_state_changed.connect(
			on_dialogue_closed_check_party, Object.CONNECT_ONE_SHOT
		)
		return
	ExplorationPartyJoins.check_join_flags(_exploration)
	if (
		EventFlags.get_flag("ember_vein_1e_seen")
		and not EventFlags.get_flag("arcanite_gear_broken")
	):
		PartyState.break_arcanite_gear()
		EventFlags.set_flag("arcanite_gear_broken", true)


## Walking into a map-transition area.
func on_transition_body_entered(body: Node2D, area: Area2D) -> void:
	if not _is_player_free_to_trigger(body):
		return
	var req_flag: String = area.get_meta("required_flag", "")
	if not req_flag.is_empty() and not EventFlags.get_flag(req_flag):
		return
	var tgt: String = area.get_meta("target_map", "")
	if tgt != "":
		_exploration.transition_to_map(tgt, area.get_meta("target_spawn", ""))


## Connect the dialogue box sfx_requested signal to AudioManager for
## non-cutscene dialogues (NPC interaction, dialogue triggers).
func connect_dialogue_signals(overlay: Node) -> void:
	DialogueConsequences.connect_overlay(overlay)
	if overlay != null and overlay.has_signal("sfx_requested"):
		if not overlay.is_connected("sfx_requested", _on_dialogue_sfx):
			overlay.sfx_requested.connect(_on_dialogue_sfx)


## Drop the one-shot party check if the scene is torn down before the dialogue
## it was waiting on closes.
func disconnect_pending_signals() -> void:
	if GameManager.overlay_state_changed.is_connected(on_dialogue_closed_check_party):
		GameManager.overlay_state_changed.disconnect(on_dialogue_closed_check_party)


func _on_dialogue_sfx(sfx_id: String) -> void:
	if not sfx_id.is_empty():
		AudioManager.play_sfx(sfx_id, AudioManager.Priority.UI_SFX)


## Whether [param body] is the player and the scene is in a state where walking
## into a trigger should fire it.
func _is_player_free_to_trigger(body: Node2D) -> bool:
	if body != _exploration.get_player():
		return false
	return not (
		_exploration.is_transitioning()
		or _exploration.is_in_cutscene()
		or _exploration.is_in_auto_walk()
	)


## The spawned entity node for an NPC id, if it is still alive and really an NPC.
func _find_entity_npc(npc_id: String) -> Node:
	var entity: Variant = _exploration.get_entities().get(npc_id, null)
	if entity is Node and is_instance_valid(entity) and entity.has_signal("npc_interacted"):
		return entity
	return null


## Pay for a night at the inn, or say the party cannot afford it.
func _handle_inn(node: Node) -> void:
	if not PartyState.spend_gold(node.get_meta("inn_cost", DEFAULT_INN_COST)):
		_exploration.flash_location_name("Not enough gold.")
		return
	PartyState.rest_at_inn()
	_exploration.flash_location_name("Rested at the inn.")
