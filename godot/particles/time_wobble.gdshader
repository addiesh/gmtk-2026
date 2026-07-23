shader_type canvas_item;
uniform sampler2D noise;
uniform float distortion_speed = 0.5;
uniform float real_time;

varying vec4 vertex_color;

void vertex() {
	vertex_color = COLOR;
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 adjusted_uv = UV * 1.5 - vec2(0.25);
	vec2 adjusted_uv_2 = UV * 1.25 - vec2(0.125);
	
	vec2 time2 = vec2(real_time / 4.0 + 1273.0, real_time) * distortion_speed;
	
	float uv_noise = (texture(
		noise,
		mod(UV + time2, 1.0)
	).r - 0.5) / 12.0;
	float uv_noise_flavor = (texture(
		noise,
		mod(UV + time2 / 2.0, 1.0)
	).r - 0.5) / 2.0;
	vec2 uv = adjusted_uv + vec2(uv_noise, 0.0);
	vec2 uv_flavor = adjusted_uv_2 + vec2(uv_noise_flavor / 2.0, uv_noise_flavor);
	vec4 wobble = texture(TEXTURE, clamp(uv, 0.0, 1.0));
	vec4 flavor = texture(TEXTURE, clamp(uv_flavor, 0.0, 1.0)) / 2.0;
	COLOR = (wobble + flavor) * vertex_color;
}
