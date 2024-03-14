class_name Rat

extends CharacterProp

const BASE_SPEED = 3.0
var accel := 10
var size := 1.0

var seeking_prop : Node3D

@onready var hotel : Hotel = get_tree().current_scene
@onready var nav_agent: NavigationAgent3D = $navigation_agent



enum State {
	IDLING,
	SEEK,
	RETRIEVE,
}

var state := State.IDLING

var picked_prop : Node3D
var terrified := false
var target_nest : Node3D

var prop_speed_malus := 1.0

@onready var player : Player = get_tree().current_scene.get_node("player")

var dead := false

@onready var animation_player : AnimationPlayer = $rat/AnimationPlayer

func _ready() -> void:
	super()
	add_to_group("Rat")
	scale *= size
	nav_agent.target_position = hotel.get_random_position(get_floor())
	$trap_area/collision.set("shape", $trap_area/collision.shape.duplicate())
	if dead:
		add_to_group("Garbage")
		$particles.emitting = false
		animation_player.play("RatArmature|Rat_Death", -1, 0.0, true)


func seek_item() -> void:
	state = State.SEEK
	seeking_prop = hotel.get_random_stealable_prop(self)
	if !is_instance_valid(seeking_prop): # no more props left
		return_to_hole()
		return
	nav_agent.target_position = seeking_prop.global_position

func return_to_hole() -> void:
	state = State.RETRIEVE
	target_nest = hotel.get_nearest_hole(self)
	if !is_instance_valid(target_nest):
		queue_free()
		return
	nav_agent.target_position = target_nest.get_entrance_point()
	

func get_floor() -> int:
	return floor(global_position.y / 8.0)

func drop_prop() -> void:
	if is_instance_valid(picked_prop):
		picked_prop.holded = false
		picked_prop = null

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	if dead:
		return
	var direction := Vector3()
	
	$rat/RootNode/RatArmature/Skeleton3D/BoneAttachment3D/left_ear/sprite.rotation.z -= delta * 0.12
	$rat/RootNode/RatArmature/Skeleton3D/BoneAttachment3D/right_ear/sprite.rotation.z += delta * 0.174
	if player.global_position.distance_to(self.global_position) < 2.5 && !terrified:
		terrified = true
		return_to_hole()
		drop_prop()
	
	if global_position.distance_to(nav_agent.target_position) > 0.5:
		direction = nav_agent.get_next_path_position() - global_position
		direction = direction.normalized()
	else:
		match state:
			State.IDLING:
				if randi() % 2 == 0:
					nav_agent.target_position = hotel.get_random_position(get_floor())
				else:
					seek_item()
			State.SEEK:
				if !is_instance_valid(seeking_prop) || seeking_prop.holded:
					seek_item()
				else:
					picked_prop = seeking_prop
					picked_prop.holded = true
					prop_speed_malus = 0.25
					return_to_hole()
			State.RETRIEVE:
				
				target_nest.rat_entered(self)
		direction = Vector3.ZERO

	var _speed := BASE_SPEED * prop_speed_malus
	if terrified:
		_speed = BASE_SPEED * 2.0
	velocity = velocity.lerp(direction * _speed, accel * delta)
	if is_instance_valid(picked_prop):
		picked_prop.global_position = global_position + Vector3(0, 0.25, 0)
	var _look_at_pos := global_position - (direction * Vector3(1, 0, 1))
	if _look_at_pos != position:
		look_at(_look_at_pos, Vector3.UP)
	move_and_slide()

func trap() -> void:
	dead = true
	add_to_group("Garbage")
	$particles.emitting = false
	animation_player.play("RatArmature|Rat_Death")
	drop_prop()


func _on_trap_area_body_entered(body: Node3D) -> void:
	pass
	#if body.is_in_group("Trap"):
		#nav_agent.target_position = body.global_position
	

func _on_trap_area_timer_timeout() -> void:
	if dead:
		return
	$trap_area/collision.shape.radius += 0.1

func holded_start() -> void:
	drop_prop()
