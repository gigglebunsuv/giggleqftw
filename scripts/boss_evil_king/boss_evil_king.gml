//The final boss: the Evil King, head of the Sapphire Order (obj_evil_king), in the throne room on
//the Castle of Bunsriel's 5F (obj_boss_arena with boss_object = obj_evil_king; final = true).
//
//He waits on his throne, speaks, then rises into the air. A barrier of sapphire light turns
//everything while he floats. He blinks between three spots across the top of the room and casts:
//	the great orb		(obj_king_orb) only the mirror shield can turn it. Sent back into him it
//						breaks his barrier: he drops to the floor, dizzy, and the sword can hurt him
//						(KING_DIZZY_HITS hits). The orb itself hurts him too.
//	a volley			a fan of sapphire bolts (the big shield blocks them)
//	Phase 2 (below 2/3)	he splits: two shadows (obj_king_shadow) stand on the other spots and cast
//						with him. Their orbs are real, but sending one back only pops a shadow.
//						The Sun Lens shows which one is really him.
//	Phase 3 (below 1/3)	lightning (obj_lightning_mark) chases Link, he calls up two adepts (once),
//						and sometimes he bats his own orb back (send it back again!)
//Beaten: obj_king_defeat plays his last words, the castle shakes, and the ending (rm_ending) starts.
//States: "throne", "rise", "idle", "orb", "volley", "storm", "summon", "out", "in", "dizzy".

#macro KING_HP 48
#macro KING_DAMAGE 4
#macro KING_ORB_DAMAGE 4
#macro KING_ORB_HIT 6			//what his own orb does to him
#macro KING_DIZZY_TIME 110
#macro KING_DIZZY_HITS 3
#macro KING_FLY_Z 18			//how high he floats
#macro KING_SPOT_DX 88			//his three spots: the middle top, and this far left and right (a bit lower)
#macro KING_SPOT_DY 24
#macro KING_BAT_CHANCE 0.35		//phase 3: the chance he sends a bounced orb back again
#macro KING_INTRO_FLAG "king_seen"
#macro KING_SPLIT_FLAG "king_split_seen"
#macro SFX_KING_LAUGH "snd_king_laugh"	//the Evil King laughing (rising, splitting)

///king_create();
function king_create() {
	is_boss = true;
	drops = false;
	tier_done = true;
	hp = KING_HP;
	hp_max = KING_HP;
	hp_last = hp;
	kb_speed = 0;
	level = -1;			//floats: on any level
	depth = DEPTH_LOWER - 6;
	throne_x = x;
	throne_y = y;
	home_x = x;
	home_y = y + 72;	//the middle spot
	z = 0;
	alpha = 1;
	anim_t = 0;
	cycle = 0;
	dizzy_hits = 0;
	summoned = false;
	wake = 0;
	image_speed = 0;
	magic_hit = king_magic_hit;
	arena_zone = noone;
	arena_ready = false;
	king_set("throne", 0);


}

///king_phase();
function king_phase() {
	if (hp > hp_max * 2 / 3) return 1;
	if (hp > hp_max / 3) return 2;
	return 3;


}

///king_set(state, timer);
function king_set(argument0, argument1) {
	state = argument0;
	timer = argument1;
	var dizzy = (state == "dizzy");
	invulnerable = !dizzy;
	can_touch = (state != "throne" && state != "rise" && state != "out");
	contact_damage = dizzy ? 0 : KING_DAMAGE;
	if (!can_touch) {contact_damage = 0}


}

///king_spots();
function king_spots() {
	//His three spots: across the top of the screen (the throne room is taller than the screen),
	//kept inside the room and clear of its north wall
	var cx = home_x;
	var ty = home_y;
	if (arena_zone != noone && instance_exists(arena_zone)) {
		var v = castle_view_rect(0, 0, 0);
		var z = arena_zone;
		cx = clamp((v[0] + v[2]) / 2, z.bbox_left + KING_SPOT_DX + 24, z.bbox_right - KING_SPOT_DX - 24);
		ty = clamp(v[1] + 72, z.bbox_top + 100, z.bbox_bottom - 64);	//(his orb starts 52 above him: clear of the wall)
	}
	return [[cx, ty], [cx - KING_SPOT_DX, ty + KING_SPOT_DY], [cx + KING_SPOT_DX, ty + KING_SPOT_DY]];


}

