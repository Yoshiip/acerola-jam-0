@tool

extends Marker3D

@export var force_wall := false:
	set(value):
		force_wall = value
		_update()

@export var left : bool:
	set(value):
		left = value
		_update()
@export var right : bool:
	set(value):
		right = value
		_update()
@export var front : bool:
	set(value):
		front = value
		_update()
@export var back : bool:
	set(value):
		back = value
		_update()

@export_range(0.0, 3.0) var rat_hole_expands := 3.0:
	set(value):
		rat_hole_expands = value
		_update()

func _ready() -> void:
	for child in get_children():
		child.queue_free()
	if Engine.is_editor_hint():
		_update()


func _update() -> void:
	rotation.y = 0
	if force_wall && !name.ends_with("WALL"):
		name += " WALL"
	elif !force_wall:
		name = name.replace(" WALL", "_")
	for child in get_children():
		child.queue_free()
	for angle in get_all_angles():
		_add_debug_shape(angle)

func get_all_angles() -> Array[Vector4]:
	var list : Array[Vector4] = []
	if left: list.append(Vector4(-4, 0, 0, PI / 2))
	if right: list.append(Vector4(4, 0, 0, -PI / 2))
	if front: list.append(Vector4(0, 0, -4, 0))
	if back: list.append(Vector4(0, 0, 4, PI))
	return list


func get_all_global_angles() -> Array[Vector4]:
	var list : Array[Vector4] = []
	if left: list.append(Vector4(-4, 0, 0, PI / 2))
	if right: list.append(Vector4(4, 0, 0, -PI / 2))
	if front: list.append(Vector4(0, 0, -4, 0))
	if back: list.append(Vector4(0, 0, 4, PI))
	return list


func _add_debug_shape(pos : Vector4) -> void:
	var mesh = MeshInstance3D.new()
	var _plane := BoxMesh.new()
	if force_wall:
		var _wall_m := StandardMaterial3D.new()
		_wall_m.albedo_color = Color.BLACK
		_plane.material = _wall_m
		mesh.material_override = _wall_m
	_plane.size.x = 8
	_plane.size.y = 4
	_plane.size.z = 0.2
	mesh.mesh = _plane
	mesh.position = Vector3(pos.x, pos.y + 2, pos.z)
	mesh.rotation.y = pos.w
	add_child(mesh)
	
	var _rat_mesh = MeshInstance3D.new()
	var _rat_m := StandardMaterial3D.new()
	_rat_m.albedo_color = Color.RED
	var _rat_plane := BoxMesh.new()
	_rat_plane.material = _rat_m
	_rat_plane.size.x = rat_hole_expands * 2
	_rat_plane.size.y = 0.2
	_rat_plane.size.z = 0.2
	_rat_mesh.mesh = _rat_plane
	_rat_mesh.position = Vector3(pos.x, pos.y + 2, pos.z) + Vector3.FORWARD.rotated(Vector3.UP, pos.w)
	_rat_mesh.rotation.y = pos.w
	add_child(_rat_mesh)
