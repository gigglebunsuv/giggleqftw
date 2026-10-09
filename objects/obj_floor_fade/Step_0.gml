/// @description Fade out, move Link, fade in

timer++;
if (!arrived && timer >= FLOOR_FADE_TIME) {
	arrived = true;
	floor_fade_arrive();
}
if (timer >= FLOOR_FADE_TIME * 2 + 4) {instance_destroy()}
