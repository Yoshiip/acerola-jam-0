extends StaticBody3D

@onready var root : Hotel = get_tree().current_scene

var generate := false

@onready var screen_floor := root.floor_number

func _ready() -> void:
	$panel/current_floor.text = str(screen_floor)

func change_floor(by : int) -> void:
	if by == 0:
		root.change_floor(screen_floor)
	else:
		screen_floor = posmod(screen_floor + by, root.max_floor)
		$panel/current_floor.text = str(screen_floor)
