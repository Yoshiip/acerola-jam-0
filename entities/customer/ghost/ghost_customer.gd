extends Customer


var i := 0.0
func _process(delta: float) -> void:
	i += delta
	$ghost.position.y = 0.2 + sin(i) * 0.2
