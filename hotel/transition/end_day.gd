extends StaticProp

func _ready() -> void:
	super()
	display_name = "End day"

func interact(_player : Player) -> void:
	get_tree().current_scene.end_day()
