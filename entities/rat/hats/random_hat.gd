extends Node3D

func _ready() -> void:
	if randi() % 4 != 0:
		queue_free()
	var hat := randi() % get_child_count()
	for i in range(get_child_count()):
		if i != hat:
			get_child(i).queue_free()