///king_magic_hit(damage, great);
function king_magic_hit(argument0, argument1) {
	//His own magic sent back into him. Only the great orb (great = true) gets through his barrier:
	//it hurts him and he falls, dizzy. Small bolts and lightning just ring off it.
	if (state == "dizzy" || state == "throne" || state == "rise") return;
	if (!argument1) {
		if (clink_timer <= 0) {
			sfx_play(SFX_SHIELD);
			clink_timer = 15;
		}
		return;
	}
	invulnerable = false;
	enemy_hurt(id, argument0, x, y - 20);
	if (!instance_exists(id)) return;
	hp_last = hp;		//the orb isn't one of the sword hits he takes while dizzy
	dizzy_hits = 0;
	with (obj_king_shadow) {instance_destroy()}
	king_set("dizzy", KING_DIZZY_TIME);
	sfx_play(SFX_BOSS_ROAR);


}

///king_step();
function king_step() {
	//Run by obj_evil_king's Step after the shared enemy logic
	var phase = king_phase();
	anim_t += 0.05;

	//Hurt by the sword while dizzy
	if (hp < hp_last) {
		hp_last = hp;
		if (state == "dizzy") {
			dizzy_hits++;
			if (dizzy_hits >= KING_DIZZY_HITS) {king_set("out", 16)}
		}
	}

	//Floating up (and down to the floor when dizzy)
	var want_z = (state == "dizzy" || state == "throne") ? 0 : KING_FLY_Z;
	z += clamp(want_z - z, -2, 1);

	timer--;
	switch (state) {
		case "throne":
			if (arena_zone == noone || (global.cam_zone == arena_zone && !global.cam_transition)) {
				wake++;
				if (wake == 40) {
					if (!flag_get(KING_INTRO_FLAG)) {
						flag_set(KING_INTRO_FLAG, true);
						dialogue_start([
							"SO. THE LAST LITTLE KNIGHT OF HAVEN.",
							"YOU FREED MY TOWERS. YOU TOOK BACK THE BUN. YOU EVEN PULLED ITS SWORD FROM THE STONE.",
							"AND STILL YOU ARE NOTHING BUT A BOY WITH A MIRROR.",
							"COME THEN, SIR GIGGLEBUNS. LET US SEE WHOSE LIGHT IS STRONGER!"
						]);
					}
				}
				if (wake >= 60) {
					king_set("rise", 40);
					sfx_play(SFX_KING_LAUGH);
				}
			}
			break;
		case "rise":
			//Up off the throne and out to the middle of the room
			x = lerp(x, home_x, 0.06);
			y = lerp(y, home_y, 0.06);
			if (timer <= 0) {
				x = home_x;
				y = home_y;
				king_set("idle", 30);
			}
			break;
		case "idle":
			if (timer <= 0) {
				cycle++;
				if (phase == 3 && !summoned) {
					summoned = true;
					king_set("summon", 40);
				} else if (phase == 3 && cycle mod 3 == 0) {
					king_set("storm", 100);
				} else if ((cycle mod 3 == 1) || (phase == 1 && cycle mod 2 == 0)) {
					king_set("volley", 28);
					sfx_play(SFX_WIZ_CHARGE);
				} else {
					king_set("orb", 40);
					sfx_play(SFX_WIZ_CHARGE);
				}
			}
			break;
		case "orb":
			with (obj_king_shadow) {casting = true}
			if (timer <= 0) {
				king_cast_orb(id);
				with (obj_king_shadow) {
					casting = false;
					king_cast_orb(id);
				}
				king_set("idle", 60);
			}
			break;
		case "volley":
			if (timer <= 0) {
				if (instance_exists(obj_link)) {
					var ang = point_direction(x, y - 20 - z, obj_link.x, obj_link.y);
					var n = (phase == 1) ? 5 : 7;
					for (var i = 0; i < n; i++) {magic_bolt(x, y - 20 - z, ang + (i - (n - 1) / 2) * 13, 0, WIZ_BOLT_DAMAGE, 2.2)}
					sfx_play(SFX_WIZ_CAST);
				}
				king_set("out", 16);
			}
			break;
		case "storm":
			//Three strikes chasing Link
			if (timer == 90 || timer == 60 || timer == 30) {
				if (instance_exists(obj_link)) {
					var m = instance_create_depth(obj_link.x, obj_link.y, DEPTH_DECOR - 3, obj_lightning_mark);
					m.caster = id;
				}
				sfx_play(SFX_WIZ_CAST);
			}
			if (timer <= 0) {king_set("out", 16)}
			break;
		case "summon":
			if (timer == 20) {
				dialogue_start(["THE ORDER, TO ME!"]);
				var spots = king_spots();
				for (var i = 1; i <= 2; i++) {
					var c = instance_create_depth(spots[i][0], spots[i][1] + 32, DEPTH_DECOR - 2, obj_summon_circle);
					c.caster = noone;
					c.what = obj_wizard_adept;
				}
			}
			if (timer <= 0) {king_set("idle", 40)}
			break;
		case "out":
			alpha = max(0, timer / 16);
			if (timer <= 0) {
				//Somewhere else (phase 2 on: with his shadows on the other two spots)
				var spots = king_spots();
				var pick = irandom(2);
				x = spots[pick][0];
				y = spots[pick][1];
				with (obj_king_shadow) {instance_destroy()}
				if (phase >= 2) {
					if (!flag_get(KING_SPLIT_FLAG)) {
						flag_set(KING_SPLIT_FLAG, true);
						dialogue_start(["THE EVIL KING LAUGHS... AND THERE ARE THREE OF HIM! ONLY ONE IS REAL. IF ONLY YOU COULD SEE THROUGH THE DARK."]);
					}
					for (var i = 0; i < 3; i++) {
						if (i == pick) continue;
						var s = instance_create_depth(spots[i][0], spots[i][1], depth, obj_king_shadow);
						s.master = id;
					}
					sfx_play(SFX_KING_LAUGH);
				}
				sfx_play(SFX_WIZ_APPEAR);
				king_set("in", 16);
			}
			break;
		case "in":
			alpha = 1 - max(0, timer / 16);
			if (timer <= 0) {
				alpha = 1;
				king_set("idle", irandom_range(20, 40) - phase * 4);
			}
			break;
		case "dizzy":
			if (timer <= 0) {king_set("out", 16)}
			break;
	}

	switch (state) {
		case "throne": image_index = 5; break;
		case "orb": case "volley": case "storm": case "summon": image_index = 2; break;
		case "dizzy": image_index = 3; break;
		default: image_index = floor(anim_t * 4) mod 2; break;
	}


}

