shader_type spatial;
render_mode blend_mix, cull_disabled, unshaded;

uniform vec4 albedo : source_color = vec4(0.26, 0.0, 0.916, 1.0);

uniform sampler2D noise_texture : repeat_enable;
uniform vec2 noise_offset = vec2(0.0, 100.0);
uniform vec2 noise_direction = vec2(1.0, 0.0);
varying vec4 noise_vec;

uniform float shock_width : hint_range(0.0, 1.0) = 0.25;
uniform float shock_height : hint_range(0.0, 10.0) = 4.0;

uniform float ext_shock_peak_pos : hint_range(-0.2, 1.2) = 0.0;


void vertex() {
	noise_vec = texture(noise_texture, noise_offset + noise_direction * (UV.x + TIME / 5.0)) - 0.498;

	float shock_peak_pos = ext_shock_peak_pos;

	float noise_cutoff = cos(clamp((UV.x - shock_peak_pos)/shock_width, -0.5, 0.5) * PI);
	VERTEX.yz += noise_vec.xy * shock_height * noise_cutoff;
}

void fragment() {
	// gradient
	float grad_pos = pow(sin(UV.y * PI), 2.0) * 1.75;
	ALBEDO = mix(albedo.rgb, vec3(0.5,0.5,2.0), grad_pos);

	METALLIC = 0.0;
	SPECULAR = 0.0;
	ROUGHNESS = 1.0;
}
