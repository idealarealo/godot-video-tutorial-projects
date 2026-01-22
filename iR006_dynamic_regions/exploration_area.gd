extends Node3D

static var WHITE_MATERIAL := preload("res://white.material")

@export var _camera: Camera3D = null
@onready var _world: DiscoverableWorld = $".."
@onready var _mesh: ImmediateMesh = $ImmediateMeshInstance3D.mesh
var _exploration_polygon := PackedVector3Array()
var _exploration_polygon_valid := false

# variables for programatic discovery
@onready var _scanner := PolygonUtils.ScanlineFill.new(_world.WORLD_RECT)
var _prev_scanpoints: Dictionary[Vector2i, bool] = {}
var rot: float = 0.0


func _process(_delta: float) -> void:
	# _exploration_polygon = camera frustum projection on the ground
	_exploration_polygon_valid = PolygonUtils.update_visible_polygon(_camera, _exploration_polygon)

	# TEST _exploration_polygon = a rotating pentagon
	#if not _world.AUTODISCOVERABLE:
		#rot = fposmod(rot + _delta, TAU)
		#_exploration_polygon.resize(5)
		#for i in 5:
			#var angle_rad: float = TAU*i/5.0 + rot
			#_exploration_polygon.set(i, 8.1 * Vector3(cos(angle_rad), 0.0, -sin(angle_rad)))
		#_exploration_polygon_valid = true

	# rebuild the polygon mesh
	_update_mesh()

	# show/hide regions
	if not _world.AUTODISCOVERABLE:
		_programatic_exploration()


func _update_mesh() -> void:
	if _exploration_polygon_valid:
		_mesh.clear_surfaces()
		_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, WHITE_MATERIAL)
		for v in _exploration_polygon:
			_mesh.surface_add_vertex(v)
		_mesh.surface_add_vertex(_exploration_polygon[0])
		_mesh.surface_end()


func _difference(d: Dictionary[Vector2i, bool], dsub: Dictionary[Vector2i, bool]) -> Dictionary[Vector2i, bool]:
	for v in dsub.keys():
		d.erase(v)
	return d


func _programatic_exploration():
	# convert the _exploration_polygon into a coarse-grained polygon
	var region: DiscoverableRegion
	var scan_polygon: Array[Vector2i] = []
	for v3 in _exploration_polygon:
		scan_polygon.append(Vector2i(round(v3.x),round(v3.z)))
	
	# find regions coordinates using a scanline-fill algorithm on scan_polygon
	var scanpoints := _scanner.scan(scan_polygon)
	
	# hide regions that are no longer explored
	for wc in _difference(_prev_scanpoints, scanpoints).keys():
		region = _world.get_region_by_coordinates(wc)
		region.discovered = false
	
	# show the regions currently explored
	for wc in scanpoints.keys():
		region = _world.get_region_by_coordinates(wc)
		region.discovered = true
	
	_prev_scanpoints = scanpoints
