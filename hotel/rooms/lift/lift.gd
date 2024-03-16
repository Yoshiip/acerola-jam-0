extends StaticBody3D

@onready var hotel : Hotel

var transitioning := false

var floor_color := ""

@onready var screen_floor : int:
	set(value):
		screen_floor = value
		$panel/current_floor.text = str(screen_floor + 1)
		$panel/rat.visible = hotel.get_rats_at_floor(screen_floor) > 0

func door_animate(close = false, instant = false) -> void:
	
	$doors.disabled = !close
	if !instant:
		await get_tree().create_timer(0.5).timeout
	var _tween := get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property($lift/doorLeft, "position:x", 0.0 if close else 1.0, 0.0 if instant else 2.0)
	_tween.tween_property($lift/doorRight, "position:x", 0.0 if close else -1.0, 0.0 if instant else 2.0)


func _ready() -> void:
	$lift/walls_002.set("surface_material_override/0", load(str("res://resources/materials/", floor_color, "_wallpaper.tres")))
	hotel.new_day_started.connect(new_day_started)
	hotel.rats_changed.connect(_rat_changed)

func _rat_changed() -> void:
	self.screen_floor = screen_floor # update rat icon

func new_day_started() -> void:
	if hotel.max_floor == 1:
		door_animate(true, true)
	else:
		door_animate(false)

func change_floor(by : int) -> void:
	$button.pitch_scale = 0.8 + fposmod($button.pitch_scale + (by / 16.0), 0.4)
	$button.play()
	if by == 0 && !transitioning:
		door_animate(true)
		transitioning = true
		await get_tree().create_timer(3.0).timeout
		hotel.change_floor(screen_floor, bodies_inside)
		door_animate(false, true)
		transitioning = false
		self.screen_floor = floor(global_position.y / 8.0)
	else:
		self.screen_floor = posmod(screen_floor + by, hotel.hotel_floors.size()) 

var bodies_inside : Array[Node3D] = []

func _on_lift_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Interaction") || body.is_in_group("Customer") || body.is_in_group("Player"):
		bodies_inside.append(body)

func _on_lift_area_body_exited(body: Node3D) -> void:
	bodies_inside.erase(body)
