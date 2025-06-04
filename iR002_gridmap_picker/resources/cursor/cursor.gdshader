shader_type spatial;

render_mode depth_test_disabled;
render_mode depth_prepass_alpha;

void vertex() {
	VERTEX.xyz = VERTEX.xyz * .998f;
}

void fragment() {
	ALBEDO = vec3(.95f, .05f, 1.f);
}
