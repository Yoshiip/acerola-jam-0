extends StaticBody3D

@export var locked := false
@export var opened := false

func interact(player : Player) -> void:
	var _holding := player.inventory[player.current_item]
	if _holding && _holding.id == "whistle":
		get_parent().assign_to_nearest()
		return
	if !locked:
		opened = !opened

func _process(delta: float) -> void:
	if opened:
		rotation.y = lerp(rotation.y, PI / 2, delta * 6.0)
	else:
		rotation.y = lerp(rotation.y, 0.0, delta * 6.0)
