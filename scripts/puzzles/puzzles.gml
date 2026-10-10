//Puzzle pieces (most of them made for the Arcanum, the rods' dungeon: see the arcanum script) and
//the rods' tricks, which work anywhere in the game:
//	obj_push_block		a stone block. Keep walking into it and it slides one tile that way (not into
//						walls, holes, deep water, people or other blocks, and never out of its room).
//						It goes back where it started when Link leaves the room, so a block pushed
//						into a corner can always be tried again (the hint statues can put it back too).
//	obj_floor_switch	(see its Create) with hold = true it's only down while Link or a block is on it.
//						A shutter door with open_when = "switches" opens once every switch in one of
//						its rooms is down at the same time.
//	obj_ice_block		a block of ice: a fireball from the fire rod melts it (for good).
//	obj_burn_barrier	a wooden barricade (or a bramble out in the world): the fire rod burns it away.
//	obj_ice_floe		the ice rod's shot freezes a tile of deep water into a floe for a while: Link
//						(and a block) can stand on it. It flashes before it melts. Link without the
//						flippers goes under when it melts (and comes back where he last stood safely).
//	obj_current			deep water flowing one way (flow = 0, 90, 180 or 270): it carries a swimmer
//						along faster than he can swim against it. Floes over it don't move.
//	obj_flame_jet		a vent in the floor blowing fire (length tiles, the way dir points). On for good
//						(period = 0) or on and off. The ice rod's shot freezes it for a while.
//	obj_lightning_post	a metal post: the lightning rod's bolt charges it for a moment (the bolt goes
//						on through it). A shutter door with open_when = "posts" opens once every post in
//						one of its rooms is charged at the same time.
//	obj_hint_statue		a stone owl with a hint for its room (hint), and a plainer one (hint2) once
//						Link has been stuck in the room for HINT_STUCK_TIME. It can put the room's
//						blocks back where they started.
//	obj_magic_font		a basin of glowing water: talk to it to fill up the magic.
//The lightning rod also strikes crystal switches from afar and opens obj_world_gate with need = "lightning".

#macro PUSH_TIME 14				//steps of walking into a block before it moves
#macro PUSH_SPEED 1				//pixels a step it slides
#macro ICE_FLOE_TIME 600		//steps a floe lasts (30 steps = 1 second)
#macro ICE_FLOE_WARN 120		//...it flashes for the last of them
#macro FLAME_FREEZE_TIME 240	//steps a frozen flame jet stays out
#macro FLAME_DAMAGE 2			//half hearts (before armor)
#macro FLAME_SHOVE 2			//pixels a step a flame pushes Link back out of it
#macro POST_CHARGE_TIME 120		//steps a lightning post stays charged
#macro CURRENT_SPEED 2.25		//pixels a step a current carries a swimmer (swimming is 1.875)
#macro HINT_STUCK_TIME 5400		//steps in a room before its statue gives the plainer hint (3 minutes)
#macro SFX_PUSH "snd_push"		//a block sliding
#macro SFX_FREEZE "snd_freeze"	//water or a flame jet freezing
#macro SFX_MELT "snd_melt"		//ice melting
#macro SFX_ZAP "snd_zap"		//a lightning post charged
#macro SFX_BURN "snd_burn"		//a barricade or bramble burning away

//================================================================ push blocks

///push_block_create();
function push_block_create() {
	//Run by obj_push_block's Create
	home_x = x;
	home_y = y;
	moving = false;
	mdx = 0;
	mdy = 0;
	mleft = 0;
	push_t = 0;
	zone = noone;
	ready = false;
	depth = DEPTH_DECOR;
	image_speed = 0;


}

///push_block_step();
function push_block_step() {
	//Run by obj_push_block's Step: slide, sink, go home, get pushed
	if (!ready) {
		ready = true;
		zone = cam_zone_at(x + 8, y + 8);
	}
	if (moving) {
		x += mdx * PUSH_SPEED;
		y += mdy * PUSH_SPEED;
		mleft -= PUSH_SPEED;
		if (mleft <= 0) {
			moving = false;
			x = round(x / 16) * 16;
			y = round(y / 16) * 16;
		}
		return;
	}
	//Its floe melted: down it goes, and it's back where it started
	if (position_meeting(x + 8, y + 8, obj_water) && !position_meeting(x + 8, y + 8, obj_ice_floe)) {
		sfx_play(SFX_SPLASH);
		push_block_home();
		return;
	}
	//Link has left its room: back where it started
	if (zone != noone && instance_exists(zone) && global.cam_zone != zone && !global.cam_transition) {
		push_block_home();
		return;
	}
	if (instance_exists(obj_link) && !obj_link.carrying && door_link_pushing()) {
		push_t++;
		if (push_t >= PUSH_TIME) {
			push_t = 0;
			var ang = player_face_angle(obj_link.dir);
			var dx = round(lengthdir_x(1, ang));
			var dy = round(lengthdir_y(1, ang));
			if (push_block_free(x + dx * 16, y + dy * 16)) {
				moving = true;
				mdx = dx;
				mdy = dy;
				mleft = 16;
				sfx_play(SFX_PUSH);
			}
		}
	} else {
		push_t = 0;
	}


}

