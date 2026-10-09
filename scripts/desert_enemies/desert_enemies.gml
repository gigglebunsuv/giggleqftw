//The Tower of Ladhellin's enemies (children of obj_enemy, see the enemies script for what they share).
//	obj_sandworm	burrows under the floor (only a trail of sand shows, nothing touches it), comes up
//					near Link, spins after him for a while, burrows again
//	obj_vulture		perches until Link comes close, then circles high over him and dives at the spot
//					he was on (its shadow is the warning). Only touchable low down: arrows are best.
//	obj_cactus		a stack of spiny segments drifting about. Every hit knocks one off, which bursts
//					into spines (obj_sand_shot). The last one is its head.
//	obj_dust_devil	a whirlwind. Nothing hurts it: it wanders after Link and flings him a long way
//					(into pits!). It blows itself out after a while and forms again where it started.
//					Doesn't count for "clear" shutter doors (ignore_clear).
//	obj_mummy		slow and very tough. Fire (the lantern's flame, the fire rod) sets it alight:
//					it runs about burning until it crumbles.
//	obj_antlion		lives in the middle of a patch of quicksand: drags Link in when he's wading in
//					its sand and bites when he gets to its jaws. Only hittable just after a bite.
//	obj_mirage		a heat-haze wraith, all but invisible: only the Sun Lens shows it, and only while
//					the lens is up can it be hurt.
//	obj_sand_shot	a ball of sand or a cactus spine (works like a skeleton's bone). fake = true makes it
//					one of the boss's mirage shots: harmless, and see-through under the lens.
//Each one's Step runs the shared enemy logic first, then its function here.
//
//enemy_desert_variant() in an enemy's Creation Code (obj_skeleton, obj_bat) makes it the tower's
//tougher kind: like enemy_bog_variant, but with the sand-coloured sprite (the name + "_sand").

#macro SANDWORM_HP 3
#macro SANDWORM_DAMAGE 2
#macro SANDWORM_SIGHT 96		//comes up when Link is this close
#macro SANDWORM_DIG_SPEED 0.9	//under the floor
#macro SANDWORM_SPIN_SPEED 0.7	//up, spinning after Link
#macro SANDWORM_UP_TIME 110

#macro VULTURE_HP 3
#macro VULTURE_DAMAGE 2
#macro VULTURE_WAKE 88
#macro VULTURE_HIGH 26			//pixels up while circling
#macro VULTURE_CIRCLE_R 36		//how far from Link it circles
#macro VULTURE_SPEED 1.7
#macro VULTURE_DIVE_TIME 24
#macro VULTURE_LOW 8			//touchable (and hurting) below this height

#macro CACTUS_SEGMENTS 3
#macro CACTUS_DAMAGE 2
#macro CACTUS_SPEED 0.45
#macro CACTUS_SPINE_DAMAGE 1
#macro CACTUS_SEG_H 8			//pixels between the segments in the stack

#macro DUST_SPEED 0.7
#macro DUST_FLING_TIME 16		//steps Link is thrown for (3 pixels a step)
#macro DUST_LIFE 420			//steps before it blows itself out
#macro DUST_REFORM 120			//steps until it forms again at home

#macro MUMMY_HP 10
#macro MUMMY_DAMAGE 2
#macro MUMMY_SPEED 0.45
#macro MUMMY_SIGHT 160
#macro MUMMY_BURN_TIME 150		//steps it burns for (losing 1 health every MUMMY_BURN_TICK)
#macro MUMMY_BURN_TICK 8

#macro ANTLION_HP 6
#macro ANTLION_BITE 2
#macro ANTLION_PULL_RANGE 80	//drags Link wading in quicksand this close
#macro ANTLION_PULL_SPEED 0.55
#macro ANTLION_UP_TIME 70		//steps it's up (hittable) after a bite

#macro MIRAGE_HP 4
#macro MIRAGE_DAMAGE 2
#macro MIRAGE_SPEED 0.55
#macro MIRAGE_SIGHT 150
#macro MIRAGE_HAZE_ALPHA 0.1	//how much of it shows without the lens

