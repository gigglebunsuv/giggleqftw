/// @description Fall, land, hurt Link if he's under it

if (!started) {
	started = true;
	fall_time = timer;
}
if (global.cam_transition) exit;
timer--;
if (timer <= 0) {
	with (obj_link) {
		if (point_distance(x, y, other.x, other.y) < 12) {player_hurt(GARG_ROCK_DAMAGE, other.x, other.y - 8)}
	}
	rock_break(x, y);
	instance_destroy();
}
