extends Control

var prop : Node3D

var camera : Camera3D
var player : Player

func _ready() -> void:
	player = get_tree().current_scene.get_node("player")
	camera = get_viewport().get_camera_3d()
	$circle.rotation = randf() * PI * 2

func _process(delta: float) -> void:
	if !is_instance_valid(prop) || player.get_floor() != prop.get_floor():
		queue_free()
		return
	var _step := (player.position - prop.position).length() * 0.2
	$label.modulate.a = smoothstep(0.0, 1.0, 1.0 - _step)
	var _circle_step := (player.position - prop.position).length() * 0.2
	$circle.modulate.a = clamp(smoothstep(0.0, 0.75, _step), 0.25, 0.5)
	$circle.scale = Vector2.ONE * clamp(smoothstep(0.0, 0.75, _step), 0.65, 1.0)
	$label.text = prop.display_name
	visible = not camera.is_position_behind(prop.global_position)
	position = camera.unproject_position(prop.global_position) - Vector2(32, 32)
	$circle.rotation += delta * (1.0 - _step)