///enemy_desert_variant();
function enemy_desert_variant() {
	//From an enemy's Creation Code: the Tower of Ladhellin's tougher kind of it, sand-coloured
	var base = sprite_get_name(sprite_index);
	enemy_bog_variant();
	var s = asset_get_index(base + "_sand");
	if (s != -1 && asset_get_type(base + "_sand") == asset_sprite) {sprite_index = s}


}

///desert_shot(x, y, angle, damage, level, frame);
function desert_shot(argument0, argument1, argument2, argument3, argument4, argument5) {
	//A ball of sand (frame 0) or a spine (frame 1) flying off at this angle
	var s = instance_create_depth(argument0, argument1, DEPTH_FLYING, obj_sand_shot);
	s.direction = argument2;
	s.damage = argument3;
	s.level = argument4;
	s.image_index = argument5;
	if (argument5 == 1) {s.image_angle = argument2}
	return s;


}

///enemy_keep_in_zone();
function enemy_keep_in_zone() {
	//Flyers: stay inside the room they started in (zone is set on their first step)
	if (zone == noone || !instance_exists(zone)) return;
	x = clamp(x, zone.bbox_left + 12, zone.bbox_right - 12);
	y = clamp(y, zone.bbox_top + 28, zone.bbox_bottom - 12);


}

///enemy_shadow(x, y, w);
function enemy_shadow(argument0, argument1, argument2) {
	//A flyer's shadow on the ground
	draw_sprite_ext(spr_pixel, 0, argument0 - argument2 / 2, argument1 + 4, argument2, 3, 0, c_black, 0.35);


}

//================================================================ the sandworm

///sandworm_set(state, timer);
function sandworm_set(argument0, argument1) {
	//Under the floor nothing can touch it (level -2 matches nothing)
	state = argument0;
	timer = argument1;
	can_touch = (state == "up");
	level = (state == "under") ? -2 : 0;


}

///sandworm_step();
function sandworm_step() {
	//Run by obj_sandworm: dig towards Link, come up, spin after him, dig back down
	timer--;
	anim_t += 0.25;
	switch (state) {
		case "under":
			var ang = wander;
			if (instance_exists(obj_link) && point_distance(x, y, obj_link.x, obj_link.y) < SANDWORM_SIGHT * 1.5) {
				ang = point_direction(x, y, obj_link.x, obj_link.y);
			} else if (timer mod 40 == 0) {
				wander = random(360);
			}
			//Under the floor it still can't go through walls or over holes
			if (level_move_as(lengthdir_x(SANDWORM_DIG_SPEED, ang), lengthdir_y(SANDWORM_DIG_SPEED, ang), 0)) {wander = random(360)}
			if (timer <= 0) {
				if (instance_exists(obj_link) && point_distance(x, y, obj_link.x, obj_link.y) < SANDWORM_SIGHT) {
					sandworm_set("rise", 14);
					sfx_play(SFX_SAND);
				} else {
					timer = 20;
				}
			}
			break;

		case "rise":
			if (timer <= 0) {sandworm_set("up", SANDWORM_UP_TIME)}
			break;

		case "up":
			if (instance_exists(obj_link)) {
				var a = point_direction(x, y, obj_link.x, obj_link.y);
				level_move(lengthdir_x(SANDWORM_SPIN_SPEED, a), lengthdir_y(SANDWORM_SPIN_SPEED, a), level);
			}
			if (timer <= 0) {
				sandworm_set("sink", 14);
				sfx_play(SFX_SAND);
			}
			break;

		case "sink":
			if (timer <= 0) {sandworm_set("under", irandom_range(40, 90))}
			break;
	}
	switch (state) {
		case "under": image_index = floor(anim_t) mod 2; break;
		case "rise": case "sink": image_index = 2; break;
		default: image_index = 3 + floor(anim_t * 2) mod 2; break;
	}


}

