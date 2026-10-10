//The castle's mini-boss: Velrune, Archmage of the Sapphire Order (obj_archmage), in the Archmage's
//study on 4F. He guards the way to the boss key. Two "clear" shutters keep Link in with him.
//
//A ward of sapphire light turns every blade, arrow and bomb. He blinks between the corners of the
//room and casts:
//	a volley		five sapphire bolts in a fan (the big shield blocks them; bounced back with the
//					mirror shield they hurt him a little, through the ward)
//	a great orb		(obj_king_orb) only the mirror shield can turn it. Bounced back into him it breaks
//					the ward: he's dizzy for a while and the sword can hurt him (ARCH_DIZZY_HITS hits)
//Once he's beaten the flag ARCHMAGE_FLAG keeps him gone.
//States: "wait", "float", "volley", "orb", "out", "in", "dizzy".

#macro ARCH_HP 24
#macro ARCH_DAMAGE 3
#macro ARCH_ORB_DAMAGE 4
#macro ARCH_ORB_HIT 4			//what his own orb does to him
#macro ARCH_BOLT_HIT 1			//...and one of his small bolts
#macro ARCH_DIZZY_TIME 100
#macro ARCH_DIZZY_HITS 3
#macro ARCH_FLAG "archmage_beaten"
#macro ARCH_INTRO_FLAG "archmage_seen"

///archmage_create();
function archmage_create() {
	if (flag_get(ARCH_FLAG) && !rush_wants(obj_archmage)) {	//(the Hall of Echoes brings him back)
		instance_destroy(id, false);
		return;
	}
	is_boss = true;
	drops = false;
	tier_done = true;
	hp = ARCH_HP;
	hp_max = ARCH_HP;
	hp_last = hp;
	kb_speed = 0;
	level = 0;
	depth = DEPTH_LOWER - 4;
	alpha = 1;
	anim_t = 0;
	cycle = 0;
	dizzy_hits = 0;
	zone = noone;
	home_x = x;
	home_y = y;
	image_speed = 0;
	magic_hit = archmage_magic_hit;
	archmage_set("wait", 0);


}

///archmage_set(state, timer);
function archmage_set(argument0, argument1) {
	state = argument0;
	timer = argument1;
	var dizzy = (state == "dizzy");
	invulnerable = !dizzy;
	can_touch = (state != "wait" && state != "out");
	contact_damage = (dizzy || !can_touch) ? 0 : ARCH_DAMAGE;


}

///archmage_spots();
function archmage_spots() {
	//The four corners of what Link can see of his room, and its middle (top half)
	var z = zone;
	if (z == noone || !instance_exists(z)) return [[home_x, home_y]];
	var v = castle_view_rect(36, 52, 20);
	var l = max(z.bbox_left + 40, v[0]);
	var r = min(z.bbox_right - 40, v[2]);
	var t = max(z.bbox_top + 64, v[1]);
	var b = min(z.bbox_bottom - 48, v[3]);
	if (r < l) {r = l}
	if (b < t) {b = t}
	return [[l, t], [r, t], [l, b], [r, b], [(l + r) / 2, t + 16]];


}

///archmage_magic_hit(damage, great);
function archmage_magic_hit(argument0, argument1) {
	//His own magic bounced back into him. A small bolt gets through his ward a little (ARCH_BOLT_HIT);
	//the great orb (great = true) breaks it: he's dizzy and the sword can hurt him.
	if (state == "wait" || state == "out") return;
	var was = invulnerable;
	invulnerable = false;
	enemy_hurt(id, argument1 ? argument0 : ARCH_BOLT_HIT, x, y - 10);
	if (!instance_exists(id)) return;
	hp_last = hp;		//the orb isn't one of the sword hits he takes while dizzy
	if (argument1) {
		dizzy_hits = 0;
		archmage_set("dizzy", ARCH_DIZZY_TIME);
		sfx_play(SFX_BOSS_ROAR);
	} else {
		invulnerable = was;
	}


}

