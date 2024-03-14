extends AreaProp

func _ready() -> void:
	add_to_group("Garbage")

func interact(player : Player) -> void:
	if is_instance_valid(player.holding) && player.holding.get("id") == "broom":
		queue_free()
