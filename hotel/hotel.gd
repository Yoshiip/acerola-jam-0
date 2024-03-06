class_name Hotel

extends Node3D

@export var floor_number := 1
@export var max_floor := 3



const CUSTOMER = preload("res://hotel/customer/customer.tscn")



const ITEMS := {
	"whistle": preload("res://items/whistle.tres"),
	"magic_whistle": preload("res://items/magic_whistle.tres"),
	"bed": preload("res://items/bed.tres")
}

@onready var current_floor := $ground_floor
@onready var player := $player

const FLOORS : Array[PackedScene] = [
	preload("res://hotel/floors/ground_floor.tscn"),
	preload("res://hotel/floors/0.tscn"),
	preload("res://hotel/floors/1.tscn"),
]

var floors_data := {}

func _ready() -> void:
	if PlayerData.hotel_level_data != null:
		$level.queue_free()
		var _child := PlayerData.hotel_level_data
		add_child(_child)
	randomize()
	$generation.place_rooms($ground_floor/markers)

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
	current_floor.add_child(_prop)
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

func _process(_delta: float) -> void:
	if player.position.y < -64:
		get_tree().reload_current_scene()


func save_floor() -> void:
	var _data := []
	for prop in get_tree().get_nodes_in_group("Prop"):
		_data.append(prop.duplicate())
	floors_data[floor_number] = _data


func load_floor(target_floor : int) -> void:
	if !floors_data.has(target_floor):
		return
	for node in floors_data[target_floor]:
		current_floor.add_child(node)


func change_floor(new_floor : int) -> void:
	var _lift_pos : Vector3 = current_floor.get_node("lift").global_position
	save_floor()
	
	floor_number = new_floor % FLOORS.size()
	current_floor.queue_free()
	var _floor := FLOORS[floor_number].instantiate()
	add_child(_floor)
	current_floor = _floor
	
	var _room_generated := floors_data.has(floor_number)
	# add rooms if the floor_number was never loaded
	$generation.place_rooms(_floor.get_node("markers"), !_room_generated)
	$player.global_position += (current_floor.get_node("lift").global_position - _lift_pos)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		get_window().mode = Window.MODE_WINDOWED if get_window().mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN


func spawn_customer() -> void:
	var _customer := CUSTOMER.instantiate()
	_customer.position = Vector3.UP
	$level/customers.add_child(_customer)


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

func end_day() -> void:
	PlayerData.hotel_level_data = $level.duplicate()
	get_tree().change_scene_to_file("res://hotel/transition/day_end.tscn")
