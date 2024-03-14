class_name Player

extends CharacterBody3D

signal inventory_changed
signal inventory_error(String)


const SPEED_CROUCH := 2
const SPEED_DEFAULT := 4

const ACCEL_DEFAULT := 4
const ACCEL_AIR := 1

const DEFAULT_FOV := 75.0
const ZOOM_FOV := 60.0

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
@onready var place_preview : CSGBox3D = $"../place_preview"
@onready var place_preview_visible_time := 0.0

@onready var hotel: Hotel = $".."

@onready var inventory : Array[Item] = [null, null, null]
@onready var current_item := 0

func _input(event):
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if holding && Input.is_action_pressed("zoom"):
			holding_rotation += (event.relative * Vector2(1, 0)) * mouse_sense * 0.15
			holding_rotation = Vector2(holding_rotation.x, holding_rotation.y)
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
			head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)

var holding : Node3D
@onready var raycast: RayCast3D = $head/camera/raycast

@onready var customer_status_ui: VBoxContainer = $"../canvas/container/customer_status"

var i := 0.0

var footstep_timer := 0.0

func _place_prop() -> void:
	# shoot a ray from player head to object to see if it not through a wall
	var _query := PhysicsRayQueryParameters3D.create(head.global_position + Vector3(0.0, 0.4, 0.0), holding.global_position)
	var _result := get_world_3d().direct_space_state.intersect_ray(_query)
	if _result != {}:
		inventory_error.emit("Can't be placed here!")
		return
	if holding.get("place_only_on_floor") && !$holding_hint.visible:
		inventory_error.emit("Only placeable on floor!")
		return

	if holding.get("place_only_on_floor"):
		var shape_rid = PhysicsServer3D.box_shape_create()
		var _prop_shape_size : Vector3 = holding.get_node("collision").shape.size
		place_preview.size = _prop_shape_size
		PhysicsServer3D.shape_set_data(shape_rid, _prop_shape_size / 2.0)

		var params = PhysicsShapeQueryParameters3D.new()
		params.shape_rid = shape_rid
		$holding_hint.rotation.x = 0
		$holding_hint.global_rotation.y = holding.global_rotation.y
		
		params.transform = $holding_hint.global_transform.translated(Vector3(0, _prop_shape_size.y, 0))
		$holding_hint.rotation.x = -PI / 2
		place_preview.global_transform = params.transform
		
		var _space_query := get_world_3d().direct_space_state.intersect_shape(params)
		
		# Release the shape when done with physics queries.
		PhysicsServer3D.free_rid(shape_rid)
		if holding.get("ground_decoration"):
			for coll in _space_query:
				if coll.collider.is_in_group("Wall"):
					place_preview_visible_time = 1.0
					inventory_error.emit("Not enough space!")
					return
		else:
			if _space_query != []:
				place_preview_visible_time = 1.0
				inventory_error.emit("Not enough space!")
				return

	# place prop
	holding.set("holded", false)
	holding.scale = Vector3.ONE
	if $holding_hint.visible:
		holding.global_position = $holding_hint.global_position
	hotel.save_prop(holding, inventory[current_item])
	
	# remove from player
	inventory[current_item] = null
	holding = null
	set_current_item(current_item)

func handle_raycast() -> void:
	if raycast.is_colliding():
		var _collider = raycast.get_collider()
		if _collider && _collider.has_method("interact"):
			if Input.is_action_just_pressed("interact"):
				_collider.interact(self)
	if Input.is_action_just_pressed("pack") && holding != null:
		if hotel.pack(holding):
			$cardboard.play()
	if Input.is_action_just_pressed("pickup"):
		# pickup item
		if raycast.is_colliding() && is_instance_valid(raycast.get_collider()) && raycast.get_collider().is_in_group("Interaction"):
			$swoosh.play()
			var _collider = raycast.get_collider()
			if _collider.get("fixed"):
				return
			var _free_index : int = max(inventory.find(null, current_item), inventory.rfind(null, current_item))
			if _free_index == -1:
				inventory_error.emit("Pockets full!")
			else:
				current_item = _free_index
				inventory[current_item] = hotel.get_item(_collider.id)
				grab_prop(_collider)
				emit_signal("inventory_changed")
		
		elif holding != null:
			_place_prop()

func update_ui() -> void:
	help_container.get_node("display_name").text = ""
	help_container.get_node("description").text = ""
	var _zooming := Input.is_action_pressed("zoom")
	if raycast.is_colliding():
		var _collider := raycast.get_collider()
		if !is_instance_valid(_collider):
			return
		if _collider.get("display_name") != null:
			help_container.get_node("display_name").text = _collider.get("display_name")
		if _collider.get("description") != null:
			help_container.get_node("description").text = _collider.get("description")

	help_container.visible = _zooming && help_container.get_node("display_name").text != ""
	customer_status_ui.visible = _zooming && raycast.is_colliding() && raycast.get_collider().is_in_group("Customer") && raycast.get_collider().room_assigned != null

