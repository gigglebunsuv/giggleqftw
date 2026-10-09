//The Tower of Ladhellin's boss: Sahran, the Mirage Sphinx, on the tower's sun-dial roof
//(obj_sphinx, obj_boss_arena with boss_object = obj_sphinx).
//
//Its stone hide turns every blade and arrow while it sits up. It slams its paws down and a ring of
//sand (obj_sand_wave) rolls out across the floor: jump it with the cape. After a slam it bows low,
//its brow-gem glowing, and then the sword (or arrows) can hurt it.
//	Phase 1 (full health)		slams, and fans of sand balls (obj_sand_shot)
//	Phase 2 (below 2/3)			it splits into three (two obj_sphinx_mirage) every time it's hurt.
//								The copies do everything it does, but their waves and sand are only
//								haze. The Sun Lens shows which one is real; hitting a copy pops it.
//	Phase 3 (below 1/3)			it also shakes the roof: the cracked tiles (obj_crumble) round Link fall
//								away for a while, so he has to jump between what's left
//
//x, y is where its front paws stand (the sprite's origin). States: "dormant", "sit", "raise"
//(paws up, the warning), "slam", "bow" (hittable), "shoot", "hurt", "split", "quake".

#macro SPHINX_HP 24
#macro SPHINX_DAMAGE 2				//touching it while it sits up
#macro SPHINX_WAVE_DAMAGE 2
#macro SPHINX_SHOT_DAMAGE 2
#macro SPHINX_RAISE_TIME 26			//paws up before a slam
#macro SPHINX_BOW_TIME 80			//steps it stays bowed (less in later phases)
#macro SPHINX_WAVE_SPEED 1.6
#macro SPHINX_WAVE_BAND 5			//how thick the wave is (pixels each way)
#macro SPHINX_WAVE_CLEAR 2			//Link this high up (or higher) is over it
#macro SPHINX_QUAKE_TILES 10		//cracked tiles the quake drops
#macro SPHINX_SPOT_DX 72			//its three spots: home, and this far left and right (and a bit lower)
#macro SPHINX_SPOT_DY 20
#macro SPHINX_INTRO_FLAG "sphinx_seen"
#macro SPHINX_SPLIT_FLAG "sphinx_split_seen"

///sphinx_phase();
function sphinx_phase() {
	if (hp > hp_max * 2 / 3) return 1;
	if (hp > hp_max / 3) return 2;
	return 3;


}

///sphinx_set(state, timer);
function sphinx_set(argument0, argument1) {
	//Changes state. Only bowed is it open to the sword and arrows, and harmless to touch.
	state = argument0;
	timer = argument1;
	var bowed = (state == "bow");
	invulnerable = !bowed;
	contact_damage = bowed ? 0 : SPHINX_DAMAGE;
	can_touch = (state != "dormant" && state != "split");
	with (obj_sphinx_mirage) {can_touch = other.can_touch}


}

///sphinx_spots();
function sphinx_spots() {
	//Its three spots: [x, y] each
	return [[home_x, home_y], [home_x - SPHINX_SPOT_DX, home_y + SPHINX_SPOT_DY], [home_x + SPHINX_SPOT_DX, home_y + SPHINX_SPOT_DY]];


}

///sphinx_wave(x, y, fake);
function sphinx_wave(argument0, argument1, argument2) {
	var w = instance_create_depth(argument0, argument1 - 4, DEPTH_DECOR - 2, obj_sand_wave);
	w.fake = argument2;
	return w;


}

///sphinx_shoot(x, y, count, spread, fake, speed);
function sphinx_shoot(argument0, argument1, argument2, argument3, argument4, argument5) {
	//A fan of sand balls at Link from its mouth (the real Sphinx works out the speed: its copies
	//have no health of their own to tell the phase from)
	if (!instance_exists(obj_link)) return;
	var ang = point_direction(argument0, argument1 - 24, obj_link.x, obj_link.y);
	for (var i = 0; i < argument2; i++) {
		var a = ang + (i - (argument2 - 1) / 2) * argument3;
		var s = desert_shot(argument0 + lengthdir_x(8, a), argument1 - 24 + lengthdir_y(8, a), a, SPHINX_SHOT_DAMAGE, 0, 0);
		s.speed = argument5;
		s.fake = argument4;
	}


}

