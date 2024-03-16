extends ColorRect

var paused := false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") && !get_parent().get_node("computer").visible:
		paused = !paused
		update_pause()
	
	if event.is_action_pressed("fullscreen"):
		print("yo")
		get_window().mode = Window.MODE_WINDOWED if get_window().mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN
		$hbox/vbox/fullscreen.button_pressed = !$hbox/vbox/fullscreen.button_pressed

func update_pause() -> void:
	get_tree().paused = paused
	visible = paused
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED


func _on_main_menu_pressed() -> void:
	paused = false
	get_tree().change_scene_to_file("res://menu/menu.tscn")


func _on_continue_pressed() -> void:
	paused = false
	update_pause()


@onready var _effects_bus := AudioServer.get_bus_index("Effects")
@onready var _music_bus := AudioServer.get_bus_index("Music")


func _on_music_slider_drag_ended(value_changed: bool) -> void:
	AudioServer.set_bus_volume_db(_music_bus, linear_to_db($hbox/vbox/settings/music_slider.value))


func _on_effects_slider_drag_ended(value_changed: bool) -> void:
	AudioServer.set_bus_volume_db(_effects_bus, linear_to_db($hbox/vbox/settings/effects_slider.value))


func _on_restart_day_pressed() -> void:
	GameManager.to_hotel()


func _on_fullscreen_pressed() -> void:

	get_window().mode = Window.MODE_WINDOWED if get_window().mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN


func _on_save_pressed() -> void:
	GameManager.save()

func _on_load_pressed() -> void:
	pass # Replace with function body.
