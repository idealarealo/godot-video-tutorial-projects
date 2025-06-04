extends Camera3D

var t := 0.0
var target := Vector3(0, 1, 0)

func _process(delta):
	t = fmod(t + delta, 20)
	position.x = 7 * cos(-t * 2*PI / 20)
	position.z = 7 * sin(-t * 2*PI / 20)
	look_at(target)
