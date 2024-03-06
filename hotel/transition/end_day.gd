extends Area3D


func interact(_player : Player) -> void:
	get_tree().current_scene.end_day()
