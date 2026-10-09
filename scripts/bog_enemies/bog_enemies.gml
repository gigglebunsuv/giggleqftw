//The Bog Tower's enemies (children of obj_enemy, see the enemies script for what they share).
//	obj_lurker		lives in deep water (obj_water): swims about under the surface (only ripples and
//					eyes show, nothing can touch it), rises, spits mud (obj_mud_shot) at Link, dives.
//					Only hittable while it's up: the sword from the shore, arrows, or the grapple hook
//					(which holds it up, stunned). Left high and dry (the water drained) it just flops.
//	obj_crab		shelled: the sword and arrows clink off. The grapple hook, boomerang, hammer or ice rod
//					flips it on its back, and then anything hurts it. Sidles to line up with Link and
//					charges straight at him.
//	obj_frog		sits, then leaps at Link in big hops (can't be hit high in the air), and lashes its
//					tongue at him when he's close on its row.
//	obj_mud_shot	a lump of mud spat by a lurker or the boss (works like a skeleton's bone)
//	obj_arrow_bundle	a few arrows lying about (the bow boss leaves them so Link never runs out)
//Placing them: a lurker's origin goes in the middle of a deep-water tile (on the lower level).
//Each one's Step runs the shared enemy logic first, then its function here.
//
//enemy_bog_variant() in an enemy's Creation Code (obj_skeleton, obj_guard, obj_bat, obj_rat,
//obj_slime...) makes it the Bog Tower's tougher kind: twice the health, a harder hit, a bit
//faster, and the bog-coloured sprite (the sprite's name + "_bog", if there is one).

#macro LURKER_HP 4
#macro LURKER_DAMAGE 2
#macro LURKER_SIGHT 128			//rises to spit at Link from this close
#macro LURKER_SWIM_SPEED 0.6
#macro LURKER_RISE_TIME 12
#macro LURKER_UP_TIME 54		//steps it stays up
#macro LURKER_SPIT_AT 34		//...and spits when this many are left (and again at half that, in pairs)
#macro LURKER_SHOT_DAMAGE 2

#macro CRAB_HP 6
#macro CRAB_DAMAGE 2
#macro CRAB_FLIP_TIME 180		//steps it lies on its back once flipped
#macro CRAB_SIDLE_SPEED 0.7
#macro CRAB_CHARGE_SPEED 2.2
#macro CRAB_CHARGE_TIME 40
#macro CRAB_RANGE 112			//charges at Link down its column (or row) from this far

#macro FROG_HP 4
#macro FROG_DAMAGE 2
#macro FROG_SIGHT 128
#macro FROG_LEAP_TIME 22		//steps in the air
#macro FROG_LEAP_HEIGHT 14		//pixels at the top of the leap (only drawn)
#macro FROG_LEAP_REACH 64		//furthest a leap goes
#macro FROG_TONGUE_REACH 36		//pixels the tongue reaches past its mouth
#macro FROG_TONGUE_DAMAGE 2

#macro ARROW_BUNDLE_ARROWS 5

///enemy_bog_variant();
function enemy_bog_variant() {
	//From an enemy's Creation Code: the Bog Tower's tougher kind of it
	if (variable_instance_exists(id, "bog") && bog) return;
	bog = true;
	hp = max(hp * 2, hp + 2);
	contact_damage += 1;
	if (variable_instance_exists(id, "spd")) {spd *= 1.2}
	if (variable_instance_exists(id, "charge_spd")) {charge_spd *= 1.15}
	if (variable_instance_exists(id, "hp_max")) {hp_max = hp}
	var s = asset_get_index(sprite_get_name(sprite_index) + "_bog");
	if (s != -1 && asset_get_type(sprite_get_name(sprite_index) + "_bog") == asset_sprite) {sprite_index = s}


}

///bog_water_under(x, y);
function bog_water_under(argument0, argument1) {
	//Is there deep water at this point?
	return position_meeting(argument0, argument1, obj_water);


}

///bog_spit(x, y, angle, damage, level);
function bog_spit(argument0, argument1, argument2, argument3, argument4) {
	//A lump of mud flying off at this angle
	var m = instance_create_depth(argument0, argument1, DEPTH_FLYING, obj_mud_shot);
	m.direction = argument2;
	m.damage = argument3;
	m.level = argument4;
	return m;


}

//================================================================ the lurker

