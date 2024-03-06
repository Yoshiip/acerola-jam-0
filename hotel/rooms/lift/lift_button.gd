extends Area3D

@onready var lift: StaticBody3D = $"../.."

@export var delta := 0



func interact(_player : Player) -> void:
	var _tween := get_tree().create_tween()
	scale *= 1.25
	$text.modulate = Color.GOLD
	_tween.tween_property(self, "scale", Vector3.ONE, 0.1)
	_tween.tween_property($text, "modulate", Color.WHITE, 0.1	)
	lift.change_floor(delta)
