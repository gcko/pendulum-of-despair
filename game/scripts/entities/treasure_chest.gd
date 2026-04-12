extends Area2D
## Treasure chest that gives an item on first interaction.
##
## Tracks opened state via EventFlags. Emits signal on open —
## does not directly modify inventory (consumer's responsibility).
##
## Usage: instance treasure_chest.tscn, call initialize("chest_01", "potion").

## Emitted when the chest is opened for the first time.
signal chest_opened(chest_id: String, item_id: String, quantity: int)

## Unique identifier for save tracking.
var chest_id: String = ""

## Item ID to give when opened.
var item_id: String = ""

## How many of the item to give.
var quantity: int = 1

## Whether this chest has already been opened.
var is_opened: bool = false

## Child node references.
@onready var _sprite: Sprite2D = $Sprite2D


## Initialize the chest with an ID and item. Checks EventFlags for prior open.
func initialize(p_chest_id: String, p_item_id: String, p_quantity: int = 1) -> void:
	if p_chest_id == "" or p_item_id == "":
		push_error("TreasureChest: empty chest_id or item_id")
		return
	chest_id = p_chest_id
	item_id = p_item_id
	quantity = maxi(1, p_quantity)
	var flag_name: String = "chest_%s_opened" % chest_id
	is_opened = EventFlags.get_flag(flag_name)
	if is_opened:
		_set_open_sprite()


## Called by exploration scene when player interacts.
func interact() -> void:
	var req: String = get_meta("required_flag", "")
	if not req.is_empty() and not EventFlags.get_flag(req):
		return
	if chest_id == "":
		return
	if is_opened:
		return
	is_opened = true
	EventFlags.set_flag("chest_%s_opened" % chest_id, true)
	_set_open_sprite()
	chest_opened.emit(chest_id, item_id, quantity)


func _set_open_sprite() -> void:
	var open_path: String = "res://assets/sprites/interactables/placeholder_chest_open.png"
	if not ResourceLoader.exists(open_path):
		push_error("TreasureChest: Open sprite not found: %s" % open_path)
		return
	var sprite: Sprite2D = _sprite if _sprite != null else get_node_or_null("Sprite2D")
	if sprite != null:
		var texture: Texture2D = load(open_path)
		sprite.texture = texture
