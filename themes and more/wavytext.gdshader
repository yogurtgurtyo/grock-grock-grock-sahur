shader_type canvas_item;

uniform float height = 2.0;
uniform float frequency = 5.0;
uniform float speed = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX.y += height * sin((frequency * UV.x) + (speed * TIME));
}