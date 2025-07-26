extends MeshInstance3D

static var t0_static: float = get_time()

var t_span: float = 1.0
var t_acc: float = 0.0

@onready var ray: MeshInstance3D = $"../ray/ray"
@onready var ray_material: ShaderMaterial = ray.mesh.surface_get_material(0)


static func get_time() -> float:
	return float(Time.get_ticks_msec()) / 1000.0


func _process(delta):
	t_acc += delta
	if t_acc > t_span:
		t_acc -= t_span
		fire()
		t_span = randf_range(0.2, 1.5)
		
	position.y = 0.09 + sin(t_acc/t_span * PI) * t_span * 0.2


func fire():
	var fire_time: float = get_time() + t0_static - t_acc
	ray_material.set_shader_parameter("ext_start_time", fire_time)
