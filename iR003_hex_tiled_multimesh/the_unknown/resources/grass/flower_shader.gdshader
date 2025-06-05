shader_type spatial;

render_mode cull_disabled; // , shadows_disabled;

uniform vec3 albedo : source_color; // 568c1e

uniform sampler2D wave : hint_normal; // seamless 1.8, normalize, Perlin, seed=3, freq=0.0208
uniform float time_scale : hint_range(0.0, 0.3, 0.005) = 0.04; // Rate of movement multiplied by TIME
uniform float noise_scale = 0.06;
uniform float height_scale = 0.8;

const vec3 height_scale_vec = vec3(1.0, 0.5, 1.0);

varying float base_height;
varying vec3 vertex_world_pos;
varying vec3 wave_displacement;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void vertex() {
	vertex_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wave_displacement = (texture(wave, vertex_world_pos.xz * noise_scale + TIME * time_scale * 2.0).rgb - 0.5);
	wave_displacement *= height_scale_vec * height_scale * VERTEX.y;
	VERTEX += wave_displacement;
}

void fragment() {
	vec3 hsv_color = vec3(
			mod(vertex_world_pos.x * 0.4 + vertex_world_pos.z * 0.3, 1.0),
			1.0,
			0.55 + (mod(vertex_world_pos.x * 0.4 + vertex_world_pos.z * 0.3, 0.3)-0.15)
		);
	ALBEDO = hsv2rgb(hsv_color);
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
}
