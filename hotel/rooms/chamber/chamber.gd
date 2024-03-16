class_name Chamber

extends StaticBody3D


var assigned_to : Customer:
	set(value):
		assigned_to = value
		$door/door/Door/owner.text = ""

func get_floor() -> int:
	return floor(global_position.y / 8.0)


var floor_number := 1
@onready var hotel : Hotel = get_tree().current_scene

var walls_color = "red"
var floor_color := ""


func _ready() -> void:
	add_to_group("Chamber")
	$chamber/walls.set("surface_material_override/3", load(str("res://resources/materials/", floor_color, "_wallpaper.tres")))
	paint(["red", "green", "blue", "purple"].pick_random())
	
	$chamber/walls.set("surface_material_override/0", load(str("res://resources/materials/", walls_color, "_wallpaper.tres")))
	var _bed := hotel.create_prop(hotel.ITEMS.bed, $bed_marker.global_position, $bed_marker.global_rotation)
	if randi() % 5 != 0:
		_bed.set_paint(walls_color)
	var _carpet := hotel.create_prop(hotel.ITEMS.carpet, $carpet_position.global_position, $carpet_position.global_rotation)
	if randi() % 5 != 0:
		_carpet.set_paint(walls_color)
	$door.mesh.get_node("number").text = name

func assign_to_nearest() -> void:
	if is_instance_valid(assigned_to):
		return
	var _nearest := hotel.get_nearest_customer(global_position, true)
	if _nearest && _nearest.global_position.distance_to($door.global_position) < 10.0 && _nearest.get_floor() == get_floor():
		assign_to(_nearest)


func assign_to(customer : Customer) -> void:
	assigned_to = customer
	customer.following = false
	customer.room_assigned = self
	assigned_to.position = $customer_position.global_position
	assigned_to.calculate_happiness()
	$door.mesh.get_node("owner").text = str("Room of ", assigned_to.display_name)
	PlayerData.unique_customers += 1
	hotel.update_music()

var furnitures_inside := []

func _room_changed() -> void:
	if is_instance_valid(assigned_to):
		assigned_to.calculate_happiness()

func paint(color : String) -> void:
	walls_color = color
	$chamber/walls.set("surface_material_override/0", load(str("res://resources/materials/", walls_color, "_wallpaper.tres")))

func _on_room_area_body_entered(body: Node3D) -> void:
	if hotel.transitioning:
		return
	if body.is_in_group("Player"):
		_room_changed()
	if body.is_in_group("Customer") && !is_instance_valid(assigned_to):
		if !is_instance_valid(body.room_assigned):
			assign_to(body)
	if body.get("id") != null:
		if body.id.contains("paint"):
			body.chamber = self
			return
		furnitures_inside.append(body)
		_room_changed()


func _on_room_area_body_exited(body: Node3D) -> void:
	if hotel.transitioning:
		return
	if body.get("id") != null:
		if body.id.contains("paint"):
			body.chamber = null
		furnitures_inside.erase(body)
		_room_changed()


#func _on_timer_timeout() -> void:
	#$room_area.position.x += 1000
	#await get_tree().physics_frame
	#await get_tree().physics_frame
	#await get_tree().physics_frame
	#$room_area.position.x -= 1000
