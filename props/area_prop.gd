class_name AreaProp

extends Area3D

@export var id : String
@export var to_save : Array[String]= []

# overriden by item data
@export var display_name : String
@export var description : String
var item_reference : Item


func interact(player : Player) -> void:
	pass

func get_floor() -> int:
	return floor(global_position.y / 8.0)
