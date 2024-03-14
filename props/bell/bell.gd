extends StaticProp

@onready var hotel : Hotel = get_tree().current_scene

@export var remaining = 3:
	set(value):
		remaining = value
		$remaining.text = str("Remaining: ", remaining)


func _new_day_started() -> void:
	self.remaining = randi_range(3, 4) + hotel.customers_bonus

func _ready() -> void:
	super()
	$remaining.text = str("Remaining: ", remaining)
	hotel.new_day_started.connect(_new_day_started)
	

func interact(_player : Player) -> void:
	$ring.play()
	if remaining > 0:
		hotel.spawn_customer()
		self.remaining -= 1