///sphinx_split();
function sphinx_split() {
	//It goes to one of its three spots at random, and copies of it stand on the other two
	with (obj_sphinx_mirage) {instance_destroy(id, false)}
	var spots = sphinx_spots();
	var real_spot = irandom(2);
	for (var i = 0; i < 3; i++) {
		if (i == real_spot) {
			x = spots[i][0];
			y = spots[i][1];
		} else {
			var m = instance_create_depth(spots[i][0], spots[i][1], depth, obj_sphinx_mirage);
			m.master = id;
		}
	}
	instance_create_depth(x, y - 20, depth - 1, obj_enemy_death);


}

///sphinx_quake();
function sphinx_quake() {
	//The cracked tiles nearest Link fall away for a while
	if (!instance_exists(obj_link)) return;
	var lx = obj_link.x;
	var ly = obj_link.y;
	var list = ds_priority_create();
	var az = arena_zone;
	with (obj_crumble) {
		if (state == "whole" && (az == noone || cam_zone_at(x + 8, y + 8) == az)) {
			ds_priority_add(list, id, point_distance(x + 8, y + 8, lx, ly) + random(24));
		}
	}
	var n = 0;
	while (!ds_priority_empty(list) && n < SPHINX_QUAKE_TILES) {
		var c = ds_priority_delete_min(list);
		with (c) {crumble_now(CRUMBLE_QUAKE_BACK)}
		n++;
	}
	ds_priority_destroy(list);


}

///sphinx_step();
function sphinx_step() {
	//Run by obj_sphinx's Step after the shared enemy logic
	var phase = sphinx_phase();

	//Hurt while bowed: recoil, then (phase 2 on) split up again
	if (hp < hp_last) {
		hp_last = hp;
		sphinx_set("hurt", 24);
		sfx_play(SFX_SPHINX);
	}

	timer--;
	switch (state) {
		case "dormant":
			if (arena_zone == noone || (global.cam_zone == arena_zone && !global.cam_transition)) {
				wake++;
				if (wake == 30) {
					sfx_play(SFX_SPHINX);
					if (!flag_get(SPHINX_INTRO_FLAG)) {
						flag_set(SPHINX_INTRO_FLAG, true);
						dialogue_start([
							"SAHRAN, THE MIRAGE SPHINX, GUARDIAN OF LADHELLIN'S SUN, OPENS ITS EYES!",
							"WHEN IT SLAMS THE GROUND A WAVE OF SAND ROLLS OUT. JUMP IT WITH YOUR CAPE! STRIKE ITS FACE WHILE IT BOWS."
						]);
					}
				}
				if (wake >= 50) {sphinx_set("sit", 40)}
			}
			break;

		case "sit":
			if (timer <= 0) {
				cycle++;
				if (phase == 3 && cycle mod 2 == 0) {
					sphinx_set("quake", 36);
					sfx_play(SFX_SPHINX);
				} else if (cycle mod 3 == 0) {
					sphinx_set("shoot", 48);
				} else {
					sphinx_set("raise", SPHINX_RAISE_TIME - (phase - 1) * 4);
				}
			}
			break;

		case "raise":
			if (timer <= 0) {
				sphinx_set("slam", 8);
				sfx_play(SFX_QUAKE);
				sphinx_wave(x, y, false);
				with (obj_sphinx_mirage) {sphinx_wave(x, y, true)}
			}
			break;

		case "slam":
			if (timer <= 0) {sphinx_set("bow", SPHINX_BOW_TIME - (phase - 1) * 12)}
			break;

		case "bow":
			if (timer <= 0) {sphinx_set("sit", irandom_range(40, 70) - phase * 8)}
			break;

		case "shoot":
			if (timer == 34 || (phase >= 2 && timer == 16)) {
				var n = (phase == 1) ? 3 : 5;
				var sp = (phase == 3) ? 2.8 : 2.3;
				sphinx_shoot(x, y, n, 20, false, sp);
				with (obj_sphinx_mirage) {sphinx_shoot(x, y, n, 20, true, sp)}
				sfx_play(SFX_FIREBALL);
			}
			if (timer <= 0) {sphinx_set("sit", 30)}
			break;

		case "quake":
			if (timer == 12) {
				sfx_play(SFX_QUAKE);
				sphinx_quake();
				sphinx_wave(x, y, false);
				with (obj_sphinx_mirage) {sphinx_wave(x, y, true)}
			}
			if (timer <= 0) {sphinx_set("bow", SPHINX_BOW_TIME - 30)}
			break;

		case "hurt":
			if (timer <= 0) {
				if (sphinx_phase() >= 2) {
					if (!flag_get(SPHINX_SPLIT_FLAG)) {
						flag_set(SPHINX_SPLIT_FLAG, true);
						dialogue_start(["THE SPHINX SHIMMERS AND SPLITS INTO THREE! ONLY ONE IS REAL... IF ONLY YOU COULD SEE THROUGH THE HAZE."]);
					}
					sphinx_set("split", 30);
				} else {
					sphinx_set("sit", 30);
				}
			}
			break;

		case "split":
			if (timer == 15) {sphinx_split()}
			if (timer <= 0) {sphinx_set("sit", 40)}
			break;
	}
	anim_t += 0.1;
	image_index = sphinx_frame();


}

