extends Camera3D

@onready var _director := $"../TheUnknown/UnkMain"

const DISTANCE := 2.5
static var TARGET := Hex.CubeVec.from_vec4x(Vector3(3.5, 3.5, 0.0), 1.0).to_world()

@onready var FLYAROUND_SPEED: float = 0.1 / _director.TIMING_SPEED
@onready var FLYDOWN_SPEED: float = 0.5 / _director.TIMING_SPEED

@export_range(0.0, 10.0, 0.01) var sensitivity: float = 3.0

var _t := 0.0
var _h_beg := 5.0
var _h_end := 2.0
var _h := _h_beg

const FIXED_LOOK_ANGLES := Vector3(-PI/8.0, 0.0, 0.0)

var driving_enabled := false
var free_look_enabled := false
var input_look_angles := Vector3.ZERO
var look_angles := Vector3.ZERO
var input_move_angles := Vector3.ZERO
var input_move_noise := Vector3.ZERO
var input_move_speed := 0.5
var input_direction := Vector3.ZERO
var move_speed := 1.0
var rotate_speed := 1.0
# var move_direction := Vector3.ZERO
var move_rotation := Vector3.ZERO

var pitch_speed := 1.0
var yaw_speed := 1.0

var _motion_recorder: MotionRecorder


func _ready():
	_motion_recorder = MotionRecorder.new(self)


func _process(delta):
	var rel_anim_count: float
	var rel_anim_ratio: float
	
	if _director._anim_count >= _director.ANIM_INIT_FLYING_START:
		if not driving_enabled:
			rel_anim_count = _director._anim_count - _director.ANIM_INIT_FLYING_START
			rel_anim_ratio = rel_anim_count / _director.ANIM_INIT_FLYING_TIME
			_t = 4.5 * TAU * rel_anim_ratio - PI/2.0
			_h = lerp(_h_beg, _h_end, clampf(rel_anim_ratio * 4.0, 0.0, 1.0))
			var dist := lerpf(DISTANCE, DISTANCE*2.5, absf(cos(PI * rel_anim_ratio)))
			position = TARGET + Vector3(dist * cos(_t), _h, dist * sin(_t))
			look_at(TARGET)

			move_rotation = rotation - FIXED_LOOK_ANGLES
			if _director._anim_count >= _director.ANIM_INIT_FLYING_END:
				# move_rotation = rotation - FIXED_LOOK_ANGLES
				input_look_angles = rotation - move_rotation - FIXED_LOOK_ANGLES * 0.95
				# input_look_angles /= 2.0
				input_move_angles = input_look_angles # Vector3.ZERO
				move_speed = 0.19
				input_move_speed = 0.19
				driving_enabled = true
				# sampling mode
				if _director.SPECIAL_MODE == 3:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					_motion_recorder.set_mode(MotionRecorder.ModeType.REC, "sampling.dat", (1.0/24.0)/2.0/_director.TIMING_SPEED/3.0)
				elif _director.SPECIAL_MODE == 0:
					# playback mode
					_motion_recorder.set_mode(MotionRecorder.ModeType.PLAY, "sampling_dragon1.dat", (1.0/24.0)/2.0/_director.TIMING_SPEED/3.0)
					input_look_angles = - FIXED_LOOK_ANGLES * 0.65
					input_direction = Vector3.ZERO
					input_move_angles = Vector3.ZERO
					move_speed = 0.0
					input_move_speed = 0.0
			


# fmod equivalent for angles (in radiants)
func _rmod(angle: float) -> float:
	if angle > PI:
		return -PI + (angle - PI)
	if angle < -PI:
		return PI + (angle + PI)
	return angle


# fmod equivalent for Vector3 of radiants
func _vrmod(v: Vector3) -> Vector3:
	var v2 := Vector3(v)
	v2.x = _rmod(v2.x)
	v2.y = _rmod(v2.y)
	v2.z = _rmod(v2.z)
	return v2


