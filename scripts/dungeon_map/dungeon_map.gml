//The dungeon map on the pause screen's QUEST page (rooms with obj_floor markers).
//One floor at a time (up/down picks the floor). Each room is drawn in its real shape, read
//from the room's tile layers: floor where there's no wall or hole, raised floor lighter.
//Rooms Link has been in are shown; with the
//dungeon's map, the rest too (darker). With the compass, the boss's room blinks red and
//chests not opened yet are dots. The map, compass and boss key are shown if Link has them.

#macro MAP_COL_UNSEEN make_colour_rgb(82,82,82)	//rooms only known from the map (#525252)
#macro MAP_COL_BOSS make_colour_rgb(222,124,112)	//the boss's room, with the compass (#de7c70)
#macro MAP_COL_CHEST make_colour_rgb(232,208,170)	//chests, with the compass (#e8d0aa)

///dungeon_map_build(map);
function dungeon_map_build(argument0) {
	//Run by menu_map_build (before the pause screen deactivates everything): adds the floors
	//to map. Each floor: {name, num, l, t, r, b, rooms: [[l, t, r, b, here, seen, runs]], has_boss, boss_x, boss_y, chests: [[x, y]]}
	//(runs: the room's floor, see dungeon_map_runs)
	var map = argument0;
	var d = global.dungeon;
	map.floors = [];
	var maps = [dungeon_map_tilemap(COLLISION_LAYER), dungeon_map_tilemap(PIT_ART_LAYER), dungeon_map_tilemap(WALL_LOW_LAYER)];
	map.has_map = global.dungeonMap[d];
	map.has_compass = global.dungeonCompass[d];
	map.has_boss_key = global.bossKey[d];
	map.title = dungeon_name(d);

	with (obj_floor) {
		array_push(map.floors, {name: floor_name, num: floor_num, l: bbox_left, t: bbox_top, r: bbox_right + 1, b: bbox_bottom + 1, rooms: [], has_boss: false, boss_x: 0, boss_y: 0, chests: []});
	}
	array_sort(map.floors, function(a, b) {return b.num - a.num});

	map.floor_view = 0;
	map.floor_link = -1;
	for (var i = 0; i < array_length(map.floors); i++) {
		var fl = map.floors[i];
		if (point_in_rectangle(map.link_x, map.link_y, fl.l, fl.t, fl.r - 1, fl.b - 1)) {
			map.floor_view = i;
			map.floor_link = i;
		}
		with (obj_cam_zone) {
			var cx = (bbox_left + bbox_right) / 2;
			var cy = (bbox_top + bbox_bottom) / 2;
			if (!point_in_rectangle(cx, cy, fl.l, fl.t, fl.r - 1, fl.b - 1)) continue;
			var seen = flag_get(zone_visit_flag(id));
			if (seen || map.has_map) {
				var runs = dungeon_map_runs(maps, bbox_left, bbox_top, bbox_right + 1, bbox_bottom + 1);
				array_push(fl.rooms, [bbox_left, bbox_top, bbox_right + 1, bbox_bottom + 1, id == global.cam_zone, seen, runs]);
			}
		}
		if (map.has_compass) {
			with (obj_boss_arena) {
				if (point_in_rectangle(x, y, fl.l, fl.t, fl.r - 1, fl.b - 1) && !flag_get(boss_flag(d))) {
					fl.has_boss = true;
					fl.boss_x = x;
					fl.boss_y = y;
				}
			}
			with (obj_chest) {
				if (!opened && point_in_rectangle(x, y, fl.l, fl.t, fl.r - 1, fl.b - 1)) {array_push(fl.chests, [bbox_left + 8, bbox_top + 8])}
			}
		}
	}
	return map;


}

///dungeon_map_tilemap(layer_name);
function dungeon_map_tilemap(argument0) {
	//The tilemap of one of the room's tile layers, or -1
	var lay = layer_get_id(argument0);
	if (lay == -1) return -1;
	return layer_tilemap_get_id(lay);


}

///dungeon_map_cell(maps, cx, cy);
function dungeon_map_cell(argument0, argument1, argument2) {
	//What one 16x16 cell is on the map: -1 nothing (wall, hole), 0 floor, 1 raised floor.
	//maps = [collision, holes, raised floor] tilemaps (-1 = the room doesn't have that layer)
	var m = argument0;
	for (var i = 0; i < 2; i++) {
		if (m[i] != -1 && tile_get_index(tilemap_get(m[i], argument1, argument2)) != 0) return -1;
	}
	if (m[2] != -1 && tile_get_index(tilemap_get(m[2], argument1, argument2)) != 0) return 1;
	return 0;


}

///dungeon_map_runs(maps, left, top, right, bottom);
function dungeon_map_runs(argument0, argument1, argument2, argument3, argument4) {
	//A room's floor as runs of cells along each row: [[x1, y1, x2, kind]] in room pixels
	//(kind: 0 floor, 1 raised floor)
	var m = argument0;
	var runs = [];
	var c1 = argument1 div 16;
	var c2 = argument3 div 16;
	for (var cy = argument2 div 16; cy < argument4 div 16; cy++) {
		var start = c1;
		var kind = -1;
		for (var cx = c1; cx <= c2; cx++) {
			var k = -1;
			if (cx < c2) {k = dungeon_map_cell(m, cx, cy)}
			if (k != kind) {
				if (kind >= 0) {array_push(runs, [start * 16, cy * 16, cx * 16, kind])}
				start = cx;
				kind = k;
			}
		}
	}
	return runs;


}

