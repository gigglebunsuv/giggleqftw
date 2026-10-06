/// @description Rest, fly, turn, stay in its room

event_inherited();
if (!active) {image_speed = 0; exit;}
if (kb_timer > 0 || stun_timer > 0) exit;

if (zone == noone) {zone = cam_zone_at(x, y)}
timer--;

if (state == "rest") {
	image_speed = 0;
	image_index = 0;
	if (timer <= 0) {
		state = "fly";
		timer = irandom_range(120, 240);
		turn_timer = 0;
	}
} else {
	image_speed = 0.3;

	//New heading every so often: roughly towards Link if he's close
	turn_timer--;
	if (turn_timer <= 0) {
		turn_timer = irandom_range(20, 40);
		if (instance_exists(obj_link) && point_distance(x, y, obj_link.x, obj_link.y) < range) {
			move_dir = point_direction(x, y, obj_link.x, obj_link.y) + random_range(-45, 45);
		} else {
			move_dir = random(360);
		}
	}
	x += lengthdir_x(spd, move_dir);
	y += lengthdir_y(spd, move_dir);

	//Turn back before leaving its room
	if (zone != noone && instance_exists(zone)) {
		if (x < zone.bbox_left + 24 || x > zone.bbox_right - 24 || y < zone.bbox_top + 24 || y > zone.bbox_bottom - 24) {
			move_dir = point_direction(x, y, (zone.bbox_left + zone.bbox_right) / 2, (zone.bbox_top + zone.bbox_bottom) / 2);
			turn_timer = 20;
		}
	}

	if (timer <= 0) {
		state = "rest";
		timer = irandom_range(40, 100);
	}
}
