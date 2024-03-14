extends Control

const PROP_HINT = preload("res://ui/prop_hint/prop_hint.tscn")


func scan() -> void:
	for node in get_tree().get_nodes_in_group("Interaction"):
		
		var _prop_hint := PROP_HINT.instantiate()
		_prop_hint.prop = node
		add_child(_prop_hint)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom"):
		scan()
	if event.is_action_released("zoom"):
		for child in get_children():
			child.queue_free()
