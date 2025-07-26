extends MeshInstance3D

var t_span: float = 1.0
var t_acc: float = 0.0

@onready var ray: MeshInstance3D = $"../ray/ray"
@onready var ray_material: ShaderMaterial = ray.mesh.surface_get_material(0)

var tween: Tween = null
var recharging: bool = false


func _process(delta):
	t_acc += delta
	if t_acc > t_span:
		t_acc -= t_span
		on_fire()
		t_span = randf_range(0.2, 1.5)
		
	position.y = 0.09 + sin(t_acc/t_span * PI) * t_span * 0.2


func on_fire():
	if not recharging:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(ray_material, "shader_parameter/ext_shock_peak_pos", 0.0, 0.0)
		tween.tween_property(ray_material, "shader_parameter/ext_shock_peak_pos", 1.2, 1.0)
		tween.tween_callback(func():recharging=false)
		recharging = true
