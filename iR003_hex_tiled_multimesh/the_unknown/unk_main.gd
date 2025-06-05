extends Node

const SPECIAL_MODE := 0

var GLOBAL_SPEED := 3.0
var TIMING_SPEED := GLOBAL_SPEED / 3.0


const GRID_AREA := preload("res://resources/grid_area.tscn")
const GRASS_AREA := preload("res://the_unknown/resources/grass/grass_area.tscn")

@onready var _sere := $Sere

enum AnimStatusType {READY, RUNNING, DONE}
var _anim_status := AnimStatusType.READY
var _anim_count := 0.0

var ANIM_INIT_FLYING_TIME := 50.0 / TIMING_SPEED
var ANIM_INIT_FLYING_START := 0.0
var ANIM_INIT_FLYING_END := ANIM_INIT_FLYING_START + ANIM_INIT_FLYING_TIME

var ANIM_SERE_WALK_TIME := 36.0 / TIMING_SPEED
var ANIM_SERE_WALK_START := ANIM_INIT_FLYING_START + 22.0 / TIMING_SPEED
var ANIM_SERE_WALK_END := ANIM_SERE_WALK_START + ANIM_SERE_WALK_TIME

var ANIM_WATER_LIFT_TIME := 7.0 / TIMING_SPEED
var ANIM_WATER_LIFT_START := ANIM_SERE_WALK_END - 9.0 / TIMING_SPEED
var ANIM_WATER_LIFT_END := ANIM_WATER_LIFT_START + ANIM_WATER_LIFT_TIME

var ANIM_TERRAIN_LIFT_TIME := 4.0 / TIMING_SPEED
var ANIM_TERRAIN_LIFT_START := ANIM_SERE_WALK_END - 3.0 / TIMING_SPEED
var ANIM_TERRAIN_LIFT_END := ANIM_TERRAIN_LIFT_START + ANIM_TERRAIN_LIFT_TIME

var ANIM_SERE_WAVE_TIME := 4.0 / TIMING_SPEED
var ANIM_SERE_WAVE_START := ANIM_SERE_WALK_END
var ANIM_SERE_WAVE_END := ANIM_SERE_WAVE_START + ANIM_SERE_WAVE_TIME

var ANIM_ALTER_FLY_TIME := 46.0 / TIMING_SPEED
var ANIM_ALTER_FLY_START := ANIM_SERE_WAVE_END - 2.1 / TIMING_SPEED
var ANIM_ALTER_FLY_END := ANIM_ALTER_FLY_START + ANIM_ALTER_FLY_TIME

var ANIM_SERE_GRAB_START := ANIM_ALTER_FLY_START + 1.6 / TIMING_SPEED
var ANIM_ALTER_IDLEVIS_START := ANIM_ALTER_FLY_END

var ANIM_FINETUNE := 0.5
var ANIM_ALTER_IDLE_TIME := 17.5 / TIMING_SPEED
var ANIM_ALTER_IDLE_START := ANIM_ALTER_FLY_END + (12.5 + ANIM_FINETUNE) / TIMING_SPEED
var ANIM_ALTER_IDLE_END := ANIM_ALTER_IDLE_START + ANIM_ALTER_IDLE_TIME

var ANIM_SERE_LASTWAVE_START := ANIM_ALTER_IDLE_START + (7.1 + ANIM_FINETUNE) / TIMING_SPEED

var _areas : Array[GridArea] = []
enum AnimStepType {
	STEP_START = 0,
	STEP_ANIM_AREA0_FWD1 = 1,
	STEP_ANIM_AREA0_BWD1 = 2,
	STEP_ANIM_AREA0_FWD2 = 3,
	STEP_ANIM_AREAS_FWD = 4,
	STEP_ANIM_AREAS_WAITRESET = 5,
	STEP_ANIM_WAITEND = 6
}
var _anim_step := AnimStepType.STEP_START

var _grass_areas : Array[GrassArea] = []


func _ready():
	var avi := Hex.AxialVeci.new()
	var ai := 0
	var area: GridArea
	var pivot := get_node("../pivot")
	
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	# DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	_areas.resize(Main.map._size_ac_sqr)
	for y in Main.map._size_ac:
		avi.vi.x = 0
		for x in Main.map._size_ac:
			if (y != 0) or (x != 0):
				area = GRID_AREA.instantiate()
				area.map_area_origin = Vector2i(avi.vi.x, avi.vi.y)
				area.position = avi.to_cube_veci().to_world()
				if "_anim_apeed" in area:
					area._anim_speed *= TIMING_SPEED
				pivot.add_child(area)
				_areas.set(ai, area)
				area.visible = false
				area.set_process(false)
				area.set_physics_process(false)
				area.set_process_input(false)
			x += 1
			avi.vi.x += Main.map.AREA_SIZE
			ai += 1
		y += 1
		avi.vi.y += Main.map.AREA_SIZE
	# first area is a special case
	area = $"../../GridArea"
	if "_anim_apeed" in area:
		area._anim_speed *= TIMING_SPEED
	_areas[0] = area
	area.visible = true
	area.set_process(false)
	area.set_physics_process(false)
	

