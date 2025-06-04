@tool
class_name NodeSorterEditorScenePostImportPlugin
extends EditorScenePostImportPlugin


const OPT_SORT_ORDER := "nodes/sort_order"

var _sort_funcs := [
	[ "None (Default)", Callable() ],
	[ "Sort by Name", func(a, b): return a.name.naturalnocasecmp_to(b.name) < 0 ],
]


func _get_import_options(path: String) -> void:
	add_import_option_advanced(TYPE_INT, OPT_SORT_ORDER, 0, PROPERTY_HINT_ENUM,
		','.join(_sort_funcs.map(func(sf): return sf[0]))
	)


func _get_option_visibility(path: String, for_animation: bool, option: String) -> Variant:
	if option == OPT_SORT_ORDER:
		return not for_animation
	return null


func _post_process(scene: Node) -> void:
	if scene.get_child_count() > 1:
		var sort_func_index = get_option_value(OPT_SORT_ORDER)
		var sort_func : Callable = self._sort_funcs[sort_func_index][1]

		if sort_func.is_valid():
			var sorted_children = scene.get_children()

			sorted_children.sort_custom(sort_func)
			for child in sorted_children:
				scene.move_child(child, -1)
