extends Control

const STAR_1 = preload("res://ui/star_1.png")
const STAR_2 = preload("res://ui/star_2.png")
const STAR_3 = preload("res://ui/star_3.png")
func update() -> void:
	var _level := PlayerData.reputation_level
	if _level >= 10:
		for child in $stars.get_children():
			child.texture_progress = STAR_3
	elif _level >= 5:
		for child in $stars.get_children():
			child.texture_progress = STAR_2
	
	var _rounded_level : int = floor(_level / 5 ) * 5
	var _sum : int = Utils.get_total_needed_xp(_rounded_level)
	for star in $stars.get_children():
		star.min_value = _sum
		_sum += Utils.get_level_needed_xp(_rounded_level)
		star.max_value = _sum
		star.value = PlayerData.reputation
		_rounded_level += 1

var i := 0.0

func _process(delta: float) -> void:
	i += delta * 2.0
	for child in range($stars.get_child_count()):
		$stars.get_child(child).position.y = sin(i + child) * 4.0


func _on_mouse_entered() -> void:
	$xp.text = str(PlayerData.reputation, "/", PlayerData.reputation_objective)
	$xp.visible = true


func _on_mouse_exited() -> void:
	$xp.visible = false
