extends Node

const MAX_CHAMBERS := 4
const MAX_LIFTS := 1

var current_floor : Node3D
var floor_number : int

const WALL = preload("res://hotel/walls/wall.tscn")

const ROOMS := {
	"chamber": preload("res://hotel/rooms/chamber/chamber.tscn"),
	"lift": preload("res://hotel/rooms/lift/lift.tscn")
}

func generate_room(markers : Node3D) -> Array[Dictionary]:
	var chambers_placed := 0
	var lifts_placed := 0
	var _markers := markers.get_children()
	_markers.shuffle()
	var _rooms : Array[Dictionary] = []
	for i in range(_markers.size()):
		var _marker : Marker3D = _markers[i]
		var _angles : Array[Vector4] = _marker.get_all_angles()
		var _data := {
			"angles": _angles,
			"transform": _marker.global_transform
		}
		if !_marker.force_wall:
			if chambers_placed < MAX_CHAMBERS:
				_data["room_id"] = "chamber"
				chambers_placed += 1
			elif lifts_placed < MAX_LIFTS:
				_data["room_id"] = "lift"
				lifts_placed += 1
			_data["room_angle"] = randi() % _angles.size()
		_rooms.append(_data)
	return _rooms

func _place_room(
	room_data : Dictionary,
	offset = Vector3.ZERO,
	generate = true,
	room_name : String = room_data.room_id
) -> void:
	var _room : Node3D = ROOMS[room_data.room_id].instantiate()
	_room.generate = generate
	_room.name = room_name
	
	var _marker_transform : Transform3D = room_data.transform
	_room.position = _marker_transform.origin + offset
	_room.rotation.y = room_data.angles[0].w + _marker_transform.basis.get_euler().y
	current_floor.add_child(_room) 

@onready var root := get_tree().current_scene

func place_rooms(markers : Node3D, generate = true) -> void:
	current_floor = root.current_floor
	floor_number = root.floor_number
	var _chambers_placed := 0
	for room in generate_room(markers):
		var _angles : Array[Vector4] = room.angles
		
		if room.has("room_id"):
			match room.room_id:
				"chamber":
					_chambers_placed += 1
					var _angle := _angles[0]
					_place_room(
						room,
						Vector3(_angle.x, _angle.y, _angle.z).normalized() * 2.0,
						generate,
						str(floor_number, "0", _chambers_placed)
					)
				_:
					_place_room(room, Vector3.ZERO, generate)
					
			for i in range(1, _angles.size()):
				_place_wall(room.transform, _angles[i])
		else:
			for angle in _angles:
				_place_wall(room.transform, angle)

		#_chamber.position = 

func _place_wall(marker_transform : Transform3D, angle : Vector4) -> void:
	var _wall := WALL.instantiate()
	_wall.position = Vector3(angle.x, angle.y, angle.z) + marker_transform.origin
	_wall.rotation.y = angle.w + marker_transform.basis.get_euler().y
	current_floor.add_child(_wall)
