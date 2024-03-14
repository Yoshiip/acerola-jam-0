extends Node3D

const RAT = preload("res://entities/rat/rat.tscn")

var rats_inside : Array[Dictionary] = [
	
]

@onready var hotel : Hotel = get_tree().current_scene

func _ready() -> void:
	add_to_group("Hole")
	$timer.wait_time = randi_range(45, 70)
	$timer.start()
	for i in randi_range(1, 3):
		rats_inside.append({
			"size": randf_range(1.0, 1.4),
			"color": "black",
			"terrified": false,
			"out_today": false,
		})
	
	hotel.new_day_started.connect(new_day_started)


func new_day_started() -> void:
	if rats_inside.is_empty():
		queue_free()
	for rat in rats_inside:
		if rat.terrified:
			rat.terrified = false
		else:
			rat.out_today = false
		rat.size += randf_range(0.2, 0.4)

func get_entrance_point() -> Vector3:
	return global_position + (-transform.basis.z * 0.25)

func rat_entered(rat : Rat) -> void:
	rats_inside.append({
		"size": rat.size,
		"color": "black",
		"out_today": true,
		"terrified": rat.terrified
	})
	rat.queue_free()
	if is_instance_valid(rat.picked_prop):
		rat.picked_prop.queue_free()

func release_rat() -> void:
	if rats_inside.is_empty() || hotel.time_left <= 0:
		return
	for rat in rats_inside:
		if !(rat.out_today && rat.terrified):
			rats_inside.erase(rat)
			var _rat_scene := RAT.instantiate()
			_rat_scene.size = rat.size
			add_sibling(_rat_scene)
			$rat_release.play()
			_rat_scene.global_position = get_entrance_point()
			return

func get_floor() -> int:
	return floor(global_position.y / 8.0)

func _on_timer_timeout() -> void:
	release_rat()
	$timer.wait_time = randi_range(45, 70)