///dungeon_map_step(map);
function dungeon_map_step(argument0) {
	//Run by obj_pause_menu on the QUEST page: up/down looks at another floor
	var map = argument0;
	if (!variable_struct_exists(map, "floors") || menu_move == 0) return;
	var n = array_length(map.floors);
	var v = clamp(map.floor_view + menu_move, 0, n - 1);
	if (v != map.floor_view) {
		map.floor_view = v;
		audio_play_sound(menu_switch, 2, false);
	}


}

///dungeon_map_draw(x, y, w, h, map);
function dungeon_map_draw(argument0, argument1, argument2, argument3, argument4) {
	//The floor list on the left (the one being looked at highlighted, Link's floor marked),
	//the floor's rooms on the right, and the map/compass/boss key across the top
	var bx = argument0;
	var by = argument1;
	var bw = argument2;
	var bh = argument3;
	var map = argument4;
	var n = array_length(map.floors);
	if (n == 0) return;

	draw_set_halign(fa_center);
	menu_draw_text(bx + bw div 2, by + 5, map.title);
	draw_set_halign(fa_left);

	//Dungeon items, top right corner
	var ix = bx + bw - 22;
	var icons = [[map.has_boss_key, spr_boss_key], [map.has_compass, spr_dungeon_compass], [map.has_map, spr_dungeon_map]];
	for (var i = 0; i < 3; i++) {
		if (icons[i][0]) {draw_sprite(icons[i][1], 0, ix, by + 3)}
		ix -= 18;
	}

	//Floors, top floor first
	var list_x = bx + 8;
	var list_y = by + 22;
	for (var i = 0; i < n; i++) {
		var fl = map.floors[i];
		var col = MENU_COL_DIM;
		if (i == map.floor_view) {col = MENU_COL_CURSOR}
		menu_draw_text_colour(list_x + 8, list_y + i * 12, fl.name, col);
		if (i == map.floor_link && (current_time div 250) mod 2 == 0) {
			menu_draw_rect(list_x, list_y + i * 12 + 2, 4, 4, MENU_COL_MAP_HERE);
		}
		if (fl.has_boss) {menu_draw_rect(list_x + 42, list_y + i * 12 + 2, 4, 4, MAP_COL_BOSS)}
	}
	menu_draw_text(list_x, by + bh - 14, global.input_using_pad ? "D-PAD" : "UP/DN");

	//The floor's rooms, as big as fits
	var fl = map.floors[map.floor_view];
	var ax = bx + 56;
	var ay = by + 18;
	var aw = bw - 64;
	var ah = bh - 24;
	var fw = fl.r - fl.l;
	var fh = fl.b - fl.t;
	var sc = min((aw - 2) / fw, (ah - 2) / fh);
	var ox = ax + (aw - floor(fw * sc)) div 2;
	var oy = ay + (ah - floor(fh * sc)) div 2;
	var blink = (current_time div 250) mod 2 == 0;

	//Each room's floor: a black outline first (every run a pixel bigger), then the floor itself
	for (var pass = 0; pass < 2; pass++) {
		for (var i = 0; i < array_length(fl.rooms); i++) {
			var r = fl.rooms[i];
			var col = r[5] ? MENU_COL_MAP : MAP_COL_UNSEEN;
			if (r[4]) {col = MENU_COL_MAP_HERE}
			if (fl.has_boss && blink && point_in_rectangle(fl.boss_x, fl.boss_y, r[0], r[1], r[2] - 1, r[3] - 1)) {col = MAP_COL_BOSS}
			var col_raised = merge_colour(col, c_white, 0.35);
			var runs = r[6];
			for (var j = 0; j < array_length(runs); j++) {
				var u = runs[j];
				var rx = ox + floor((u[0] - fl.l) * sc);
				var ry = oy + floor((u[1] - fl.t) * sc);
				var rw = max(1, ox + floor((u[2] - fl.l) * sc) - rx);
				var rh = max(1, oy + floor((u[1] + 16 - fl.t) * sc) - ry);
				if (pass == 0) {menu_draw_rect(rx - 1, ry - 1, rw + 2, rh + 2, c_black)}
				else {menu_draw_rect(rx, ry, rw, rh, u[3] == 1 ? col_raised : col)}
			}
		}
	}
	for (var i = 0; i < array_length(fl.chests); i++) {
		var c = fl.chests[i];
		menu_draw_rect(ox + floor((c[0] - fl.l) * sc) - 1, oy + floor((c[1] - fl.t) * sc) - 1, 2, 2, MAP_COL_CHEST);
	}
	if (map.floor_view == map.floor_link && blink) {
		menu_draw_rect(ox + floor((map.link_x - fl.l) * sc) - 1, oy + floor((map.link_y - fl.t) * sc) - 1, 3, 3, MENU_COL_CURSOR);
	}


}
