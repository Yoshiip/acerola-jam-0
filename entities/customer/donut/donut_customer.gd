extends Customer


func _process(delta: float) -> void:
	$donut.rotation.z += (velocity * Vector3(1, 0, 1)).length() * delta * 0.5
