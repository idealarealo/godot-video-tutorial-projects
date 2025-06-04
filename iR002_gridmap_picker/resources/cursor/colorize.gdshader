shader_type spatial;

const vec3 ALLOW_COLOUR = vec3(0., 1., 0.);
const vec3 DENY_COLOUR = vec3(1., 0., 0.);

uniform bool allow = true;

void fragment() {
	// if (!allow) {
		ALBEDO = allow ? ALLOW_COLOUR : DENY_COLOUR;
		ALPHA = fma(sin(TIME * PI), .5, .5);
	// } else {
	//	ALPHA = 0.;
	//}
}
