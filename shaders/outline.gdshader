shader_type spatial;
render_mode unshaded, cull_front, depth_draw_always;

uniform vec4 outline_color : source_color = vec4(0.2, 0.7, 1.0, 1.0);
uniform float outline_width = 0.06;

void vertex() {
	// В Godot 4 вершины/нормали уже с учётом скининга — просто выталкиваем вдоль нормали.
	VERTEX += normalize(NORMAL) * outline_width;
}

void fragment() {
	ALBEDO = outline_color.rgb;
	ALPHA  = outline_color.a;
}
