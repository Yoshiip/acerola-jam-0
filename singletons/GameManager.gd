extends Node

var hotel : Hotel

const DAY_END_SCENE := preload("res://hotel/transition/day_end.tscn")
func to_day_results() -> void:
	hotel = get_tree().current_scene
	get_tree().root.remove_child(hotel)

	get_tree().change_scene_to_packed(DAY_END_SCENE)


func to_hotel() -> void:
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(hotel)
	get_tree().current_scene = get_tree().root.get_node("hotel")
	hotel.start_new_day()


func save() -> void:
	pass