func get_floor() -> int:
	return floor(global_position.y / 8.0)

var holding_rotation : Vector2

func grab_prop(node : Node3D) -> void:
	if is_instance_valid(holding):
		hotel.remove_prop(holding, inventory[current_item])
	holding = node
	holding.set("holded", true)

func set_current_item(new_value : int) -> void:
	new_value = posmod(new_value, inventory.size())
	# save previous item
	
	if is_instance_valid(holding):
		hotel.save_prop(holding, inventory[current_item])
	
	if current_item != new_value || !is_instance_valid(holding):
		$click.play()
		current_item = new_value
		var _item := inventory[new_value]
		if _item == null:
			if is_instance_valid(holding):
				hotel.remove_prop(holding, inventory[current_item])
		else:
			var _item_prop : Node3D = hotel.create_prop(_item)
			grab_prop(_item_prop)
	else:
		current_item = new_value
	
	inventory_changed.emit()


func handle_inventory() -> void:
	if Input.is_action_just_released("previous_item"):
		set_current_item(current_item - 1)
	if Input.is_action_just_released("next_item"):
		set_current_item(current_item + 1)




func handle_holding() -> void:
	$holding_hint.visible = false
	if is_instance_valid(holding):
		holding.scale = Vector3.ONE * (holding.get("hold_size") if holding.get("hold_size") != null else 1.0)
		holding.rotation.y = rotation.y + holding_rotation.x
		if !holding.get("lock_rot_x"):
			holding.rotation.x = holding_rotation.y
		holding.position = global_position + Vector3(0, 0.75, 0) + Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
		holding.rotation.z = 0
		if raycast.is_colliding():
			if raycast.get_collision_normal() == Vector3.UP:
				$holding_hint.visible = true
				$holding_hint.global_position = raycast.get_collision_point() + (Vector3.UP * 0.01)
		if Input.is_action_just_pressed("action") && holding.has_method("use"):
			holding.use(self)
	elif inventory[current_item] != null:
		inventory[current_item] = null
		inventory_changed.emit()
	else:
		holding = null

@onready var help_container := get_tree().current_scene.get_node("canvas/container/help")

func _process(delta: float) -> void:
	if is_on_floor() && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if footstep_timer < 0.0:
			$footstep.pitch_scale = randf_range(0.95, 1.1)
			$footstep.play()
			footstep_timer = randf_range(1.8, 2.4)
		footstep_timer -= (velocity * Vector3(1, 0, 1)).length() * delta

func _physics_process(delta : float) -> void:
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input := 0
	var h_input := 0
	if stun <= 0.0 && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	place_preview_visible_time -= delta
	place_preview.visible = place_preview_visible_time > 0.0
	
	i += (velocity * Vector3(1, 0, 1)).length() * delta * 3.0
	
	$head/camera.v_offset = sin(i) * 0.05
	if Input.is_action_pressed("zoom") && !holding:
		$head/camera.fov = lerp($head/camera.fov, ZOOM_FOV, delta * 10.0)
	else:
		$head/camera.fov = lerp($head/camera.fov, DEFAULT_FOV, delta * 10.0)
	
	var speed := SPEED_DEFAULT
	if Input.is_action_pressed("crouching") && is_on_floor() && stun <= 0.0:
		speed = SPEED_CROUCH
		$head.position.y = lerp($head.position.y, 1.0, delta * 10.0)
	else:
		$head.position.y = lerp($head.position.y, 1.7, delta * 10.0)

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		handle_raycast()
		handle_inventory()
		update_ui()
		handle_holding()

	#jumping and gravity
	if is_on_floor():
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
	if Input.is_action_just_pressed("jump") && is_on_floor() && stun <= 0.0:
		gravity_vec = Vector3.UP * jump
	
	velocity.y = 0
	
	stun -= delta
	
	#make it move
	movement = velocity.lerp(direction * speed, accel * delta)
	velocity = movement + gravity_vec
	
	if is_inside_tree():
		move_and_slide()
		
	
	for coll in get_slide_collision_count():
		var c = get_slide_collision(coll)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal() * 2.0)

func _unhandled_key_input(event: InputEvent) -> void:
	if !event.is_pressed():
		return
	match event.as_text():
		"1":
			set_current_item(0)
		"2":
			set_current_item(1)
		"3":
			set_current_item(2)
		"4":
			set_current_item(3)
		"5":
			set_current_item(4)
		"6":
			set_current_item(5)

var stun := 0.0

func trap() -> void:
	stun = 3.0
