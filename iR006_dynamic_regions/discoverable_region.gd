class_name DiscoverableRegion
extends Node3D

@onready var MESH_MATERIAL = $MeshInstance3D.mesh.material
var SHOW_HOOK: Callable = func():_set_discovered(true)
var HIDE_HOOK: Callable = func():_set_discovered(false)
var _discovery_tween: Tween = null
var _autodiscover: bool = false
var _discovered: bool = false  # hidden by default

var autodiscover: bool = false:
	set(autodiscover):
		if _autodiscover != autodiscover:
			_autodiscover = autodiscover
			if autodiscover:
				$VisibleOnScreenNotifier3D.screen_entered.connect(SHOW_HOOK)
				$VisibleOnScreenNotifier3D.screen_exited.connect(HIDE_HOOK)
			else:
				$VisibleOnScreenNotifier3D.screen_entered.disconnect(SHOW_HOOK)
				$VisibleOnScreenNotifier3D.screen_exited.disconnect(HIDE_HOOK)

var discovered: bool:
	set = _set_discovered

func _set_discovered(discover: bool) -> void:
	if _discovered != discover:
		_discovered = discover
		if _discovery_tween:
			_discovery_tween.kill()
		_discovery_tween = create_tween()
		if discover:
			# current -> RED -> GREEN
			_discovery_tween.tween_property(MESH_MATERIAL, "albedo_color", Color(1.0, 0.2, 0.0, 0.75), 0.2)
			_discovery_tween.tween_property(MESH_MATERIAL, "albedo_color", Color(0.2, 1.0, 0.1, 1.0), 0.3)
		else:
			# current -> TRANSPARENT
			_discovery_tween.tween_property(MESH_MATERIAL, "albedo_color", Color(1.0, 0.2, 0.0, 0.0), 0.2)
