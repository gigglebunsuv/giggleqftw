/// @description Flicker, burn out

if (lit) {
	image_index = 1 + (current_time div 150) mod 2;
	if (burn_time > 0) {
		burn_timer--;
		if (burn_timer <= 0) {lit = false}
	}
} else {
	image_index = 0;
}
