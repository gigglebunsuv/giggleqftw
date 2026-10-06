/// @description Fly, hit, break

timer++;
x += lengthdir_x(spd, direction);
y += lengthdir_y(spd, direction);
var t = min(1, timer / fly_time);
z = lerp(start_z, 0, t) + arc * 4 * t * (1 - t);

//Walls for its level (the rock's body is about 12 x 12)
var level_wall = obj_wall_low;
if (level == 1) {level_wall = obj_wall_high}
var hit_wall = collision_rectangle(x - 5, y - 5, x + 5, y + 5, obj_wall, false, true) != noone
	|| collision_rectangle(x - 5, y - 5, x + 5, y + 5, level_wall, false, true) != noone;

//Enemies
var lvl = level;
var rx = x;
var ry = y;
var hit_enemy = false;
with (obj_enemy) {
	if (!hit_enemy && (level == -1 || level == lvl) && collision_rectangle(rx - 6, ry - 6, rx + 6, ry + 6, id, false, false)) {
		enemy_hurt(id, ROCK_DAMAGE, rx, ry);
		hit_enemy = true;
	}
}

//Flip-screen: rocks don't fly into the next screen
var off_screen = false;
if (view_enabled) {
	var cam = view_camera[0];
	var vx = camera_get_view_x(cam);
	var vy = camera_get_view_y(cam);
	off_screen = (x < vx || y < vy || x > vx + camera_get_view_width(cam) || y > vy + camera_get_view_height(cam));
}

if (hit_wall || hit_enemy || off_screen || timer >= fly_time) {
	rock_break(x, y - round(z));
	instance_destroy();
}