///push_block_home();
function push_block_home() {
	//Run by obj_push_block: back to where it was put in the room
	x = home_x;
	y = home_y;
	moving = false;
	push_t = 0;
	//Link was standing there: step him off onto the nearest free tile, not stuck inside the block
	if (instance_exists(obj_link) && place_meeting(x, y, obj_link)) {
		with (obj_link) {
			safe_x = x;
			safe_y = y;
			player_safe_ground();
			x = safe_x;
			y = safe_y;
			move_frac_x = 0;
			move_frac_y = 0;
		}
	}


}

///push_block_free(x, y);
function push_block_free(argument0, argument1) {
	//Run by obj_push_block: can it slide to this tile (its top left)?
	var tx = argument0;
	var ty = argument1;
	var cx = tx + 8;
	var cy = ty + 8;
	//Never out of its room (or into a doorway: the walls round a room are a tile thick, two at the top)
	if (zone != noone && instance_exists(zone)) {
		if (tx < zone.bbox_left + 16 || tx + 15 > zone.bbox_right - 16 || ty < zone.bbox_top + 32 || ty + 15 > zone.bbox_bottom - 16) return false;
	}
	if (collision_rectangle(tx + 1, ty + 1, tx + 14, ty + 14, obj_wall, false, true) != noone) return false;
	if (collision_rectangle(tx + 1, ty + 1, tx + 14, ty + 14, obj_wall_low, false, true) != noone) return false;
	if (collision_rectangle(tx + 1, ty + 1, tx + 14, ty + 14, obj_pit, false, true) != noone) return false;
	if (collision_rectangle(tx + 1, ty + 1, tx + 14, ty + 14, obj_enemy, false, true) != noone) return false;
	if (instance_exists(obj_link) && collision_rectangle(tx + 1, ty + 1, tx + 14, ty + 14, obj_link, false, true) != noone) return false;
	if (position_meeting(cx, cy, obj_water) && !position_meeting(cx, cy, obj_ice_floe)) return false;
	return true;


}

///push_blocks_home(zone);
function push_blocks_home(argument0) {
	//Every block in a camera zone back where it started (the hint statue's offer)
	var z = argument0;
	with (obj_push_block) {
		if (zone == z) {push_block_home()}
	}


}

///push_blocks_moved(zone);
function push_blocks_moved(argument0) {
	//True if any block in a camera zone isn't where it started
	var z = argument0;
	var moved = false;
	with (obj_push_block) {
		if (zone == z && (x != home_x || y != home_y)) {moved = true}
	}
	return moved;


}

//================================================================ floor switches

///switch_weighed();
function switch_weighed() {
	//Run by obj_floor_switch: Link standing on it (not in the air, not swimming), or a block resting on it
	if (instance_exists(obj_link) && position_meeting(obj_link.x, obj_link.y, id) && obj_link.z == 0 && !obj_link.swimming) return true;
	var b = collision_rectangle(x + 5, y + 5, x + 10, y + 10, obj_push_block, false, true);
	if (b != noone && !b.moving) return true;
	return false;


}

///zone_switches_all(zone);
function zone_switches_all(argument0) {
	//True when every obj_floor_switch in a camera zone is down at the same time (and it has at least one)
	var z = argument0;
	var n = 0;
	var down = 0;
	with (obj_floor_switch) {
		if (point_in_rectangle(x + 8, y + 8, z.bbox_left, z.bbox_top, z.bbox_right, z.bbox_bottom)) {
			n++;
			if (pressed) {down++}
		}
	}
	return n > 0 && down == n;


}

//================================================================ ice blocks and barricades

///ice_block_melt();
function ice_block_melt() {
	//Run by obj_ice_block when a fireball hits it: gone for good
	flag_set(door_flag(), true);
	sfx_play(SFX_MELT);
	instance_create_depth(x - 4, y - 4, depth - 1, obj_enemy_death);
	instance_destroy();


}