///king_cast_orb(caster);
function king_cast_orb(argument0) {
	if (!instance_exists(obj_link)) return;
	with (argument0) {
		var ox = x + 9;
		var oy = y - 34 - z;
		var o = king_orb(ox, oy, point_direction(ox, oy, obj_link.x, obj_link.y), KING_ORB_DAMAGE, KING_ORB_HIT);
		o.caster = id;
	}
	sfx_play(SFX_WIZ_CAST);


}

///king_draw();
function king_draw() {
	//Run by obj_evil_king's Draw (and his shadows'): his shadow on the floor, him floating over it,
	//the barrier round him, the orb gathering in his hand
	var a = alpha * image_alpha;
	if (a <= 0) return;
	draw_sprite_ext(spr_pixel, 0, x - 9, y + 5, 18, 3, 0, c_black, 0.35 * a);
	var col = image_blend;
	if (object_index == obj_king_shadow) {
		col = make_colour_rgb(56, 55, 188);
		a *= lens_active() ? 0.25 : 0.85;
	}
	var dx = (state == "dizzy") ? choose(-1, 0, 1) : 0;
	var bob = (state == "dizzy" || state == "throne") ? 0 : round(sin(anim_t * 3) * 1.5);
	draw_sprite_ext(sprite_index, image_index, x + dx, y - z + bob, 1, 1, 0, col, a);
	if (invulnerable && state != "throne" && state != "out" && object_index == obj_evil_king) {
		draw_set_alpha(0.3 * a);
		draw_set_colour(make_colour_rgb(105, 158, 252));
		draw_ellipse(x - 20, y - z - 40, x + 20, y - z + 6, true);
		draw_ellipse(x - 19, y - z - 39, x + 19, y - z + 5, true);
		draw_set_alpha(1);
		draw_set_colour(c_white);
	}
	if (state == "orb" || (object_index == obj_king_shadow && casting)) {
		var s = clamp(1 - timer / 40, 0, 1);
		if (object_index == obj_king_shadow && instance_exists(master)) {s = clamp(1 - master.timer / 40, 0, 1)}
		draw_sprite_ext(spr_king_orb, (current_time div 100) mod 2, x + 9, y - 34 - z + bob, s, s, 0, c_white, a);
	}


}

