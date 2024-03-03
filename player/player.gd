class_name Player

extends CharacterBody3D

signal inventory_changed
signal inventory_error(String)


const SPEED_CROUCH := 2
const SPEED_DEFAULT := 4

const ACCEL_DEFAULT := 4
const ACCEL_AIR := 1

const DEFAULT_FOV := 75.0
const ZOOM_FOV := 30.0

@onready var accel := ACCEL_DEFAULT
var gravity := 9.8
var jump := 4




var cam_accel := 40
var mouse_sense := 0.25

var direction := Vector3()
var gravity_vec := Vector3()
var movement := Vector3()

@onready var head := $head
@onready var camera := $head/camera

@onready var root: Node3D = $".."

@onready var inventory : Array[Item] = [null, null, null]
@onready var current_item := 0

func _ready():

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		if holding && Input.is_action_pressed("zoom"):
			holding_rotation += event.relative * mouse_sense * 0.5
			holding_rotation = Vector2(fmod(holding_rotation.x, PI * 2), fmod(holding_rotation.y, PI * 2))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
			head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)

var holding : Node3D
@onready var raycast: RayCast3D = $head/camera/raycast

@onready var customer_status_ui: VBoxContainer = $"../canvas/container/customer_status"

var i := 0.0

func _place_prop() -> void:
	# shoot a ray from player head to object to see if it not through a wall
	var _query := PhysicsRayQueryParameters3D.create(head.global_position, holding.global_position)
	var _result := get_world_3d().direct_space_state.intersect_ray(_query)
	if _result != {}:
		inventory_error.emit("Can't be placed here!")
		return
	if holding.get("place_only_on_floor") && !$holding_hint.visible:
		inventory_error.emit("Only placeable on floor!")
		return

	var shape_rid = PhysicsServer3D.box_shape_create()
	var _prop_shape_size : Vector3 = holding.get_node("collision").shape.size
	PhysicsServer3D.shape_set_data(shape_rid, _prop_shape_size)

	var params = PhysicsShapeQueryParameters3D.new()
	params.shape_rid = shape_rid
	params.transform = $holding_hint.global_transform.translated(Vector3(0, 2.0, 0))

	var _space_query := get_world_3d().direct_space_state.intersect_shape(params)
	
	# Release the shape when done with physics queries.
	PhysicsServer3D.free_rid(shape_rid)
	
	if _space_query != []:
		inventory_error.emit("Not enough space!")
		return

	# place prop
	holding.set("holded", false)
	holding.scale = Vector3.ONE
	if $holding_hint.visible:
		holding.global_position = $holding_hint.global_position
	root.save_prop(holding, inventory[current_item])
	
	# remove from player
	inventory[current_item] = null
	holding = null
	set_current_item(current_item)

func handle_raycast() -> void:
	help_container.get_node("display_name").text = ""
	help_container.get_node("description").text = ""
	customer_status_ui.visible = false
	if raycast.is_colliding():
		var _collider = raycast.get_collider()
		if _collider && _collider.has_method("interact"):
			if Input.is_action_just_pressed("interact"):
				_collider.interact(self)
		if _collider && _collider.get("display_name") != null:
			help_container.get_node("display_name").text = _collider.get("display_name")
		if _collider && _collider.get("description") != null:
			help_container.get_node("description").text = _collider.get("description")
		if _collider && _collider.is_in_group("Customer"):
			customer_status_ui.visible = true
	if Input.is_action_just_pressed("pickup"):
		
		# pickup item
		if raycast.is_colliding() && raycast.get_collider().is_in_group("Interaction"):
			var _collider = raycast.get_collider()
			if _collider.get("fixed"):
				return
			var _free_index : int = max(inventory.find(null, current_item), inventory.rfind(null, current_item))
			if _free_index == -1:
				inventory_error.emit("Pockets full!")
			else:
				current_item = _free_index
				inventory[current_item] = root.get_item(_collider.id)
				grab_prop(_collider)
				emit_signal("inventory_changed")
		
		elif holding != null:
			_place_prop()


var holding_rotation : Vector2

func grab_prop(node : Node3D) -> void:
	if is_instance_valid(holding):
		root.remove_prop(holding, inventory[current_item])
	holding = node
	holding.set("holded", true)

func set_current_item(new_value : int) -> void:
	new_value = posmod(new_value, inventory.size())
	# save previous item
	
	if is_instance_valid(holding):
		root.save_prop(holding, inventory[current_item])
	
	if current_item != new_value || !is_instance_valid(holding):
		current_item = new_value
		var _item := inventory[new_value]
		if _item == null:
			if is_instance_valid(holding):
				root.remove_prop(holding, inventory[current_item])
		else:
			var _item_prop : Node3D = root.create_prop(_item)
			grab_prop(_item_prop)
	else:
		current_item = new_value
		
	inventory_changed.emit()


func handle_inventory() -> void:
	if Input.is_action_just_released("previous_item"):
		set_current_item(current_item - 1)
	if Input.is_action_just_released("next_item"):
		set_current_item(current_item + 1)




func handle_holding(delta : float) -> void:
	$holding_hint.visible = false
	if is_instance_valid(holding):
		holding.scale = Vector3.ONE * (holding.get("hold_size") if holding.get("hold_size") != null else 1.0)
		holding.rotation.y = rotation.y + holding_rotation.x
		if !holding.get("lock_rot_x"):
			holding.rotation.x = holding_rotation.y
		holding.position = global_position + Vector3(0, 0.75, 0) + Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
		#if !Input.is_action_pressed("zoom"):
			#holding_rotation = holding_rotation.lerp(Vector2.ZERO, delta * 10.0)
		if raycast.is_colliding():
			if raycast.get_collision_normal() == Vector3.UP:
				$holding_hint.visible = true
				$holding_hint.global_position = raycast.get_collision_point() + (Vector3.UP * 0.01)
		if Input.is_action_just_pressed("action") && holding.has_method("use"):
			holding.use(self)
	elif inventory[current_item] != null:
		inventory[current_item] = null
		inventory_changed.emit()

@onready var help_container := get_tree().current_scene.get_node("canvas/container/help")

func _physics_process(delta : float) -> void:
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	i += (velocity * Vector3(1, 0, 1)).length() * delta * 3.0
	
	$head/camera.v_offset = sin(i) * 0.05
	
	if Input.is_action_pressed("zoom") && !holding:
		$head/camera.fov = lerp($head/camera.fov, ZOOM_FOV, delta * 10.0)
		help_container.visible = help_container.get_node("display_name").text != ""
	else:
		help_container.visible = false
		$head/camera.fov = lerp($head/camera.fov, DEFAULT_FOV, delta * 10.0)
	
	var speed := SPEED_DEFAULT
	if Input.is_action_pressed("crouching") && is_on_floor():
		speed = SPEED_CROUCH
		$head.position.y = lerp($head.position.y, 0.8, delta * 10.0)
	else:
		$head.position.y = lerp($head.position.y, 1.7, delta * 10.0)

	handle_raycast()
	handle_inventory()
	handle_holding(delta)

	#jumping and gravity
	if is_on_floor():
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		gravity_vec = Vector3.UP * jump
	
	velocity.y = 0
	
	#make it move
	movement = velocity.lerp(direction * speed, accel * delta)
	velocity = movement + gravity_vec
	
	move_and_slide()
