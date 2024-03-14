extends AnimatableBody3D

@onready var door: Node3D = $"../../.."

func interact(player : Player) -> void:
	door.interact(player)
