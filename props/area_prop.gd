class_name AreaProp

extends Area3D

@export var id : String
@export var to_save : Array[String]= []

# overriden by item data
@export var display_name : String
@export var description : String


func interact(player : Player) -> void:
	pass
