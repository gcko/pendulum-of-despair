extends GutTest
## Tests for dialogue_box.gd embedded_mode property.

const DIALOGUE_SCENE: PackedScene = preload("res://scenes/overlay/dialogue.tscn")


func _create_dialogue(embedded: bool = false) -> Node:
	var dlg: Node = DIALOGUE_SCENE.instantiate()
	dlg.embedded_mode = embedded
	add_child_autofree(dlg)
	return dlg


func _single_entry() -> Array:
	return [
		{
			"id": "t1",
			"speaker": "edren",
			"lines": ["Test line."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null,
		}
	]


func test_default_mode_pops_overlay_on_empty() -> void:
	var dlg: Node = _create_dialogue(false)
	watch_signals(dlg)
	dlg.show_dialogue([])
	assert_signal_emitted(dlg, "dialogue_finished")


func test_embedded_mode_does_not_pop_overlay_on_empty() -> void:
	var dlg: Node = _create_dialogue(true)
	watch_signals(dlg)
	dlg.show_dialogue([])
	assert_signal_emitted(dlg, "dialogue_finished")


func test_embedded_mode_emits_dialogue_finished() -> void:
	var dlg: Node = _create_dialogue(true)
	watch_signals(dlg)
	dlg.show_dialogue([])
	assert_signal_emitted(dlg, "dialogue_finished")


func test_embedded_mode_still_emits_animation_requested() -> void:
	var dlg: Node = _create_dialogue(true)
	watch_signals(dlg)
	var entries := [
		{
			"id": "t1",
			"speaker": "edren",
			"lines": ["Test."],
			"condition": null,
			"animations": [{"who": "edren", "anim": "nod", "when": "before_line_0"}],
			"choice": null,
			"sfx": null,
		}
	]
	dlg.show_dialogue(entries)
	assert_signal_emitted(dlg, "animation_requested")
