extends RigidBody3D


const SPEED = 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


var target_position : Vector3

func _physics_process(delta: float) -> void:
	
	var _dir := -transform.basis.z
	linear_velocity.x = _dir.x * SPEED
	linear_velocity.z = _dir.z * SPEED
	
	if position.distance_to(target_position) < 2.0:
		linear_velocity.x = 0.0
		linear_velocity.z = 0.0

func whistle(pos : Vector3) -> void:
	target_position = pos
	look_at(Vector3(pos.x, position.y, pos.z), Vector3.UP)
