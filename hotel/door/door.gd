extends Node3D

@export var locked := false
@export var opened := false
@export var golden := false

func _ready() -> void:
	$door/Door/number.modulate = Color("fea000") if golden else Color.LIGHT_GOLDENROD

func interact(player : Player) -> void:
	var _holding := player.inventory[player.current_item]
	if _holding && _holding.id == "whistle":
		get_parent().assign_to_nearest()
		return
	if !locked:
		opened = !opened
		$door_open.play()

@onready var mesh := $door/Door

func _process(delta: float) -> void:
	if opened:
		mesh.rotation.y = lerp(mesh.rotation.y, PI / 2, delta * 6.0)
	else:
		mesh.rotation.y = lerp(mesh.rotation.y, 0.0, delta * 6.0)
