//The Bog Tower's boss: Murkmaw, a great bog serpent living in the pool in the middle of its room
//(obj_bog_boss, obj_boss_arena with boss_object = obj_bog_boss).
//
//Its scaly hide turns every blade, bomb and hammer: only arrows hurt it, and only when it opens
//its jaws wide and its soft throat glows (arrow_weak, see obj_arrow). It swims under the surface
//(just ripples, nothing touches it), rises, spits mud at Link, then roars with its maw open.
//The grapple hook in its jaw makes it gag them open early.
//	Phase 1 (full health)		rise, spit 3 mud lumps, open up
//	Phase 2 (below 2/3)			it also lunges at the shore next to Link, biting, and is left
//								stuck there with its maw open for a moment
//	Phase 3 (below 1/3)			faster, wider spits, and lurkers (obj_lurker) join it in the pool
//Swimming in its pool is a bad idea: it homes in on Link under the water and bursts up under him.
//So he never runs out of arrows, it keeps a bundle of arrows (obj_arrow_bundle) on the shore near
//him whenever he's low.
//
//x, y is where its neck meets the water (the sprite's origin). States: "dormant", "under", "rise",
//"spit", "open", "hurt", "sink", "lunge" (rising fast at the shore), "stuck" (after a lunge).

#macro BOGB_HP 16				//arrows do 2: 8 good shots
#macro BOGB_SHOT_DAMAGE 2
#macro BOGB_BITE_DAMAGE 3		//bursting up under Link, or a lunge
#macro BOGB_OPEN_TIME 60		//steps its maw stays open (less in later phases)
#macro BOGB_STUCK_TIME 75		//steps it's stuck after a lunge (maw open)
#macro BOGB_RISE_TIME 16
#macro BOGB_ARROWS_LOW 3		//fewer arrows than this (counting bundles lying about): drop a bundle
#macro BOGB_ARROW_DELAY 120		//steps between bundles
#macro BOGB_INTRO_FLAG "bog_boss_seen"

///bogb_phase();
function bogb_phase() {
	if (hp > hp_max * 2 / 3) return 1;
	if (hp > hp_max / 3) return 2;
	return 3;


}

///bogb_set(state, timer);
function bogb_set(argument0, argument1) {
	//Changes state, and what can touch it: under the water nothing (level -2 matches nothing)
	state = argument0;
	timer = argument1;
	var up = (state != "dormant" && state != "under");
	can_touch = up && state != "rise" && state != "sink";
	level = up ? -1 : -2;
	invulnerable = true;
	arrow_weak = (state == "open" || state == "stuck");
	contact_damage = (state == "lunge") ? BOGB_BITE_DAMAGE : 2;


}

///bogb_pool_point();
function bogb_pool_point() {
	//A random spot in the deep water of its room (away from the water's edge), or where it is
	var list = [];
	var az = arena_zone;
	with (obj_water) {
		var cx = (bbox_left + bbox_right) / 2;
		var cy = (bbox_top + bbox_bottom) / 2;
		if (az == noone || !instance_exists(az) || point_in_rectangle(cx, cy, az.bbox_left, az.bbox_top, az.bbox_right, az.bbox_bottom)) {
			array_push(list, id);
		}
	}
	if (array_length(list) == 0) return [x, y];
	repeat (20) {
		var w = list[irandom(array_length(list) - 1)];
		var m = 14;
		var px = (w.bbox_right - w.bbox_left > m * 2) ? random_range(w.bbox_left + m, w.bbox_right - m) : (w.bbox_left + w.bbox_right) / 2;
		var py = (w.bbox_bottom - w.bbox_top > m * 2) ? random_range(w.bbox_top + m, w.bbox_bottom - m) : (w.bbox_top + w.bbox_bottom) / 2;
		if (position_meeting(px, py, obj_water) && position_meeting(px - 12, py, obj_water) && position_meeting(px + 12, py, obj_water)) {
			return [round(px), round(py)];
		}
	}
	return [x, y];


}

///bogb_pool_point_near(x, y);
function bogb_pool_point_near(argument0, argument1) {
	//The spot in the water (of a few tries) closest to this point: the shore next to Link
	var best = [x, y];
	var bd = infinity;
	repeat (30) {
		var p = bogb_pool_point();
		var d = point_distance(p[0], p[1], argument0, argument1);
		if (d < bd) {
			bd = d;
			best = p;
		}
	}
	return best;


}

///bogb_link_in_pool();
function bogb_link_in_pool() {
	//Link swimming in its room
	if (!instance_exists(obj_link) || !obj_link.swimming) return false;
	return arena_zone == noone || !instance_exists(arena_zone) || global.cam_zone == arena_zone;


}

