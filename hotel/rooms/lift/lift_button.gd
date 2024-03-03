extends Area3D

@onready var lift: StaticBody3D = $"../.."

@export var delta := 0

func interact(player : Player) -> void:
	lift.change_floor(delta)
