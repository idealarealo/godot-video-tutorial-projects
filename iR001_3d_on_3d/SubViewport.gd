extends SubViewport

var main_camera : Camera3D
var sub_camera : Camera3D
signal mouse_moved

# Called when the node enters the scene tree for the first time.
func _ready():
	main_camera = get_tree().root.get_camera_3d()
	sub_camera = main_camera.duplicate(0)
	add_child(sub_camera)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	sub_camera.transform = main_camera.transform


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var mouse_position = get_mouse_position()
		var ray_origin = main_camera.project_ray_origin(mouse_position)
		var ray_direction = main_camera.project_ray_normal(mouse_position)
		# ray_target.y = 0  (ground)
		if absf(ray_direction.y) > 0.001:
			var target_distance = -ray_origin.y / ray_direction.y
			var ray_target = ray_origin + ray_direction * target_distance
			mouse_moved.emit(ray_target)
