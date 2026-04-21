shader_type canvas_item;

uniform float drift_speed = 0.01;
uniform float beam_width = 0.34;
uniform float glow_strength = 0.42;

float band(float x, float width) {
	return smoothstep(width, width * 0.35, abs(x - 0.5));
}

float noise_line(float y) {
	return 0.5 + 0.5 * sin(y * 12.0) * 0.5
	             + 0.25 * sin(y * 27.0 + 1.4)
	             + 0.12 * sin(y * 51.0 + 0.7);
}

void fragment() {
	vec2 uv = UV;
	uv.y += TIME * drift_speed;

	float beam = band(uv.x, beam_width);

	float variation = noise_line(uv.y);
	float inner = smoothstep(0.12, 0.0, abs(uv.x - 0.5));
	float outer = beam;

	vec3 bright = vec3(0.25, 0.65, 1.0);
	vec3 marine = vec3(0.05, 0.25, 0.50);

	vec3 col = marine * outer * 0.7;
	col += bright * inner * 0.35 * variation;

	float alpha = outer * glow_strength + inner * 0.12 * variation;

	COLOR = vec4(col, alpha);
}