func _physics_process(delta):
	if driving_enabled:
		if _motion_recorder._mode != MotionRecorder.ModeType.PLAY:
			if not free_look_enabled:
				input_look_angles *= (1.0 - 0.5 * delta * _director.GLOBAL_SPEED)
			look_angles = lerp(look_angles, input_look_angles, 0.33) 

			input_move_speed += \
				((float)(Input.is_physical_key_pressed(KEY_W)) \
				-(float)(Input.is_physical_key_pressed(KEY_S))) * delta
			input_move_speed = clampf(input_move_speed, 0.0, 3.0)
			
			input_move_noise *= (1.0 - 0.5 * delta)
			input_move_noise.x = clampf(input_move_noise.x + (exp(randf())-1.0)/exp(1.0) * delta * input_move_speed / 3.0, -PI/10.0, PI/10.0)
			input_move_noise.y = clampf(input_move_noise.y + (exp(randf())-1.0)/exp(1.0) * delta * input_move_speed / 3.0, -PI/10.0, PI/10.0)
			
			input_move_angles *= (1.0 - 1.25 * delta * _director.GLOBAL_SPEED)
			move_rotation.x *= (1.0 - 0.2 * delta * _director.GLOBAL_SPEED)
			move_rotation.z *= (1.0 - 1.0 * delta * _director.GLOBAL_SPEED)
			
			move_rotation = _vrmod(move_rotation + (input_move_angles * delta * 4.0 * _director.GLOBAL_SPEED))
			var move_direction := -(Basis.from_euler(move_rotation, rotation_order)).z  # EULER_ORDER_YXZ
			position += move_direction * delta * input_move_speed * _director.GLOBAL_SPEED
			if is_zero_approx(input_move_speed):
				position.y += (2.7 - position.y) * delta * 0.2 * _director.GLOBAL_SPEED
			# position.y = (position.y + 0.005 * GLOBAL_SPEED * 3.0) / (1.0 + 0.005 * GLOBAL_SPEED)
			rotation = move_rotation + look_angles + input_move_noise + FIXED_LOOK_ANGLES * (sin(-PI/2.0 + PI * input_move_speed / 3.0)*0.25+0.75)
		
	if _motion_recorder._mode != MotionRecorder.ModeType.IDLE:
		_motion_recorder.process(delta)
		if _motion_recorder._mode == MotionRecorder.ModeType.PLAY:
			move_rotation = rotation

		
func _input(event):
	if event is InputEventKey:
		match event.physical_keycode:
			KEY_ESCAPE:
				if event.is_pressed():
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					get_tree().quit()
			KEY_CTRL:
				free_look_enabled = event.is_pressed()
			KEY_Y:
				if event.is_pressed():
					if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
						Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					else:
						Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			KEY_R:
				if event.is_pressed():
					if _motion_recorder._mode != MotionRecorder.ModeType.REC:
						_motion_recorder._sampling_time = (1.0/24.0)/2.0/_director.TIMING_SPEED
						_motion_recorder.set_mode(MotionRecorder.ModeType.REC, "sampling.dat")
					else:
						_motion_recorder.set_mode(MotionRecorder.ModeType.IDLE)
			KEY_P:
				if event.is_pressed():
					if _motion_recorder._mode != MotionRecorder.ModeType.PLAY:
						_motion_recorder._sampling_time = (1.0/24.0)/2.0/_director.TIMING_SPEED
						_motion_recorder.set_mode(MotionRecorder.ModeType.PLAY, "sampling.dat")
					else:
						_motion_recorder.set_mode(MotionRecorder.ModeType.IDLE)

	if driving_enabled:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				free_look_enabled = event.is_pressed()
		if event is InputEventMouseMotion:
			var delta_x = - event.relative.x * sensitivity * _director.GLOBAL_SPEED / 1000.0
			var delta_y = - event.relative.y * sensitivity * _director.GLOBAL_SPEED / 1000.0
			if free_look_enabled:
				# pitch
				input_look_angles.x = clampf(input_look_angles.x + delta_y, -PI/2.0, PI/2.0)
				# yaw
				input_look_angles.y = clampf(input_look_angles.y + delta_x, -PI/2.0, PI/2.0)
				# roll
				input_look_angles.z = input_look_angles.y / 2.0
			else:
				# pitch
				input_move_angles.x = clampf(input_move_angles.x + delta_y, -PI/2.0, PI/2.0)
				# yaw
				input_move_angles.y = clampf(input_move_angles.y + delta_x, -PI/2.0, PI/2.0)
				# roll
				input_move_angles.z = input_move_angles.y * 2.0
	else:
		if event is InputEventKey:
			if (not driving_enabled) and (event.is_pressed() && event.physical_keycode == KEY_SPACE):
				move_rotation = rotation - FIXED_LOOK_ANGLES + Vector3(0.0, PI/8.0, 0.0)
				input_look_angles = rotation - move_rotation - FIXED_LOOK_ANGLES
				input_move_angles = Vector3.ZERO
				move_speed = 0.1
				input_move_speed = 0.1
				driving_enabled = true
