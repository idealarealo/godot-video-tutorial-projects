@tool
class_name NodeSorterEditorPlugin
extends EditorPlugin


var _nsespip : NodeSorterEditorScenePostImportPlugin


func _enter_tree() -> void:
	_nsespip = preload("node_sorter_editor_scene_post_import_plugin.gd").new()
	add_scene_post_import_plugin(_nsespip)


func _exit_tree() -> void:
	remove_scene_post_import_plugin(_nsespip)
	_nsespip = null
