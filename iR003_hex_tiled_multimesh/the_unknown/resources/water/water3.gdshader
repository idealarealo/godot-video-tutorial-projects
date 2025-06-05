// Simplified water shader
shader_type spatial;
// render_mode blend_mix;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;

uniform vec3 albedo1 : source_color; // #09152c
uniform vec3 albedo2 : source_color; // #216caa

uniform vec4 color_shallow : source_color; // #ffffff // Shallow depth color
uniform vec4 color_deep : source_color; // #030713 // Deep depth color

uniform float metallic : hint_range(0.0, 1.0) = 0.2; // 0.3
uniform float roughness : hint_range(0.0, 1.0) = 0.1;
// normals
uniform sampler2D normalmap_a : hint_normal;
uniform sampler2D normalmap_b : hint_normal;
// motion
uniform vec2 move_dir1 = vec2(0.96, 0.05);
uniform vec2 move_dir2 = vec2(-0.15, 0.22);
uniform float move_strength = 0.1;
uniform float uv_scale = 1.0;

uniform sampler2D wave : hint_normal;
uniform float time_scale : hint_range(0.0, 0.3, 0.005) = 0.025; // Rate of movement multiplied by TIME
uniform float noise_scale = 0.04;
uniform float height_scale = 0.2;
uniform float normal_scale = 1.0;

uniform float edge_scale = 0.14;
uniform vec3 edge_color : source_color;

uniform float alpha : hint_range(0.0, 1.0) = 1.0;

varying float wave_height;
varying vec3 vertex_world_pos;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

void vertex() {
	vertex_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wave_height = texture(wave, vertex_world_pos.xz * noise_scale + TIME * time_scale * 2.0).r * height_scale;
	VERTEX.y += wave_height;
}

void fragment() {
	// fragment depth and position
	float depth = textureLod(depth_texture, SCREEN_UV, 0.0).x;
	vec4 fragment_world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
	fragment_world_pos.xyz /= fragment_world_pos.w;  // remove perspective

	float depth_blend = clamp(
		smoothstep(fragment_world_pos.z, fragment_world_pos.z + 3.0, VERTEX.z), 0.0, 1.0);
	float depth_blend_powered = pow(depth_blend, 2.0);
	vec3 screen_color = texture(screen_texture, SCREEN_UV).rgb;
	vec3 color = mix(screen_color, color_deep.rgb, depth_blend_powered); // 0a0f16

	float wt = fma(textureLod(wave, (vertex_world_pos.xz + TIME / 9.0) / 4.0 , 0.0).x, 8.0, -1.0);
	float edge_depth_blend = clamp(
		smoothstep(fragment_world_pos.z, fragment_world_pos.z+edge_scale*wt, VERTEX.z), 0.0, 1.0);

	// Interpolate albedo values by frensel
	float basic_fresnel = fresnel(5.0, NORMAL, VIEW); // 5.0
	vec3 surface_color = mix(albedo1, albedo2, basic_fresnel);

	color = mix(color, surface_color, 0.75);
	vec3 depth_color_with_edge = mix(edge_color, color, step(edge_scale, edge_depth_blend));

	ALBEDO = depth_color_with_edge;

	ROUGHNESS = roughness * mix(0.0, 1.0, basic_fresnel);
	METALLIC = metallic;

	vec3 normalmap = mix(
		texture(normalmap_a, vertex_world_pos.xz * noise_scale + move_dir1 * TIME * time_scale).rgb,
		texture(normalmap_b, vertex_world_pos.xz * noise_scale + move_dir2 * TIME * time_scale).rgb,
		0.5) * normal_scale;
	NORMAL_MAP = normalmap;

	ALPHA = alpha;
}
