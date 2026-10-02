//Enemy helpers. Enemies are children of obj_enemy, which handles getting hit,
//knockback, flashing and hurting Link on contact.
//
//Enemy variables (set in the child's Create after event_inherited()):
//	hp, contact_damage, level (0 lower, 1 upper, -1 flying = any level)

///enemy_is_active();
function enemy_is_active() {
	//Enemies only move while Link is in their camera zone, and wait during a slide
	if (global.cam_transition) return false;
	var z = global.cam_zone;
	if (z == noone || !instance_exists(z)) return true;
	return point_in_rectangle(x, y, z.bbox_left, z.bbox_top, z.bbox_right, z.bbox_bottom);


}

///enemy_same_level(level);
function enemy_same_level(argument0) {
	//Run by an enemy: can it touch something on this level?
	return level == -1 || level == argument0;


}

///enemy_can_see_link(range);
function enemy_can_see_link(argument0) {
	//Run by an enemy: Link is on the same level, in range and not behind a wall
	if (!instance_exists(obj_link)) return false;
	if (obj_link.level != level) return false;
	if (point_distance(x, y, obj_link.x, obj_link.y) > argument0) return false;
	return level_line_clear(x, y, obj_link.x, obj_link.y, level);


}

///enemy_hurt(enemy, damage, from_x, from_y);
function enemy_hurt(argument0, argument1, argument2, argument3) {
	//Damages an enemy and knocks it away from (from_x, from_y).
	//Ignored while it's still flashing from the last hit.
	with (argument0) {
		if (hurt_timer <= 0) {
			hp -= argument1;
			hurt_timer = 20;
			kb_timer = 6;
			kb_dir = point_direction(argument2, argument3, x, y);
			if (hp <= 0) {instance_destroy()}
		}
	}


}
