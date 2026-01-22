extends Camera3D

var _t: float = 0.0

func _process(delta: float) -> void:
	_t += delta
	_animate2()

func _animate1():
	rotation_degrees = Vector3(
		-30.0 + 30.0 * sin(fmod(_t, 4.0) * TAU / 4.0),
		180.0 * sin(fmod(_t, 16.0) * TAU / 16.0),
		45.0 * sin(fmod(_t, 8.0) * TAU / 8.0)
		)

func _animate2():
	var angle = PI * (sin(fmod(_t, 12.0) * TAU / 12.0) - 0.75)
	var distance = (sin(fmod(_t, 1.14) * TAU / 1.14) * 0.5 + 0.5) * 2.0 + 1.75
	position = Vector3(distance * cos(angle), 0.5, distance * sin(angle))
	look_at(Vector3(0.0, 0.6, 0.0))
	angle = PI * cos(fmod(_t, 5.0) * TAU / 5.0)
	rotation.z = angle / 6.0
