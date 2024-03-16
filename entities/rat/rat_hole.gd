extends Node3D

const RAT = preload("res://entities/rat/rat.tscn")

var rats_inside : Array[Dictionary] = [
	
]

@onready var hotel : Hotel = get_tree().current_scene

func _ready() -> void:
	add_to_group("Hole")
	#$timer.wait_time = randi_range(1, 2)
	$timer.wait_time = randi_range(50, 70)
	$timer.start()
	for i in randi_range(1, 3):
		rats_inside.append({
			"size": randf_range(1.0, 1.2),
			"color": "black",
			"terrified": false,
			"out_today": false,
		})
	
	hotel.new_day_started.connect(new_day_started)


func new_day_started() -> void:
	if rats_inside.is_empty():
		queue_free()
	var _all_terrified = true
	for rat in rats_inside:
		if rat.terrified:
			rat.terrified = false
		else:
			_all_terrified = false
			rat.out_today = false
		grow_rat(rat, randf_range(0.2, 0.4))
	if _all_terrified:
		queue_free()

func grow_rat(rat : Dictionary, by : float) -> void:
	rat.size = min(rat.size + by, 4)

func get_entrance_point() -> Vector3:
	return global_position + (-transform.basis.z * 0.25)

func rat_entered(rat : Rat) -> void:
	if rats_inside.size() < 5:
		rats_inside.append({
			"size": rat.size,
			"color": "black",
			"out_today": true,
			"terrified": rat.terrified
		})
	else:
		for rat_data in rats_inside:
			grow_rat(rat_data, rat.size / 5.0)
	rat.queue_free()
	if is_instance_valid(rat.picked_prop):
		for rat_data in rats_inside:
			grow_rat(rat_data, 0.2)

		rat.picked_prop.queue_free()
	hotel.emit_signal("rats_changed")

func release_rat() -> void:
	if rats_inside.is_empty() || hotel.time_left <= 0:
		return
	for rat in rats_inside:
		if !(rat.out_today && rat.terrified):
			rats_inside.erase(rat)
			var _rat_scene := RAT.instantiate()
			_rat_scene.size = rat.size
			_rat_scene.start_hole = self
			add_sibling(_rat_scene)
			$rat_release.play()
			hotel.emit_signal("rats_changed")
			return

func get_floor() -> int:
	return floor(global_position.y / 8.0)

func _on_timer_timeout() -> void:
	release_rat()
	$timer.wait_time = randi_range(45, 70)