///sphinx_frame();
function sphinx_frame() {
	//0 sitting, 1 paws up, 2 slam, 3 bowed (gem glowing), 4 mouth open, 5 hurt
	switch (state) {
		case "raise": return 1;
		case "slam": return 2;
		case "bow": return 3;
		case "shoot": return (timer < 40) ? 4 : 0;
		case "quake": return (timer > 12) ? 1 : 2;
		case "hurt": return 5;
	}
	return 0;


}

///sphinx_draw();
function sphinx_draw() {
	//Run by obj_sphinx's Draw (and its copies'): fading out and in as it splits, shaking when hurt
	var a = image_alpha;
	if (state == "split") {a = abs(timer - 15) / 15}
	if (state == "dormant") {a = 1}
	var bx = x;
	if (state == "hurt" || state == "raise") {bx += choose(-1, 0, 1)}
	draw_sprite_ext(sprite_index, image_index, bx, y, 1, 1, 0, image_blend, a);
	//The glowing gem on its brow while it bows (the target)
	if (state == "bow" && (current_time div 150) mod 2 == 0) {
		draw_sprite_ext(spr_pixel, 0, bx - 2, y - 22, 4, 3, 0, c_white, 0.7 * a);
	}


}

//================================================================ the copies

///sphinx_mirage_step();
function sphinx_mirage_step() {
	//Run by obj_sphinx_mirage: does what the real one does (it's only haze)
	if (!instance_exists(master)) {
		instance_destroy();
		return;
	}
	state = master.state;
	timer = master.timer;
	image_index = master.image_index;


}

///sphinx_mirage_draw();
function sphinx_mirage_draw() {
	//Just like the real one, but under the lens it's thin purple haze
	if (lens_active()) {
		draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, 0, make_colour_rgb(174, 118, 255), 0.3);
		return;
	}
	sphinx_draw();


}

//================================================================ the sand wave

///sand_wave_step();
function sand_wave_step() {
	//Run by obj_sand_wave: a ring of sand rolling out. Link on the ground under it gets hurt.
	r += SPHINX_WAVE_SPEED;
	if (r > max_r) {
		instance_destroy();
		return;
	}
	if (fake || !instance_exists(obj_link)) return;
	with (obj_link) {
		//The ring is squashed (flat on the floor): measure in its shape
		var dx = x - other.x;
		var dy = (y - other.y) / 0.75;
		var d = sqrt(dx * dx + dy * dy);
		if (abs(d - other.r) <= SPHINX_WAVE_BAND && z < SPHINX_WAVE_CLEAR && state != "jump" && state != "fall" && state != "land") {
			player_hurt(SPHINX_WAVE_DAMAGE, other.x, other.y);
		}
	}


}

///sand_wave_draw();
function sand_wave_draw() {
	//A ring of sand clumps (a mirage's ring is see-through under the lens)
	var a = (fake && lens_active()) ? 0.15 : 1;
	var n = max(16, round(r * 0.9));
	for (var i = 0; i < n; i++) {
		var ang = i * 360 / n;
		var px = round(x + lengthdir_x(r, ang));
		var py = round(y + lengthdir_y(r * 0.75, ang));
		draw_sprite_ext(spr_pixel, 0, px - 1, py - 2, 3, 2, 0, make_colour_rgb(232, 208, 170), a);
		draw_sprite_ext(spr_pixel, 0, px - 1, py, 3, 1, 0, make_colour_rgb(111, 63, 0), a);
	}


}