///lurker_set(state, timer);
function lurker_set(argument0, argument1) {
	//Changes state. Under the water nothing can touch it (level -2 matches nothing).
	state = argument0;
	timer = argument1;
	var up = (state != "under");
	can_touch = up;
	level = up ? home_level : -2;


}

///lurker_step();
function lurker_step() {
	//Run by obj_lurker: swim under the surface, rise, spit, dive
	if (mouth > 0) {mouth--}

	//The water's gone from under it (drained): stuck, flopping, an easy target
	if (state != "stranded" && instance_exists(obj_water) && !bog_water_under(x, y)) {
		lurker_set("stranded", 0);
		contact_damage = 1;
	}
	if (state == "stranded") {
		anim_t += 0.2;
		return;
	}

	timer--;
	switch (state) {
		case "under":
			anim_t += 0.08;
			//Drift about, towards Link if he's near (staying in the water)
			turn--;
			if (turn <= 0) {
				turn = irandom_range(30, 60);
				move_dir = random(360);
				if (instance_exists(obj_link) && point_distance(x, y, obj_link.x, obj_link.y) < LURKER_SIGHT) {
					move_dir = point_direction(x, y, obj_link.x, obj_link.y) + random_range(-50, 50);
				}
			}
			var nx = x + lengthdir_x(LURKER_SWIM_SPEED, move_dir);
			var ny = y + lengthdir_y(LURKER_SWIM_SPEED, move_dir);
			if (bog_water_under(nx + lengthdir_x(6, move_dir), ny + lengthdir_y(6, move_dir))) {
				x = nx;
				y = ny;
			} else {
				turn = 0;
			}
			if (timer <= 0) {
				if (instance_exists(obj_link) && point_distance(x, y, obj_link.x, obj_link.y) < LURKER_SIGHT) {
					lurker_set("rise", LURKER_RISE_TIME);
					sfx_play(SFX_SPLASH);
				} else {
					timer = 30;
				}
			}
			break;

		case "rise":
			if (timer <= 0) {lurker_set("up", LURKER_UP_TIME)}
			break;

		case "up":
			if ((timer == LURKER_SPIT_AT || (bog && timer == LURKER_SPIT_AT div 2)) && instance_exists(obj_link)) {
				var ang = point_direction(x, y, obj_link.x, obj_link.y);
				bog_spit(x, y - 4, ang, LURKER_SHOT_DAMAGE, obj_link.level);
				mouth = 10;
			}
			if (timer <= 0) {lurker_set("dive", 10)}
			break;

		case "dive":
			if (timer <= 0) {
				lurker_set("under", irandom_range(50, 110));
				sfx_play(SFX_SPLASH);
			}
			break;
	}


}

///lurker_frame();
function lurker_frame() {
	//0-1 under (eyes and ripples), 2 half out, 3 up, 4 spitting
	switch (state) {
		case "rise":
		case "dive":
			return 2;
		case "up":
			return (mouth > 0) ? 4 : 3;
		case "stranded":
			return 3 + floor(anim_t) mod 2;
	}
	return floor(anim_t) mod 2;


}

//================================================================ the crab

///crab_flip_check();
function crab_flip_check() {
	//Run by obj_crab every step: stunned (grapple hook, boomerang, hammer, ice rod) means flipped
	//on its back with its soft belly up. It rights itself when the stun wears off.
	if (stun_timer > 0 && !flipped) {
		flipped = true;
		stun_timer = max(stun_timer, CRAB_FLIP_TIME);
		invulnerable = false;
		state = "walk";
	}
	if (stun_timer <= 0 && flipped) {
		flipped = false;
		invulnerable = true;
		timer = 20;
	}
	if (flipped) {
		anim_t += 0.3;
		image_index = 2 + floor(anim_t) mod 2;
	}


}