func _recolor_area(area: GridArea, check0: bool = true):
	var wh := 0.5
	var cavi = Hex.CubeVeci.new();
	var cmvi = Hex.CubeVeci.new();
	var tile_index := 0
	var th: float
	var green_cvi := Hex.CubeVeci.from_vec4xi(
			Vector3i(Main.map.size-16, Main.map.size-10, 0), 0
		).adjust_z()
	var map_area_origin := Vector3i(area.map_area_origin.x, area.map_area_origin.y, 0)
	cavi.vi.z = 0
	cavi.vi.y = 0
	while cavi.vi.y < Main.map.AREA_SIZE:
		cavi.vi.x = 0
		while cavi.vi.x < Main.map.AREA_SIZE:
			cmvi.vi = cavi.vi + map_area_origin
			th = exp(Main.map.get_color_v3(cmvi.vi).r * 3.0) - 1.0
			if absf(th - wh) < 0.2:
				th = wh + sign(th - wh - 0.175) * 0.2 - 0.19 + randf_range(-0.03, 0.00)
				
			if check0 and (map_area_origin.x == 0) and (map_area_origin.y == 0):
				area._initial_heights[tile_index] = th
			elif "_target_heights" in area:
				area._target_heights[tile_index] = th
				
				var col_dark := Color.from_hsv(randf_range(0.0, 1.0), 0.1, randf_range(0.15, 0.25))
				if (area.map_area_origin.x >= (Main.map.size-(Main.map.AREA_SIZE<<2))) and \
						(area.map_area_origin.y >= (Main.map.size-(Main.map.AREA_SIZE<<2))):
					var distance := cmvi.distance(green_cvi)
					var norm_dist := clampf((distance as float) / (Main.map.AREA_SIZE<<2), 0.0, 1.0)
					var col_green := Color.from_hsv(
						0.15 + norm_dist * 0.55,
						0.7, randf_range(0.15, 0.25))
					area._target_colors[tile_index] = col_green.lerp(
							col_dark, norm_dist
						)
				else:
					area._target_colors[tile_index] = col_dark
			cavi.vi.x += 1
			tile_index += 1
		cavi.vi.y += 1


func _add_grass():
	var avi := Hex.AxialVeci.new()
	var ai := 0
	var pivot := get_node("../pivot")

	_grass_areas.resize(16)
	ai = 0
	for y in 4:
		avi.vi.x = 0
		for x in 4:
			var garea = GRASS_AREA.instantiate()
			garea.linked_grid_area = _areas[
					((Main.map._size_ac-4+y)<<Main.map._size_ac_2pow) +
					(Main.map._size_ac-4+x)
				]
			garea.visible = true
			garea.set_process(false)
			garea.set_physics_process(false)
			garea.set_process_input(false)
			_grass_areas.set(ai, garea)
			pivot.add_child(garea)
			x += 1
			ai += 1
		y += 1


func _ready2():
	for area in _areas:
		_recolor_area(area)


func _process(delta):
	var rel_anim_count: float
	_anim_count += delta
	match _anim_status:
		AnimStatusType.READY:
			if _anim_count >= ANIM_INIT_FLYING_START:
				_anim_status = AnimStatusType.RUNNING
				if SPECIAL_MODE > 0:
					_anim_count = ANIM_INIT_FLYING_END - 1.0 / TIMING_SPEED
			pass
		AnimStatusType.RUNNING:
			match _anim_step:
				AnimStepType.STEP_START:
					if _anim_count >= ANIM_INIT_FLYING_START + ANIM_INIT_FLYING_TIME * 2.5 / 4.0:
						_anim_step = AnimStepType.STEP_ANIM_AREA0_FWD1
						_areas[0].animate()
					if (_anim_count >= ANIM_SERE_WALK_START) and (_anim_count <= ANIM_SERE_WALK_START + 3.0 / TIMING_SPEED):
						rel_anim_count = _anim_count - ANIM_SERE_WALK_START
						$"../../Sun".shadow_opacity = lerp(0.0, 1.0, rel_anim_count / 3.0 * TIMING_SPEED)
				AnimStepType.STEP_ANIM_AREA0_FWD1:
					if _anim_count >= ANIM_INIT_FLYING_START + ANIM_INIT_FLYING_TIME * 3.0 / 4.0:
						_anim_step = AnimStepType.STEP_ANIM_AREA0_BWD1
						_areas[0].animate()
				AnimStepType.STEP_ANIM_AREA0_BWD1:
					if _anim_count >= ANIM_INIT_FLYING_START + ANIM_INIT_FLYING_TIME * 3.4 / 4.0:
						_anim_step = AnimStepType.STEP_ANIM_AREA0_FWD2
						_areas[0].animate()
				AnimStepType.STEP_ANIM_AREA0_FWD2:
					if _anim_count >= ANIM_TERRAIN_LIFT_START:
						_anim_step = AnimStepType.STEP_ANIM_AREAS_FWD
						_ready2()
						for area in _areas:
							area.animate()
							area.visible = true
				AnimStepType.STEP_ANIM_AREAS_FWD:
					if _anim_count > ANIM_TERRAIN_LIFT_END:
						_anim_step = AnimStepType.STEP_ANIM_AREAS_WAITRESET
						_add_grass()
						$"../../Sun".shadow_opacity = 1.0
				AnimStepType.STEP_ANIM_AREAS_WAITRESET:
					if _anim_count >= ANIM_SERE_GRAB_START:
						_anim_step = AnimStepType.STEP_ANIM_WAITEND
						var area: GridArea = _areas[0]
						_recolor_area(area, false)
						area._anim_speed = 2.0
						area.animate()
						
			process_others(delta)


func process_others(delta):
	for area in _areas:
		if area is GridArea:
			area.process(delta)
#	$"../../Camera".process(delta)
	$Water.process(delta)
	$SereSkirt.process(delta)
	_sere.process(delta)
	$GlassBall.process(delta)
