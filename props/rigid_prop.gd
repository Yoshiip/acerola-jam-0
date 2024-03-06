class_name RigidProp

extends RigidBody3D

@export var retrieve_data := false

@export var id : String
@export var to_save : Array[String] = []

# overriden by item data
var display_name : String
var description : String

func _ready() -> void:
	var _item : Item = get_tree().current_scene.ITEMS[id]
	display_name = _item.name
	description = _item.description

var holded := false:
	set(value):
		holded = value
		$collision.disabled = holded
		if !holded:
			apply_impulse(Vector3.ZERO)

func _process(_delta: float) -> void:
	if holded:
		sleeping = true
	elif position.y < -64:
		linear_velocity = Vector3.ZERO
		position = Vector3.UP

func use(_player : Player) -> void:
	pass

func interact(_player : Player) -> void:
	pass
