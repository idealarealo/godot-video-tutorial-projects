extends Node3D

@onready var _director = $".."
@onready var _main_camera := $"../../../Camera"
@onready var _sm_playback : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

var _anim_status := 0
var _motion_recorder: MotionRecorder
var _next_anim_count := 0
#var _next_print_count := 0


func _ready():
	visible = false
	_motion_recorder = MotionRecorder.new(self)


func _process(delta):
	# var rel_anim_count: float
	match _anim_status:
		0:
			if _director._anim_count >= _director.ANIM_ALTER_FLY_START:
				_anim_status += 1
				_motion_recorder.set_mode(
					MotionRecorder.ModeType.PLAY,
					"res://sampling_dragon2.dat",
					(1.0/24.0)/2.0/_director.TIMING_SPEED)
				_next_anim_count = _director.ANIM_ALTER_FLY_START + 7.0 / _director.TIMING_SPEED
				$AnimationTree.active = true
				# _sm_playback.travel("FlyingPose")
				visible = true
		1:
			if _director._anim_count >= _next_anim_count:
				_sm_playback.travel("FlyingAnim")
				_next_anim_count += 5.0 / _director.TIMING_SPEED
			#if _director._anim_count >= _next_print_count:
			#	_next_print_count += 5.0 / _director.TIMING_SPEED
			#	print_debug("Dragon2: %d sec" %
			#		[((_motion_recorder._sampling_total + _director.ANIM_ALTER_FLY_START - _director.ANIM_SERE_GRAB_START)/3.0) as int])


func _physics_process(delta):
	if _motion_recorder._mode != MotionRecorder.ModeType.IDLE:
		_motion_recorder.process(delta)
