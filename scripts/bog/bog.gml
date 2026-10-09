//The Bog Tower (rm_bog_tower): the sluice, water that comes and goes, eye switches, animated water.
//
//rm_bog_tower is built by dungeon_placeholders/make_bog_room.py (close GameMaker and re-run it
//rather than editing the room by hand). The room has one obj_bog, which runs all of this.
//
//The sluice: every obj_sluice_lever in the tower flips the same story flag (BOG_SLUICE_FLAG).
//	Off (the start): the A basins are full and the B basins are empty.
//	On: the A basins drain and the B basins fill up.
//Each set has a hidden tile layer for its deep water (Water_A / Water_B, like the "Water" layer)
//and one for the holes that open up when it's empty (Pits_A / Pits_B: the holes' pictures, so they
//stay visible), and a visible layer with the water's picture (Tiles_WaterA / Tiles_WaterB) that's
//shown only while it's full. Water that's always there is on the usual "Water" and "Tiles_Water".
//
//obj_eye_switch: a stone eye in a wall. An arrow shuts it for good; a shutter door with
//open_when = "eye" opens once every eye in one of its rooms is shut.

#macro BOG_SLUICE_FLAG "bog_sluice"
#macro BOG_GONE 100000			//water and holes that aren't there are moved this far away
#macro BOG_LEVER_WAIT 30		//steps before a lever can be hit again
#macro BOG_WATER_FRAME_TIME 220	//milliseconds per frame of the water's animation
#macro BOG_WATER_LAYERS ["Tiles_Water", "Tiles_WaterA", "Tiles_WaterB"]

///bog_room_start();
function bog_room_start() {
	//Run by obj_bog at Room Start: the A and B water and holes from their tile layers
	water_a = layer_tiles_to_instances("Water_A", obj_water);
	water_b = layer_tiles_to_instances("Water_B", obj_water);
	pits_a = layer_tiles_to_instances("Pits_A", obj_pit);
	pits_b = layer_tiles_to_instances("Pits_B", obj_pit);
	var sets = [water_a, water_b, pits_a, pits_b];
	for (var s = 0; s < 4; s++) {
		for (var i = 0; i < array_length(sets[s]); i++) {
			with (sets[s][i]) {
				home_x = x;
				visible = false;
			}
		}
	}
	//The holes' pictures stay on screen (under the water's)
	if (layer_get_id("Pits_A") != -1) {layer_set_visible("Pits_A", true)}
	if (layer_get_id("Pits_B") != -1) {layer_set_visible("Pits_B", true)}
	bog_water_apply();
	bog_water_init();


}

///bog_sluice_on();
function bog_sluice_on() {
	return flag_get(BOG_SLUICE_FLAG);


}

///bog_set_present(instances, present);
function bog_set_present(argument0, argument1) {
	//Puts water or holes back where they belong, or moves them far out of the way
	for (var i = 0; i < array_length(argument0); i++) {
		with (argument0[i]) {x = argument1 ? home_x : home_x - BOG_GONE}
	}


}

///bog_water_apply();
function bog_water_apply() {
	//Run by obj_bog: the A and B basins full or empty, as the sluice says
	var on = bog_sluice_on();
	bog_set_present(water_a, !on);
	bog_set_present(pits_a, on);
	bog_set_present(water_b, on);
	bog_set_present(pits_b, !on);
	if (layer_get_id("Tiles_WaterA") != -1) {layer_set_visible("Tiles_WaterA", !on)}
	if (layer_get_id("Tiles_WaterB") != -1) {layer_set_visible("Tiles_WaterB", on)}


}

///bog_sluice_toggle();
function bog_sluice_toggle() {
	//A lever was hit: the water rushes from one set of basins to the other
	flag_set(BOG_SLUICE_FLAG, !bog_sluice_on());
	with (obj_bog) {bog_water_apply()}
	sfx_play(SFX_SPLASH);
	sfx_play(SFX_SECRET);
	floor_name_show(bog_sluice_on() ? "THE SLUICE OPENS" : "THE SLUICE SHUTS");


}

