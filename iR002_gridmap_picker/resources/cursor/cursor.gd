extends Node3D

var _MOTION_RATIO : float = 1.

@export var MOVEMENT_SPEED : float = 20. * _MOTION_RATIO
@export var ROTATION_SPEED : float = .75 * _MOTION_RATIO

@onready var _main_viewport = get_tree().root.get_viewport()
@onready var _main_camera = get_tree().root.get_camera_3d()
@onready var _target_position = position
var _rotation_delta_tot : float = 0.
var _visibility_direction : int = 1
var _visibility_amount : float = 1.

@onready var _colorizeShaderMat : ShaderMaterial = preload("res://resources/cursor/colorize.tres")
@onready var _pivot : MeshInstance3D = $pivot
var _selected_item : int = -1

@export var _terrain_map : GridMap = null
@export var _object_map : GridMap = null

func _process(delta):
	# movement
	if position != _target_position:
		var pos_delta = (_target_position - position);
		var pos_delta_len = pos_delta.length();
		var speed = pos_delta_len * delta * MOVEMENT_SPEED;
		if speed > 0.0025 and speed < 5.:
			position += pos_delta * delta * MOVEMENT_SPEED;
			position.y = max(position.y, _target_position.y)
		else:
			position = _target_position

	# self rotation
	_rotation_delta_tot = fmod(_rotation_delta_tot + delta * ROTATION_SPEED, 2.)
	$Cursor.rotation_degrees.y = 45. * cos(PI * _rotation_delta_tot)


func _on_mouse_moved(mouse_3d_position : Vector3):
	var _show : bool = true
	_target_position = round(mouse_3d_position)
	if _terrain_map:
		var ci : int = _terrain_map.get_cell_item(_terrain_map.local_to_map(_target_position))
		if ci >= 0:
			var cm : Mesh = (_terrain_map.mesh_library.get_item_mesh(ci))
			_target_position.y = cm.get_aabb().end.y
		if _selected_item != -1:
			_colorizeShaderMat.set_shader_parameter("allow", abs(_target_position.y + _pivot.position.y) <= 0.001)

func _input(event):
	if Input.is_action_just_released("ui_accept"):
		if _object_map:
			var map_coordinates = _object_map.local_to_map(_target_position)
			var old_selected_item : int = _selected_item
			var new_selected_item : int = _object_map.get_cell_item(map_coordinates)
			if (old_selected_item == -1) and (new_selected_item != -1):
				# capture
				_selected_item = new_selected_item
				var new_selected_mesh : Mesh = _object_map.mesh_library.get_item_mesh(new_selected_item)
				_pivot.mesh = new_selected_mesh.duplicate()
				for idx in new_selected_mesh.get_surface_count():
					var mat : StandardMaterial3D = _pivot.mesh.surface_get_material(idx).duplicate()
					mat.render_priority = 1
					mat.next_pass = _colorizeShaderMat
					_pivot.mesh.surface_set_material(idx, mat)
				
				var terrain_item : int = _terrain_map.get_cell_item(map_coordinates)
				if terrain_item != -1:
					var terrain_mesh : Mesh = _terrain_map.mesh_library.get_item_mesh(terrain_item)
					_pivot.position.y = -terrain_mesh.get_aabb().end.y
				else:
					_pivot.position.y = 0.
				
				_object_map.set_cell_item(map_coordinates, -1)
			elif (old_selected_item != -1) and (new_selected_item == -1):
				# release
				_selected_item = -1
				_pivot.mesh = null
				_object_map.set_cell_item(map_coordinates, old_selected_item)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var mouse_position = _main_viewport.get_mouse_position()
		var ray_origin = _main_camera.project_ray_origin(mouse_position)
		var ray_direction = _main_camera.project_ray_normal(mouse_position)
		# ray_target.y = 0  (ground)
		if absf(ray_direction.y) > .001:
			var target_distance = -ray_origin.y / ray_direction.y
			var ray_target = ray_origin + ray_direction * target_distance
			_on_mouse_moved(ray_target)
