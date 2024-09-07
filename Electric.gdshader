shader_type spatial;

uniform float wave_height = 0.2;

void vertex() {
	VERTEX.y += random;
}

void fragment() {
	vec3 color;
	color.r = 0.5;
	color.g = 0.5;
	color.b = (sin(TIME * 8.0 + VERTEX.x + 10.0) + 1.0) * 0.5;
	ALBEDO = color;

}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
