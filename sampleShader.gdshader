shader_type sky;

void sky() {
	COLOR = EYEDIR.yyy;// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.
}
