shader_type spatial;

uniform sampler2D grass_tex : source_color, filter_nearest, repeat_enable;
uniform sampler2D dirt_tex : source_color, filter_nearest, repeat_enable;
uniform sampler2D path_mask : hint_default_black, filter_linear, repeat_disable;
uniform float tile_count = 14.0;

void fragment() {
	vec2 tuv = UV * tile_count;
	vec3 grass = texture(grass_tex, tuv).rgb;
	vec3 dirt = texture(dirt_tex, tuv).rgb;
	float m = texture(path_mask, UV).r;
	ALBEDO = mix(grass, dirt, smoothstep(0.35, 0.65, m));
	ROUGHNESS = 1.0;
}