///level_move_as(hspd, vspd, level);
function level_move_as(argument0, argument1, argument2) {
	//level_move for something that's on a level it can't move on by itself (a burrowing sandworm
	//is on level -2 so nothing touches it, but digs along the lower floor's walls)
	var keep = level;
	level = argument2;
	var hit = level_move(argument0, argument1, argument2);
	level = keep;
	return hit;


}

//================================================================ the vulture

///vulture_step();
function vulture_step() {
	//Run by obj_vulture: perch, circle over Link, dive at where he was, climb back up
	if (zone == noone) {zone = cam_zone_at(x, y)}
	timer--;
	anim_t += (state == "perch") ? 0.05 : 0.2;
	switch (state) {
		case "perch":
			z = 0;
			if (instance_exists(obj_link) && point_distance(x, y, obj_link.x, obj_link.y) < VULTURE_WAKE) {
				state = "climb";
				sfx_play(SFX_WIND);
			}
			break;

		case "climb":
			z = min(VULTURE_HIGH, z + 1.2);
			vulture_circle();
			if (z >= VULTURE_HIGH) {
				state = "circle";
				timer = irandom_range(60, 110);
			}
			break;

		case "circle":
			vulture_circle();
			if (timer <= 0 && instance_exists(obj_link)) {
				state = "dive";
				timer = VULTURE_DIVE_TIME;
				dive_x = obj_link.x;
				dive_y = obj_link.y;
			}
			break;

		case "dive":
			//Straight down at the spot (its shadow slides onto it)
			var t = max(1, timer);
			x += (dive_x - x) / t;
			y += (dive_y - y) / t;
			z = VULTURE_HIGH * timer / VULTURE_DIVE_TIME;
			if (timer <= 0) {
				z = 0;
				state = "climb";
			}
			break;
	}
	enemy_keep_in_zone();
	can_touch = (z < VULTURE_LOW);
	image_index = (state == "perch") ? 0 : ((state == "dive") ? 3 : 1 + floor(anim_t) mod 2);


}

///vulture_circle();
function vulture_circle() {
	//Glide round a circle about Link
	if (!instance_exists(obj_link)) return;
	circle_ang += 2.5;
	var tx = obj_link.x + lengthdir_x(VULTURE_CIRCLE_R, circle_ang);
	var ty = obj_link.y + lengthdir_y(VULTURE_CIRCLE_R * 0.6, circle_ang);
	var d = point_distance(x, y, tx, ty);
	if (d > VULTURE_SPEED) {
		var a = point_direction(x, y, tx, ty);
		x += lengthdir_x(VULTURE_SPEED, a);
		y += lengthdir_y(VULTURE_SPEED, a);
	} else {
		x = tx;
		y = ty;
	}
	if (abs(lengthdir_x(1, point_direction(x, y, tx, ty))) > 0.2) {face = sign(tx - x)}


}

///vulture_draw();
function vulture_draw() {
	//Run by obj_vulture's Draw: its shadow on the ground, the bird up in the air
	if (z > 0) {enemy_shadow(x, y, 12)}
	draw_sprite_ext(sprite_index, image_index, x, y - round(z), face, 1, 0, image_blend, image_alpha);


}

//================================================================ the cactus

///cactus_step();
function cactus_step() {
	//Run by obj_cactus: drift about diagonally, bouncing off walls. Each hit knocks off a segment.
	if (hp < hp_last) {
		hp = CACTUS_SEGMENTS * 100;
		hp_last = hp;
		segments--;
		//The segment bursts into spines
		var sy = y - (segments) * CACTUS_SEG_H;
		for (var i = 0; i < 4; i++) {desert_shot(x, sy, 45 + i * 90, CACTUS_SPINE_DAMAGE, level, 1)}
		if (segments <= 0) {
			instance_create_depth(x, y, depth - 1, obj_enemy_death);
			sfx_play(SFX_ENEMY_DIE);
			instance_destroy();
			return;
		}
	}
	anim_t += 0.08;
	var hit_h = level_move(lengthdir_x(CACTUS_SPEED, move_dir), 0, level);
	var hit_v = level_move(0, lengthdir_y(CACTUS_SPEED, move_dir), level);
	if (hit_h) {move_dir = 180 - move_dir}
	if (hit_v) {move_dir = -move_dir}
	move_dir = (move_dir + 360) mod 360;


}

