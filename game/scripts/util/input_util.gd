class_name InputUtil
extends RefCounted
## Static input helpers shared across UI scripts.


## Mark the current input event as handled so it does not propagate
## further down the scene tree.  Safe to call from any Node.
static func consume(node: Node) -> void:
	var vp: Viewport = node.get_viewport()
	if vp != null:
		vp.set_input_as_handled()
