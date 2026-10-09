/// @description Drift and fade

life--;
image_alpha = min(1, life / 10);
if (life <= 0) {instance_destroy()}
