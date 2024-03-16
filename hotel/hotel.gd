
class_name Hotel

extends Node3D

signal new_day_started
signal rats_changed

var floor_number := 1
var max_floor := 1


const CUSTOMERS := {
	"ghost": preload("res://entities/customer/ghost/ghost_customer.tscn"),
	"monkey": preload("res://entities/customer/monkey/monkey_customer.tscn"),
	"donut": preload("res://entities/customer/donut/donut_customer.tscn"),
}



const ITEMS := {
	"cardboard": preload("res://resources/props/cardboard.tres"),
	"whistle": preload("res://resources/props/whistle.tres"),
	#"magic_whistle": preload("res://resources/props/magic_whistle.tres"),
	"bell": preload("res://resources/props/bell.tres"),
	"broom": preload("res://resources/props/broom.tres"),
	"trap": preload("res://resources/props/trap.tres"),
	
	# DECORATIONS
	"bed": preload("res://resources/props/bed.tres"),
	"carpet": preload("res://resources/props/carpet.tres"),
	"door_mat": preload("res://resources/props/door_mat.tres"),
	"fountain": preload("res://resources/props/fountain.tres"),
	"vase": preload("res://resources/props/vase.tres"),
	
	# GARBAGE
	"trash_bag": preload("res://resources/props/trash_bag.tres"),
	"water": preload("res://resources/props/water.tres"),

	# GIFTS
	"banana": preload("res://resources/props/gifts/banana.tres"),
	"bouncing_ball": preload("res://resources/props/gifts/bouncing_ball.tres"),
	"star": preload("res://resources/props/gifts/star.tres"),
	
	# BLUEPRINTS
	"chamber_blueprint": preload("res://resources/props/blueprints/chamber_blueprint.tres"),
	"deluxe_chamber_blueprint": preload("res://resources/props/blueprints/deluxe_chamber_blueprint.tres"),
	"storage_blueprint": preload("res://resources/props/blueprints/storage_blueprint.tres"),
	"garbage_blueprint": preload("res://resources/props/blueprints/garbage_blueprint.tres"),
	
	"rat": preload("res://resources/props/rat.tres"),
	
	# PAINTS
	"red_paint": preload("res://resources/props/paints/red.tres"),
	"green_paint": preload("res://resources/props/paints/green.tres"),
	"blue_paint": preload("res://resources/props/paints/blue.tres"),
	"purple_paint": preload("res://resources/props/paints/purple.tres"),
	
}



@onready var current_floor := $"0"
@onready var player := $player

var transitioning := false

var floors_color := ["red"]

const FLOORS : Array[PackedScene] = [
	#preload("res://hotel/floors/0.tscn"),
	preload("res://hotel/floors/1.tscn"),
	preload("res://hotel/floors/2.tscn"),
	preload("res://hotel/floors/3.tscn"),
	preload("res://hotel/floors/4.tscn"),
	preload("res://hotel/floors/5.tscn"),
]

@onready var hotel_floors := [
	$"0"
]


const DEFAULT_TIME_LEFT := 240.0

var time_left := DEFAULT_TIME_LEFT
var cleanliness = 1.0

const RAT = preload("res://entities/rat/rat.tscn")



func _ready() -> void:
	randomize()
	$generation.place_rooms($"0", 0)
	add_floor(FLOORS[0])
	#add_floor(FLOORS[1])
	#add_floor(FLOORS[2])
	#add_floor(FLOORS[3])
	#add_floor(FLOORS[4])
	start_new_day()
	create_prop(ITEMS.whistle, $"0/whistle".global_position, $"0/whistle".global_rotation)
	#
	#create_prop(ITEMS.trap)
	#create_prop(ITEMS.bouncing_ball)
	#create_prop(ITEMS.star)
	#create_prop(ITEMS.trash_bag)
	#for i in 100:
		#add_rat_hole()


func add_random_floor() -> void:
	add_floor(FLOORS.pick_random())

func add_floor(floor_scene : PackedScene) -> void:
	floors_color.append(["red", "green", "blue", "purple"].pick_random())
	var _floor := floor_scene.instantiate()
	_floor.name = str(max_floor)
	_floor.floor_color = floors_color[max_floor]
	_floor.position.y = hotel_floors.size() * 8.0
	add_child(_floor)
	$generation.place_rooms(_floor, hotel_floors.size())
	hotel_floors.append(_floor)
	max_floor = hotel_floors.size()

var customers_bonus := 0

