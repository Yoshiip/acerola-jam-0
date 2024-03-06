extends CanvasLayer



func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var _level_data := PlayerData.hotel_level_data
	xp_animation_progress = PlayerData.reputation
	if is_instance_valid(_level_data):
		$container/vbox/grid/clients_value.text = str(_level_data.get_node("customers").get_child_count())
		for customer in _level_data.get_node("customers").get_children():
			print(customer.happiness)
			PlayerData.reputation += customer.happiness
			PlayerData.money += 10
			customer.nights_left -= 1
	$container/vbox/title.text = str("[center][wave]Day ", PlayerData.day, "[/wave][/center]")
	var _sum := 0
	var _level := 1
	for bar in $container/vbox/level/vbox/hbox.get_children():
		bar.min_value = _sum
		_sum += Utils.get_level_needed_xp(_level)
		bar.max_value = _sum
		_level += 1


	$container/vbox/grid/money_value.text = str(PlayerData.money, "c")
	$container/vbox/grid/happiness_value.text = str(PlayerData.reputation)


var xp_animation_progress := 0.0

func _process(delta: float) -> void:
	if xp_animation_progress <= PlayerData.reputation:
		xp_animation_progress += delta * 10.0
	for bar in $container/vbox/level/vbox/hbox.get_children():
		bar.value = xp_animation_progress


func _on_continue_pressed() -> void:
	PlayerData.day += 1
	get_tree().change_scene_to_file("res://hotel/hotel.tscn")
