class_name GrassArea
extends MultiMeshInstance3D

static var MESH := preload("res://the_unknown/resources/grass/grass_blade.res")

var linked_grid_area : GridArea = null

var _heights := PackedFloat32Array()

enum AnimStatusType {READY, RUNNING}
var _anim_status := AnimStatusType.READY
var _anim_count := 0.0
var _anim_direction := 1.0


func _ready():
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	multimesh.use_custom_data = false
	multimesh.instance_count = Main.map.AREA_SIZE_SQR
	multimesh.mesh = MESH
	_generate()


func _generate():
	var ZERO_TRANSFORM = Transform3D.IDENTITY.scaled(Vector3.ZERO)
	self.transform = linked_grid_area.transform
	self.position.y = 0.0
	
	var transform := Transform3D()
	var avi = Hex.AxialVeci.new();
	var tile_index := 0
	var map_area_origin_v3 := Vector3i(linked_grid_area.map_area_origin.x, linked_grid_area.map_area_origin.y, 0)
	avi.vi.z = 0
	avi.vi.y = 0
	while avi.vi.y < Main.map.AREA_SIZE:
		avi.vi.x = 0
		while avi.vi.x < Main.map.AREA_SIZE:
			var height : float
			if "_target_heights" in linked_grid_area:
				height = linked_grid_area._target_heights[tile_index]
			else:
				height = 0.0
			if (height >= 0.20) and (height <= 2.6):
				transform = Transform3D.IDENTITY.rotated(Vector3.UP, randf_range(0.0, 360.0))
				transform.origin = avi.to_cube_veci().to_world()
				transform.origin.y = height
			else:
				transform = ZERO_TRANSFORM
			multimesh.set_instance_transform(tile_index, transform)
			var col = Color.from_hsv(
					89.0/360.0 + randf_range(-0.02, +0.1),
					.86,
					.55 + randf_range(-0.07, +0.1)
				)
			col.a = height   # trick
			multimesh.set_instance_color(tile_index, col)

			tile_index += 1
			avi.vi.x += 1
		avi.vi.y += 1
