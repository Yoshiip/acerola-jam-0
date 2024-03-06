extends RigidProp



@onready var root : Hotel = get_tree().current_scene

func use(player : Player) -> void:
	var _nearest := root.get_nearest_customer(player.position, true)
	if _nearest:
		_nearest.whistle(player.position)
