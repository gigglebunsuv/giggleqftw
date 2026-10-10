//The Castle of Bunsriel's enemies: the Sapphire Order's wizards and the royal knights.
//
//Wizards (obj_wizard_*, children of obj_enemy): they blink in somewhere in their room, float for a
//moment, glow while they gather a spell (the warning), cast it, then blink out and come back
//somewhere else. Hitting one sends it away early. Only while they're there can they be hurt.
//	adept (blue)		a sapphire bolt at Link
//	fire (red)			three fire bolts in a fan
//	ice (white)			an ice bolt: hitting Link slows him down for a moment (chill_timer)
//	storm (violet)		calls lightning down on Link: a ring follows him, stops, then the bolt strikes.
//						It can't be blocked; it hurts enemies standing under it too.
//	summoner (magenta)	calls up bats and skeletons through circles on the floor (up to 3 at a time)
//The bolts (obj_magic_bolt) need the big shield (tier 2) to block; the mirror shield (tier 3) bounces
//them back, and a bounced bolt hurts whatever enemy it hits (WIZ_REFLECT_DAMAGE, through any armour).
//
//Knights (obj_knight): slow, heavy, a tall shield that turns the sword, arrows and bombs from the front.
//They turn to face Link, but slowly: get round them, or stun them with the boomerang (the shield drops).
//
//Castle enemies are made for the castle, so they set tier_done = true (no extra toughness, see enemy_tier_apply).

#macro WIZ_DAMAGE 2				//touching a wizard
#macro WIZ_FADE 14				//steps to blink in or out
#macro WIZ_WINDUP 24			//steps of glowing before a spell (the warning)
#macro WIZ_NEAR 56				//it comes back at least this far from Link...
#macro WIZ_FAR 120				//...and at most this far
#macro WIZ_BOLT_SPEED 2.2
#macro WIZ_BOLT_DAMAGE 2
#macro WIZ_REFLECT_DAMAGE 6
#macro WIZ_CHILL_TIME 75		//steps an ice bolt slows Link down
#macro WIZ_STORM_FOLLOW 20		//steps the lightning's ring follows Link...
#macro WIZ_STORM_STRIKE 40		//...and when it strikes
#macro WIZ_STORM_DAMAGE 4
#macro WIZ_STORM_RADIUS 12
#macro WIZ_SUMMON_MAX 3
#macro WIZ_SUMMON_TIME 30		//steps a circle glows before something climbs out
#macro KNIGHT_HP 10
#macro KNIGHT_DAMAGE 3
#macro KNIGHT_SPEED 0.55
#macro KNIGHT_TURN 28			//steps between the knight's turns towards Link
#macro KNIGHT_SIGHT 140
#macro SFX_WIZ_APPEAR "snd_wizard_appear"	//a wizard blinking in (or out)
#macro SFX_WIZ_CHARGE "snd_wizard_charge"	//a wizard gathering a spell
#macro SFX_WIZ_CAST "snd_wizard_cast"		//a spell let go
#macro SFX_REFLECT "snd_reflect"			//the mirror shield bouncing magic back
#macro SFX_CHILL "snd_chill"				//Link hit by ice
#macro SFX_SUMMON "snd_summon"				//something called up through a circle

//================================================================ wizards

///wizard_create(kind, hp);
function wizard_create(argument0, argument1) {
	//Run by each wizard's Create (after event_inherited)
	kind = argument0;
	hp = argument1;
	hp_last = hp;
	contact_damage = 0;
	tier_done = true;
	level = 0;
	depth = DEPTH_LOWER;
	kb_speed = 2;
	zone = noone;
	alpha = 0;
	anim_t = random(2);
	image_speed = 0;
	target_x = x;		//the storm wizard's lightning
	target_y = y;
	summons = [];
	wizard_set("away", irandom_range(10, 40));


}

///wizard_set(state, timer);
function wizard_set(argument0, argument1) {
	state = argument0;
	timer = argument1;
	var there = (state == "idle" || state == "cast" || state == "after");
	can_touch = there;
	contact_damage = there ? WIZ_DAMAGE : 0;


}

///castle_view_rect(margin_x, margin_top, margin_bottom);
function castle_view_rect(argument0, argument1, argument2) {
	//[left, top, right, bottom] of the screen, pulled in by the margins: where a caster can stand
	//so Link can see it (the castle's big rooms are bigger than the screen)
	var cam = view_camera[0];
	var vx = camera_get_view_x(cam);
	var vy = camera_get_view_y(cam);
	return [vx + argument0, vy + argument1, vx + camera_get_view_width(cam) - argument0, vy + camera_get_view_height(cam) - argument2];


}

