extends Node

var current_floor : Node3D
var floor_number : int

const WALL = preload("res://hotel/walls/wall.tscn")

const ROOMS := {
	"chamber": preload("res://hotel/rooms/chamber/chamber.tscn"),
	"lift": preload("res://hotel/rooms/lift/lift.tscn"),
	"construction": preload("res://hotel/rooms/construction/construction.tscn"),
	"deluxe_chamber": preload("res://hotel/rooms/deluxe_chamber/deluxe_chamber.tscn"),
	"storage": preload("res://hotel/rooms/storage/storage_room.tscn"),
	"garbage": preload("res://hotel/rooms/trash_room/trash_room.tscn"),
}

var colors : Array[String] = []

func generate_room(markers : Node3D) -> Array[Dictionary]:
	var chambers_left := randi_range(3, 4)
	var construction_left := 3 if chambers_left == 3 else 2
	var lifts_left := 1
	var _markers := markers.get_children()
	_markers.shuffle()
	var _rooms : Array[Dictionary] = []
	for i in range(_markers.size()):
		var _marker : Marker3D = _markers[i]
		var _angles : Array[Vector4] = _marker.get_all_angles()
		var _data := {
			"angles": _angles,
			"transform": _marker.global_transform,
			"rat": _marker.rat_hole_expands,
		}
		if !_marker.force_wall:
			if lifts_left > 0:
				_data["room_id"] = "lift"
				lifts_left -= 1
			elif chambers_left > 0:
				_data["room_id"] = "chamber"
				chambers_left -= 1
			elif construction_left > 0:
				_data["room_id"] = "construction"
				construction_left -= 1
			_data["room_angle"] = randi() % _angles.size()
		_rooms.append(_data)
	return _rooms

func place_room(room_data : Dictionary, room_name : String = room_data.room_id) -> Node3D:
	var _room : Node3D = ROOMS[room_data.room_id].instantiate()
	_room.name = room_name
	_room.set("hotel", hotel)
	
	var _marker_transform : Transform3D = room_data.transform
	_room.position = _marker_transform.origin * Vector3(1, 0, 1)
	_room.rotation.y = room_data.angles[0].w + _marker_transform.basis.get_euler().y + PI
	if room_data.get("floor") != null:
		_room.set("floor_color", hotel.floors_color[room_data.floor])
		var _floor := get_parent().get_node(str(room_data.floor))
		
		_floor.add_child(_room)
		if room_data.get("rebake_floor"):
			$"../effects/plinth".play()
			await get_tree().physics_frame
			_floor.generate_navigation()
	else:
		_room.set("floor_color", hotel.floors_color[floor_number])
		current_floor.add_child(_room)
	return _room

@onready var hotel : Hotel = get_tree().current_scene

func place_rooms(floor : NavigationRegion3D, floor_number : int) -> void:
	current_floor = floor
	self.floor_number = floor_number
	var _chambers_placed := 0
	for room in generate_room(floor.get_node("markers")):
		var _angles : Array[Vector4] = room.angles
		
		if room.has("room_id"):
			match room.room_id:
				"chamber":
					_chambers_placed += 1
					place_room(room, str(floor_number + 1, "0", _chambers_placed))
				"lift":
					var _lift := await place_room(room)
					_lift.screen_floor = floor_number
				_:
					place_room(room)
					
			for i in range(1, _angles.size()):
				_place_wall(room.transform, _angles[i], room.rat)
		else:
			for angle in _angles:
				_place_wall(room.transform, angle, room.rat)
	current_floor.generate_navigation()


func _place_wall(marker_transform : Transform3D, angle : Vector4, rat : float) -> void:
	var _wall := WALL.instantiate()
	_wall.position = Vector3(angle.x, angle.y, angle.z) + marker_transform.origin - current_floor.global_position
	_wall.rotation.y = angle.w + marker_transform.basis.get_euler().y
	_wall.color = hotel.floors_color[floor_number]
	_wall.set_meta("rat_hole_expands", rat)
	current_floor.add_child(_wall)
