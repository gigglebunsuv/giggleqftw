//The Southern Tower's boss: the Gargoyle, on the tower's roof (obj_gargoyle, obj_boss_arena).
//
//It sleeps as a statue on a pillar until Link comes onto the roof. Then it flies circles
//over the roof, swoops down at him, and lands on the corner pillars (obj_tower_pillar) to
//spit fireballs. In the air or on a pillar nothing hurts it.
//The grapple hook (aimed at its shadow) yanks it down out of the air: it lies stunned on
//the roof for a while, and that's when the sword hurts it.
//Below half health it's faster, flaps gusts of wind that push Link toward the roof's edge,
//and rocks fall around him while it sits on a pillar.
//
//x, y is the spot on the ground under it (its shadow, what the grapple hook and sword hit),
//z is how high it is (it's drawn z pixels up).
//States: "dormant", "wake", "rise", "hover", "swoop", "perch" (flying to a pillar),
//"perched", "gust", "yanked" (pulled down), "grounded".

#macro GARG_HP 8
#macro GARG_FLY_Z 28			//height it flies at
#macro GARG_PERCH_Z 14			//height sitting on a pillar
#macro GARG_GROUND_TIME 150		//steps it lies stunned (less below half health)
#macro GARG_GROUND_HITS 3		//it gets up after this many hits
#macro GARG_GUST_PUSH 1.1		//pixels a step the wind pushes Link
#macro GARG_ROCK_DAMAGE 2
#macro GARG_SHOT_DAMAGE 2

///gargoyle_angry();
function gargoyle_angry() {
	//Below half health
	return hp <= hp_max div 2;


}

///gargoyle_set(state, timer);
function gargoyle_set(argument0, argument1) {
	//Changes state, and what can touch it in that state
	state = argument0;
	timer = argument1;
	invulnerable = (state != "grounded");
	can_touch = (state == "grounded");
	contact_damage = 2;
	if (state == "grounded") {contact_damage = 0}


}

///gargoyle_move_to(x, y, speed);
function gargoyle_move_to(argument0, argument1, argument2) {
	//Flies toward a spot (walls don't stop it). Returns true once it's there.
	var d = point_distance(x, y, argument0, argument1);
	if (d <= argument2) {
		x = argument0;
		y = argument1;
		return true;
	}
	var ang = point_direction(x, y, argument0, argument1);
	x += lengthdir_x(argument2, ang);
	y += lengthdir_y(argument2, ang);
	return false;


}

///gargoyle_pick_pillar();
function gargoyle_pick_pillar() {
	//A pillar on the roof other than the one it sat on last, or noone
	var az = arena_zone;
	var list = [];
	with (obj_tower_pillar) {
		if (id != other.perch && (az == noone || point_in_rectangle(x + 16, y + 16, az.bbox_left, az.bbox_top, az.bbox_right, az.bbox_bottom))) {
			array_push(list, id);
		}
	}
	if (array_length(list) == 0) return noone;
	return list[irandom(array_length(list) - 1)];


}

///gargoyle_yank();
function gargoyle_yank() {
	//The grapple hook caught it: down it comes, a little toward Link
	gargoyle_set("yanked", 0);
	sfx_play(SFX_BOSS_ROAR);
	if (instance_exists(obj_link)) {yank_dir = point_direction(x, y, obj_link.x, obj_link.y)}


}

///gargoyle_fire();
function gargoyle_fire() {
	//A fireball at Link from up on its pillar
	if (!instance_exists(obj_link)) return;
	//Starts just off the pillar, so the pillar doesn't stop it
	var ang = point_direction(x, y, obj_link.x, obj_link.y);
	var shot = instance_create_depth(x + lengthdir_x(26, ang), y + lengthdir_y(26, ang), DEPTH_FLYING, obj_gargoyle_shot);
	shot.direction = ang;
	shot.level = obj_link.level;
	sfx_play(SFX_FIRE_ROD);


}

///gargoyle_drop_rocks(count);
function gargoyle_drop_rocks(argument0) {
	//Rocks fall around Link (their shadows show where)
	if (!instance_exists(obj_link)) return;
	for (var i = 0; i < argument0; i++) {
		var ang = random(360);
		var d = (i == 0) ? 0 : random_range(20, 48);
		var rx = obj_link.x + lengthdir_x(d, ang);
		var ry = obj_link.y + lengthdir_y(d, ang);
		var rock = instance_create_depth(rx, ry, DEPTH_FLYING, obj_gargoyle_rock);
		rock.timer = 45 + i * 12;
	}


}

