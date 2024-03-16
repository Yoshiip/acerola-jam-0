extends RigidProp


var inside : Node3D:
	set(value):
		if is_instance_valid(value):
			inside = value
			if inside.item_reference == null:
				printerr("Invalid cardboard")
				queue_free()
				return
			$name.text = inside.item_reference.name
			$icon.texture = inside.item_reference.icon
			description = description.replace("[OBJECT]", inside.item_reference.name)

func _ready() -> void:
	super()
	self.inside = inside


func interact(_player : Player) -> void:
	if is_instance_valid(inside):
		add_sibling(inside)
		inside.holded = false
		inside.global_position = global_position
	queue_free()
