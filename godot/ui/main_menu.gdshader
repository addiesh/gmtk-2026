shader_type canvas_item;

uniform sampler2D noise1;
uniform sampler3D noise2;
uniform vec4 accent : source_color;
uniform vec2 scale = vec2(1.0, 1.0);

varying vec4 bart;

void vertex() {
	bart = COLOR;
}

void fragment() {
	vec2 uv = UV * scale;
	vec2 noisy_uv = mod(
	    uv + vec2(
	        texture(noise2, mod(vec3(uv, TIME / 8.0 + 4.0), 1.0)).r,
	        texture(noise2, mod(vec3(uv, TIME / 8.0), 1.0)).r
	), 1.0);
	vec2 uv1 = mod(noisy_uv + vec2(0.0, TIME / 4.0), 1.0);
	vec3 uv2 = mod(vec3(noisy_uv, TIME / 8.0), 1.0);
	vec3 col = ((
		texture(noise1, uv1).r * bart
		- texture(noise2, uv2).r * accent)
	).rgb;
	COLOR = vec4(col, 1.0) * texture(TEXTURE, mod(uv, 1.0));
}