///cactus_draw();
function cactus_draw() {
	//Run by obj_cactus's Draw: the segments stacked up, swaying, the head on top
	for (var i = 0; i < segments; i++) {
		var sway = round(sin(anim_t + i * 0.9) * min(i, 2));
		var frame = (i == segments - 1) ? 0 : 1;
		draw_sprite_ext(sprite_index, frame, x + sway, y - i * CACTUS_SEG_H, 1, 1, 0, image_blend, image_alpha);
	}


}

//================================================================ the dust devil

///dust_devil_step();
function dust_devil_step() {
	//Run by obj_dust_devil: wander after Link, fling him if it catches him
	anim_t += 0.35;
	image_index = floor(anim_t) mod sprite_get_number(sprite_index);
	if (state == "gone") {
		timer--;
		if (timer <= 0) {
			x = home_x;
			y = home_y;
			state = "whirl";
			life = DUST_LIFE;
			sfx_play(SFX_WIND);
		}
		return;
	}
	life--;
	if (life <= 0) {
		state = "gone";
		timer = DUST_REFORM;
		return;
	}
	//Drift after Link, weaving about
	weave += 4;
	var ang = weave;
	if (instance_exists(obj_link) && point_distance(x, y, obj_link.x, obj_link.y) < 160) {
		ang = point_direction(x, y, obj_link.x, obj_link.y) + sin(degtorad(weave)) * 50;
	}
	level_move(lengthdir_x(DUST_SPEED, ang), lengthdir_y(DUST_SPEED, ang), 0);

	//Caught him: up and away
	if (instance_exists(obj_link) && place_meeting(x, y, obj_link) && obj_link.z == 0 && obj_link.hurt_timer <= 0
		&& obj_link.level == 0 && obj_link.state != "fall" && obj_link.state != "jump") {
		var fling = point_direction(x, y, obj_link.x, obj_link.y);
		player_hurt(1, x, y);
		with (obj_link) {
			if (state == "hurt") {
				dur = DUST_FLING_TIME;
				kb_dir = fling;
			}
		}
		sfx_play(SFX_WIND);
	}


}

///dust_devil_draw();
function dust_devil_draw() {
	//Run by obj_dust_devil's Draw (nothing while it's blown out, a faint swirl just as it forms)
	if (state == "gone") {
		if (timer < 30) {draw_sprite_ext(sprite_index, image_index, home_x, home_y, 0.6, 0.6, 0, c_white, 0.4)}
		return;
	}
	var a = (life < 40) ? life / 40 : 1;
	draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, 0, c_white, a);


}

//================================================================ the mummy

///mummy_step();
function mummy_step() {
	//Run by obj_mummy: shamble after Link. Alight, it runs about until it crumbles.
	timer--;
	if (burning > 0) {
		burning--;
		anim_t += 0.35;
		if (burning mod MUMMY_BURN_TICK == 0) {
			hp -= 1;
			if (hp <= 0) {
				instance_create_depth(x, y, depth - 1, obj_enemy_death);
				sfx_play(SFX_ENEMY_DIE);
				instance_destroy();
				return;
			}
		}
		if (timer <= 0) {
			move_dir = random(360);
			timer = irandom_range(10, 25);
		}
		if (level_move(lengthdir_x(1.5, move_dir), lengthdir_y(1.5, move_dir), level)) {timer = 0}
	} else {
		anim_t += 0.08;
		if (enemy_can_see_link(MUMMY_SIGHT)) {
			move_dir = point_direction(x, y, obj_link.x, obj_link.y);
		} else if (timer <= 0) {
			move_dir = choose(0, 90, 180, 270);
			timer = irandom_range(40, 90);
		}
		level_move(lengthdir_x(MUMMY_SPEED, move_dir), lengthdir_y(MUMMY_SPEED, move_dir), level);
	}
	image_index = enemy_face_frame(move_dir, floor(anim_t));


}

