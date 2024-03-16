extends RigidProp

@export_range(-2, 3) var ghost := 0
@export_range(-2, 3) var monkey := 0
@export_range(-2, 3) var donut := 0
@export_range(-2, 3) var general := 0

var is_gift := true

func _ready() -> void:
	super()
	description = "This is a gift. Give it to one of your customers, maybe they'll like it ;)"
