//Enemy helpers. Enemies are children of obj_enemy, which handles getting hit,
//knockback, flashing and hurting Link on contact.
//
//Enemy variables (set in the child's Create after event_inherited()):
//	drops (false = nothing left behind, see enemy_drop), is_boss (longer hitstop, a shake),
//	hp, contact_damage, level (0 lower, 1 upper, -1 flying = any level),
//	boomerang_kills (true = the boomerang kills it instead of stunning it),
//	invulnerable (true = hits just clink off), can_touch (false = Link and the sword pass
//	underneath it, like the boss high in the air)
//
//Children skip their own AI while active is false, kb_timer > 0 or stun_timer > 0.

///enemy_is_active();
function enemy_is_active() {
	//Enemies only move while Link is in their camera zone, and wait during a slide
	if (global.cam_transition || instance_exists(obj_floor_fade) || instance_exists(obj_room_fade)) return false;
	//The overworld: only near the screen too (see world_enemy_awake)
	if (instance_exists(obj_world)) return world_enemy_awake();
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
		//Armoured right now (the boss in the air): a clink and nothing else
		if (invulnerable) {
			if (clink_timer <= 0) {
				sfx_play(SFX_SHIELD);
				clink_timer = 15;
			}
			break;
		}
		if (hurt_timer <= 0) {
			hp -= global.dbg_onehit ? max(argument1, hp) : argument1;	//the debug menu's one hit kills
			hurt_timer = 20;
			kb_timer = 6;
			kb_dir = point_direction(argument2, argument3, x, y);
			//A moment's freeze so the hit lands (see the game_feel script)
			if (is_boss) {
				feel_hitstop(HITSTOP_BOSS);
				feel_shake(SHAKE_BOSS, SHAKE_BOSS_TIME);
			} else if (hp <= 0) {
				feel_hitstop(HITSTOP_KILL);
			}
			if (hp <= 0) {
				instance_create_depth(x, y, depth - 1, obj_enemy_death);
				sfx_play(SFX_ENEMY_DIE);
				global.demo_kills++;	//the dungeon demo's thank-you screen (demo script)
				if (drops) {enemy_drop(x, y)}
				instance_destroy();
			} else {
				sfx_play(SFX_ENEMY_HIT);
			}
		}
	}


}

///enemy_stun(enemy, time);
function enemy_stun(argument0, argument1) {
	//Freezes an enemy (boomerang, grapple hook): it can't move or hurt Link until it wears off.
	with (argument0) {
		if (stun_timer <= 0) {sfx_play(SFX_ENEMY_STUN)}
		stun_timer = max(stun_timer, argument1);
	}


}

///enemy_dir4(angle);
function enemy_dir4(argument0) {
	//An angle snapped to right, up, left or down (0, 90, 180, 270)
	return ((round(argument0 / 90) mod 4) + 4) mod 4 * 90;


}

///enemy_face_frame(angle, walk_frame);
function enemy_face_frame(argument0, argument1) {
	//Frame in a 4-way walking sprite (2 frames each: right, up, left, down) for the way it faces
	return (enemy_dir4(argument0) div 90) * 2 + (argument1 mod 2);


}

//================================================================ toughness by dungeon

///enemy_tier_apply();
function enemy_tier_apply() {
	//Run once by obj_enemy on its first step, after the child's Create has set hp and contact_damage.
	//Enemies met again late in the game (guards, skeletons, bats... in the Castle of Bunsriel) are
	//tougher there: more health and harder hits, so better armor is worth having.
	//Bosses and enemies made for the castle (they set tier_done = true) are left alone.
	if (is_boss || invulnerable) return;
	var t = dungeon_enemy_tier(global.dungeon);
	if (t <= 0) return;
	hp = ceil(hp * (1 + 0.5 * t));
	if (contact_damage > 0) {contact_damage *= (1 + t)}


}