///crab_step();
function crab_step() {
	//Run by obj_crab: sidle to line up with Link, then charge straight at him
	timer--;
	switch (state) {
		case "walk":
			anim_t += 0.15;
			var dx = 0;
			var dy = 0;
			if (enemy_can_see_link(CRAB_RANGE)) {
				//Line up on Link's column (or his row, whichever is closer)
				var ox = obj_link.x - x;
				var oy = obj_link.y - y;
				if (abs(ox) <= abs(oy)) {dx = sign(ox) * min(abs(ox), CRAB_SIDLE_SPEED)}
				else {dy = sign(oy) * min(abs(oy), CRAB_SIDLE_SPEED)}
				if (timer <= 0 && (abs(ox) <= 4 || abs(oy) <= 4)) {
					state = "charge";
					timer = CRAB_CHARGE_TIME;
					charge_dir = enemy_dir4(point_direction(x, y, obj_link.x, obj_link.y));
					sfx_play(SFX_BLADE);
					break;
				}
			} else {
				if (timer <= 0) {
					wander = choose(0, 180, 90, 270);
					timer = irandom_range(30, 70);
				}
				dx = lengthdir_x(CRAB_SIDLE_SPEED * 0.6, wander);
				dy = lengthdir_y(CRAB_SIDLE_SPEED * 0.6, wander);
			}
			level_move(dx, dy, level);
			break;

		case "charge":
			anim_t += 0.4;
			if (level_move(lengthdir_x(CRAB_CHARGE_SPEED, charge_dir), lengthdir_y(CRAB_CHARGE_SPEED, charge_dir), level) || timer <= 0) {
				state = "walk";
				timer = 45;
			}
			break;
	}
	image_index = floor(anim_t) mod 2;


}

//================================================================ the frog

///frog_step();
function frog_step() {
	//Run by obj_frog: sit, crouch, leap at Link; tongue when he's close on its row
	timer--;
	switch (state) {
		case "sit":
			z = 0;
			can_touch = true;
			if (instance_exists(obj_link) && abs(obj_link.x - x) > 2) {face = sign(obj_link.x - x)}
			if (timer <= 0) {
				if (enemy_can_see_link(FROG_SIGHT)) {
					var ox = obj_link.x - x;
					if (abs(obj_link.y - y) <= 8 && abs(ox) <= FROG_TONGUE_REACH + 6) {
						face = sign(ox);
						state = "tongue";
						timer = 18;
						tongue = 0;
						break;
					}
					leap_dir = point_direction(x, y, obj_link.x, obj_link.y);
					leap_len = min(FROG_LEAP_REACH, point_distance(x, y, obj_link.x, obj_link.y) + 8);
				} else {
					leap_dir = random(360);
					leap_len = FROG_LEAP_REACH / 2;
				}
				state = "crouch";
				timer = 12;
			}
			break;

		case "crouch":
			if (timer <= 0) {
				state = "leap";
				timer = FROG_LEAP_TIME;
				sfx_play(SFX_HOP);
				if (abs(lengthdir_x(1, leap_dir)) > 0.1) {face = sign(lengthdir_x(1, leap_dir))}
			}
			break;

		case "leap":
			var sp = leap_len / FROG_LEAP_TIME;
			level_move(lengthdir_x(sp, leap_dir), lengthdir_y(sp, leap_dir), level);
			z = FROG_LEAP_HEIGHT * sin(pi * (1 - timer / FROG_LEAP_TIME));
			can_touch = (z < 6);
			if (timer <= 0) {
				state = "sit";
				z = 0;
				can_touch = true;
				timer = irandom_range(bog ? 15 : 25, bog ? 35 : 50);
			}
			break;

		case "tongue":
			//Out for 6 steps, held for 6, back in 6
			var t = 18 - timer;
			tongue = FROG_TONGUE_REACH;
			if (t < 6) {tongue = FROG_TONGUE_REACH * (t / 6)}
			else if (t >= 12) {tongue = FROG_TONGUE_REACH * (timer / 6)}
			if (tongue > 4 && instance_exists(obj_link) && enemy_same_level(obj_link.level)) {
				var x0 = x + face * 6;
				var x1 = x + face * (6 + tongue);
				if (collision_line(x0, y + 1, x1, y + 1, obj_link, false, true) != noone) {
					if (shield_blocks(point_direction(obj_link.x, obj_link.y, x, y), 1)) {
						sfx_play(SFX_SHIELD);
					} else {
						player_hurt(FROG_TONGUE_DAMAGE, x, y);
					}
					timer = min(timer, 6);
				}
			}
			if (timer <= 0) {
				state = "sit";
				tongue = 0;
				timer = irandom_range(30, 50);
			}
			break;
	}
	switch (state) {
		case "crouch": image_index = 1; break;
		case "leap": image_index = 2; break;
		case "tongue": image_index = 3; break;
		default: image_index = 0; break;
	}


}

//================================================================ arrows lying about

///arrow_bundle_drop(x, y);
function arrow_bundle_drop(argument0, argument1) {
	var b = instance_create_depth(argument0, argument1, DEPTH_DECOR - 1, obj_arrow_bundle);
	if (instance_exists(obj_link)) {b.depth = obj_link.depth + 1}
	return b;


}
