extends StaticProp

@export var remaining = 5

@onready var root : Hotel = get_tree().current_scene

func interact(player : Player) -> void:
	if remaining > 0:
		root.spawn_customer()
		remaining -= 1
	$remaining.text = str("Remaining: ", remaining)
