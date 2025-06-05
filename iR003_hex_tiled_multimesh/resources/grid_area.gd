class_name GridArea
extends MultiMeshInstance3D

static var MESH := preload("res://resources/terrain/terrain_mesh.tres")

@export_group("Map Attributes")
@export var map_area_origin := Vector2i(0, 0)

var _initial_heights := PackedFloat32Array()
var _initial_colors := PackedColorArray()
var _target_heights := PackedFloat32Array()
var _target_colors := PackedColorArray()

enum AnimStatusType {READY, RUNNING}
var _anim_status := AnimStatusType.READY
var _anim_count := 0.0
var _anim_speed := 0.333
var _anim_direction := 1.0


func _ready():
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	multimesh.use_custom_data = false
	multimesh.instance_count = Main.map.AREA_SIZE_SQR
	multimesh.mesh = MESH

	_generate()

	position.y = -1.0;	


func _generate():
	_initial_heights.resize(Main.map.AREA_SIZE_SQR)
	_initial_colors.resize(Main.map.AREA_SIZE_SQR)
	_target_heights.resize(Main.map.AREA_SIZE_SQR)
	_target_colors.resize(Main.map.AREA_SIZE_SQR)

	var transform := Transform3D()
	var avi = Hex.AxialVeci.new();
	var tile_index := 0
	var map_area_origin_v3 := Vector3i(map_area_origin.x, map_area_origin.y, 0)
	
	avi.vi.z = 0
	avi.vi.y = 0
	while avi.vi.y < Main.map.AREA_SIZE:
		avi.vi.x = 0
		while avi.vi.x < Main.map.AREA_SIZE:
			_initial_heights[tile_index] = 0.0
			_initial_colors[tile_index] = Color.from_hsv(
				Main.rnd.randf_range(0.0, 1.0), 1.0, 0.8)

			_target_heights[tile_index] = Main.rnd.randf_range(0.0, 0.6)
			_target_colors[tile_index] = Color.from_hsv(
				Main.rnd.randf_range(0.0, 1.0), 1.0,
					Main.rnd.randf_range(0.4, 0.6))
			
			transform.origin = avi.to_cube_veci().to_world()
			multimesh.set_instance_transform(tile_index, transform)
			multimesh.set_instance_color(tile_index, _initial_colors[tile_index])

			tile_index += 1
			avi.vi.x += 1
		avi.vi.y += 1


func _process(delta):
	process(delta)


func process(delta):
	if _anim_status == AnimStatusType.RUNNING:
		# advance _anim_count
		_anim_count += _anim_direction * delta * _anim_speed
		# check for animation end
		if ((_anim_direction > 0) and (_anim_count >= 1.0)) or \
				((_anim_direction < 0) and (_anim_count <= 0.0)):
			_anim_status = AnimStatusType.READY
			_anim_count = (_anim_direction + 1.0) / 2.0
			_anim_direction = -_anim_direction
		# interpolate transforms and colors
		for tile_index in Main.map.AREA_SIZE_SQR:
			var transform = self.multimesh.get_instance_transform(tile_index)
			transform.basis.y.y = 1.0 + lerpf(
				_initial_heights[tile_index],
				_target_heights[tile_index],
				_anim_count
			)
			var color = self.multimesh.get_instance_color(tile_index)
			color = _initial_colors[tile_index].lerp(_target_colors[tile_index], _anim_count)
			# apply new transform and color
			multimesh.set_instance_transform(tile_index, transform)
			multimesh.set_instance_color(tile_index, color)


func animate():
	if _anim_status == AnimStatusType.READY:
		_anim_status = AnimStatusType.RUNNING

func _input(event):
	if (event is InputEventKey) and event.is_pressed():
		if event.keycode == KEY_ENTER:
			animate()
			
