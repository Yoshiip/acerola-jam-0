extends VBoxContainer

@onready var player: Player = %player

const NOTHING_TEXTURE := preload("res://ui/items/empty.png")
const ITEM_FRAME = preload("res://ui/items/item_frame.tscn")

func _ready() -> void:
	player.inventory_changed.connect(_inventory_changed)
	player.inventory_error.connect(_show_error)
	_inventory_changed()

var error_time_left := 0.0
var error_text := ""

func _process(delta: float) -> void:
	error_time_left -= delta
	if error_time_left > 0.0:
		$holding_label.set("theme_override_colors/font_color", Color.RED)
		$holding_label.text = error_text
	else:
		$holding_label.set("theme_override_colors/font_color", Color.WHITE)
		_inventory_changed()
		set_process(false)

func _show_error(message : String, time : float = 1.5) -> void:
	error_time_left = time
	error_text = message
	set_process(true)

func _inventory_changed() -> void:
	for child in $items.get_children():
		child.queue_free()
	for i in range(player.inventory.size()):
		var item = player.inventory[i]
		var _item_frame := ITEM_FRAME.instantiate()
		if item == null:
			_item_frame.get_node("image").texture = NOTHING_TEXTURE
		else:
			_item_frame.get_node("image").texture = item.icon
		_item_frame.get_node("label").text = str(i + 1)
		_item_frame.modulate.a = 1.0 if i == player.current_item else 0.5
		$items.add_child(_item_frame)
	if player.inventory[player.current_item]:
		$holding_label.text = player.inventory[player.current_item].name
	else:
		$holding_label.text = "hands"