///wizard_spot();
function wizard_spot() {
	//Somewhere free in its room, not too near Link and not too far. [x, y], or its own spot if none.
	var z = zone;
	if (z == noone || !instance_exists(z) || !instance_exists(obj_link)) return [x, y];
	var best = [x, y];
	//On screen, inside its room
	var v = castle_view_rect(16, 36, 16);
	var l = max(z.bbox_left + 20, v[0]);
	var t = max(z.bbox_top + 44, v[1]);
	var r = min(z.bbox_right - 20, v[2]);
	var b = min(z.bbox_bottom - 20, v[3]);
	if (r <= l || b <= t) return best;
	for (var i = 0; i < 40; i++) {
		var px = random_range(l, r);
		var py = random_range(t, b);
		var d = point_distance(px, py, obj_link.x, obj_link.y);
		if (d < WIZ_NEAR || d > WIZ_FAR) continue;
		if (collision_rectangle(px - 7, py - 7, px + 7, py + 7, obj_wall, false, true) != noone) continue;
		if (collision_rectangle(px - 7, py - 7, px + 7, py + 7, obj_wall_low, false, true) != noone) continue;
		if (position_meeting(px, py, obj_pit) || position_meeting(px, py, obj_water)) continue;
		return [round(px), round(py)];
	}
	return best;


}

///wizard_step();
function wizard_step() {
	//Run by a wizard's Step after the shared enemy logic (and not while it's knocked back or stunned)
	if (zone == noone) {zone = cam_zone_at(x, y)}
	anim_t += 0.05;

	//Hurt: it blinks away
	if (hp < hp_last) {
		hp_last = hp;
		if (state != "vanish" && state != "away") {wizard_set("vanish", WIZ_FADE)}
	}

	timer--;
	switch (state) {
		case "away":
			alpha = 0;
			if (timer > 0) break;
			if (global.cam_zone != zone || !instance_exists(obj_link)) {
				timer = 20;
				break;
			}
			var spot = wizard_spot();
			x = spot[0];
			y = spot[1];
			wizard_set("appear", WIZ_FADE);
			sfx_play(SFX_WIZ_APPEAR);
			break;
		case "appear":
			alpha = 1 - timer / WIZ_FADE;
			if (timer <= 0) {wizard_set("idle", irandom_range(16, 40))}
			break;
		case "idle":
			alpha = 1;
			if (timer <= 0) {
				wizard_set("cast", WIZ_WINDUP);
				sfx_play(SFX_WIZ_CHARGE);
				if (instance_exists(obj_link)) {
					target_x = obj_link.x;
					target_y = obj_link.y;
				}
			}
			break;
		case "cast":
			alpha = 1;
			if (timer <= 0) {
				wizard_cast();
				wizard_set("after", 16);
			}
			break;
		case "after":
			if (timer <= 0) {
				//The adept sometimes casts again before it goes
				if (kind == "adept" && random(1) < 0.3) {wizard_set("idle", 12)}
				else {wizard_set("vanish", WIZ_FADE)}
			}
			break;
		case "vanish":
			alpha = max(0, timer / WIZ_FADE);
			if (timer <= 0) {
				sfx_play(SFX_WIZ_APPEAR);
				wizard_set("away", irandom_range(25, 60));
			}
			break;
	}

	if (state == "cast") {image_index = 2}
	else if (hurt_timer > 0) {image_index = 3}
	else {image_index = floor(anim_t * 4) mod 2}


}

///wizard_cast();
function wizard_cast() {
	if (!instance_exists(obj_link)) return;
	var hx = x;
	var hy = y - 10;
	var ang = point_direction(hx, hy, obj_link.x, obj_link.y);
	sfx_play(SFX_WIZ_CAST);
	switch (kind) {
		case "adept":
			magic_bolt(hx, hy, ang, 0, WIZ_BOLT_DAMAGE, WIZ_BOLT_SPEED);
			break;
		case "fire":
			for (var i = -1; i <= 1; i++) {magic_bolt(hx, hy, ang + i * 22, 1, WIZ_BOLT_DAMAGE, 1.9)}
			break;
		case "ice":
			magic_bolt(hx, hy, ang, 2, 1, 2.5);
			break;
		case "storm":
			var m = instance_create_depth(obj_link.x, obj_link.y, DEPTH_DECOR - 3, obj_lightning_mark);
			m.caster = id;
			break;
		case "summoner":
			//Forget the ones that are gone
			var keep = [];
			for (var i = 0; i < array_length(summons); i++) {
				if (instance_exists(summons[i])) {array_push(keep, summons[i])}
			}
			summons = keep;
			var n = min(2, WIZ_SUMMON_MAX - array_length(summons));
			for (var i = 0; i < n; i++) {
				var spot = wizard_spot();
				var c = instance_create_depth(spot[0], spot[1], DEPTH_DECOR - 2, obj_summon_circle);
				c.caster = id;
				c.what = (i == 0) ? obj_bat : obj_skeleton;
			}
			break;
	}


}

