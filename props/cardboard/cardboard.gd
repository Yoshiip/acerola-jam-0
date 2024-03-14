extends RigidProp

var hotel : Hotel

var inside : Node3D:
	set(value):
		if is_instance_valid(value):
			inside = value
			$name.text = hotel.ITEMS[inside.id].name
			$icon.texture = hotel.ITEMS[inside.id].icon
			description = description.replace("[OBJECT]", hotel.ITEMS[inside.id].name)

func _ready() -> void:
	super()
	self.inside = inside


func interact(player : Player) -> void:
	if is_instance_valid(inside):
		add_sibling(inside)
		inside.holded = false
		inside.global_position = global_position
	queue_free()
