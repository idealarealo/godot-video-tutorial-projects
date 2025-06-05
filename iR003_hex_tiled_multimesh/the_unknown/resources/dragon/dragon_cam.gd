extends Node3D

@onready var _director = $".."
@onready var _main_camera := $"../../../Camera"
@onready var _sm_playback : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

var _anim_status := 0
var _next_anim_count := 0


func _process(_delta):
	match _anim_status:
		1:
			position = _main_camera.position
			rotation = _main_camera.move_rotation
			if _director._anim_count >= _director.ANIM_WATER_LIFT_START:
				if _director._anim_count >= _next_anim_count:
					_sm_playback.travel("FlyingAnim")
					_next_anim_count = _director._anim_count + 6.0 / _director.TIMING_SPEED
		0:
			if _director._anim_count >= _director.ANIM_WATER_LIFT_START:
				if _director._anim_count < _director.ANIM_WATER_LIFT_END:
					_anim_status = 1
					position = _main_camera.position
					rotation = _main_camera.move_rotation
					$AnimationTree.active = true
					visible = true
					_next_anim_count = _director._anim_count + 4.0 / _director.TIMING_SPEED
