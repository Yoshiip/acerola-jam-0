extends Customer


func _physics_process(delta: float) -> void:
	super(delta)
	$monkey/ball.rotation.z += velocity.length() * delta