///wizard_draw();
function wizard_draw() {
	//Run by a wizard's Draw: fading in and out, its shadow, the glow of the spell it's gathering
	if (alpha <= 0) return;
	draw_sprite_ext(spr_pixel, 0, x - 5, y + 6, 10, 2, 0, c_black, 0.35 * alpha);
	var bob = round(sin(anim_t * 3) * 1);
	var col = image_blend;
	if (state == "cast" && (timer div 3) mod 2 == 0) {col = make_colour_rgb(255, 255, 200)}
	draw_sprite_ext(sprite_index, image_index, x, y - 2 + bob, 1, 1, 0, col, alpha);
	if (state == "cast") {
		//sparks drawn in towards its hands as the spell gathers
		var t = 1 - timer / WIZ_WINDUP;
		var r = 14 * (1 - t);
		for (var i = 0; i < 6; i++) {
			var a = current_time / 4 + i * 60;
			draw_sprite_ext(spr_pixel, 0, x + lengthdir_x(r, a) - 1, y - 14 + lengthdir_y(r, a) - 1, 2, 2, 0, c_white, 0.9);
		}
	}


}

//================================================================ bolts

///magic_bolt(x, y, angle, kind, damage, speed);
function magic_bolt(argument0, argument1, argument2, argument3, argument4, argument5) {
	//A wizard's bolt: kind 0 sapphire, 1 fire, 2 ice (slows Link down)
	var b = instance_create_depth(argument0, argument1, DEPTH_FLYING, obj_magic_bolt);
	b.direction = argument2;
	b.kind = argument3;
	b.image_index = argument3;
	b.damage = argument4;
	b.spd = argument5;
	b.speed = argument5;
	b.caster = id;
	b.level = 0;
	return b;


}

///magic_bolt_step();
function magic_bolt_step() {
	//Run by obj_magic_bolt: fly; the big shield stops it, the mirror shield sends it back
	if (feel_frozen()) {
		speed = 0;
		return;
	}
	speed = spd;
	life--;
	if (life <= 0 || level_wall_at(x, y, level)) {
		instance_create_depth(x - 12, y - 12, depth - 1, obj_enemy_death);
		instance_destroy();
		return;
	}

	if (reflected) {
		//Back the way it came: it hurts the first enemy it meets
		var e = instance_place(x, y, obj_enemy);
		if (e != noone && e.can_touch && (e.level == -1 || e.level == level)) {
			enemy_magic_hit(e, WIZ_REFLECT_DAMAGE, x, y);
			instance_destroy();
		}
		return;
	}

	if (!instance_exists(obj_link) || !place_meeting(x, y, obj_link) || obj_link.level != level) return;
	var from = direction + 180;
	if (shield_blocks(from, 3)) {
		//The mirror shield: straight back at whoever cast it
		reflected = true;
		image_index = 3;
		spd = max(spd, 3);
		if (instance_exists(caster)) {direction = point_direction(x, y, caster.x, caster.y - 10)}
		else {direction = from}
		sfx_play(SFX_REFLECT);
		feel_hitstop(2);
		return;
	}
	if (shield_blocks(from, shield_tier)) {
		sfx_play(SFX_SHIELD);
		instance_destroy();
		return;
	}
	player_hurt(damage, x, y);
	if (kind == 2) {
		with (obj_link) {chill_timer = WIZ_CHILL_TIME}
		sfx_play(SFX_CHILL);
	}
	instance_destroy();


}

