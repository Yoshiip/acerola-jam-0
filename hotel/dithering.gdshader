shader_type canvas_item;

uniform float n = 4.0;
uniform float col_mix = 1.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void fragment() {
	vec4 original_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 color = original_color;
	color.r = floor(color.r * (n - 1.0) + 0.5) / (n - 1.0);
	color.g = floor(color.g * (n - 1.0) + 0.5) / (n - 1.0);
	color.b = floor(color.b * (n - 1.0) + 0.5) / (n - 1.0);
	COLOR = mix(original_color, color, col_mix);
}