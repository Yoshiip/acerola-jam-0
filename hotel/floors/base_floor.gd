extends NavigationRegion3D

func _ready() -> void:
	$roof.visible = true

func generate_navigation() -> void:
	var _navigation := NavigationMesh.new()
	_navigation.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	_navigation.agent_radius = 0.4
	_navigation.cell_size = 0.2
	_navigation.cell_height = 0.1
	_navigation.geometry_collision_mask = 23
	navigation_mesh = _navigation
	bake_navigation_mesh()
