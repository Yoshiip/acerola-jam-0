extends StaticProp

var color := "none"

const COLORS := {
	"red": preload("res://hotel/texture/carpets/red.png"),
	"green": preload("res://hotel/texture/carpets/green.png"),
	"blue": preload("res://hotel/texture/carpets/blue.png"),
	"purple": preload("res://hotel/texture/carpets/purple.png")
}

func set_paint(new_color : String) -> void:
	color = new_color
	$sprite.texture = COLORS[color]
	description = str("Painted ", color)

func _ready() -> void:
	super()
	if color == "none": color = ["red", "green", "blue", "purple"].pick_random()
	set_paint(color)

func interact(player : Player) -> void:
	if is_instance_valid(player.holding) && player.holding.get("id").ends_with("_paint"):
		player.holding.queue_free()
		set_paint(player.holding.color)
