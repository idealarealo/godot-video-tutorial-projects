shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx, blend_mix;

group_uniforms albedo;
uniform vec4 albedo : source_color = vec4(0.2, 0.9, 1.0, 0.0);
uniform sampler2D albedo_texture : source_color, hint_default_white;

group_uniforms roughness;
uniform float roughness : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D roughness_texture : hint_roughness_r;

group_uniforms normal;
uniform float normal_strength : hint_range(-16.0, 16.0) = 1.0;
uniform sampler2D normal_map : hint_normal;

group_uniforms misc;
uniform vec4 edge_color : source_color = vec4(0.0, 0.32, 0.44, 1.0);

float SchlickFresnel(float u) {
	// float m = 1.0 - u;
	// float m2 = m * m;
	return pow(1.0 - u, 5.0);
}

void fragment() {
	// calculate fresnel values
	float VdotN = dot(VIEW, NORMAL);
	float fresnel = SchlickFresnel(VdotN);

	// sample and mix textures
	vec4 _albedo = texture(albedo_texture, UV) * albedo;
	float _roughness = texture(roughness_texture, UV).r * roughness;
	// float _fresnel = 0.6 * sin((2.75 * fresnel - PI/48.0) * PI/2.0);
	// float _fresnel = 0.5 * sin((3.5 * fresnel - PI/96.0) * PI/2.0);
	float _fresnel = 1.0 * pow(sin((4.0 * fresnel - PI/48.0) * PI/2.0), 2.0);

	// apply glass look
	ALPHA = _fresnel * edge_color.a * 0.9;
	ALBEDO = edge_color.rgb * edge_color.a; // / 2.0;
	ROUGHNESS = _roughness;
	NORMAL_MAP = texture(normal_map, UV).xyz;
	NORMAL_MAP_DEPTH = normal_strength;

	// function to compensate specular for alpha blend
	// 0.5 * ALPHA^-0.5
	SPECULAR = 0.5 * inversesqrt(ALPHA);
}