///burn_barrier_burn();
function burn_barrier_burn() {
	//Run by obj_burn_barrier when a fireball hits it: gone for good
	flag_set(door_flag(), true);
	sfx_play(SFX_BURN);
	instance_create_depth(x - 4, y - 4, depth - 1, obj_enemy_death);
	instance_destroy();


}

//================================================================ the rods' shots

///rod_shot_tricks();
function rod_shot_tricks() {
	//Run by obj_magic_shot every step (before it checks for walls). Returns true if the shot is used up.
	switch (kind) {
		case SHOT.FIRE:
			var ib = instance_place(x, y, obj_ice_block);
			if (ib != noone) {
				with (ib) {ice_block_melt()}
				return true;
			}
			var bb = instance_place(x, y, obj_burn_barrier);
			if (bb != noone) {
				with (bb) {burn_barrier_burn()}
				return true;
			}
			break;
		case SHOT.ICE:
			//A flame jet (its vent or its fire)
			var hit_jet = noone;
			var sx = x;
			var sy = y;
			with (obj_flame_jet) {
				if (flame_jet_touches(sx, sy)) {hit_jet = id}
			}
			if (hit_jet != noone) {
				with (hit_jet) {
					if (frozen_t <= 0) {sfx_play(SFX_FREEZE)}
					frozen_t = FLAME_FREEZE_TIME;
				}
				return true;
			}
			//Deep water (not already frozen, and nothing swimming in it): a floe
			if (position_meeting(x, y, obj_water) && !position_meeting(x, y, obj_ice_floe) && instance_position(x, y, obj_enemy) == noone) {
				ice_floe_make(x, y);
				return true;
			}
			break;
		case SHOT.LIGHTNING:
			var post = instance_place(x, y, obj_lightning_post);
			if (post != noone) {
				with (post) {
					if (charged_t <= 0) {sfx_play(SFX_ZAP)}
					charged_t = POST_CHARGE_TIME;
				}
			}
			var cs = instance_place(x, y, obj_crystal_switch);
			if (cs != noone) {
				with (cs) {
					if (!on) {
						on = true;
						image_index = 1;
						flag_set(door_flag(), true);
						sfx_play(SFX_SWITCH);
						instance_create_depth(x - 4, y - 4, depth - 1, obj_enemy_death);
					}
				}
				return true;
			}
			var gate = instance_place(x, y, obj_world_gate);
			if (gate != noone && gate.need == "lightning") {
				with (gate) {world_gate_open()}
				return true;
			}
			break;
	}
	return false;


}

///rod_enemy_damage(enemy, shot_kind, damage);
function rod_enemy_damage(argument0, argument1, argument2) {
	//Elemental weaknesses: some enemies take more from one of the rods
	var e = argument0;
	var o = e.object_index;
	switch (argument1) {
		case SHOT.FIRE:
			if (o == obj_wizard_ice) return argument2 * 3;		//the frost magus melts
			if (o == obj_spitter || o == obj_crow) return argument2 * 2;
			break;
		case SHOT.ICE:
			if (o == obj_wizard_fire) return argument2 * 4;		//the flame magus is put out
			if (o == obj_scorpion || o == obj_sandworm || o == obj_antlion) return argument2 * 3;	//desert things hate the cold
			break;
		case SHOT.LIGHTNING:
			if (o == obj_knight || o == obj_guard) return argument2 * 2;	//metal armour
			if (o == obj_lurker || o == obj_crab || o == obj_frog) return argument2 * 2;	//wet things
			if (o == obj_wizard_storm) return 0;	//the storm magus drinks it in
			break;
	}
	return argument2;


}

///rod_enemy_freeze_time(enemy);
function rod_enemy_freeze_time(argument0) {
	//How long the ice rod freezes an enemy: slimes and frogs freeze solid for twice as long
	var o = argument0.object_index;
	if (o == obj_slime || o == obj_frog) return ICE_FREEZE_TIME * 2;
	return ICE_FREEZE_TIME;


}

//================================================================ ice floes, currents

///ice_floe_make(x, y);
function ice_floe_make(argument0, argument1) {
	//A floe on the water tile under this point
	var tx = (argument0 div 16) * 16;
	var ty = (argument1 div 16) * 16;
	var f = instance_position(tx + 8, ty + 8, obj_ice_floe);
	if (f == noone) {f = instance_create_depth(tx, ty, DEPTH_DECOR + 2, obj_ice_floe)}
	f.life = ICE_FLOE_TIME;
	sfx_play(SFX_FREEZE);
	return f;


}

