extends Node3D

@onready var _director = $".."
@onready var _main_camera := $"../../../Camera"

var _anim_status := 0
var _next_anim_count := 0


func _ready():
	visible = false


func _process(delta):
	match _anim_status:
		0: # invisible --> visible, frozen
			if _director._anim_count >= _director.ANIM_ALTER_IDLEVIS_START:
				_anim_status += 1
				position = Hex.AxialVeci.from_vec3(
					Vector3(Main.map.size - 22, Main.map.size - 18, 0.0)
					).to_cube_veci().to_world()
				position += Vector3(-Hex.TILE_RADIUS / 4.0, -Hex.TILE_RADIUS / 2.0, 0.0)
				position.y = 1.5
				rotation = Vector3(0.0, PI/2.0, 0.0)
				visible = true
		1: # visible, frozen --> idle animation
			if _director._anim_count >= _director.ANIM_ALTER_IDLE_START:
				_anim_status += 1
				$AnimationPlayer.play("idle Pose")
