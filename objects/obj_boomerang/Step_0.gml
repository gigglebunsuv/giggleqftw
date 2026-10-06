/// @description Fly out, turn back at a wall, an enemy or max range, return to Link

if (global.cam_transition) exit;
if (!instance_exists(obj_link)) {
	instance_destroy();
	exit;
}

image_angle += 30;

if (state == "out") {
	x += lengthdir_x(spd, direction);
	y += lengthdir_y(spd, direction);
	dist += spd;
	if (dist >= max_dist || level_wall_at(x, y, level)) {state = "back"}
} else {
	//Comes straight back, through walls
	var ang = point_direction(x, y, obj_link.x, obj_link.y);
	x += lengthdir_x(spd + 0.5, ang);
	y += lengthdir_y(spd + 0.5, ang);
	if (point_distance(x, y, obj_link.x, obj_link.y) <= spd + 1) {
		instance_destroy();
		exit;
	}
}

//Bats (boomerang_kills) die, other enemies are stunned
var hit = instance_place(x, y, obj_enemy);
if (hit != noone && (hit.level == -1 || hit.level == level)) {
	if (hit.boomerang_kills) {enemy_hurt(hit, hit.hp, x, y)}
	else {enemy_stun(hit, ITEM_STUN_TIME)}
	state = "back";
}
