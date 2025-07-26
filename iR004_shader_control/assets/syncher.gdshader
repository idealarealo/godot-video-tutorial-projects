shader_type canvas_item;

uniform float gdscript_time;
uniform float passnumber;
varying flat float delta_time;

void vertex() {
	delta_time = TIME - gdscript_time;
}

void fragment() {
	float pulse = (delta_time >= 0.0) ? clamp(1.0 - delta_time*2.0, 0.0, 1.0) : 0.0;
	float red = (clamp(delta_time, -10.0, 10.0) + 10.0) / 20.0;
	COLOR = vec4(red, pulse, passnumber, 1.0);
}