//================================================================ his shadows

///king_shadow_step();
function king_shadow_step() {
	//Run by obj_king_shadow: copies the king's pose and height. Popped by his own orb sent back into it.
	if (!instance_exists(master)) {
		instance_destroy();
		return;
	}
	z = master.z;
	alpha = master.alpha;
	state = master.state;
	timer = master.timer;
	image_index = master.image_index;
	anim_t = master.anim_t;


}

//================================================================ the great orb

///king_orb(x, y, angle, damage, hit);
function king_orb(argument0, argument1, argument2, argument3, argument4) {
	//The great orb (the king's, the archmage's): hit = what it does to the caster when sent back
	var o = instance_create_depth(argument0, argument1, DEPTH_FLYING - 2, obj_king_orb);
	o.direction = argument2;
	o.damage = argument3;
	o.hit = argument4;
	o.caster = id;
	return o;


}

///king_orb_step();
function king_orb_step() {
	//Run by obj_king_orb: only the mirror shield turns it. Sent back, it flies at whoever cast it.
	if (feel_frozen()) {
		speed = 0;
		return;
	}
	speed = spd;
	image_index = (current_time div 100) mod 2;
	life--;
	if (life <= 0 || x < 0 || y < 0 || x > room_width || y > room_height || position_meeting(x, y, obj_wall)) {
		instance_create_depth(x - 12, y - 12, depth, obj_enemy_death);
		instance_destroy();
		return;
	}

	if (reflected) {
		//Into the one who cast it (or a shadow in the way)
		var t = noone;
		var ox = x;
		var oy = y;
		with (obj_king_shadow) {
			if (point_distance(ox, oy, x, y - 20 - z) < 16) {t = id}
		}
		if (t == noone && instance_exists(caster) && point_distance(x, y, caster.x, caster.y - 20 - caster_z()) < 16) {t = caster}
		if (t == noone) return;
		if (t.object_index == obj_king_shadow) {
			instance_create_depth(t.x - 12, t.y - 32, depth, obj_enemy_death);
			with (t) {instance_destroy()}
			sfx_play(SFX_ENEMY_DIE);
			instance_destroy();
			return;
		}
		//Phase 3: the king may swat it back
		if (t.object_index == obj_evil_king && king_phase_of(t) == 3 && bounces < 2 && random(1) < KING_BAT_CHANCE) {
			bounces++;
			reflected = false;
			spd += 0.5;
			if (instance_exists(obj_link)) {direction = point_direction(x, y, obj_link.x, obj_link.y)}
			sfx_play(SFX_REFLECT);
			return;
		}
		var hit_for = hit;
		with (t) {
			if (variable_instance_exists(id, "magic_hit")) {magic_hit(hit_for, true)}
		}
		instance_create_depth(x - 12, y - 12, depth, obj_enemy_death);
		instance_destroy();
		return;
	}

	if (!instance_exists(obj_link) || !place_meeting(x, y, obj_link)) return;
	if (shield_blocks(direction + 180, 3)) {
		reflected = true;
		spd = max(spd + 0.6, 3);
		var cz = caster_z();
		if (instance_exists(caster)) {direction = point_direction(x, y, caster.x, caster.y - 20 - cz)}
		else {direction += 180}
		sfx_play(SFX_REFLECT);
		feel_hitstop(3);
		feel_shake(1, 6);
		return;
	}
	player_hurt(damage, x, y);
	instance_create_depth(x - 12, y - 12, depth, obj_enemy_death);
	instance_destroy();


}