///archmage_step();
function archmage_step() {
	if (zone == noone) {zone = cam_zone_at(home_x, home_y)}
	anim_t += 0.05;

	//Hit by the sword while dizzy
	if (hp < hp_last) {
		var lost = hp_last - hp;
		hp_last = hp;
		if (state == "dizzy") {
			dizzy_hits++;
			if (dizzy_hits >= ARCH_DIZZY_HITS) {archmage_set("out", 14)}
		}
	}

	timer--;
	switch (state) {
		case "wait":
			if (global.cam_zone == zone && !global.cam_transition) {
				if (!flag_get(ARCH_INTRO_FLAG)) {
					flag_set(ARCH_INTRO_FLAG, true);
					dialogue_start([
						"SO THE LITTLE KNIGHT HAS COME ALL THIS WAY.",
						"I AM VELRUNE, ARCHMAGE OF THE SAPPHIRE ORDER. MY WARD TURNS EVERY BLADE.",
						"...WHAT IS THAT ON YOUR ARM? A MIRROR? HOW QUAINT."
					]);
				}
				archmage_set("float", 30);
			}
			break;
		case "float":
			if (timer <= 0) {
				cycle++;
				if (cycle mod 3 == 0 || (hp <= hp_max / 2 && cycle mod 2 == 0)) {
					archmage_set("orb", 34);
				} else {
					archmage_set("volley", 26);
				}
				sfx_play(SFX_WIZ_CHARGE);
			}
			break;
		case "volley":
			if (timer <= 0) {
				if (instance_exists(obj_link)) {
					var ang = point_direction(x, y - 12, obj_link.x, obj_link.y);
					var n = (hp <= hp_max / 2) ? 7 : 5;
					for (var i = 0; i < n; i++) {
						var b = magic_bolt(x, y - 12, ang + (i - (n - 1) / 2) * 14, 0, WIZ_BOLT_DAMAGE, 2.1);
					}
					sfx_play(SFX_WIZ_CAST);
				}
				archmage_set("out", 14);
			}
			break;
		case "orb":
			if (timer <= 0) {
				if (instance_exists(obj_link)) {
					var o = king_orb(x + 8, y - 22, point_direction(x + 8, y - 22, obj_link.x, obj_link.y), ARCH_ORB_DAMAGE, ARCH_ORB_HIT);
					sfx_play(SFX_WIZ_CAST);
				}
				archmage_set("float", 50);
			}
			break;
		case "out":
			alpha = max(0, timer / 14);
			if (timer <= 0) {
				var spots = archmage_spots();
				var s = spots[irandom(array_length(spots) - 1)];
				x = s[0];
				y = s[1];
				sfx_play(SFX_WIZ_APPEAR);
				archmage_set("in", 14);
			}
			break;
		case "in":
			alpha = 1 - max(0, timer / 14);
			if (timer <= 0) {
				alpha = 1;
				archmage_set("float", irandom_range(20, 40));
			}
			break;
		case "dizzy":
			if (timer <= 0) {archmage_set("out", 14)}
			break;
	}

	switch (state) {
		case "volley": case "orb": image_index = 2; break;
		case "dizzy": image_index = 3; break;
		default: image_index = floor(anim_t * 4) mod 2; break;
	}


}

///archmage_draw();
function archmage_draw() {
	if (state == "wait" && alpha <= 0) return;
	draw_sprite_ext(spr_pixel, 0, x - 7, y + 6, 14, 3, 0, c_black, 0.35 * alpha);
	var col = image_blend;
	if ((state == "volley" || state == "orb") && (timer div 3) mod 2 == 0) {col = make_colour_rgb(255, 255, 200)}
	var bob = (state == "dizzy") ? 0 : round(sin(anim_t * 3) * 1.5);
	draw_sprite_ext(sprite_index, image_index, x, y - 2 + bob, 1, 1, 0, col, alpha);
	//His ward: a ring of light round him while he can't be hurt
	if (invulnerable && state != "out" && state != "wait") {
		draw_set_alpha(0.35 * alpha);
		draw_set_colour(make_colour_rgb(105, 158, 252));
		draw_ellipse(x - 14, y - 34, x + 14, y + 8, true);
		draw_set_alpha(1);
		draw_set_colour(c_white);
	}
	//The great orb gathering over his staff
	if (state == "orb") {
		var s = 1 - timer / 34;
		draw_sprite_ext(spr_king_orb, (current_time div 100) mod 2, x + 9, y - 30, s, s, 0, c_white, 1);
	}


}

///archmage_destroy();
function archmage_destroy() {
	//Run by obj_archmage's Destroy: beaten for good
	flag_set(ARCH_FLAG, true);
	for (var i = 0; i < 6; i++) {
		instance_create_depth(x - 12 + irandom_range(-12, 12), y - 24 + irandom_range(-12, 12), depth - 1, obj_enemy_death);
	}
	sfx_play(SFX_BOSS_DEFEAT);
	with (obj_magic_bolt) {instance_destroy()}
	with (obj_king_orb) {instance_destroy()}
	dialogue_start(["VELRUNE: IMPOSSIBLE... A BOY WITH A MIRROR... THE KING WILL... NOT BE SO... KIND..."]);


}
