class_name StaticProp

extends AnimatableBody3D

@export var id : String
@export var to_save : Array[String]= []
@export var fixed := false

@export var decoration_value := 0

@export var ground_decoration := false
@export var place_only_on_floor := true
@export var lock_rot_x := true
@export var hold_size := 1.0

# overriden by item data
var display_name : String
var description : String
var flipped := false

@export var retrieve_data := false

var holded : bool:
	set(value):
		holded = value
		rotation.x = 0
		sync_to_physics = false
		$collision.disabled = holded
		flipped = false
		if !holded && place_only_on_floor:
			position.y = 0.0

func flip() -> void:
	flipped = !flipped
	if flipped:
		position.y += 4
		rotation.x = PI
	else:
		position.y -= 4
		rotation.x = 0

func _ready() -> void:
	sync_to_physics = false
	if retrieve_data:
		var _item : Item = get_tree().current_scene.ITEMS[id]
		display_name = _item.name
		description = _item.description
	add_to_group("Interaction")

func get_floor() -> int:
	return floor(global_position.y / 8.0)

func use(_player : Player) -> void:
	pass

func interact(_player : Player) -> void:
	pass