func start_new_day() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	PlayerData.day += 1
	time_left = DEFAULT_TIME_LEFT
	
	music_played = false
	transitioning = false
	
	new_day_started.emit()
	
	for reward in PlayerData.rewards_to_apply:
		match reward:
			"bag":
				if player.inventory.size() == 6:
					PlayerData.money += randi_range(15, 20) * 10
				else:
					player.inventory.append(null)
					player.inventory_changed.emit()
			"customers":
				customers_bonus += 1
			"vip":
				PlayerData.vip_chance -= 1
			"money":
				PlayerData.money += randi_range(15, 20) * 10
			#"gift":
				## TODO
				#pass
	PlayerData.rewards_to_apply.clear()
	
	if PlayerData.day > 1:
		for i in range((floor(PlayerData.day) / 4) + randi_range(1, 2)):
			add_rat_hole()
	
	player.global_transform = $player_start_transform.global_transform
	$canvas/container/day/value.text = str(PlayerData.day)
	$canvas/container/day/animation_player.play("fade")
	$canvas/container/transition/animation_player.play("fade_out")
	for customer in $customers.get_children():
		if customer.room_assigned == null:
			customer.queue_free()
		else:
			customer.nights_left -= 1
			if customer.nights_left <= 0:
				customer.room_assigned.assigned_to = null
				customer.room_assigned = null
				customer.queue_free()

	if PlayerData.day >= 3:
		for prop in $props.get_children():
			if !prop.get("fixed") && is_instance_of(prop, StaticProp) && randi() % 8 == 0:
				prop.flip()


func get_random_wall_point(floor : int) -> Vector4:
	var _walls : Array[StaticBody3D]
	for node in get_node(str(floor)).get_children():
		if node.get_meta("is_wall", false) && floor(node.global_position.y / 8.0) == floor && node.get_meta("rat_hole_expands") != 0.0:
			_walls.append(node)
	var _wall : StaticBody3D = _walls.pick_random()
	if is_instance_valid(_wall):
		var _pos := _wall.global_position + Vector3(
			randf_range(-_wall.get_meta("rat_hole_expands"), _wall.get_meta("rat_hole_expands")),
			0, 0).rotated(Vector3.UP, _wall.global_rotation.y)
		return Vector4(_pos.x, _pos.y, _pos.z, _wall.global_rotation.y)
	return Vector4.INF

func get_item(id : String) -> Item:
	if ITEMS.has(id):
		return ITEMS.get(id).duplicate()
	if id == "cardboard":
		return ITEMS.cardboard.duplicate()
	return null

func create_prop(from : Item, pos : Vector3 = Vector3(randf(), 2, randf()), rot : Vector3 = Vector3.ZERO) -> Node3D:
	var _prop : Node3D = from.prop.instantiate()
	_prop.id = from.id
	_prop.set("display_name", from.get("name"))
	_prop.set("description", from.get("description"))
	_prop.set("item_reference", from)
	_prop.set("hotel", self)
	for key in from.get("data"):
		_prop.set(key, from.data[key])
	_prop.position = pos
	_prop.rotation = rot
	$props.add_child(_prop)
	_prop.name = from.id
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

func _process(delta: float) -> void:
	time_left -= delta
	if player.position.y < -64:
		get_tree().reload_current_scene()


const RAT_HOLE = preload("res://entities/rat/rat_hole.tscn")

func add_rat_hole() -> void:
	var _point := get_random_wall_point(randi() % hotel_floors.size())
	var _hole := RAT_HOLE.instantiate()
	
	_hole.position = Vector3(_point.x, _point.y, _point.z)
	_hole.rotation.y = _point.w
	add_child(_hole)

func change_floor(new_floor : int, bodies : Array[Node3D]) -> void:
	var _old_elevator_pos : Vector3 = current_floor.get_node("lift").global_position
	var _old_elevator_rot : float = current_floor.get_node("lift").rotation.y
	
	current_floor.get_node("lift").screen_floor = floor_number
	floor_number = new_floor % hotel_floors.size()
	current_floor = hotel_floors[floor_number]

	var _new_elevator_pos : Vector3 = current_floor.get_node("lift").global_position
	var _new_elevator_rot : float = current_floor.get_node("lift").rotation.y
	
	var _tween := get_tree().create_tween()
	_tween.tween_property(AudioServer.get_bus_effect(2, 0), "wet", floor_number / 25.0, 5.0)
	
	current_floor.get_node("lift").door_animate(true, true) # instant close
	current_floor.get_node("lift").door_animate(false, false) # play reopen
	
	for body in bodies:
		var _new_pos : Vector3 = _new_elevator_pos + (body.position - _old_elevator_pos).rotated(Vector3.UP, -(_old_elevator_rot - _new_elevator_rot))
		body.global_position = _new_pos
		
		body.rotation.y += _new_elevator_rot - _old_elevator_rot
		
	await get_tree().create_timer(2.0).timeout
	$effects/bell.play()


func spawn_customer() -> void:
	await get_tree().create_timer(randf_range(0.5, 1.5)).timeout
	$door.play()
	
	var _customer : Customer = CUSTOMERS.values().pick_random().instantiate()
	_customer.position = $customer_spawn_position.position + Vector3(randf(), 0, randf())
	$customers.add_child(_customer)


func get_nearest_customer(pos : Vector3, no_room = false) -> Customer:
	var _customers := $customers.get_children()
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
	if transitioning:
		return
	for rat in get_tree().get_nodes_in_group("Rat"):
		if !rat.dead:
			var _hole := get_nearest_hole(rat)
			if is_instance_valid(_hole):
				_hole.rat_entered(rat)
			else:
				rat.queue_free()
	for customer in $customers.get_children():
		customer.calculate_happiness()
	transitioning = true
	$canvas/container/transition/animation_player.play("fade_in")
	await get_tree().create_timer(0.8).timeout
	GameManager.to_day_results()

