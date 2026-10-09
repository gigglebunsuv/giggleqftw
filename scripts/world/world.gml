//The overworld (rm_overworld) and its caves (rm_caves): starting a new game, area names and
//music, enemies that only wake up near the screen, gates, bushes and pieces of heart.
//
//rm_overworld and rm_caves are built by world_placeholders/make_overworld_room.py and
//make_caves_room.py (close GameMaker and re-run them rather than editing the rooms by hand).
//Each area is an obj_cam_zone with area_name and area_music in its Creation Code. The room's
//obj_world shows the area's name when Link walks in, and plays its music.

#macro WORLD_START_X 1384			//in front of Link's house (rm_overworld)
#macro WORLD_START_Y 1450
#macro WORLD_TOWER_X 912			//in front of the Southern Tower's door (rm_overworld)
#macro WORLD_TOWER_Y 2314
#macro WORLD_BOG_X 176				//on the Bog Tower's porch, in front of its door (rm_overworld)
#macro WORLD_BOG_Y 1194
#macro WORLD_LADHELLIN_X 3152		//in front of the Tower of Ladhellin's door, below its pegs (rm_overworld)
#macro WORLD_LADHELLIN_Y 1416
#macro WORLD_WAKE_MARGIN 48			//overworld enemies move while they're this close to the screen
#macro WORLD_GATE_TORCH_RANGE 48	//a "torches" gate opens once every torch this close to it is lit
#macro HEART_PIECES_PER_HEART 1		//pieces of heart that make a new heart (set to 4 for quarter pieces)
#macro WATER_FRAME_TIME 220			//milliseconds per frame of the water's animation
#macro WATER_LAYERS ["Tiles_Water", "Tiles_Detail", "Tiles_Walls"]	//deep water, shallow water, the waterfall

///world_start_new_game();
function world_start_new_game() {
	//Play from the title: the very start of the game. Link stands in front of his house with
	//3 hearts, the tunic and the flute, and nothing else: no sword, no shield, no money.
	//The knight at the village's north gate gives him the sword and shield (dlg_village_guard),
	//the lantern comes from the lamplighter's side quest, the rest from shops, caves and dungeons.
	global.pHealthMax = 6;
	global.pHealth = 6;
	global.pMagic = global.pMagicMax;
	global.pMoney = 0;
	global.swordTier = 0;
	global.swordOre = 0;
	global.armorTier = 1;
	for (var i = 0; i < ITEM.COUNT; i++) {item_take(i)}
	global.pArrows = 0;
	global.pBombs = 0;
	shield_set_tier(0);
	item_give(ITEM.FLUTE);


}

///world_room_start();
function world_room_start() {
	//Run by obj_world at Room Start: the music for the area Link starts in
	area = noone;
	world_music_play(world_zone_music(cam_zone_at(obj_link.x, obj_link.y)));


}

///world_step();
function world_step() {
	//Run by obj_world every step: walking into another area shows its name and changes the music
	var z = global.cam_zone;
	if (z == noone || !instance_exists(z) || z == area) return;
	area = z;
	if (z.area_name != "") {floor_name_show(z.area_name)}
	world_music_play(world_zone_music(z));


}

///world_zone_music(zone);
function world_zone_music(argument0) {
	//The music for a zone (-1: keep playing whatever is on)
	if (argument0 == noone || !instance_exists(argument0)) return -1;
	return argument0.area_music;


}

///world_music_play(sound);
function world_music_play(argument0) {
	//Loops this music, unless it's already the one playing (-1 = leave it alone)
	if (argument0 == -1) return;
	if (variable_global_exists("world_music") && global.world_music == argument0 && audio_is_playing(argument0)) return;
	//Stop the other music (not the sound effects)
	var tracks = [Overworld, Village, DungeonOne, BogTower, LadhellinTower, BossTheme, House, Intro, Title, FileSelect];
	for (var i = 0; i < array_length(tracks); i++) {audio_stop_sound(tracks[i])}
	audio_play_sound(argument0, 1, true);
	global.world_music = argument0;


}

