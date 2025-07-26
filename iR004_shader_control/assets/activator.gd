extends MeshInstance3D

static var t0_static: float = get_time()

var t_span: float = 1.0
var t_acc: float = 0.0

var t0_delta: float = 0.0
enum ProbeStatusType {IDLE, WAITING}
var probe_status := ProbeStatusType.IDLE
var counter: float = 0.0

@onready var ray: MeshInstance3D = $"../ray/ray"
@onready var ray_material: ShaderMaterial = ray.mesh.surface_get_material(0)

@onready var syncher := $"../Syncher"
@onready var syncher_viewport: SubViewport = $"../Syncher/SubViewport"
@onready var syncher_material: ShaderMaterial = $"../Syncher/SubViewport/ColorRect".material


static func get_time() -> float:
	return float(Time.get_ticks_msec()) / 1000.0


func _ready():
	print("t0_static = {0}".format([t0_static]))


func _process(delta):
	if syncher:
		syncher_an_quas_lor()
	
	t_acc += delta
	if t_acc > t_span:
		t_acc -= t_span
		fire()
		t_span = randf_range(0.2, 1.5)
		
	position.y = 0.09 + sin(t_acc/t_span * PI) * t_span * 0.2


func fire():
	var fire_time: float = get_time() + t0_delta - t_acc
	ray_material.set_shader_parameter("ext_start_time", fire_time)
	
	if syncher:
		syncher_ask()


func syncher_ask() -> void:
	counter += 1.0
	if counter < 120.0:
		syncher_material.set_shader_parameter("passnumber", fmod(counter, 1.0)/10.0)
		syncher_material.set_shader_parameter("gdscript_time", get_time())
		probe_status = ProbeStatusType.WAITING
	else:
		syncher.queue_free()
		syncher = null
	

func syncher_an_quas_lor() -> void:
	if probe_status == ProbeStatusType.WAITING:
		var syncher_texture: Texture = syncher_viewport.get_texture()
		if syncher_texture:
			var syncher_image: Image = syncher_texture.get_image()
			if absf(syncher_image.get_pixel(0, 0).b - fmod(counter, 1.0)/10.0) < 0.001:
				t0_delta = syncher_image.get_pixel(0, 0).r * 20.0 - 10.0
				print("t0_delta = {0}".format([t0_delta]))
				probe_status = ProbeStatusType.IDLE