///sluice_lever_step();
function sluice_lever_step() {
	//Run by obj_sluice_lever: the sword, an arrow, the boomerang or the grapple hook flips it
	image_index = bog_sluice_on();
	if (wait > 0) {
		wait--;
		return;
	}
	var hit = false;
	if (collision_rectangle(bbox_left - 2, bbox_top - 2, bbox_right + 2, bbox_bottom + 2, obj_sword, false, true) != noone) {hit = true}
	var a = collision_rectangle(bbox_left - 6, bbox_top - 6, bbox_right + 6, bbox_bottom + 6, obj_arrow, false, true);
	if (a != noone) {
		with (a) {instance_destroy()}
		hit = true;
	}
	if (collision_rectangle(bbox_left - 4, bbox_top - 4, bbox_right + 4, bbox_bottom + 4, obj_boomerang, false, true) != noone) {hit = true}
	if (collision_rectangle(bbox_left - 4, bbox_top - 4, bbox_right + 4, bbox_bottom + 4, obj_hookshot, false, true) != noone) {hit = true}
	if (hit) {
		wait = BOG_LEVER_WAIT;
		bog_sluice_toggle();
		image_index = bog_sluice_on();
	}


}

//================================================================ eye switches

///eye_switch_step();
function eye_switch_step() {
	//Run by obj_eye_switch: an arrow flying into it (or just about to) shuts it for good
	if (!checked) {
		checked = true;
		shut = flag_get(door_flag());
	}
	image_index = shut;
	if (shut) return;
	var a = collision_rectangle(bbox_left - 6, bbox_top - 6, bbox_right + 6, bbox_bottom + 6, obj_arrow, false, true);
	if (a != noone) {
		with (a) {instance_destroy()}
		shut = true;
		image_index = 1;
		flag_set(door_flag(), true);
		sfx_play(SFX_SWITCH);
		instance_create_depth(x - 4, y - 4, depth - 1, obj_enemy_death);
	}


}

///zone_eyes_shut(zone);
function zone_eyes_shut(argument0) {
	//True when every obj_eye_switch in a camera zone has been shot (and it has at least one)
	var z = argument0;
	var n = 0;
	var shut_n = 0;
	with (obj_eye_switch) {
		if (point_in_rectangle(x + 8, y + 8, z.bbox_left, z.bbox_top, z.bbox_right, z.bbox_bottom)) {
			n++;
			if (shut || flag_get(door_flag())) {shut_n++}
		}
	}
	return n > 0 && shut_n == n;


}

//================================================================ animated water

///bog_water_init();
function bog_water_init() {
	//Run by bog_room_start: the 4 frames of the deep water in tile_bog (keep in step with
	//WATER_FRAMES in dungeon_placeholders/bog_tiles.py), 16 tiles each (one per edge mask)
	water_frames = [336, 352, 368, 384];
	water_maps = [];
	var names = BOG_WATER_LAYERS;
	for (var i = 0; i < array_length(names); i++) {
		var lay = layer_get_id(names[i]);
		if (lay == -1) continue;
		var map = layer_tilemap_get_id(lay);
		if (map != -1) {array_push(water_maps, map)}
	}
	water_frame = -1;
	water_cam_x = -1;
	water_cam_y = -1;


}

///bog_water_animate();
function bog_water_animate() {
	//Run by obj_bog every step: the water tiles on screen (and a tile round it) show the frame
	//the clock is on
	if (!variable_instance_exists(id, "water_maps") || array_length(water_maps) == 0) return;
	var f = (current_time div BOG_WATER_FRAME_TIME) mod 4;
	var cam = view_camera[0];
	var cx = camera_get_view_x(cam);
	var cy = camera_get_view_y(cam);
	if (f == water_frame && cx == water_cam_x && cy == water_cam_y) return;
	water_frame = f;
	water_cam_x = cx;
	water_cam_y = cy;
	var first = water_frames[0];
	var last = water_frames[3] + 15;
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
				if (t < first || t > last) continue;
				var nt = water_frames[f] + ((t - first) mod 16);
				if (nt != t) {tilemap_set(map, tile_set_index(data, nt), tx, ty)}
			}
		}
	}


}