///enemy_ignite(enemy);
function enemy_ignite(argument0) {
	//Fire touched it: an enemy that burns (a mummy has a burning variable) catches alight
	with (argument0) {
		if (variable_instance_exists(id, "burning") && burning <= 0) {
			burning = MUMMY_BURN_TIME;
			sfx_play(SFX_TORCH);
		}
	}


}

///mummy_draw();
function mummy_draw() {
	//Run by obj_mummy's Draw: the mummy, flames on it while it burns
	draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, 0, image_blend, image_alpha);
	if (burning > 0) {
		var f = (current_time div 80) mod 2;
		draw_sprite_ext(spr_lantern_flame, f, x - 3, y - 9, 0.7, 0.7, 0, c_white, 1);
		draw_sprite_ext(spr_lantern_flame, 1 - f, x + 4, y - 5, 0.6, 0.6, 0, c_white, 1);
	}


}

//================================================================ the antlion

///antlion_step();
function antlion_step() {
	//Run by obj_antlion: drag Link in through the quicksand, bite, sink back
	timer--;
	var near = instance_exists(obj_link) && obj_link.level == 0;
	var d = near ? point_distance(x, y, obj_link.x, obj_link.y) : 999;

	//The sand slides towards its jaws
	if (near && obj_link.in_sand && d < ANTLION_PULL_RANGE && d > 3 && (obj_link.state == "idle" || obj_link.state == "hurt")) {
		var a = point_direction(obj_link.x, obj_link.y, x, y);
		with (obj_link) {level_move(lengthdir_x(ANTLION_PULL_SPEED, a), lengthdir_y(ANTLION_PULL_SPEED, a), level)}
	}

	switch (state) {
		case "hide":
			invulnerable = true;
			if (timer <= 0 && d < 18) {
				state = "snap";
				timer = 12;
			}
			break;

		case "snap":
			if (timer == 4 && d < 18) {player_hurt(ANTLION_BITE, x, y)}
			if (timer <= 0) {
				state = "up";
				timer = ANTLION_UP_TIME;
				invulnerable = false;
				sfx_play(SFX_SAND);
			}
			break;

		case "up":
			if (timer <= 0) {
				state = "hide";
				timer = 40;
				invulnerable = true;
				sfx_play(SFX_SAND);
			}
			break;
	}
	image_index = (state == "hide") ? (current_time div 300) mod 2 : ((state == "snap") ? 2 : 3);


}

//================================================================ the mirage

///mirage_step();
function mirage_step() {
	//Run by obj_mirage: float after Link (through anything)
	if (zone == noone) {zone = cam_zone_at(x, y)}
	anim_t += 0.06;
	if (instance_exists(obj_link) && obj_link.level == 0 && point_distance(x, y, obj_link.x, obj_link.y) < MIRAGE_SIGHT) {
		var a = point_direction(x, y, obj_link.x, obj_link.y) + sin(anim_t * 2) * 30;
		x += lengthdir_x(MIRAGE_SPEED, a);
		y += lengthdir_y(MIRAGE_SPEED, a);
	}
	enemy_keep_in_zone();
	image_index = floor(anim_t * 2) mod 2;


}

///mirage_draw();
function mirage_draw() {
	//Run by obj_mirage's Draw: a ripple of haze, or (under the lens) the wraith itself
	var bob = round(sin(anim_t * 3) * 2);
	if (lens_active()) {
		draw_sprite_ext(sprite_index, image_index, x, y - 4 + bob, 1, 1, 0, image_blend, 1);
	} else {
		var wob = round(sin(current_time / 90) * 1);
		draw_sprite_ext(sprite_index, image_index, x + wob, y - 4 + bob, 1, 1, 0, c_white, MIRAGE_HAZE_ALPHA);
	}


}
