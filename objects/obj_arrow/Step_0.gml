/// @description Stop at walls and the screen edge

if (level_wall_at(x, y, level)) {
	instance_destroy();
	exit;
}

var hit = instance_place(x, y, obj_enemy);
if (hit != noone && (hit.level == -1 || hit.level == level)) {
	enemy_hurt(hit, 2, x, y);
	instance_destroy();
	exit;
}

//Flip-screen: arrows don't fly into the next screen
if (view_enabled) {
	var cam = view_camera[0];
	var vx = camera_get_view_x(cam);
	var vy = camera_get_view_y(cam);
	if (x < vx || y < vy || x > vx + camera_get_view_width(cam) || y > vy + camera_get_view_height(cam)) {
		instance_destroy();
	}
} else if (x < 0 || y < 0 || x > room_width || y > room_height) {
	instance_destroy();
}
