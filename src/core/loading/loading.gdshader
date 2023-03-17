shader_type canvas_item;

void vertex() {
	VERTEX += vec2(tan(TIME * 2.0) * 10.0, 0);
}
