shader_type canvas_item;

void fragment() {
	float x = abs(UV.x - 0.5) * 2.0;

	vec3 center = vec3(0.10, 0.45, 0.95);   // tiny bright blue accent
	vec3 mid    = vec3(0.03, 0.20, 0.38);   // marine blue
	vec3 outer  = vec3(0.01, 0.04, 0.10);   // dark blue
	vec3 edge   = vec3(0.00, 0.00, 0.00);   // black

	vec3 col;

	if (x < 0.18) {
		float t = x / 0.18;
		col = mix(center, mid, t);
	} else if (x < 0.42) {
		float t = (x - 0.18) / (0.42 - 0.18);
		col = mix(mid, outer, t);
	} else {
		float t = (x - 0.42) / (1.0 - 0.42);
		col = mix(outer, edge, t);
	}

	COLOR = vec4(col, 1.0);
}