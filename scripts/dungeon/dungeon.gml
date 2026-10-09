//Dungeons: which room is which dungeon, its small keys, boss key, map and compass,
//its floors (all in the one room), the stairs between floors and holes that drop to the floor below.
//
//Every floor of a dungeon is in the same room, each in its own area, marked by an obj_floor
//rectangle (floor_num, floor_name, holes_drop: see its Create event). Floors line up: a hole at
//some spot on a floor drops Link to the same spot on the floor below (the obj_floor with the
//next lower floor_num). Upper and lower levels inside a floor (balconies) still use the
//levels script (obj_ledge, obj_stairs, obj_level_zone).
//
//Small keys only count in the dungeon they were found in: global.pKeys is the current
//dungeon's keys, swapped in and out by dungeon_room_start. Dungeon 0 = not in a dungeon.
//Doors: obj_locked_door (small key), obj_boss_door (boss key), obj_shutter_door (opens by itself).

#macro DUNGEON_COUNT 4			//0 = outside, 1 = the Southern Tower, 2-3 for later
#macro FLOOR_FADE_TIME 12		//steps to fade out (and back in) on the stairs between floors
#macro FLOOR_NAME_TIME 90		//steps the floor's name ("2F") shows after changing floors
#macro DROP_HEIGHT 48			//pixels Link falls from after dropping through a hole
#macro DROP_TIME 14				//steps that takes
#macro TOWER_START_X 1792		//the Southern Tower's entrance (1F, the entrance hall's front door)
#macro TOWER_START_Y 680

///dungeon_init();
function dungeon_init() {
	//Run by obj_link's Create: a new game has no dungeon things yet
	global.dungeon = 0;
	global.dungeonKeys = array_create(DUNGEON_COUNT, 0);
	global.bossKey = array_create(DUNGEON_COUNT, false);
	global.dungeonMap = array_create(DUNGEON_COUNT, false);
	global.dungeonCompass = array_create(DUNGEON_COUNT, false);
	global.floor_name = "";
	global.floor_name_timer = 0;


}

///dungeon_of_room(room);
function dungeon_of_room(argument0) {
	//Which dungeon a room is (0 = not a dungeon)
	if (argument0 == rm_southern_tower) return 1;
	return 0;


}

///dungeon_name(dungeon);
function dungeon_name(argument0) {
	switch (argument0) {
		case 1: return "SOUTHERN TOWER";
	}
	return "";


}

///dungeon_room_start();
function dungeon_room_start() {
	//Run by obj_link at Room Start: swap in this dungeon's small keys, show the floor's name
	var d = dungeon_of_room(room);
	if (d != global.dungeon) {
		global.dungeonKeys[global.dungeon] = global.pKeys;
		global.dungeon = d;
		global.pKeys = global.dungeonKeys[d];
	}
	cur_floor = noone;
	dungeon_step();


}

///dungeon_step();
function dungeon_step() {
	//Run by obj_link every step: notices changing floors and marks rooms visited (for the map)
	if (global.dungeon == 0) return;
	var f = floor_at(x, y);
	if (f != noone && f != cur_floor) {
		cur_floor = f;
		floor_name_show(f.floor_name);
	}
	var zone = global.cam_zone;
	if (zone != noone && instance_exists(zone)) {
		var flag = zone_visit_flag(zone);
		if (!flag_get(flag)) {flag_set(flag, true)}
	}


}

///dungeon_has_boss_key();
function dungeon_has_boss_key() {
	return global.bossKey[global.dungeon];


}

///zone_visit_flag(zone);
function zone_visit_flag(argument0) {
	//The story flag that remembers Link has been in a camera zone (shown on the map)
	return "visit_" + room_get_name(room) + "_" + string(argument0.bbox_left) + "_" + string(argument0.bbox_top);


}

//================================================================ floors

///floor_at(x, y);
function floor_at(argument0, argument1) {
	//The obj_floor containing the point, or noone
	var found = noone;
	with (obj_floor) {
		if (point_in_rectangle(argument0, argument1, bbox_left, bbox_top, bbox_right, bbox_bottom)) {found = id}
	}
	return found;


}

///floor_below(floor);
function floor_below(argument0) {
	//The floor under this one (the next lower floor_num), or noone
	var f = argument0;
	var found = noone;
	var best = -infinity;
	with (obj_floor) {
		if (floor_num < f.floor_num && floor_num > best) {
			best = floor_num;
			found = id;
		}
	}
	return found;


}

///floor_name_show(name);
function floor_name_show(argument0) {
	global.floor_name = argument0;
	global.floor_name_timer = FLOOR_NAME_TIME;


}

///floor_stairs_take(stairs);
function floor_stairs_take(argument0) {
	//Run by obj_link: fade out, come out below the stairs with the same pair on the other floor
	var s = argument0;
	var partner = noone;
	with (obj_floor_stairs) {
		if (id != s && pair == s.pair) {partner = id}
	}
	if (partner == noone) return false;

	var f = instance_create_depth(0, 0, -900, obj_floor_fade);
	f.target_x = (partner.bbox_left + partner.bbox_right + 1) / 2;
	f.target_y = partner.bbox_bottom + 1 + 10;
	sfx_play(SFX_STAIRS);
	return true;


}

