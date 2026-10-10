/// @description Fly, hit an enemy or a wall

if (feel_frozen()) {
	speed = 0;
	exit;
}
speed = SWORD_BEAM_SPEED;
life--;
if (life <= 0 || level_wall_at(x, y, level)) {
	instance_create_depth(x - 12, y - 12, depth - 1, obj_enemy_death);
	instance_destroy();
	exit;
}
//Off the screen
var cam = view_camera[0];
if (x < camera_get_view_x(cam) - 8 || y < camera_get_view_y(cam) - 8
	|| x > camera_get_view_x(cam) + camera_get_view_width(cam) + 8 || y > camera_get_view_y(cam) + camera_get_view_height(cam) + 8) {
	instance_destroy();
	exit;
}
//Bushes and pots break, torches light
var cut = instance_place(x, y, obj_bush);
if (cut != noone) {with (cut) {bush_cut()}}
var pot = instance_place(x, y, obj_pot);
if (pot != noone) {with (pot) {pot_break()}}
var e = instance_place(x, y, obj_enemy);
if (e != noone && e.can_touch && (e.level == -1 || e.level == level)) {
	enemy_hurt(e, SWORD_BEAM_DAMAGE, x - lengthdir_x(8, direction), y - lengthdir_y(8, direction));
	instance_create_depth(x - 12, y - 12, depth - 1, obj_enemy_death);
	instance_destroy();
}
