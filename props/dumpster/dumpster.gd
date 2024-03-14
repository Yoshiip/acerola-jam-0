extends StaticProp

func _ready() -> void:
	super()
	display_name = "Dumpster"
	description = "The dumpster allows you to dispose of objects. Interact with the dumpster by holding the object you wish to dispose of in your hands."
	

func interact(player : Player) -> void:
	if is_instance_valid(player.holding):
		player.holding.queue_free()
		$debris.play()
