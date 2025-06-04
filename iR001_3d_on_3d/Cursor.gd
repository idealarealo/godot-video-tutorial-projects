extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().mouse_moved.connect(_on_mouse_moved)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_mouse_moved(mouse_3d_position : Vector3):
	position = round(mouse_3d_position / 2.0) * 2.0
