extends Control

@onready var hotel: Hotel = get_tree().current_scene

const ITEM_BUTTON = preload("res://ui/shop/item_button.tscn")

func _ready() -> void:
	visible = false

var floors_upgrade : Array[Array] = [
	[0, 0],
	[0, 0],
	[100, 1],
	[250, 3],
	[500, 5],
	[1000, 7],
	[1500, 9],
	[2500, 11],
	[5000, 13],
	[10000, 15],
]

func shop_screen() -> void:
	var _floor_upgrade_data : Array = floors_upgrade[hotel.hotel_floors.size()]
	$panel/Shop/vbox/build_new_floor/price.text = str(_floor_upgrade_data[0], "c")
	$panel/Shop/vbox/build_new_floor/stars.text = str("(Need ", _floor_upgrade_data[1], " stars)")
	$panel/Shop/vbox/build_new_floor.disabled = _floor_upgrade_data[0] > PlayerData.money || _floor_upgrade_data[1] > PlayerData.reputation_level
	
	for child in $panel/Shop/vbox/grid.get_children():
		child.queue_free()
	for item in hotel.ITEMS.values():
		if item.price != 0:
			var _button := ITEM_BUTTON.instantiate()
			_button.get_node("name").text = item.name.replace(" Blueprint", "")
			_button.get_node("price").text = str(item.price, "c")
			_button.get_node("icon").texture = item.icon
			_button.get_node("price").set("theme_override_colors/font_color", Color("ef3a0c") if item.price > PlayerData.money else Color.WHITE)
			
			_button.get_node("Button").disabled = item.price > PlayerData.money
			_button.get_node("Button").pressed.connect(_shop_button_pressed.bind(item.id))
			if item.name.contains("blueprint"):
				$panel/Shop/vbox/blueprints.add_child(_button)
			else:
				$panel/Shop/vbox/grid.add_child(_button)

const NUMBER_TO_STR = [
	"First",
	"Second",
	"Third",
	"Fourth",
	"Fifth",
	"Sixth",
	"Seventh",
	"Eigth",
]

const CHAMBER_SCREEN_UI = preload("res://ui/customers_screen/chamber_screen_ui.tscn")

func customers_screen() -> void:
	for child in $panel/Customers/scroll/vbox.get_children():
		child.queue_free()
		
	var _chambers : Array[Node] = get_tree().get_nodes_in_group("Chamber")
	for floor in range(hotel.hotel_floors.size()):
		var _label := Label.new()
		_label.text = str(NUMBER_TO_STR[floor], " floor")
		var _grid := GridContainer.new()
		_grid.columns = 3
		for chamber in _chambers:
			if chamber.get_floor() == floor:
				var _chamber_ui := CHAMBER_SCREEN_UI.instantiate()
				_chamber_ui.get_node("number").text = chamber.name
				if is_instance_of(chamber, DeluxeChamber):
					_chamber_ui.get_node("number").set("theme_override_colors/font_color", Color("efac28"))
					
				_chamber_ui.get_node("color").modulate = Color(chamber.walls_color)
				if is_instance_valid(chamber.assigned_to):
					_chamber_ui.get_node("customer_name").text = chamber.assigned_to.display_name
					chamber.assigned_to.calculate_happiness()
					_chamber_ui.get_node("happiness").text = str(chamber.assigned_to.happiness)
				else:
					_chamber_ui.get_node("customer_name").text = "Nobody"
					_chamber_ui.get_node("happiness").visible = false
				_grid.add_child(_chamber_ui)
		$panel/Customers/scroll/vbox.add_child(_label)
		$panel/Customers/scroll/vbox.add_child(_grid)


func overview_screen() -> void:
	$panel/Overview/vbox/stars.update()
	$panel/Overview/vbox/bar.value = hotel.cleanliness
	if hotel.cleanliness > 0.9:
		$panel/Overview/vbox/status.text = "Status: Perfect!"
	elif hotel.cleanliness > 0.8:
		$panel/Overview/vbox/status.text = "Status: Very good"
	elif hotel.cleanliness > 0.6:
		$panel/Overview/vbox/status.text = "Status: Tolerable"
	elif hotel.cleanliness > 0.4:
		$panel/Overview/vbox/status.text = "Status: Bad"
	else:
		$panel/Overview/vbox/status.text = "Status: Unsanitary"

func display() -> void:
	$money_label.text = str(PlayerData.money, "c")
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for child in $panel.get_children():
		child.custom_minimum_size.x = $panel.size.x - 32
		child.get_child(0).custom_minimum_size.x = $panel.size.x - 32
	shop_screen()
	customers_screen()
	overview_screen()

func _shop_button_pressed(item_id : String) -> void:
	PlayerData.money -= hotel.ITEMS[item_id].price
	display()
	$buy.play()
	hotel.delivery(item_id)

func _on_close_pressed() -> void:
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("escape") && visible:
		#_on_close_pressed()

func _on_build_new_floor_pressed() -> void:
	var _floor_upgrade_data : Array = floors_upgrade[hotel.hotel_floors.size()]
	PlayerData.money -= _floor_upgrade_data[0]
	hotel.add_random_floor()
	$buy.play()
	display()