///floor_fade_arrive();
function floor_fade_arrive() {
	//Run by obj_floor_fade once the screen is black: move Link, jump the camera.
	//Dying (CONTINUE) brings him back to the last stairs he came out of.
	var tx = target_x;
	var ty = target_y;
	with (obj_link) {
		x = tx;
		y = ty;
		dir = "down";
		sprite_index = player_get_sprite(dir);
		move_frac_x = 0;
		move_frac_y = 0;
		if (level_room_uses_levels()) {level_set(0)}
		safe_x = x;
		safe_y = y;
		safe_level = 0;
		entry_x = x;
		entry_y = y;
		dungeon_step();
	}
	camera_snap();


}

///floor_drop();
function floor_drop() {
	//Run by obj_link when he's done falling into a hole: on a floor with a floor under it
	//(and solid lower-level ground at the same spot down there), he drops through instead of coming back.
	//Returns true if he dropped.
	var f = floor_at(x, y);
	if (f == noone || !f.holes_drop) return false;
	var below = floor_below(f);
	if (below == noone) return false;

	var nx = round(x - f.x + below.x);
	var ny = round(y - f.y + below.y);
	if (cam_zone_at(nx, ny) == noone || position_meeting(nx, ny, obj_pit)) return false;
	if (place_meeting(nx, ny, obj_wall) || place_meeting(nx, ny, obj_wall_low)) return false;

	x = nx;
	y = ny;
	image_xscale = 1;
	image_yscale = 1;
	move_frac_x = 0;
	move_frac_y = 0;
	fall_grace = 0;
	safe_x = x;
	safe_y = y;
	safe_level = 0;
	if (level_room_uses_levels()) {level_set(0)}
	dir = "down";
	sprite_index = player_get_sprite(dir);
	spr_prev = sprite_index;

	//Falls in from above (see floor_land_step)
	state = "land";
	cnt = 0;
	dur = DROP_TIME;
	z = DROP_HEIGHT;
	pose = -1;
	camera_snap();
	dungeon_step();
	return true;


}

///floor_land_step();
function floor_land_step() {
	//Run by obj_link: dropping down from the floor above (state "land", ended by the timer)
	if (state != "land") return;
	var t = min(1, (cnt + 1) / dur);
	z = DROP_HEIGHT * (1 - t * t);
	if (t >= 1) {
		z = 0;
		sfx_play(SFX_LAND);
	}


}

//================================================================ doors

///door_flag();
function door_flag() {
	//Run by a door: the story flag that remembers it was opened (one per door, by room and spot)
	return "door_" + room_get_name(room) + "_" + string(x) + "_" + string(y);


}

///door_link_pushing();
function door_link_pushing() {
	//Run by a door: Link is up against it, walking into it
	if (!instance_exists(obj_link)) return false;
	with (obj_link) {
		if (state != "idle") return false;
		var ang = player_face_angle(dir);
		if (xx != round(lengthdir_x(1, ang)) || yy != round(lengthdir_y(1, ang))) return false;
		return place_meeting(x + lengthdir_x(2, ang), y + lengthdir_y(2, ang), other);
	}
	return false;


}

///door_can_open();
function door_can_open() {
	//Run by a locked door (a small key) or a boss door (the boss key)
	if (object_index == obj_boss_door) return dungeon_has_boss_key();
	return global.pKeys > 0;


}

///door_use_key();
function door_use_key() {
	//A small key is used up, the boss key isn't
	if (object_index != obj_boss_door) {player_add_keys(-1)}


}

///door_open();
function door_open() {
	//Run by a locked or boss door: it opens for good
	flag_set(door_flag(), true);
	sfx_play(SFX_DOOR);
	instance_create_depth(x - 12, y - 12, depth - 1, obj_enemy_death);
	instance_destroy();


}

///door_zones();
function door_zones() {
	//Run by a door: the camera zones on either side of it (the rooms it joins)
	var pts = [[x, bbox_top + 2], [x, bbox_bottom - 2], [bbox_left + 2, y], [bbox_right - 2, y]];
	var zones = [];
	for (var i = 0; i < 4; i++) {
		var z = cam_zone_at(pts[i][0], pts[i][1]);
		if (z == noone) continue;
		var dup = false;
		for (var j = 0; j < array_length(zones); j++) {
			if (zones[j] == z) {dup = true}
		}
		if (!dup) {array_push(zones, z)}
	}
	return zones;


}

///zone_enemies_left(zone);
function zone_enemies_left(argument0) {
	//How many enemies are still alive in a camera zone
	var z = argument0;
	var n = 0;
	with (obj_enemy) {
		if (point_in_rectangle(x, y, z.bbox_left, z.bbox_top, z.bbox_right, z.bbox_bottom)) {n++}
	}
	return n;


}