func pack(prop : Node3D) -> bool:
	if prop.get("id") != "cardboard":
		var _ref : Item = prop.item_reference
		var _cardboard := create_prop(ITEMS.cardboard, prop.global_position, prop.global_rotation)
		var _prop := prop.duplicate()
		_prop.item_reference = _ref
		_cardboard.inside = _prop
		prop.queue_free()
		return true
	return false


func get_random_stealable_prop(rat : Rat) -> Node3D:
	var _props : Array[Node3D]
	for node in get_tree().get_nodes_in_group("Interaction"):
		if (node.get_floor() == rat.get_floor()
		&& !node.holded
		&& !node.is_in_group("Trap") && !node.is_in_group("Rat")
		&& node.get("stealable") != true && node.get("fixed") != true
		&& (node.global_position.y - rat.global_position.y) < 0.2):
			_props.append(node)
	if _props.is_empty():
		return null
	return _props.pick_random()

func get_random_position(floor : int) -> Vector3:
	if floor != -1:
		var _carpets : Array[Sprite3D]
		for node in get_node(str(floor)).get_node("carpets").get_children():
			_carpets.append(node)
		var _carpet : Sprite3D = _carpets.pick_random()
		if is_instance_valid(_carpet):
			var _dimensions := _carpet.region_rect.size * _carpet.pixel_size
			var _pos := _carpet.global_position + Vector3(
				randf_range(-_dimensions.x / 2 - 0.5, _dimensions.x / 2 + 0.5),
				0,
				randf_range(-_dimensions.y / 2, _dimensions.y / 2),
				).rotated(Vector3.UP, _carpet.global_rotation.y)
			return Vector3(_pos.x, _pos.y, _pos.z)
	return Vector3.INF

func get_nearest_hole(rat : Rat) -> Node3D:
	var _nearest : Node3D
	var _rat_pos := rat.global_position
	for hole in get_tree().get_nodes_in_group("Hole"):
		if (hole.get_floor() == rat.get_floor() &&
		(_nearest == null || _rat_pos.distance_to(hole.position) < _nearest.global_position.distance_to(_rat_pos))):
			_nearest = hole
	if !is_instance_valid(_nearest):
		return null
	return _nearest


func _on_dirt_timer_timeout() -> void:
	if time_left <= 0:
		return
	$dirt_timer.wait_time = randf_range(120.0, 180.0) * max(cleanliness, 0.2)
	var _floors := range(hotel_floors.size())
	_floors.shuffle()
	for floor in _floors:
		if floor != player.get_floor():
			var _prop := create_prop([ITEMS.water, ITEMS.trash_bag].pick_random(), get_random_position(floor), Vector3(0, randf() * PI * 2, 0))
			for customer in $customers.get_children():
				customer.calculate_happiness()
			return


func _on_music_timeout() -> void:
	for music in $musics.get_children():
		music.stop()
		music.play()

func get_total_dirts_object_floor(floor : int) -> int:
	var _total := 0
	for node in get_tree().get_nodes_in_group("Garbage"):
		if node.get_floor() == floor:
			_total += 1
	return _total

func get_total_garbage() -> int:
	var _total := 0
	for node in get_tree().get_nodes_in_group("Garbage"):
		_total += 2
	for hole in get_tree().get_nodes_in_group("Hole"):
		_total += 3
	return _total

var music_played := false

func get_rats_at_floor(floor : int) -> int:
	var _total := 0
	for rat in get_tree().get_nodes_in_group("Rat"):
		if rat.get_floor() == floor:
			_total += 1
	return _total

func update_music() -> void:
	
	if music_played:
		return
	music_played = true
	var _customers := PlayerData.unique_customers
	_on_music_timeout()
	$"musics/0".volume_db = 0 if _customers >= 1 else -80
	$"musics/1".volume_db = 0 if _customers >= 3 else -80
	$"musics/2".volume_db = 0 if _customers >= 5 else -80
	$"musics/3".volume_db = 0 if _customers >= 7 else -80
	$"musics/4".volume_db = 0 if _customers >= 10 else -80
	$"musics/5".volume_db = 0 if _customers >= 15 else -80

func show_computer_ui() -> void:
	$canvas/container/computer.display()

func delivery(id : String) -> void:
	var _prop := create_prop(ITEMS[id], $"0/DeliveryRoom".global_position + Vector3(
		randf_range(-2, 2), 2, randf_range(-2, 2)
	), Vector3(0, randf() * PI * 2, 0))
	if is_instance_of(_prop, StaticProp):
		pack(_prop)


var _last_clean := 1.0
func _on_update_timeout() -> void:
	cleanliness = 1.0 - clamp((get_total_garbage() - $customers.get_child_count()) / 75.0, 0.0, 1.0)
	if _last_clean != cleanliness:
		$canvas/container/cleanliness.value = cleanliness
		$canvas/container/cleanliness.visible = true
	else:
		$canvas/container/cleanliness.visible = false
	
	_last_clean = cleanliness
