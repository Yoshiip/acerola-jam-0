class_name StaticProp

extends StaticBody3D

@export var id : String
@export var to_save : Array[String]= []
@export var fixed := false

@export var place_only_on_floor := true
@export var lock_rot_x := true
@export var hold_size := 1.0

# overriden by item data
var display_name : String
var description : String

var holded : bool:
	set(value):
		holded = value
		$collision.disabled = holded

func use(player : Player) -> void:
	pass

func interact(player : Player) -> void:
	pass