///caster_z();
function caster_z() {
	//Run by obj_king_orb: how high its caster floats (0 for the archmage)
	if (!instance_exists(caster)) return 0;
	if (variable_instance_exists(caster, "z")) return caster.z;
	return 0;


}

///king_phase_of(king);
function king_phase_of(argument0) {
	var p = 1;
	with (argument0) {p = king_phase()}
	return p;


}

//================================================================ beaten

///king_destroy();
function king_destroy() {
	//Run by obj_evil_king's Destroy: his last words and the ending (obj_king_defeat)
	with (obj_king_shadow) {instance_destroy()}
	with (obj_magic_bolt) {instance_destroy()}
	with (obj_king_orb) {instance_destroy()}
	with (obj_lightning_mark) {instance_destroy()}
	with (obj_summon_circle) {instance_destroy()}
	var d = instance_create_depth(x, y, -100, obj_king_defeat);	//over the overhead tiles (the flash covers everything)
	d.king_sprite = sprite_index;


}

///king_defeat_create();
function king_defeat_create() {
	timer = 0;
	phase = "kneel";
	flash = 0;
	fade = 0;
	audio_stop_all();
	options_volume_apply();
	sfx_play(SFX_BOSS_DEFEAT);
	with (obj_link) {
		state = "scene";
		pose = -1;
		shielding = false;
	}
	//The Order's servants vanish with him
	with (obj_enemy) {
		instance_create_depth(x - 12, y - 12, depth - 1, obj_enemy_death);
		instance_destroy(id, false);
	}


}

///king_defeat_step();
function king_defeat_step() {
	if (instance_exists(obj_dialogue)) return;
	with (obj_link) {state = "scene"}	//(a text box closing lets him go: not yet)
	timer++;
	switch (phase) {
		case "kneel":
			if (timer == 40) {
				dialogue_start([
					"N-NO... THE BUN'S LIGHT... IT BURNS...",
					"YOU THINK THIS IS THE END, LITTLE KNIGHT? THE ORDER WILL...",
					"...THE ORDER... WILL..."
				]);
				phase = "boom";
				timer = 0;
			}
			break;
		case "boom":
			if (timer mod 7 == 0) {
				instance_create_depth(x - 12 + irandom_range(-18, 18), y - 30 + irandom_range(-20, 14), depth - 1, obj_enemy_death);
				sfx_play(SFX_BOMB);
				feel_shake(2, 8);
			}
			flash = max(0, (timer - 60) / 40);
			if (timer >= 100) {
				flag_set(boss_flag(DUNGEON_CASTLE), true);
				phase = "white";
				timer = 0;
			}
			break;
		case "white":
			flash = 1;
			if (timer >= 40) {
				//In the Hall of Echoes' rush he was the last echo: back to the Hall, not the ending
				if (rush_active()) {rush_next()}
				else {ending_start()}
				instance_destroy();
			}
			break;
	}


}

///king_defeat_draw();
function king_defeat_draw() {
	if (phase == "kneel" || phase == "boom") {
		var dx = (phase == "boom") ? choose(-1, 0, 1) : 0;
		draw_sprite_ext(king_sprite, 4, x + dx, y, 1, 1, 0, c_white, (phase == "boom") ? max(0, 1 - timer / 90) : 1);
	}
	if (flash > 0) {
		var cam = view_camera[0];
		var vx = camera_get_view_x(cam);
		var vy = camera_get_view_y(cam);
		draw_set_alpha(min(1, flash));
		draw_set_colour(c_white);
		draw_rectangle(vx - 4, vy - 4, vx + camera_get_view_width(cam) + 4, vy + camera_get_view_height(cam) + 4, false);
		draw_set_alpha(1);
	}


}
