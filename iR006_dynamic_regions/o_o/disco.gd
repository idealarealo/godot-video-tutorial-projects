extends Node3D

@onready var mirrorball : MeshInstance3D = $MirrorBall
@onready var reflection : MeshInstance3D = $MirrorBall/ReflectionProbe/Reflection
@onready var sere : MeshInstance3D = $MirrorBall/ReflectionProbe/Reflection

var _t : float = 0.0

func _ready():
	set_process(visible)

func _process(delta: float) -> void:
	_t += delta
	mirrorball.rotation.y = - fmod(_t, 4.0) * TAU / 4.0
	reflection.rotation = Vector3(
		fmod(_t, 5.0) * TAU / 5.0,
		PI/2.0 + fmod(_t, 6.0) * TAU / 6.0,
		PI/3.0 - fmod(_t, 4.5) * TAU / 4.5,
		)