///zone_torches_lit(zone);
function zone_torches_lit(argument0) {
	//True when every obj_torch in a camera zone is lit (and it has at least one)
	var z = argument0;
	var n = 0;
	var lit_n = 0;
	with (obj_torch) {
		if (point_in_rectangle(x + 8, y + 8, z.bbox_left, z.bbox_top, z.bbox_right, z.bbox_bottom)) {
			n++;
			if (lit) {lit_n++}
		}
	}
	return n > 0 && lit_n == n;


}

///zone_switch_pressed(zone);
function zone_switch_pressed(argument0) {
	//True when an obj_floor_switch in a camera zone has been stepped on
	var z = argument0;
	var found = false;
	with (obj_floor_switch) {
		if (pressed && point_in_rectangle(x + 8, y + 8, z.bbox_left, z.bbox_top, z.bbox_right, z.bbox_bottom)) {found = true}
	}
	return found;


}

///shutter_should_open();
function shutter_should_open() {
	//Run by obj_shutter_door every step (see its Create event for open_when)
	switch (open_when) {
		case "clear":
			//Open unless Link is in one of its rooms and enemies are still in there
			var lz = global.cam_zone;
			for (var i = 0; i < array_length(zones); i++) {
				if (zones[i] == lz && zone_enemies_left(lz) > 0) return false;
			}
			return true;
		case "torches":
			for (var i = 0; i < array_length(zones); i++) {
				if (zone_torches_lit(zones[i])) return true;
			}
			return false;
		case "switch":
			for (var i = 0; i < array_length(zones); i++) {
				if (zone_switch_pressed(zones[i])) return true;
			}
			return false;
	}
	return true;


}

//================================================================ boss rewards

///boss_flag(dungeon);
function boss_flag(argument0) {
	//The story flag set once a dungeon's boss is beaten
	return "boss_" + string(argument0);


}

///boss_reward_flag(dungeon, what);
function boss_reward_flag(argument0, argument1) {
	//The story flag for one of the boss's rewards ("heart", "bun") having been picked up
	return "boss_" + string(argument0) + "_" + argument1;


}

///boss_music_step();
function boss_music_step() {
	//Run by obj_boss_arena: the boss theme plays while Link is in the boss's room and the boss
	//is alive. Leaving before it wakes up brings the dungeon's music back; beating it stops the
	//theme, and the dungeon's music comes back once the explosions are over.
	var zone = cam_zone_at(x, y);
	var boss_alive = instance_exists(obj_gargoyle) && !flag_get(boss_flag(global.dungeon));
	var fighting = boss_alive && zone != noone && global.cam_zone == zone;

	if (fighting && !music_on) {
		music_on = true;
		audio_stop_sound(room_music);
		audio_play_sound(music, 1, true);
	} else if (!fighting && music_on) {
		music_on = false;
		audio_stop_sound(music);
		resume_music = true;
	}
	if (resume_music && (boss_alive || flag_get(boss_flag(global.dungeon)))) {
		resume_music = false;
		if (!audio_is_playing(room_music)) {audio_play_sound(room_music, 1, true)}
	}


}

///boss_rewards_spawn();
function boss_rewards_spawn() {
	//Run by obj_boss_arena once the boss is beaten: the heart container and the piece of
	//the Bun, each held up over Link's head when he walks onto it (the ones not picked up yet)
	var d = global.dungeon;
	if (!flag_get(boss_reward_flag(d, "heart"))) {
		var h = instance_create_depth(x - 8, y + 8, DEPTH_DECOR, obj_treasure);
		h.equip = "heart";
		h.hold_up = true;
		h.pedestal = false;
		h.flag = boss_reward_flag(d, "heart");
	}
	if (!flag_get(boss_reward_flag(d, "bun"))) {
		var b = instance_create_depth(x - 8, y - 32, DEPTH_DECOR, obj_treasure);
		b.equip = "bun";
		b.hold_up = true;
		b.flag = boss_reward_flag(d, "bun");
		b.message = "THE BUN GLOWS WARMLY. A WAY OUT HAS OPENED IN THE MIDDLE OF THE ROOF.";
	}
	sfx_play(SFX_ITEM_GET);


}

//================================================================ starting in a dungeon

///dungeon_start_southern_tower();
function dungeon_start_southern_tower() {
	//Level select: Link starts at the tower's entrance with 3 hearts, the level 1 sword,
	//the wooden shield, the tunic and the lantern (nothing else)
	global.pHealthMax = 6;
	global.pHealth = 6;
	global.pMagic = global.pMagicMax;
	global.swordTier = 1;
	global.armorTier = 1;
	for (var i = 0; i < ITEM.COUNT; i++) {item_take(i)}
	global.pArrows = 0;
	global.pBombs = 0;
	shield_set_tier(1);
	item_give(ITEM.LANTERN);


}
