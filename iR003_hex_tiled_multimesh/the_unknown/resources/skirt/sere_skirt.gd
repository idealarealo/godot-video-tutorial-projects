extends Node3D

@onready var _director := $"../../UnkMain"
@onready var _sere := $"../Sere"

var _t := 0.0
var _rot_axis := Vector3(1.0, 0.0, 1.0).normalized()
var _move_dir := Vector3(-2.5, -2.5, 2.0).normalized() * 0.25

func process(delta):
	if visible:
		if position.y > 0.75:
			_t += delta
			basis = Basis.IDENTITY.rotated(_rot_axis, PI/6.0 - PI/5.0 * cos(_t * PI * 0.6 * _director.GLOBAL_SPEED))
			position += _move_dir * delta * _director.GLOBAL_SPEED
		elif position.y > -0.2:
			position.y -= delta * 0.1 * _director.GLOBAL_SPEED
	elif _director._anim_count >= _director.ANIM_SERE_GRAB_START:
		position = _sere.position
		position.y += 1.0
		visible = true
	
