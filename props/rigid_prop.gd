class_name RigidProp

extends RigidBody3D

@export var retrieve_data := false

@export var id : String
@export var to_save : Array[String] = []

@export var place_only_on_floor := false
@export var lock_rot_x := false
@export var hold_size := 1.0
@export var stealable := true

# overriden by item data
var display_name : String
var description : String
var item_reference : Item

func _ready() -> void:
	add_to_group("Interaction")
	if retrieve_data:
		var _item : Item = get_tree().current_scene.ITEMS[id]
		display_name = _item.name
		description = _item.description

var holded := false:
	set(value):
		holded = value
		$collision.disabled = holded
		if !holded:
			apply_impulse(Vector3.ZERO)

func get_floor() -> int:
	return floor(global_position.y / 8.0)

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
