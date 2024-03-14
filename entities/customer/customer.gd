class_name Customer

extends CharacterBody3D


@export var display_name := "Customer"
var description := ""

var favorite_color = "red"
var nature = "normal"

### -1 : Déteste la lumière /// 1: Adore la lumière
#@export_range(-1, 1, 1) var light
### -1: Préfère être bas /// 1 : Préfère être en haut
var height
### -1: Aime les mauvaises odeurs /// 1 : Aime les bonnes odeurs
#@export_range(-1, 1, 1) var smell
### -1: Déteste la musique /// 1 : Adore la musique
#@export_range(-1, 1, 1) var sounds

#@export_flags("Noise", "Light") var likes = 0

var happiness := 0

var nights_left := 2

var room_assigned : Chamber

const SPEED = 3.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var moving := false
var target_position : Vector3

@onready var nav_agent := $navigation_agent

@onready var hotel : Hotel = get_tree().current_scene


@onready var player := get_tree().current_scene.get_node("player")

var accel := 10

var gifted_today := false
var gift_name := ""
var gift_value := 0
var vip := false
var long_stay := false



var money_per_night := 0

func _ready() -> void:
	
	if PlayerData.day > 2:
		vip = randi() % PlayerData.vip_chance == 0
	$vip_particles.emitting = vip
	if PlayerData.day > 2:
		long_stay = randi() % 3 == 0
	nights_left = (randi_range(1, 3) +
	(randi_range(2, 3) if long_stay else 0) +
	(randi_range(1, 2) if vip else 0))
	
	favorite_color = ["red", "green", "blue", "purple"].pick_random()
	if PlayerData.day > 3:
		height = randi_range(-1, 1)
	if PlayerData.day <= 3:
		nature = ["normal", "happy"].pick_random()
	else:
		nature = ["normal", "happy", "sour"].pick_random()

	update_description()
	nav_agent.target_position = Vector3(randf_range(-2, 2), 0, -1)
	#light = randi_range(-1, 1)
	#smell = randi_range(-1, 1)
	#sounds = randi_range(-1, 1)

func update_description() -> void:
	var desc := ""
	if is_instance_valid(room_assigned):
		desc += str("Stays for [color='3c9f9c']", nights_left, " more nights[/color]\n")
		desc += str("He will pay you [color='efac28']", money_per_night, "c[/color] per night\n")
	else:
		desc += str("Plans to stay [color='3c9f9c']", nights_left, " nights[/color]\n")
	
	if vip:
		desc += "[color='efac28']This customer is VIP. Treat him as well as possible and he will reward you well![/color]\n"
	desc += str("His favorite color is [color=", Color(favorite_color).lightened(0.5).to_html(false), "]", favorite_color, "[/color]\n")
	if nature != "normal":
		desc += str(nature.capitalize(), "\n")
	if long_stay:
		desc += "Long stay\n"
	#if light: desc += str("love" if light == 1 else "hate" , " light\n")
	if height: desc += str("Likes height\n" if height == 1 else "Dizzy\n")
	#if smell: desc += str("love good" if smell == 1 else "love bad" , " smells\n")
	#if sounds: desc += str("love" if sounds == 1 else "hate" , " sounds\n")
	description = desc

func calculate_happiness() -> void:
	if !is_instance_valid(room_assigned):
		return
	var _summary : Array[Array] = []
	
	if nature != "normal":
		_summary.append([str("base happiness (", nature, ")"), 4 if nature == "happy" else 2])
	else:
		_summary.append(["base happiness", 3])
	if room_assigned.walls_color == favorite_color: _summary.append(["nice walls color", 1])
	if room_assigned.get("is_deluxe"):
		_summary.append(["deluxe room", 2])

	var _uniques_furnitures : Array[String] = []
	for furniture in room_assigned.furnitures_inside:
		if is_instance_valid(furniture):
			var _id : String = furniture.get("id")
			if !_uniques_furnitures.has(_id):
				_uniques_furnitures.append(_id)
				if furniture.get("color") == favorite_color:
					_summary.append([str("nice ", furniture.display_name.to_lower(), " color"), 1])
				if furniture.get("decoration_value"):
					_summary.append([furniture.display_name.to_lower(), furniture.get("decoration_value")])
	if !_uniques_furnitures.has("bed"): _summary.append(["no bed ?", -5])
	
	
	var _garbage_props : int = hotel.get_total_dirts_object_floor(get_floor())
	
	if _garbage_props <= 2:
		_summary.append(["very clean hotel!", 2])
	elif _garbage_props <= 5:
		_summary.append(["fairly clean hotel.", 1])
	elif _garbage_props < 10:
		_summary.append(["hotel has some dirt...", -1])
	else:
		_summary.append(["really filthy hotel!", -3])
	if gifted_today:
		_summary.append([str("Gift: ", gift_name), gift_value])
	
	match height:
		-1:
			var _value = -2 if get_floor() > 1 else 2
			_summary.append(["Dizzy", _value])
		1:
			var _value = 2 if get_floor() > hotel.max_floor - 2 else -2
			_summary.append(["Likes height", _value])
	happiness = 0
	for value in _summary:
		happiness += value[1]
	
	if vip:
		money_per_night = base_money + max(floor(happiness * 0.8), 0)
	else:
		money_per_night = (base_money * 2) + max(floor(happiness * 2.4), 0)
	update_description()
	hotel.get_node("canvas/container/customer_status").display(_summary)

@onready var base_money := randi_range(4, 6)

var following := false

func get_floor() -> int:
	return floor((global_position.y + 0.1) / 8.0)

func whistle() -> void:
	if room_assigned || get_floor() != player.get_floor():
		return
	following = !following
	if !following:
		nav_agent.target_position = global_position



func _physics_process(delta: float) -> void:
	if room_assigned:
		look_at(room_assigned.get_node("door").global_position, Vector3.UP)
		return
	var direction := Vector3()
	if following:
		nav_agent.target_position = player.global_position
	if global_position.distance_to(nav_agent.target_position) > 1.5 && stun <= 0.0:
		direction = nav_agent.get_next_path_position() - global_position
		direction = direction.normalized()
	else:
		direction = Vector3.ZERO

	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= gravity * delta
	velocity = velocity.lerp(direction * SPEED, accel * delta)
	if direction != Vector3.ZERO:
		look_at(global_position + (direction * Vector3(1, 0, 1)), Vector3.UP)
	
	stun -= delta
	move_and_slide()
	#update_description()
	#var _player_distance : float = player.position.distance_to(position)
	#if _player_distance < 1.2:
		#look_at(position + (position - player.position).normalized(), Vector3.UP)
		#target_position = position + ((position - player.position).normalized() * 2.0)
		#moving = true
	#if moving:
		#var _dir := -transform.basis.z
		#velocity.x = _dir.x * SPEED
		#velocity.z = _dir.z * SPEED
	#
	#if position.distance_to(target_position) < 1.5:
		#velocity.x = 0.0
		#velocity.z = 0.0
		#moving = false
	
var delay := 0
func interact(_player : Player) -> void:
	if room_assigned == null && !is_instance_valid(player.holding):
		if Time.get_ticks_msec() - delay < 200:
			nav_agent.target_position = hotel.get_random_position(get_floor())
		else:
			delay = Time.get_ticks_msec()
			following = !following
	if room_assigned != null && is_instance_valid(player.holding) && player.holding.get("is_gift"):
		gifted_today = true
		gift_name = player.holding.display_name
		gift_value = player.holding.get(str(display_name.to_lower()))
		calculate_happiness()
		player.holding.queue_free()


var stun := 0.0

func trap() -> void:
	stun = 5.0
