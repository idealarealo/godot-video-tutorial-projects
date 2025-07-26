extends MeshInstance3D

var t_span: float = 1.0
var t_acc: float = 0.0

@onready var ray_aplayer: AnimationPlayer = $"../ray/AnimationPlayer"


func _process(delta):
	t_acc += delta
	if t_acc > t_span:
		t_acc -= t_span
		on_fire()
		t_span = randf_range(0.2, 1.5)
		
	position.y = 0.09 + sin(t_acc/t_span * PI) * t_span * 0.2


func on_fire():
	ray_aplayer.stop()
	ray_aplayer.play("fire")