///gargoyle_step();
function gargoyle_step() {
	//Run by obj_gargoyle's Step after the shared enemy logic
	var angry = gargoyle_angry();
	if (gust_cd > 0) {gust_cd--}

	//The grapple hook stuns enemies: in the air that means it gets pulled down,
	//on a pillar it just clinks off the stone
	if (stun_timer > 0) {
		stun_timer = 0;
		image_blend = c_white;
		if (state == "hover" || state == "swoop" || state == "gust") {gargoyle_yank()}
		else if (state == "perched" || state == "dormant") {sfx_play(SFX_HOOK_HIT)}
	}

	switch (state) {
		case "dormant":
			z = GARG_PERCH_Z;
			if (global.cam_zone == arena_zone && !global.cam_transition) {
				timer++;
				if (timer >= 40) {
					gargoyle_set("wake", 40);
					sfx_play(SFX_BOSS_ROAR);
				}
			}
			break;

		case "wake":
			timer--;
			if (timer <= 0) {gargoyle_set("rise", 0)}
			break;

		case "rise":
			z = min(GARG_FLY_Z, z + 1);
			if (z >= GARG_FLY_Z) {gargoyle_set("hover", irandom_range(90, 150))}
			break;

		case "hover":
			orbit += angry ? 1.6 : 1.1;
			var ox = arena_x + lengthdir_x(orbit_rx, orbit);
			var oy = arena_y + lengthdir_y(orbit_ry, orbit);
			gargoyle_move_to(ox, oy, angry ? 2.2 : 1.6);
			z = GARG_FLY_Z + sin(current_time / 200) * 2;
			timer--;
			if (angry && gust_cd <= 0 && timer == 40) {
				gargoyle_set("gust", 90);
				sfx_play(SFX_WIND);
				break;
			}
			if (timer <= 0) {
				if (irandom(9) < 3 && gargoyle_pick_pillar() != noone) {
					perch = gargoyle_pick_pillar();
					gargoyle_set("perch", 0);
				} else if (instance_exists(obj_link)) {
					//Swoop through where Link is, out the other side
					swoop_x0 = x;
					swoop_y0 = y;
					var ang = point_direction(x, y, obj_link.x, obj_link.y);
					var d = point_distance(x, y, obj_link.x, obj_link.y) + 40;
					swoop_x1 = x + lengthdir_x(d, ang);
					swoop_y1 = y + lengthdir_y(d, ang);
					swoop_t = 0;
					swoop_len = max(20, d / (angry ? 4.2 : 3.2));
					gargoyle_set("swoop", 0);
				}
			}
			break;

		case "swoop":
			swoop_t++;
			var t = min(1, swoop_t / swoop_len);
			x = lerp(swoop_x0, swoop_x1, t);
			y = lerp(swoop_y0, swoop_y1, t);
			z = GARG_FLY_Z - (GARG_FLY_Z - 4) * sin(pi * t);
			can_touch = (z < 12);
			if (t >= 1) {gargoyle_set("hover", irandom_range(70, 130))}
			break;

		case "perch":
			if (!instance_exists(perch)) {
				gargoyle_set("hover", 60);
				break;
			}
			z += clamp(GARG_PERCH_Z - z, -1, 1);
			if (gargoyle_move_to(perch.x + 16, perch.y + 16, 2.4)) {
				z = GARG_PERCH_Z;
				gargoyle_set("perched", 110);
				shots = angry ? 4 : 3;
				if (angry) {gargoyle_drop_rocks(3)}
			}
			break;

		case "perched":
			timer--;
			if (shots > 0 && timer < 100 && timer mod 22 == 0) {
				gargoyle_fire();
				shots--;
			}
			if (timer <= 0) {gargoyle_set("rise", 0)}
			break;

		case "gust":
			//Hovers in place flapping hard: the wind pushes Link away from it
			timer--;
			z = GARG_FLY_Z + sin(current_time / 80) * 2;
			if (instance_exists(obj_link)) {
				var ang = point_direction(x, y, obj_link.x, obj_link.y);
				with (obj_link) {
					if (state == "idle" || state == "attack" || state == "shoot") {
						player_move(lengthdir_x(GARG_GUST_PUSH, ang), lengthdir_y(GARG_GUST_PUSH, ang));
					}
				}
				if (timer mod 6 == 0) {
					var g = instance_create_depth(x + random_range(-12, 12), y + random_range(-8, 8), DEPTH_FLYING - 1, obj_gust);
					g.direction = ang + random_range(-20, 20);
				}
			}
			if (timer <= 0) {
				gust_cd = 240;
				gargoyle_set("hover", irandom_range(60, 100));
			}
			break;

		case "yanked":
			x += lengthdir_x(1.5, yank_dir);
			y += lengthdir_y(1.5, yank_dir);
			z -= 3;
			if (z <= 0) {
				z = 0;
				gargoyle_set("grounded", angry ? GARG_GROUND_TIME - 40 : GARG_GROUND_TIME);
				hp_at_ground = hp;
				sfx_play(SFX_ROCK);
			}
			break;

		case "grounded":
			timer--;
			if (timer <= 0 || hp_at_ground - hp >= GARG_GROUND_HITS * global.swordTier) {
				gargoyle_set("rise", 0);
				sfx_play(SFX_BOSS_ROAR);
			}
			break;
	}

	//Wing flaps
	anim_t += (state == "gust") ? 0.5 : 0.2;


}

///gargoyle_frame();
function gargoyle_frame() {
	//0-1 flying, 2 stone, 3 knocked down, 4 swooping
	switch (state) {
		case "dormant":
		case "perched":
			return 2;
		case "wake":
			return ((timer div 4) mod 2 == 0) ? 2 : 0;
		case "grounded":
		case "yanked":
			return 3;
		case "swoop":
			return 4;
	}
	return floor(anim_t) mod 2;


}
