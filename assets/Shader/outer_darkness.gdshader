shader_type spatial;
render_mode unshaded, blend_mix, depth_test_disabled, cull_disabled;

uniform sampler2D depth_tex : hint_depth_texture, repeat_disable, filter_nearest;

uniform vec2 center = vec2(0.0, 0.0);
uniform vec2 half_size = vec2(9.5, 9.5);
uniform float fade_width = 14.0;
uniform float far_width = 14.0;

uniform float max_dark : hint_range(0.0, 1.0) = 0.6;
uniform float end_dark : hint_range(0.0, 1.0) = 0.9;
uniform vec3 mist_color : source_color = vec3(0.29, 0.25, 0.37);
uniform vec3 deep_color : source_color = vec3(0.05, 0.05, 0.11);

uniform float drift_amount = 2.0;
uniform float drift_speed = 0.12;

// Batas tinggi: efek penuh di bawah fade_start, hilang total di atas fade_end
uniform float fade_start = 4.0;
uniform float fade_end = 16.0;
uniform float top_strength : hint_range(0.0, 1.0) = 0.0;  // sisa gelap di ketinggian atas

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	float depth = texture(depth_tex, SCREEN_UV).x;

	// Langit / tanpa geometri: tidak disentuh sama sekali
	if (depth >= 0.9999) {
		ALPHA = 0.0;
	} else {
		vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth * 2.0 - 1.0);
		vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
		view.xyz /= view.w;
		vec3 world = (INV_VIEW_MATRIX * vec4(view.xyz, 1.0)).xyz;

		vec2 d = abs(world.xz - center) - half_size;
		float out_d = length(max(d, vec2(0.0)));

		float n = sin(world.x * 0.12 + TIME * drift_speed)
				* sin(world.z * 0.10 - TIME * drift_speed * 0.7);
		out_d += n * drift_amount;
		out_d = max(out_d, 0.0);

		float t1 = smoothstep(0.0, fade_width, out_d);
		float t2 = smoothstep(fade_width * 0.6, fade_width + far_width, out_d);

		vec3 col = mix(mist_color, deep_color, t2);
		float a = mix(t1 * max_dark, end_dark, t2);

		// Pudar ke atas: bagian tinggi (batang atas, tajuk) makin tipis gelapnya
		float h = 1.0 - smoothstep(fade_start, fade_end, world.y);
		a *= mix(top_strength, 1.0, h);

		ALBEDO = col;
		ALPHA = a;
	}
}