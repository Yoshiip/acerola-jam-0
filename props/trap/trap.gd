extends StaticProp

@export var durability := 3

var reloading := false

func _ready() -> void:
	super()
	if durability <= 0:
		$trap/metal.queue_free()
	update_description()
	add_to_group("Trap")

func update_description() -> void:
	description = "A basic rodent trap that can be used to capture rodents.\n\n"
	if durability > 0:
		description += str("It has ", durability, " uses left.")
	else:
		description += "It's broken... It should be thrown away."

func _on_trigger_area_body_entered(body: Node3D) -> void:
	if (body.is_in_group("Rat") || body.is_in_group("Player") || body.is_in_group("Customer")) && !$collision.disabled && !reloading && durability > 0:
		$animation_player.play("trigger")
		reloading = true
		$trap_trigger.play()
		body.trap()
		durability -= 1
		update_description()
		await get_tree().create_timer(3.0).timeout
		if durability <= 0:
			$trap/metal.queue_free()
		await get_tree().create_timer(5.0).timeout
		$trap_place.play()
		reloading = false
