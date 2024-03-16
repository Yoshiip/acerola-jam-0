extends NavigationRegion3D

var floor_color := "red"

func _ready() -> void:
	$roof.visible = true
	for carpet in $carpets.get_children():
		carpet.texture = load(str("res://hotel/texture/corridor_carpets/", floor_color, ".png"))

func generate_navigation() -> void:
	var _navigation := NavigationMesh.new()
	_navigation.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	_navigation.agent_radius = 0.4
	_navigation.cell_size = 0.2
	_navigation.cell_height = 0.1
	_navigation.geometry_collision_mask = 23
	navigation_mesh = _navigation
	bake_navigation_mesh()
