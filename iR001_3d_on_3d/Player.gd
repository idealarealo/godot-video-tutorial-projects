extends StaticBody3D

var t := 0.0

func _process(delta):
	t = fmod(t + delta, 12)
	position.x = 4 * cos(t * PI / 6)
	position.z = 4 * sin(t * PI / 3)
