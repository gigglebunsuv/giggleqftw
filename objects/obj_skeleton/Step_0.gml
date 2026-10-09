/// @description Walk, spot Link, pause, throw

event_inherited();
if (!active) exit;
if (kb_timer > 0 || stun_timer > 0) exit;

if (throw_cd > 0) {throw_cd--}

if (state == "walk") {
	anim_t += 0.15;
	face = move_dir;
	//Bumping into a wall picks a new direction
	if (level_move(lengthdir_x(spd, move_dir), lengthdir_y(spd, move_dir), level)) {move_timer = 0}
	move_timer--;
	if (move_timer <= 0) {
		move_dir = choose(0, 90, 180, 270);
		move_timer = irandom_range(40, 100);
	}

	if (throw_cd <= 0 && enemy_can_see_link(sight)) {
		state = "aim";
		aim_timer = aim_time;
		face = enemy_dir4(point_direction(x, y, obj_link.x, obj_link.y));
	}
} else if (state == "aim") {
	aim_timer--;
	if (aim_timer <= 0) {
		if (instance_exists(obj_link)) {
			var bone = instance_create_depth(x, y, depth, obj_bone);
			bone.direction = point_direction(x, y, obj_link.x, obj_link.y);
			bone.level = level;
		}
		throw_cd = 90;
		state = "walk";
	}
}

image_index = enemy_face_frame(face, floor(anim_t));
