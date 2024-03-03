class_name RigidProp

extends RigidBody3D

@export var id : String
@export var to_save : Array[String]= []

# overriden by item data
var display_name : String
var description : String

var holded := false:
	set(value):
		holded = value
		$collision.disabled = holded
		if !holded:
			apply_impulse(Vector3.ZERO)

func _process(delta: float) -> void:
	if holded:
		sleeping = true
	elif position.y < -64:
		linear_velocity = Vector3.ZERO
		position = Vector3.UP

func use(player : Player) -> void:
	pass

func interact(player : Player) -> void:
	pass
