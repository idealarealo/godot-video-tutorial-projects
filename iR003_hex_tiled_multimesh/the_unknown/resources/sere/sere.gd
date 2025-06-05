extends Node3D

const COLORING_RADIUS := 12

@onready var _director = $".."
@onready var _area: GridArea = $"../../../GridArea"
@onready var _sm_playback : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var _dragon2 := $"../Dragon2"

var _anim_num: int

# Animation 0
var _centre_vec: Vector3
var _radius := Hex.TILE_RADIUS * 4.2

# Animation 1
var _anim1_transform1: Transform3D
var _anim1_transform2: Transform3D


var _old_idx: int = -1
var _new_idx: int
var _new_coords := Hex.AxialVeci.new()
var _cv = Hex.CubeVec.new()
var _cvi = Hex.CubeVeci.new()
var _old_color: Color
var cur_cvi = Hex.CubeVeci.new()

var _basey: float

func _ready():
	_centre_vec = Hex.AxialVec.from_vec3(Vector3i(3.5, 3.5, 0.0)).to_cube_vec().to_world()
	_anim_num = 0
	visible = false


func _get_map_height(pos: Vector3, default: float = 0.0) -> float:
	_cv.set_from_world(pos).to_cube_veci(_cvi)
	var _idx: int = (_cvi.vi.y << Main.map.AREA_SIZE_2POW) + _cvi.vi.x;
	if _idx >= 0 && _idx < 64:
		var t := _area.multimesh.get_instance_transform(_idx)
		return t.origin.y + t.basis.y.y - 1.0
	return default


func _get_max_map_height(pos: Vector3) -> float:
	const dx := 0.2
	const dz := 0.2
	var h: float
	h = _get_map_height(pos + Vector3(dx, 0.0, dz))
	h = maxf(h, _get_map_height(pos + Vector3(-dx, 0.0, dz)))
	h = maxf(h, _get_map_height(pos + Vector3(-dx, 0.0, -dz)))
	h = maxf(h, _get_map_height(pos + Vector3(dx, 0.0, -dz)))
	return h

func _get_avg_map_height(pos: Vector3) -> float:
	const dx := 0.3
	const dz := 0.4
	var h: float
	var tot := 0.0
	var num := 0
	h = _get_map_height(pos + Vector3(dx, 0.0, dz), NAN)
	if not is_nan(h):
		tot += h
		num += 1
	h = _get_map_height(pos + Vector3(-dx, 0.0, dz), NAN)
	if not is_nan(h):
		tot += h
		num += 1
	h = _get_map_height(pos + Vector3(-dx, 0.0, -dz), NAN)
	if not is_nan(h):
		tot += h
		num += 1
	h = _get_map_height(pos + Vector3(dx, 0.0, -dz), NAN)
	if not is_nan(h):
		tot += h
		num += 1
	return (tot / num) if num > 0 else 0.0


func color_around(pos: Vector3, radius: int = 20, reset: bool = false, mark_centre: bool = true):
	var xcvi := Hex.CubeVeci.new()
	var xcv := Hex.CubeVec.new()
	var p := pos
	var xcol: Color
	var _vi := Vector3i()
	_cv.set_from_world(pos).to_cube_veci(_cvi)
	p.y = 0.0
	for dy in range(-radius, radius):
		xcvi.vi.y = _cvi.vi.y + dy
		if (xcvi.vi.y < 0) or (xcvi.vi.y >= Main.map.size):
			continue
		for dx in range(-radius, radius):
			xcvi.vi.x = _cvi.vi.x + dx
			if (xcvi.vi.x < 0) or (xcvi.vi.x >= Main.map.size):
				continue
			xcvi.adjust_z()
			if _cvi.distance(xcvi) <= radius:
				var mac := Vector2i(xcvi.vi.x >> Main.map.AREA_SIZE_2POW, xcvi.vi.y >> Main.map.AREA_SIZE_2POW)
				var mai: int = (mac.y << Main.map._size_ac_2pow) + mac.x
				var area: GridArea = _director._areas[mai]
				if area:
					var ac := Vector2i(xcvi.vi.x & Main.map.AREA_SIZE_MASK, xcvi.vi.y & Main.map.AREA_SIZE_MASK)
					var ai: int = (ac.y << Main.map.AREA_SIZE_2POW) + ac.x
					if (_cvi.distance(xcvi) <= radius-1) and not reset:
						var v := xcv.set_from_cube_veci(xcvi).to_world()
						var d := clampf(v.distance_to(p) / (radius * Hex.TILE_RADIUS), 0.0, 1.0)
						xcol = area._initial_colors[ai] if !mark_centre or (dx != 0) or (dy != 0) else Color.WHITE
						var col: Color = area._target_colors[ai].lerp(xcol, 1.0 - d)
						area.multimesh.set_instance_color(ai, col)
					else:
						area.multimesh.set_instance_color(ai, area._target_colors[ai])
					

