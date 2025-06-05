shader_type spatial;

render_mode cull_disabled; // , shadows_disabled;

uniform vec3 albedo : source_color; // 568c1e

uniform sampler2D wave : hint_normal; // seamless 1.8, normalize, Perlin, seed=3, freq=0.0208
uniform float time_scale : hint_range(0.0, 0.3, 0.005) = 0.04;
uniform float noise_scale = 0.06;
uniform float height_scale = 0.8;

const vec3 height_scale_vec = vec3(1.0, 0.5, 1.0);

varying float base_height;
varying vec3 vertex_world_pos;
varying float vertex_relative_elevation;
varying vec3 wave_displacement;

void vertex() {
	vertex_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	// COLOR.a = mesh instance elevation (externally set)
	vertex_relative_elevation = vertex_world_pos.y - COLOR.a;
	wave_displacement = (texture(wave, vertex_world_pos.xz * noise_scale + TIME * time_scale * 2.0).rgb - 0.5);
	wave_displacement *= height_scale_vec * height_scale * VERTEX.y;
	VERTEX += wave_displacement;
}

void fragment() {
	ALBEDO = clamp(COLOR.rgb * (wave_displacement.g+0.15)*5.0 * (vertex_relative_elevation+0.05)*3.0, 0.0, 1.0);
	METALLIC = 0.1;
	SPECULAR = 0.5;
	ROUGHNESS = 0.46;
}
