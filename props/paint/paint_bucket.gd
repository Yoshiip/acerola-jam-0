extends StaticProp

@export_enum("red", "green", "blue", "purple") var color = "red"

const COLORS := {
	"red": Color.RED,
	"green": Color.GREEN,
	"blue": Color.BLUE,
	"purple": Color.PURPLE
}

var chamber : Chamber

func set_paint(new_color : String) -> void:
	color = new_color
	$paint_bucket/Bucket.get("surface_material_override/1").albedo_color = COLORS[color]
	description = str("Painted ", color)

func _ready() -> void:
	super()
	if color == "none": color = ["red", "green", "blue", "purple"].pick_random()
	$paint_bucket/Bucket.set("surface_material_override/1", $paint_bucket/Bucket.get("surface_material_override/1").duplicate())
	set_paint(color)

func interact(_player : Player) -> void:
	if is_instance_valid(chamber) && chamber.walls_color != color:
		chamber.paint(color)
		queue_free()