///bogb_spit(count, spread);
function bogb_spit(argument0, argument1) {
	//A fan of mud lumps at Link from its mouth
	if (!instance_exists(obj_link)) return;
	var ang = point_direction(x, y - 20, obj_link.x, obj_link.y);
	var n = argument0;
	for (var i = 0; i < n; i++) {
		var a = ang + (i - (n - 1) / 2) * argument1;
		var m = bog_spit(x + lengthdir_x(8, a), y - 20 + lengthdir_y(8, a), a, BOGB_SHOT_DAMAGE, obj_link.level);
		m.speed = (bogb_phase() == 3) ? 2.8 : 2.3;
	}
	sfx_play(SFX_FIREBALL);


}

///bogb_arrow_check();
function bogb_arrow_check() {
	//So Link can always win: when he's low on arrows (bundles already lying about count too),
	//leave a bundle on dry floor near him
	if (arrow_cd > 0) {arrow_cd--; return;}
	if (!instance_exists(obj_link) || !global.item_have[ITEM.BOW]) return;
	if (global.pArrows + instance_number(obj_arrow_bundle) * ARROW_BUNDLE_ARROWS >= BOGB_ARROWS_LOW) return;
	var az = arena_zone;
	repeat (40) {
		var ang = random(360);
		var d = random_range(20, 72);
		var bx = round(obj_link.x + lengthdir_x(d, ang));
		var by = round(obj_link.y + lengthdir_y(d, ang));
		if (az != noone && instance_exists(az) && !point_in_rectangle(bx, by, az.bbox_left + 24, az.bbox_top + 40, az.bbox_right - 24, az.bbox_bottom - 24)) continue;
		var bad = false;
		for (var i = 0; i < 5; i++) {
			var cx = bx + choose(-7, 7, 0, 0, 0) * (i > 0);
			var cy = by + choose(-7, 7, 0) * (i > 2);
			if (position_meeting(cx, cy, obj_water) || position_meeting(cx, cy, obj_wall) || position_meeting(cx, cy, obj_wall_low) || position_meeting(cx, cy, obj_pit)) {bad = true}
		}
		if (bad) continue;
		arrow_bundle_drop(bx, by);
		sfx_play(SFX_SECRET);
		arrow_cd = BOGB_ARROW_DELAY;
		return;
	}
	arrow_cd = 20;	//no room this time: try again soon


}