///world_enemy_awake();
function world_enemy_awake() {
	//Run by an enemy (see enemy_is_active): in the overworld it only moves while it's in the area
	//Link is in and near the screen, so the whole land isn't busy at once
	if (!instance_exists(obj_world)) return true;
	if (cam_zone_at(x, y) != global.cam_zone) return false;
	var cam = view_camera[0];
	var vx = camera_get_view_x(cam);
	var vy = camera_get_view_y(cam);
	var m = WORLD_WAKE_MARGIN;
	return point_in_rectangle(x, y, vx - m, vy - m, vx + camera_get_view_width(cam) + m, vy + camera_get_view_height(cam) + m);


}

///world_give(what);
function world_give(argument0) {
	//Gives Link something straight from a conversation (a shop, someone's gift). what is a struct with
	//any of obj_treasure's variables, e.g. {equip: "sword", tier: 1}. Returns the "YOU GOT..." steps.
	var t = {item: ITEM.NONE, equip: "", tier: 1, contents: BOTTLE.EMPTY, amount: 1, message: ""};
	var names = variable_struct_get_names(argument0);
	for (var i = 0; i < array_length(names); i++) {variable_struct_set(t, names[i], variable_struct_get(argument0, names[i]))}
	var steps = [];
	with (t) {
		treasure_collect();
		steps = chest_item_steps();
	}
	return steps;


}

///dialogue_insert(steps);
function dialogue_insert(argument0) {
	//From a dlg_run: these steps play next in the conversation that's open
	with (obj_dialogue) {array_push(stack, {steps: argument0, pos: 0})}


}

//================================================================ animated water

///world_water_init();
function world_water_init() {
	//Run by obj_world's Create. The 4 frames of each animated tile in tile_world (keep in step with
	//WATER_FRAMES, SHALLOW_FRAMES and WATERFALL_FRAMES in world_placeholders/world_tiles.py):
	//[frame 0, 1, 2, 3, how many tiles in the set]. Rooms only ever have frame 0 painted in them.
	var sets = [
		[320, 1680, 1728, 1776, 47],	//deep water (a 47 tile blob set)
		[384, 1824, 1872, 1920, 47],	//shallow water
		[110, 1968, 1971, 1974, 3]		//the waterfall (A, B, foam)
	];
	water_sets = sets;
	water_lut = array_create(2048, -1);	//tile -> set * 64 + its place in the set
	for (var s = 0; s < array_length(sets); s++) {
		for (var f = 0; f < 4; f++) {
			for (var k = 0; k < sets[s][4]; k++) {water_lut[sets[s][f] + k] = s * 64 + k}
		}
	}
	water_maps = [];
	var names = WATER_LAYERS;
	for (var i = 0; i < array_length(names); i++) {
		var lay = layer_get_id(names[i]);
		if (lay == -1) continue;
		var map = layer_tilemap_get_id(lay);
		if (map != -1 && tilemap_get_tileset(map) == tile_world) {array_push(water_maps, map)}
	}
	water_frame = -1;
	water_cam_x = -1;
	water_cam_y = -1;


}

