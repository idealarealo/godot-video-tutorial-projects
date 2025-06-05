extends MeshInstance3D

@onready var _director := $"../../UnkMain"

var _mat: StandardMaterial3D
var _t := 0.0

func _ready() -> void:
	_mat = get_active_material(0)
	position = Hex.AxialVeci.from_vec3(Vector3(Main.map.size - 16, Main.map.size - 10, 0.0)).to_cube_veci().to_world()

func process(delta) -> void:
	if visible:
		_t += delta
		position.y = sin(_t * PI * 0.6) * 0.20 + 2.1
		# _mat.emission_energy_multiplier = (pow(4.0, (sin(_t * PI * 0.25 * _director.GLOBAL_SPEED) * 0.5 + 0.5)) - 1.0) / 1.75
		_mat.emission_energy_multiplier = sin(_t * PI * 0.25 * _director.GLOBAL_SPEED) * 0.04
		_mat.emission = Color.from_hsv(0.14 + 0.02 * sin(_t * PI * 0.05 * _director.GLOBAL_SPEED), 1.0, 0.7)
	elif _director._anim_count >= _director.ANIM_SERE_WAVE_END:
		visible = true
	
