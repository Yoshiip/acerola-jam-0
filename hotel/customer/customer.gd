class_name Customer

extends CharacterBody3D


@export var display_name := "Customer"
@export_multiline var description := "coucou"

@export_enum("red", "green", "blue", "purple") var favorite_color = "red"
## -1 : Déteste la lumière /// 1: Adore la lumière
@export_range(-1, 1, 1) var light
## -1: Préfère être bas /// 1 : Préfère être en haut
@export_range(-1, 1, 1) var height
## -1: Aime les mauvaises odeurs /// 1 : Aime les bonnes odeurs
@export_range(-1, 1, 1) var smell
## -1: Déteste la musique /// 1 : Adore la musique
@export_range(-1, 1, 1) var sounds

@export_flags("Noise", "Light") var likes = 0
@export_subgroup("Hate")


@export var happiness := 0

var nights_left := 2

var room_assigned : Chamber

const SPEED = 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var moving := false
var target_position : Vector3

@onready var root : Hotel = get_tree().current_scene

func _ready() -> void:
	favorite_color = ["red", "green", "blue", "purple"].pick_random()
	light = randi_range(-1, 1)
	height = randi_range(-1, 1)
	smell = randi_range(-1, 1)
	sounds = randi_range(-1, 1)

func update_description() -> void:
	var desc := ""
	if is_instance_valid(room_assigned):
		desc += str("Stays for ", nights_left, " more nights\n")
	else:
		desc = "No room\n"
		desc += str("Plans to stay ", nights_left, " nights\n")
	desc += str("His favorite color is ", favorite_color, "\n")
	#if light: desc += str("love" if light == 1 else "hate" , " light\n")
	#if height: desc += str("love" if height == 1 else "hate" , " heights\n")
	#if smell: desc += str("love good" if smell == 1 else "love bad" , " smells\n")
	#if sounds: desc += str("love" if sounds == 1 else "hate" , " sounds\n")
	description = desc

func calculate_happiness() -> void:
	var _summary : Array[Array] = []
	if room_assigned.floor_color == favorite_color: _summary.append(["nice floor color", 1])
	if room_assigned.walls_color == favorite_color: _summary.append(["nice walls color", 1])
	var _has_bed := false
	for furniture in room_assigned.furnitures_inside:
		if furniture.id == "bed":
			_has_bed = true
		if furniture.get("color") == favorite_color:
			_summary.append([str("nice ", furniture.display_name, " color"), 1])
	if !_has_bed: _summary.append(["no bed ?", -5])
	
	happiness = 0
	for value in _summary:
		happiness += value[1]
	
	root.get_node("canvas/container/customer_status").display(_summary)

func _physics_process(delta: float) -> void:
	update_description()
	if moving:
		var _dir := -transform.basis.z
		velocity.x = _dir.x * SPEED
		velocity.z = _dir.z * SPEED
	
	if position.distance_to(target_position) < 2.0:
		velocity.x = 0.0
		velocity.z = 0.0
		moving = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()

func whistle(pos : Vector3) -> void:
	if room_assigned:
		return
	target_position = pos
	moving = true
	look_at(Vector3(pos.x, position.y, pos.z), Vector3.UP)
