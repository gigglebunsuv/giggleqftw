/// @description Shared enemy logic
//Children run event_inherited() first, then skip their own AI while
//active is false or kb_timer > 0.

active = enemy_is_active();
if (!active) exit;

//Stunned: frozen and harmless, tinted blue (blinking just before it wears off)
if (stun_timer > 0) {
	stun_timer--;
	image_speed = 0;
}

//Flash after a hit
if (hurt_timer > 0) {hurt_timer--}
if (clink_timer > 0) {clink_timer--}
image_blend = c_white;
if (stun_timer > 30 || (stun_timer > 0 && (stun_timer div 4) mod 2 == 0)) {image_blend = make_colour_rgb(120,160,255)}
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
if (can_touch && place_meeting(x, y, obj_sword) && enemy_same_level(obj_link.level)) {
	enemy_hurt(id, global.swordTier, obj_link.x, obj_link.y);
	if (hp <= 0) exit;
}

//Touching Link hurts him, unless it runs into his shield: then it bounces off
if (can_touch && contact_damage > 0 && stun_timer <= 0 && place_meeting(x, y, obj_link) && enemy_same_level(obj_link.level)) {
	if (shield_blocks(point_direction(obj_link.x, obj_link.y, x, y), 1)) {
		if (kb_timer <= 0) {
			kb_timer = 6;
			kb_dir = point_direction(obj_link.x, obj_link.y, x, y);
			sfx_play(SFX_SHIELD);
		}
	} else {
		player_hurt(contact_damage, x, y);
	}
}
