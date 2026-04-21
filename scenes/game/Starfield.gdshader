shader_type canvas_item;

uniform float scroll_speed = 0.015;
uniform float star_density = 110.0;
uniform float star_brightness = 0.22;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
}

void fragment() {
	vec2 uv = UV;
	uv.y += TIME * scroll_speed;

	vec2 grid_uv = uv * star_density;
	vec2 cell = floor(grid_uv);
	vec2 local = fract(grid_uv) - 0.5;

	float rnd = hash(cell);
	float star = 0.0;

	if (rnd > 0.985) {
		float d = length(local);
		star = smoothstep(0.08, 0.0, d);
		star *= 0.7 + 0.3 * sin(TIME * 2.0 + rnd * 20.0);
	}

	vec3 col = vec3(0.45, 0.70, 1.0) * star * star_brightness;
	COLOR = vec4(col, star * 0.75);
}