extends MeshInstance3D

@onready var _director = $".."
@export var camera: Camera3D

const TARGET_HEIGHT := 0.5
var material: ShaderMaterial

func _ready():
	material = self.mesh.surface_get_material(0)
	material.set_shader_parameter("alpha", 0.0)

func process(delta):
	var rel_anim_count: float
	
	position.x = camera.position.x
	position.z = camera.position.z
	
	if _director._anim_count >= _director.ANIM_WATER_LIFT_START:
		if !visible:
			visible = true
		if _director._anim_count < _director.ANIM_WATER_LIFT_END:
			rel_anim_count = _director._anim_count - _director.ANIM_WATER_LIFT_START
			material.set_shader_parameter("alpha", rel_anim_count / _director.ANIM_WATER_LIFT_TIME)
			position.y = lerpf(0.0, TARGET_HEIGHT, rel_anim_count / _director.ANIM_WATER_LIFT_TIME)
