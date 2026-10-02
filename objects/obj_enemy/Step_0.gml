/// @description Shared enemy logic
//Children run event_inherited() first, then skip their own AI while
//active is false or kb_timer > 0.

active = enemy_is_active();
if (!active) exit;

//Flash after a hit
if (hurt_timer > 0) {hurt_timer--}
image_blend = c_white;
if (hurt_timer > 0 && (hurt_timer div 2) mod 2 == 0) {image_blend = c_red}

//Knocked back
if (kb_timer > 0) {
	kb_timer--;
	if (level == -1) {
		x += lengthdir_x(kb_speed, kb_dir);
		y += lengthdir_y(kb_speed, kb_dir);
	} else {
		level_move(lengthdir_x(kb_speed, kb_dir), lengthdir_y(kb_speed, kb_dir), level);
	}
}

if (!instance_exists(obj_link)) exit;

//Hit by the sword (damage = sword tier)
if (place_meeting(x, y, obj_sword) && enemy_same_level(obj_link.level)) {
	enemy_hurt(id, global.swordTier, obj_link.x, obj_link.y);
	if (hp <= 0) exit;
}

//Touching Link hurts him
if (place_meeting(x, y, obj_link) && enemy_same_level(obj_link.level)) {
	player_hurt(contact_damage, x, y);
}
