extends StaticProp

@onready var hotel : Hotel = get_tree().current_scene

func _ready() -> void:
	display_name = "Architect's Plinth"
	description = "Use a blueprint on this plinth to construct the building."

func interact(player : Player) -> void:
	if is_instance_valid(player.holding) && player.holding.get("id").ends_with("blueprint"):
		player.holding.queue_free()
		var _pos : Vector3 = (global_position - get_parent().global_position).normalized() * 4
		var _angle : float
		if _pos.x == -4:
			_angle = PI / 2
		elif _pos.x == 4:
			_angle = -PI / 2
		elif _pos.y == -4:
			_angle = 0
		else:
			_angle = PI
		
		
		var _name := "new_room"
		if player.holding.get("id").contains("chamber"):
			var _total := 0
			for child in hotel.get_node(str(get_floor())).get_children():
				if is_instance_of(child, Chamber):
					_total += 1
			_name = str(get_floor() + 1, "0", _total + 1)
		
		hotel.get_node("generation").place_room({
			"angles": [Vector4(_pos.x, _pos.y, _pos.z, PI)],
			"transform": get_parent().global_transform,
			"rat": 3,
			"room_id": player.holding.get("id").replace("_blueprint", ""),
			"room_angle": 0,
			"floor": get_floor(),
			"rebake_floor": true,
		}, _name)
		get_parent().queue_free()
