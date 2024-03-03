extends StaticProp

@export_enum("red", "green", "blue", "purple") var color = "red"

const COLORS := {
	"red": Color.RED,
	"green": Color.GREEN,
	"blue": Color.BLUE,
	"purple": Color.PURPLE
}

func set_paint(new_color : String) -> void:
	color = new_color
	$mesh/sheet.get("surface_material_override/0").albedo_color = COLORS[color]
	description = str("Painted ", color)

func _ready() -> void:
	$mesh/sheet.set("surface_material_override/0", $mesh/sheet.get("surface_material_override/0").duplicate())
	set_paint(color)

func interact(player : Player) -> void:
	var _keys := COLORS.keys()
	set_paint(_keys[(_keys.find(color) + 1) % _keys.size()])