///bogb_step();
function bogb_step() {
	//Run by obj_bog_boss's Step after the shared enemy logic
	var phase = bogb_phase();
	if (state != "dormant") {bogb_arrow_check()}

	//The grapple hook (stuns enemies): hooked in the jaw, it gags them open
	if (stun_timer > 0) {
		stun_timer = 0;
		image_blend = c_white;
		if (state == "spit") {
			sfx_play(SFX_BOSS_ROAR);
			bogb_set("open", BOGB_OPEN_TIME div 2);
		} else if (state != "open" && state != "stuck") {
			sfx_play(SFX_HOOK_HIT);
		}
	}

	//An arrow got it: recoil and dive
	if (hp < hp_last) {
		hp_last = hp;
		bogb_set("hurt", 24);
		sfx_play(SFX_BOSS_ROAR);
		//Phase 3 starts: lurkers come up from the deep
		if (bogb_phase() == 3 && !lurkers_out) {
			lurkers_out = true;
			repeat (2) {
				var p = bogb_pool_point();
				instance_create_depth(p[0], p[1], DEPTH_LOWER, obj_lurker);
			}
		}
	}

	timer--;
	switch (state) {
		case "dormant":
			if (arena_zone == noone || (global.cam_zone == arena_zone && !global.cam_transition)) {
				wake++;
				if (wake == 30) {
					sfx_play(SFX_BOSS_ROAR);
					if (!flag_get(BOGB_INTRO_FLAG)) {
						flag_set(BOGB_INTRO_FLAG, true);
						dialogue_start([
							"MURKMAW, THE TERROR OF THE BOG, RISES FROM THE BLACK WATER!",
							"ITS SCALY HIDE TURNS ASIDE ANY BLADE... BUT WHEN IT OPENS ITS JAWS WIDE, ITS SOFT THROAT GLOWS. SHOOT AN ARROW RIGHT IN!"
						]);
					}
				}
				if (wake >= 50) {
					bogb_set("rise", BOGB_RISE_TIME);
					sfx_play(SFX_SPLASH);
				}
			}
			break;

		case "under":
			//Swim to the next spot (homing in on Link if he's in the water)
			var speeds = [1.4, 1.4, 1.8, 2.3];
			var spd = speeds[phase];
			if (bogb_link_in_pool()) {
				dest_x = obj_link.x;
				dest_y = obj_link.y;
				spd += 0.6;
			}
			var d = point_distance(x, y, dest_x, dest_y);
			if (d > spd) {
				var a = point_direction(x, y, dest_x, dest_y);
				x += lengthdir_x(spd, a);
				y += lengthdir_y(spd, a);
			} else {
				x = dest_x;
				y = dest_y;
			}
			if (timer <= 0 && d <= spd) {
				//Right under Link swimming: it bursts up and bites (a lunge)
				if (bogb_link_in_pool() && point_distance(x, y, obj_link.x, obj_link.y) < 16) {lunging = true}
				if (lunging) {
					lunging = false;
					bogb_set("lunge", 10);
				} else {
					bogb_set("rise", BOGB_RISE_TIME);
				}
				sfx_play(SFX_SPLASH);
			}
			break;

		case "rise":
			if (timer <= 0) {
				bogb_set("spit", 70);
				volleys = (phase == 1) ? 1 : 2;
			}
			break;

		case "spit":
			//Cheeks full (a warning), then a fan of mud; once or twice, then it opens up
			if (timer == 50 || (volleys > 1 && timer == 24)) {
				bogb_spit((phase == 3) ? 5 : 3, (phase == 3) ? 18 : 22);
			}
			if (timer <= 0) {
				bogb_set("open", BOGB_OPEN_TIME - (phase - 1) * 10);
				sfx_play(SFX_BOSS_ROAR);
			}
			break;

		case "open":
		case "stuck":
			if (timer <= 0) {bogb_set("sink", 12)}
			break;

		case "hurt":
			if (timer <= 0) {bogb_set("sink", 10)}
			break;

		case "sink":
			if (timer <= 0) {
				//Next: a lunge at the shore by Link (phase 2 and up, half the time), or another spot
				var p;
				if (phase >= 2 && !bogb_link_in_pool() && instance_exists(obj_link) && irandom(1) == 0) {
					p = bogb_pool_point_near(obj_link.x, obj_link.y);
					lunging = true;
				} else {
					p = bogb_pool_point();
				}
				dest_x = p[0];
				dest_y = p[1];
				bogb_set("under", irandom_range(40, 80) - phase * 10);
				sfx_play(SFX_SPLASH);
			}
			break;

		case "lunge":
			//Bursts up at the water's edge, biting toward Link, then it's stuck with its jaw open
			if (timer == 9 && instance_exists(obj_link)) {
				var a = point_direction(x, y, obj_link.x, obj_link.y);
				lunge_x = lengthdir_x(3, a);
				lunge_y = lengthdir_y(3, a);
			}
			if (timer > 4) {
				x += lunge_x;
				y += lunge_y;
			}
			if (timer <= 0) {
				bogb_set("stuck", BOGB_STUCK_TIME);
				sfx_play(SFX_ROCK);
			}
			break;
	}
	anim_t += 0.1;


}

///bogb_frame();
function bogb_frame() {
	//0 jaw shut, 1 maw open, 2 hurt, 3 cheeks full (spitting)
	switch (state) {
		case "open":
		case "stuck":
			return 1;
		case "hurt":
			return 2;
		case "spit":
			return (timer > 44 || (volleys > 1 && timer > 18 && timer < 34)) ? 3 : 0;
		case "lunge":
			return 1;
	}
	return 0;


}

///bogb_draw();
function bogb_draw() {
	//Run by obj_bog_boss's Draw: ripples while it's under, the head rising out of the water
	var rip = floor(current_time / 250) mod 2;
	switch (state) {
		case "dormant":
		case "under":
			draw_sprite_ext(spr_bog_ripple, rip, x, y, lunging ? 1.3 : 1, 1, 0, c_white, 0.85);
			return;
		case "rise":
		case "sink":
			//Only the part above the water: the top rows of the sprite, standing on the waterline
			var t = (state == "rise") ? 1 - timer / BOGB_RISE_TIME : timer / 12;
			var h = max(1, round(41 * clamp(t, 0, 1)));
			draw_sprite_ext(spr_bog_ripple, rip, x, y, 1.2, 1, 0, c_white, 0.85);
			draw_sprite_part_ext(sprite_index, 0, 0, 0, 48, h, x - 24, y + 1 - h, 1, 1, image_blend, 1);
			return;
	}
	var bx = x;
	if (state == "hurt" || state == "stuck") {bx += choose(-1, 0, 1)}
	draw_sprite_ext(spr_bog_ripple, rip, x, y, 1.4, 1, 0, c_white, 0.6);
	draw_sprite_ext(sprite_index, bogb_frame(), bx, y, 1, 1, 0, image_blend, image_alpha);
	//The glowing throat pulses (the target)
	if (arrow_weak && (current_time div 150) mod 2 == 0) {
		draw_sprite_ext(spr_pixel, 0, bx - 3, y - 18, 6, 3, 0, c_white, 0.6);
	}


}
