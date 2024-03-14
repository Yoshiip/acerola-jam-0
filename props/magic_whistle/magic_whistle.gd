extends RigidProp

@onready var magic_trolley : RigidBody3D

func use(player : Player) -> void:
	$audio.play()
	var _trolley := get_tree().get_nodes_in_group("Trolley")
	if !_trolley.is_empty():
		_trolley[0].whistle(player.global_position)