func process(delta):
	var rel_anim_count: float
	
	if _director._anim_status != _director.AnimStatusType.RUNNING:
		return
	match _anim_num:
		0: # waiting --> walking
			if _director._anim_count >= _director.ANIM_SERE_WALK_START:
				# go walking
				_anim_num = 1
				visible = true
				$AnimationTree.active = true
				_basey = _get_max_map_height(position)
				position.y = _basey
				
		1: # walking --> wavingpose
			if _director._anim_count >= _director.ANIM_SERE_WALK_END:
				# go wavingpose
				_anim_num = 2
				_sm_playback.travel("WavingPose")
				_anim1_transform1 = transform
				_anim1_transform2 = transform.rotated_local(Vector3.UP, -PI/2.0)
				_anim1_transform2.origin = Hex.AxialVeci.from_vec3i(Vector3i(1, 0, 0)).to_cube_veci().to_world()
			else:
				rel_anim_count = _director._anim_count - _director.ANIM_SERE_WALK_START
				var b := Basis.IDENTITY.rotated(Vector3.UP, (rel_anim_count / _director.ANIM_SERE_WALK_TIME) * -TAU * 2.0 + PI/2.0 + PI/12.0 )
				transform = Transform3D(b, _centre_vec + b * Vector3(_radius, 0.0, 0.0))
				_new_coords.set_from_cube_veci(_cv.set_from_world(position).to_cube_veci(_cvi))
				cur_cvi.set_from_cube_veci(_cvi)
				_new_idx = (_new_coords.vi.y << Main.map.AREA_SIZE_2POW) + _new_coords.vi.x;
				if _new_idx < 0 || _new_idx >= 64:
					_new_idx = -1
				if _new_idx != _old_idx:
					if _director._anim_count < _director.ANIM_TERRAIN_LIFT_START:
						if _old_idx >= 0:
							_area.multimesh.set_instance_color(_old_idx, _old_color)
					_old_idx = _new_idx
					_old_color = _area.multimesh.get_instance_color(_new_idx)
				if _director._anim_count < _director.ANIM_TERRAIN_LIFT_START:
					if _new_idx >= 0:
						_area.multimesh.set_instance_color(_new_idx, Color.WHITE)

				var h := _get_max_map_height(position)
				var speed := 1.0 if (h - _basey) < h * 0.1 else 3.0
				_basey = lerpf(_basey, h, delta * speed * _director.GLOBAL_SPEED)
				position.y = _basey
				
		2: # wavingpose + waving --> flying
			if _director._anim_count >= _director.ANIM_SERE_GRAB_START:
				_anim_num = 3
				_sm_playback.travel("Flying")
				
				# $Model/Skeleton3D/pants.visible = true
				# $Model/Skeleton3D/skirt.visible = false
				_area.multimesh.set_instance_color(_new_idx, _old_color)
				
				# reparent to Dragon2
				get_parent().remove_child(self)
				_dragon2.get_child(0).add_child(self)
				position = Vector3(0.0, -1.54, -0.167)
				rotation = Vector3.ZERO
			else:
				rel_anim_count = _director._anim_count - _director.ANIM_SERE_WAVE_START
				transform = _anim1_transform1.interpolate_with(_anim1_transform2, clampf(rel_anim_count * 4.0 / _director.ANIM_SERE_WAVE_TIME, 0.0, 1.0))

				var h := _get_max_map_height(position)
				var speed := 1.0 if (h - _basey) < h * 0.1 else 3.0
				_basey = lerpf(_basey, h, delta * speed * _director.GLOBAL_SPEED)
				position.y = _basey
				
		3:	# flying --> laying
			if _director._anim_count >= _director.ANIM_ALTER_IDLEVIS_START:
				_anim_num = 4
				# reparent to UnkMain
				get_parent().remove_child(self)
				_director.add_child(self)

				var sere_cvi = Hex.AxialVeci.from_vec3(
					Vector3(Main.map.size - 24, Main.map.size - 18, 0.0)
					).to_cube_veci()
				position = sere_cvi.to_world()
				position += Vector3(Hex.TILE_RADIUS/5.0, 0.0, 0.0)
				position.y = 1.5
				rotation = Vector3(0.0, PI - PI/20.0, 0.0)

				var mac := Vector2i(sere_cvi.vi.x >> Main.map.AREA_SIZE_2POW, sere_cvi.vi.y >> Main.map.AREA_SIZE_2POW)
				var macg := Vector2i(mac.x - Main.map._size_ac + 4, mac.y - Main.map._size_ac + 4)
				var maig: int = (macg.y << 2) + macg.x
				var areag: GrassArea = _director._grass_areas[maig]
				if areag:
					var ac := Vector2i(sere_cvi.vi.x & Main.map.AREA_SIZE_MASK, sere_cvi.vi.y & Main.map.AREA_SIZE_MASK)
					var ai: int = (ac.y << Main.map.AREA_SIZE_2POW) + ac.x
					areag.multimesh.set_instance_transform(ai, Transform3D.IDENTITY.scaled(Vector3.ZERO))

				_sm_playback.travel("LayingPoseAnim")
				
		4:	# laying --> lastwave
			if _director._anim_count >= _director.ANIM_SERE_LASTWAVE_START:
				_anim_num = 5
				_sm_playback.travel("LastWave")

	if _director._anim_count >= _director.ANIM_TERRAIN_LIFT_START:
		color_around(global_position, COLORING_RADIUS,
				_director._anim_count >= _director.ANIM_ALTER_FLY_END - (2.0/_director.TIMING_SPEED),
				_director._anim_count <= _director.ANIM_SERE_GRAB_START
			)
