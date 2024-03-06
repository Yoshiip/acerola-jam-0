class_name Chamber

extends StaticBody3D


var assigned_to : CharacterBody3D

var floor_number := 1
@onready var root : Hotel = get_tree().current_scene

var walls_color := "red"
var floor_color := "red"

var generate := true

func _ready() -> void:
	if generate:
		root.create_prop(root.ITEMS.bed, $bed_marker.global_position, $bed_marker.global_rotation)
	$door/number.text = name

func assign_to_nearest() -> void:
	var _nearest := root.get_nearest_customer(global_position, true)
	if _nearest:
		assigned_to = _nearest
		_nearest.room_assigned = self
		assigned_to.position = $customer_position.global_position
		assigned_to.calculate_happiness()
		$door/owner.text = str("Room of ", assigned_to.display_name)

var furnitures_inside := []

func _room_changed() -> void:
	if is_instance_valid(assigned_to):
		assigned_to.calculate_happiness()

func _on_room_area_body_entered(body: Node3D) -> void:
	if body.get("id") != null:
		furnitures_inside.append(body)
		_room_changed()


func _on_room_area_body_exited(body: Node3D) -> void:
	if body.get("id") != null:
		furnitures_inside.erase(body)
		_room_changed()
