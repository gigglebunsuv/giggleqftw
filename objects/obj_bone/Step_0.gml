/// @description Spin, break on walls, hurt Link

image_angle += 20;

if (level_wall_at(x, y, level) || !enemy_is_active()) {
	instance_destroy();
	exit;
}

if (instance_exists(obj_link) && place_meeting(x, y, obj_link) && obj_link.level == level) {
	//Blocked if Link's shield faces the way it came from
	if (shield_blocks(direction + 180, shield_tier)) {
		sfx_play(SFX_SHIELD);
	} else {
		player_hurt(1, x, y);
	}
	instance_destroy();
}
