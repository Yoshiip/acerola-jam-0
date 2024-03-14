extends StaticProp

@export_enum("red", "green", "blue", "purple") var color = "none"

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
	super()
	if color == "none": color = ["red", "green", "blue", "purple"].pick_random()
	$mesh/sheet.set("surface_material_override/0", $mesh/sheet.get("surface_material_override/0").duplicate())
	set_paint(color)

func interact(player : Player) -> void:
	$collision.disabled = true
	await get_tree().create_timer(1.0).timeout
	$collision.disabled = false
	if is_instance_valid(player.holding) && player.holding.get("id").ends_with("_paint"):
		player.holding.queue_free()
		set_paint(player.holding.color)
