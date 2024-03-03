class_name Hotel

extends Node3D

@export var floor := 1
@export var max_floor := 3

const ROOMS := {
	"chamber": preload("res://hotel/rooms/chamber/chamber.tscn"),
	"lift": preload("res://hotel/rooms/lift/lift.tscn")
}

const CUSTOMER = preload("res://hotel/customer/customer.tscn")

const WALL = preload("res://hotel/walls/wall.tscn")

const ITEMS := {
	"whistle": preload("res://items/whistle.tres"),
	"magic_whistle": preload("res://items/magic_whistle.tres"),
	"bed": preload("res://items/bed.tres"),
	"bell": preload("res://items/bell.tres")
}

@onready var current_floor := $ground_floor

const MAX_CHAMBERS := 4
const MAX_LIFTS := 1

func _ready() -> void:
	randomize()
	place_rooms($ground_floor/markers)
	create_prop(ITEMS.whistle)
	create_prop(ITEMS.magic_whistle)
	create_prop(ITEMS.bell, $ground_floor/desk.global_position + Vector3(0.0, 0.5, 0.0))

func get_item(id : String) -> Item:
	if ITEMS.has(id):
		return ITEMS.get(id).duplicate()
	return null

func create_prop(from : Item, pos : Vector3 = Vector3(randf(), 2, randf()), rot : Vector3 = Vector3.ZERO) -> Node3D:
	var _prop : Node3D = from.prop.instantiate()
	_prop.name = from.id
	_prop.id = from.id
	_prop.set("display_name", from.get("name"))
	_prop.set("description", from.get("description"))
	for key in from.get("data"):
		_prop.set(key, from.data[key])
	_prop.position = pos
	_prop.rotation = rot
	$props.add_child(_prop)
	return _prop

func remove_prop(node : Node3D, item : Item = null) -> void:
	if item != null && node.get("to_save"):
		for key in node.get("to_save"):
			item.data[key] = node.get(key)
	node.queue_free()


func save_prop(node : Node3D, item : Item) -> void:
	if node != null && item != null && node.get("to_save"):
		for key in node.get("to_save"):
			item.data[key] = node.get(key)

func place_rooms(markers : Node3D) -> void:
	var chambers_placed := 0
	var lifts_placed := 0
	var _markers := markers.get_children()
	_markers.shuffle()
	for marker in _markers:
		var _angles : Array[Vector4] = marker.get_all_angles()
		if lifts_placed < MAX_LIFTS && !marker.force_wall:
			_angles.shuffle()
			var _room := ROOMS.lift.instantiate()
			for i in range(_angles.size()):
				var _angle := _angles[i]
				if i == 0: # place lift
					_room.name = "lift"
					_room.position = marker.position
					_room.rotation.y = _angle.w + marker.rotation.y
					current_floor.add_child(_room)
					lifts_placed += 1
				else: # place wall
					_place_wall(marker, _angle)
		elif chambers_placed < MAX_CHAMBERS && !marker.force_wall:
			_angles.shuffle()
			var _room := ROOMS.chamber.instantiate()
			for i in range(_angles.size()):
				var _angle := _angles[i]
				if i == 0: # place room
					_room.name = str(floor, "0", (chambers_placed + 1))
					_room.position = (Vector3(_angle.x, _angle.y, _angle.z).normalized() * 2.0) + marker.position
					_room.rotation.y = _angle.w + marker.rotation.y
					current_floor.add_child(_room)
					chambers_placed += 1
				else: # place wall
					_place_wall(marker, _angle)
		else:
			for angle in _angles:
				_place_wall(marker, angle)
		#var _room := ROOM.instantiate()
		#_room.position = marker.position
		#add_child(_room)

func _place_wall(marker : Marker3D, angle : Vector4) -> void:
	var _wall := WALL.instantiate()
	_wall.position = Vector3(angle.x, angle.y, angle.z) + marker.position
	_wall.rotation.y = angle.w + marker.rotation.y
	current_floor.add_child(_wall)

@onready var player := $player

func _process(delta: float) -> void:
	if player.position.y < -64:
		get_tree().reload_current_scene()

const FLOORS : Array[PackedScene] = [
	preload("res://hotel/floors/ground_floor.tscn"),
	preload("res://hotel/floors/0.tscn"),
	preload("res://hotel/floors/1.tscn"),
]

var floors_data := {}

func save_floor() -> void:
	var _data := []
	for prop in $props.get_children():
		_data.append(prop.duplicate())
	floors_data[floor] = _data


func change_floor(new_floor : int) -> void:
	var _lift_pos : Vector3 = current_floor.get_node("lift").global_position
	save_floor()
	for prop in $props.get_children():
		prop.queue_free()
	floor = new_floor % FLOORS.size()
	current_floor.queue_free()
	var _floor := FLOORS[floor].instantiate()
	add_child(_floor)
	current_floor = _floor
	place_rooms(_floor.get_node("markers"))
	$player.global_position += (current_floor.get_node("lift").global_position - _lift_pos)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		get_window().mode = Window.MODE_WINDOWED if get_window().mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN



func spawn_customer() -> void:
	var _customer := CUSTOMER.instantiate()
	_customer.position = Vector3.UP
	add_child(_customer)

func get_nearest_customer(pos : Vector3, no_room = false) -> Customer:
	var _customers := get_tree().get_nodes_in_group("Customer")
	if _customers.size() > 0:
		var _nearest : Customer
		for customer in _customers:
			if no_room:
				if customer.room_assigned == null:
					if _nearest == null:
						_nearest = customer
					if customer.position.distance_to(pos) < _nearest.position.distance_to(pos):
						_nearest = customer
			else:
				if _nearest == null || customer.position.distance_to(pos) < _nearest.position.distance_to(pos):
					_nearest = customer
		return _nearest
	return null