///enemy_magic_hit(enemy, damage, from_x, from_y);
function enemy_magic_hit(argument0, argument1, argument2, argument3) {
	//Bounced-back magic (or lightning): it gets through any armour (the knights' shields).
	//The Archmage and the Evil King decide for themselves (their magic_hit: only the great orb breaks their wards).
	with (argument0) {
		if (variable_instance_exists(id, "magic_hit")) {
			magic_hit(argument1, false);
		} else {
			var was = invulnerable;
			invulnerable = false;
			enemy_hurt(id, argument1, argument2, argument3);
			if (instance_exists(id)) {invulnerable = was}
		}
	}


}

//================================================================ lightning

///lightning_mark_step();
function lightning_mark_step() {
	//Run by obj_lightning_mark: the ring follows Link, stops, then the bolt comes down
	if (feel_frozen()) return;
	timer++;
	if (timer < WIZ_STORM_FOLLOW && instance_exists(obj_link)) {
		x = lerp(x, obj_link.x, 0.25);
		y = lerp(y, obj_link.y, 0.25);
	}
	if (timer == WIZ_STORM_STRIKE) {
		depth = DEPTH_FLYING;	//the bolt comes down over everything
		sfx_play(SFX_THUNDER);
		feel_shake(2, 8);
		var mx = x;
		var my = y;
		with (obj_link) {
			if (point_distance(x, y, mx, my) <= WIZ_STORM_RADIUS && z < 4 && state != "jump" && state != "fall") {
				player_hurt(WIZ_STORM_DAMAGE, mx, my);
			}
		}
		var who = caster;
		with (obj_enemy) {
			if (id != who && can_touch && point_distance(x, y, mx, my) <= WIZ_STORM_RADIUS) {enemy_magic_hit(id, WIZ_STORM_DAMAGE, mx, my)}
		}
	}
	if (timer >= WIZ_STORM_STRIKE + 10) {instance_destroy()}


}

///lightning_mark_draw();
function lightning_mark_draw() {
	if (timer < WIZ_STORM_STRIKE) {
		//Blinks faster as it's about to strike
		var rate = (timer > WIZ_STORM_STRIKE - 14) ? 2 : 5;
		draw_sprite(spr_target_ring, (timer div rate) mod 2, x, y);
	} else {
		draw_sprite(spr_lightning, (timer div 2) mod 2, x, y);
	}


}

//================================================================ summoning

///summon_circle_step();
function summon_circle_step() {
	//Run by obj_summon_circle: glows, then something climbs out of it (and is the summoner's)
	if (feel_frozen()) return;
	timer++;
	image_index = (timer div 4) mod 2;
	if (timer == WIZ_SUMMON_TIME) {
		var e = instance_create_depth(x, y, DEPTH_LOWER, what);
		if (what == obj_bat) {e.depth = DEPTH_FLYING}
		instance_create_depth(x - 12, y - 12, depth - 1, obj_enemy_death);
		sfx_play(SFX_SUMMON);
		if (instance_exists(caster)) {array_push(caster.summons, e)}
		instance_destroy();
	}


}

//================================================================ knights

///knight_step();
function knight_step() {
	//Run by obj_knight's Step after the shared enemy logic: walk at Link, shield up in front
	if (!instance_exists(obj_link)) return;
	var to = point_direction(x, y, obj_link.x, obj_link.y);
	var sees = enemy_can_see_link(KNIGHT_SIGHT);

	//Turns towards Link every so often (that's the opening to get round it)
	turn_t--;
	if (turn_t <= 0) {
		turn_t = KNIGHT_TURN;
		if (sees) {face = enemy_dir4(to)}
	}
	walking = false;
	if (sees) {
		var ang = face;
		if (abs(angle_difference(face, to)) < 50) {ang = to}
		walking = true;
		if (level_move(lengthdir_x(KNIGHT_SPEED, ang), lengthdir_y(KNIGHT_SPEED, ang), level)) {turn_t = min(turn_t, 6)}
	} else {
		//Pacing about
		walking = true;
		if (level_move(lengthdir_x(KNIGHT_SPEED * 0.6, face), lengthdir_y(KNIGHT_SPEED * 0.6, face), level)) {face = (face + 180) mod 360}
	}
	if (walking) {anim_t += 0.1}
	image_index = enemy_face_frame(face, floor(anim_t));


}

///knight_guard();
function knight_guard() {
	//Run by obj_knight before the shared enemy logic: from the front its shield turns everything
	//(not while the boomerang has it stunned)
	if (!instance_exists(obj_link)) {
		invulnerable = false;
		return;
	}
	var to = point_direction(x, y, obj_link.x, obj_link.y);
	invulnerable = (stun_timer <= 0) && abs(angle_difference(face, to)) <= 60;


}
