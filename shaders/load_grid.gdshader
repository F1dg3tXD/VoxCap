shader_type spatial;
render_mode unshaded, cull_back, blend_mix, depth_draw_opaque;

uniform vec3 grid_color : source_color = vec3(0.1, 0.8, 1.0);
uniform float grid_spacing : hint_range(0.1, 10.0) = 1.0;
uniform float grid_thickness : hint_range(0.001, 1.0) = 0.05; // % of spacing

uniform float wave_speed : hint_range(0.1, 5.0) = 1.0;
uniform float wave_height : hint_range(0.0, 1.0) = 0.2;
uniform float wave_frequency : hint_range(0.1, 10.0) = 1.0;

uniform float emission_multiplier : hint_range(0.0, 10.0) = 1.0;
uniform float alpha_background : hint_range(0.0, 1.0) = 0.0;

varying vec3 world_pos;
varying float wave_offset;

void vertex() {
	// Compute world position
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// Compute wave height offset
	wave_offset = sin(VERTEX.x * wave_frequency + TIME * wave_speed)
	            + cos(VERTEX.z * wave_frequency + TIME * wave_speed);
	wave_offset *= 0.5;

	// Apply wave offset
	VERTEX.y += wave_offset * wave_height;
}

float grid_line_factor(float coord, float spacing, float thickness) {
	float mod_pos = mod(coord, spacing);
	float line_dist = min(mod_pos, spacing - mod_pos);
	return 1.0 - smoothstep(0.0, spacing * thickness, line_dist);
}

void fragment() {
	// Compute grid line factors for X/Z
	float line_x = grid_line_factor(world_pos.x, grid_spacing, grid_thickness);
	float line_z = grid_line_factor(world_pos.z, grid_spacing, grid_thickness);
	float grid_mask = max(line_x, line_z);

	// Set base color + transparency
	ALBEDO = grid_color * grid_mask;
	ALPHA = mix(alpha_background, 1.0, grid_mask);

	// Emission linked to wave strength
	float wave_emission = abs(wave_offset * wave_height);
	EMISSION = grid_color * wave_emission * grid_mask * emission_multiplier;
}