///ice_floe_step();
function ice_floe_step() {
	//Run by obj_ice_floe: melt away in the end
	life--;
	image_index = (life < ICE_FLOE_WARN) ? 1 : 0;
	visible = !(life < ICE_FLOE_WARN && (life div 4) mod 2 == 0);
	if (life <= 0) {
		instance_create_depth(x - 4, y - 4, depth - 1, obj_enemy_death);
		instance_destroy();
	}


}

///water_open_at(x, y);
function water_open_at(argument0, argument1) {
	//Run by obj_link: would any of him be over deep water that isn't frozen, standing at (x, y)?
	var ox = argument0 - x;
	var oy = argument1 - y;
	var pts = [[bbox_left + 2, bbox_top + 2], [bbox_right - 2, bbox_top + 2], [bbox_left + 2, bbox_bottom - 2],
		[bbox_right - 2, bbox_bottom - 2], [(bbox_left + bbox_right) div 2, (bbox_top + bbox_bottom) div 2]];
	for (var i = 0; i < array_length(pts); i++) {
		var px = pts[i][0] + ox;
		var py = pts[i][1] + oy;
		if (position_meeting(px, py, obj_water) && !position_meeting(px, py, obj_ice_floe)) return true;
	}
	return false;


}

///player_water_step();
function player_water_step() {
	//Run by obj_link after player_swim_check: a current carries him along. Without the flippers
	//(a floe melted under him) he goes under and comes back where he last stood safely.
	if (!swimming || state == "fall" || state == "dead") return;
	if (!global.hasFlippers) {
		fall_no_drop = true;
		player_fall_start();
		return;
	}
	var c = instance_position(x, y, obj_current);
	if (c != noone) {
		level_move(lengthdir_x(CURRENT_SPEED, c.flow), lengthdir_y(CURRENT_SPEED, c.flow), level);
	}


}

///current_draw();
function current_draw() {
	//Run by obj_current: streaks on the water, moving the way it flows (spr_current, turned)
	var n = round(image_xscale);
	var m = round(image_yscale);
	var f = (current_time div 160) mod 2;
	for (var i = 0; i < n; i++) {
		for (var j = 0; j < m; j++) {
			draw_sprite_ext(spr_current, f, x + i * 16 + 8, y + j * 16 + 8, 1, 1, flow, c_white, 0.7);
		}
	}


}

///rune_warp_step();
function rune_warp_step() {
	//Run by obj_rune_warp (a 2x2 rune circle): Link standing in it fades away and comes back
	//at target_x, target_y (the Arcanum's lobby)
	if (!instance_exists(obj_link) || instance_exists(obj_floor_fade)) return;
	with (obj_link) {
		if (state != "idle" || z != 0) return;
		if (!point_in_rectangle(x, y, other.x + 6, other.y + 6, other.x + 25, other.y + 25)) return;
	}
	sfx_play(SFX_WARP);
	var f = instance_create_depth(0, 0, -900, obj_floor_fade);
	f.target_x = target_x;
	f.target_y = target_y;


}

//================================================================ flame jets

///flame_jet_create();
function flame_jet_create() {
	//Run by obj_flame_jet's Create. Creation Code can change dir, length, period and offset.
	dir = 0;			//the way the fire blows: 0 right, 90 up, 180 left, 270 down
	length = 3;			//tiles of fire
	period = 0;			//0 = always on, otherwise steps for a whole on-and-off
	offset = 0;			//steps into its period it starts at
	frozen_t = 0;
	timer = 0;
	on = true;
	depth = DEPTH_DECOR;
	image_speed = 0;


}

///flame_jet_rect();
function flame_jet_rect() {
	//Run by obj_flame_jet: [x1, y1, x2, y2] of its fire (the tiles past the vent)
	var dx = round(lengthdir_x(1, dir));
	var dy = round(lengthdir_y(1, dir));
	var x1 = x + dx * 16;
	var y1 = y + dy * 16;
	var x2 = x + dx * 16 * length;
	var y2 = y + dy * 16 * length;
	return [min(x1, x2) + 2, min(y1, y2) + 2, max(x1, x2) + 13, max(y1, y2) + 13];


}

///flame_jet_touches(x, y);
function flame_jet_touches(argument0, argument1) {
	//Run by obj_flame_jet: is this point on the vent, or in the fire while it's lit?
	if (point_in_rectangle(argument0, argument1, x, y, x + 15, y + 15)) return true;
	if (!on) return false;
	var r = flame_jet_rect();
	return point_in_rectangle(argument0, argument1, r[0], r[1], r[2], r[3]);


}

