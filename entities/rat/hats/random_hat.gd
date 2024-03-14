extends Node3D


func _ready() -> void:
	if randi() % 4 != 0:
		queue_free()
