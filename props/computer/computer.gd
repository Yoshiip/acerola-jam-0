extends StaticProp

@onready var hotel : Hotel = get_tree().current_scene

func _ready() -> void:
	super()
	display_name = "Computer"
	description = "The computer gives you access to lots of tools to manage your hotel. Take a look!"

func interact(player : Player) -> void:
	hotel.show_computer_ui()
