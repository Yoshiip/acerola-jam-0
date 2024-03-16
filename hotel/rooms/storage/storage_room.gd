extends StaticBody3D

@onready var hotel : Hotel = get_tree().current_scene

func _ready() -> void:
	var props := []
	for i in range(randi_range(4, 5)):
		props.append(["red_paint", "green_paint", "blue_paint", "purple_paint", "bed", "carpet", "broom", "trap"].pick_random())
	var _points_history : Array
	while !props.is_empty():
		var _point : Node = $random_points.get_children().pick_random()
		if !_points_history.has(_point):
			_points_history.append(_point)
			var _prop := hotel.create_prop(hotel.ITEMS[props[0]], _point.global_position, _point.global_rotation + Vector3(0, PI / 2, 0))
			if is_instance_of(_prop, StaticProp):
				hotel.pack(_prop)
			props.remove_at(0)
