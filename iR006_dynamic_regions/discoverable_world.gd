class_name DiscoverableWorld
extends Node3D

const AUTODISCOVERABLE := true
const WORLD_RECT := Rect2i(-10, -10, 21, 21)
static var _discoverable_region_scene := preload("res://discoverable_region.tscn")
@onready var _regions: Dictionary[Vector2i, DiscoverableRegion] = {}

func _ready() -> void:
	for z in range(WORLD_RECT.position.y, WORLD_RECT.end.y):
		for x in range(WORLD_RECT.position.x, WORLD_RECT.end.x):
			var region: DiscoverableRegion = _discoverable_region_scene.instantiate()
			region.position = Vector3(x, 0.0, z)
			region.autodiscover = AUTODISCOVERABLE
			_regions.set(Vector2i(x, z), region)
			$Regions.add_child(region)

func get_region_by_coordinates(rc: Vector2i) -> DiscoverableRegion:
	if WORLD_RECT.has_point(rc):
		return _regions.get(rc)
	return null

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
