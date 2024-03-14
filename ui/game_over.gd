extends Control

func _ready() -> void:
	$vbox/grid/reputation.text += str("\n", PlayerData.reputation)
	$vbox/grid/stars.text += str("\n", PlayerData.reputation_level)
	$vbox/grid/customers.text += str("\n", PlayerData.unique_customers)
	$vbox/grid/money.text += str("\n", PlayerData.money)


var i = 0.0

func _process(delta: float) -> void:
	i += delta * 4.0
	$background.position.y = -32 + sin(i) * 32.0


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://menu/menu.tscn")