///world_water_animate();
function world_water_animate() {
	//Run by obj_world every step: the water tiles on screen (and a tile round it) show the frame
	//the clock is on, so water just scrolling into view is always in step
	if (array_length(water_maps) == 0) return;
	var f = (current_time div WATER_FRAME_TIME) mod 4;
	var cam = view_camera[0];
	var cx = camera_get_view_x(cam);
	var cy = camera_get_view_y(cam);
	if (f == water_frame && cx == water_cam_x && cy == water_cam_y) return;
	water_frame = f;
	water_cam_x = cx;
	water_cam_y = cy;
	var x0 = max(0, floor(cx / 16) - 1);
	var y0 = max(0, floor(cy / 16) - 1);
	var x1 = x0 + ceil(camera_get_view_width(cam) / 16) + 2;
	var y1 = y0 + ceil(camera_get_view_height(cam) / 16) + 2;
	for (var m = 0; m < array_length(water_maps); m++) {
		var map = water_maps[m];
		var w = tilemap_get_width(map);
		var h = tilemap_get_height(map);
		for (var ty = y0; ty <= min(y1, h - 1); ty++) {
			for (var tx = x0; tx <= min(x1, w - 1); tx++) {
				var data = tilemap_get(map, tx, ty);
				var t = tile_get_index(data);
				if (t <= 0 || t >= 2048) continue;
				var v = water_lut[t];
				if (v < 0) continue;
				var nt = water_sets[v div 64][f] + (v mod 64);
				if (nt != t) {tilemap_set(map, tile_set_index(data, nt), tx, ty)}
			}
		}
	}


}

//================================================================ gates

///world_gate_open_now();
function world_gate_open_now() {
	//Run by obj_world_gate: true once what it needs is done
	switch (need) {
		case "torches":
			//every torch close by is lit (and there's at least one)
			var found = false;
			var all_lit = true;
			with (obj_torch) {
				if (point_distance(x + 8, y + 8, other.x + other.sprite_width / 2, other.y + other.sprite_height / 2) <= WORLD_GATE_TORCH_RANGE) {
					found = true;
					if (!lit) {all_lit = false}
				}
			}
			return found && all_lit;
		case "sword":
			//struck with a strong enough sword
			if (instance_exists(obj_sword) && place_meeting(x, y, obj_sword)) {
				if (global.swordTier >= tier) return true;
				if (clink_timer <= 0) {
					sfx_play(SFX_SHIELD);
					clink_timer = 20;
				}
			}
			return false;
		case "flag":
			return flag_get(open_flag);
	}
	return false;


}

///world_gate_open();
function world_gate_open() {
	//Run by obj_world_gate: it's gone for good (its flag remembers)
	if (flag != "") {flag_set(flag, true)}
	sfx_play(SFX_SECRET);
	instance_destroy();


}

//================================================================ bushes

///bush_cut();
function bush_cut() {
	//Run by obj_bush when the sword (or fire) gets it: a stub is left, sometimes something to pick up
	var cx = x;
	var cy = y;
	var stub = instance_create_depth(x, y, DEPTH_DECOR + 1, obj_decal);
	stub.sprite_index = spr_bush;
	stub.image_index = 1;
	sfx_play(SFX_BUSH);
	var roll = irandom(11);
	if (roll == 0) {pickup_create(PICKUP.HEART, cx, cy)}
	else if (roll == 1) {pickup_create(PICKUP.MONEY1, cx, cy)}
	else if (roll == 2) {pickup_create(PICKUP.MAGIC, cx, cy)}
	instance_destroy();


}

//================================================================ pieces of heart

///heart_piece_collect();
function heart_piece_collect() {
	//A piece of heart: HEART_PIECES_PER_HEART of them make a new heart container
	global.heartPieces++;
	if (global.heartPieces >= HEART_PIECES_PER_HEART) {
		global.heartPieces -= HEART_PIECES_PER_HEART;
		player_add_heart();
	}


}

///heart_piece_desc();
function heart_piece_desc() {
	//The line under "YOU GOT A PIECE OF HEART!" (after it was collected)
	if (HEART_PIECES_PER_HEART <= 1) return "YOUR LIFE WENT UP BY ONE HEART!";
	if (global.heartPieces == 0) return "THE PIECES MAKE A WHOLE HEART! YOUR LIFE WENT UP BY ONE HEART!";
	var left = HEART_PIECES_PER_HEART - global.heartPieces;
	return string(left) + " MORE AND YOU'LL HAVE A NEW HEART.";


}