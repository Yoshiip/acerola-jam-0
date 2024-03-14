class_name CharacterProp

extends CharacterBody3D

@export var retrieve_data := false

@export var id : String
@export var to_save : Array[String] = []

@export var lock_rot_x := false
@export var hold_size := 1.0
@export var stealable := false

# overriden by item data
var display_name : String
var description : String

func _ready() -> void:
	add_to_group("Interaction")

var holded := false:
	set(value):
		holded = value
		$collision.disabled = holded
		holded_start()

func get_floor() -> int:
	return floor(global_position.y / 8.0)

func _process(_delta: float) -> void:
	if position.y < -64:
		position = Vector3.UP

func use(_player : Player) -> void:
	pass

func interact(_player : Player) -> void:
	pass

func holded_start() -> void:
	pass
