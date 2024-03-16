shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float pct = 0.0;
	
	pct = distance(UV, vec2(0.5));
	pct = smoothstep(0.4, 0.8, pct);
	COLOR = vec4(0.0, 0.0, 0.0, pct);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