///flame_jet_step();
function flame_jet_step() {
	//Run by obj_flame_jet: on or off, frozen, burn Link (and push him back out of the fire)
	timer++;
	if (frozen_t > 0) {frozen_t--}
	if (period <= 0) {on = true}
	else {on = ((timer + offset) mod period) < period div 2}
	if (frozen_t > 0) {on = false}
	if (!on || !instance_exists(obj_link)) return;
	var r = flame_jet_rect();
	with (obj_link) {
		if (z > 0 || state == "fall" || state == "dead") break;
		if (rectangle_in_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, r[0], r[1], r[2], r[3]) == 0) break;
		var horiz = (other.dir == 0 || other.dir == 180);
		var fx = horiz ? x : (r[0] + r[2]) / 2;
		var fy = horiz ? (r[1] + r[3]) / 2 : y;
		if (hurt_timer <= 0) {player_hurt(FLAME_DAMAGE, fx, fy)}
		var ang = point_direction(fx, fy, x, y);
		level_move(lengthdir_x(FLAME_SHOVE, ang), lengthdir_y(FLAME_SHOVE, ang), level);
	}


}

///flame_jet_draw();
function flame_jet_draw() {
	//Run by obj_flame_jet: the vent (spr_flame_jet: 0 lit, 1 frozen), then its fire (spr_jet_fire, turned the way it blows)
	draw_sprite(sprite_index, (frozen_t > 0) ? 1 : 0, x, y);
	if (!on) return;
	var dx = round(lengthdir_x(1, dir));
	var dy = round(lengthdir_y(1, dir));
	var f = (current_time div 100) mod 2;
	for (var i = 1; i <= length; i++) {
		draw_sprite_ext(spr_jet_fire, f, x + dx * 16 * i + 8, y + dy * 16 * i + 8, 1, 1, dir, c_white, 1);
	}


}

//================================================================ lightning posts

///zone_posts_charged(zone);
function zone_posts_charged(argument0) {
	//True when every obj_lightning_post in a camera zone is charged at the same time (and it has at least one)
	var z = argument0;
	var n = 0;
	var on_n = 0;
	with (obj_lightning_post) {
		if (point_in_rectangle(x + 8, y + 8, z.bbox_left, z.bbox_top, z.bbox_right, z.bbox_bottom)) {
			n++;
			if (charged_t > 0) {on_n++}
		}
	}
	return n > 0 && on_n == n;


}

//================================================================ hint statues, the magic font

///hint_statue_steps();
function hint_statue_steps() {
	//Run as obj_hint_statue's dialogue (a method bound to it): its hint, the plainer one once Link
	//has been stuck in its room a while, and putting the room's blocks back
	var steps = ["THE STONE OWL'S EYES GLOW...", hint];
	if (hint2 != "" && stay_t >= HINT_STUCK_TIME) {
		array_push(steps, "...IT LEANS CLOSER, AND SPEAKS MORE PLAINLY:");
		array_push(steps, hint2);
	}
	if (zone != noone && instance_exists(zone) && push_blocks_moved(zone)) {
		var z = zone;
		array_push(steps, dlg_choice("PUT THE BLOCKS BACK WHERE THEY STARTED?", [
			["YES", [dlg_run(method({z: z}, function() {push_blocks_home(z); sfx_play(SFX_PUSH);})), "THE BLOCKS GRIND BACK INTO PLACE."]],
			"NO"
		]));
	}
	return steps;


}

///hint_statue_step();
function hint_statue_step() {
	//Run by obj_hint_statue: how long Link has been in its room (since he last came in)
	if (zone == noone) {zone = cam_zone_at(x, y)}
	if (global.cam_zone == zone && zone != noone) {
		if (!instance_exists(obj_dialogue)) {stay_t++}
	} else {
		stay_t = 0;
	}


}

///magic_font_steps();
function magic_font_steps() {
	//Run as obj_magic_font's dialogue: the magic fills up
	if (global.pMagic >= global.pMagicMax) return ["THE FONT'S WATER GLOWS SOFTLY. YOUR MAGIC IS ALREADY FULL."];
	return [dlg_run(function() {
		global.pMagic = global.pMagicMax;
		sfx_play(SFX_MAGIC);
	}), "YOU DIP YOUR HANDS IN THE GLOWING WATER... YOUR MAGIC IS FULL!"];


}
