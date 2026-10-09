//Drawing helpers for the pause screen and other menus. Call from a Draw GUI event.
//Everything is drawn with spr_pixel (1x1 white) so the colours are easy to change here.
//Boxes are black with a gold trim.

#macro MENU_COL_BOX c_black
#macro MENU_COL_SLOT make_colour_rgb(50,19,0)		//empty item slots (#321300)
#macro MENU_COL_BORDER make_colour_rgb(200,145,62)	//gold trim (#c8913e)
#macro MENU_COL_TRIM_DARK make_colour_rgb(111,63,0)	//inner edge of the trim (#6f3f00)
#macro MENU_COL_CURSOR make_colour_rgb(248,216,0)
#macro MENU_COL_DIM make_colour_rgb(160,160,160)	//pages that aren't open (#a0a0a0)
#macro MENU_COL_MAP make_colour_rgb(160,160,160)	//map rooms (#a0a0a0)
#macro MENU_COL_MAP_HERE make_colour_rgb(99,196,70)	//the room Link is in (#63c446)
#macro MENU_EQUIP_SLOT 20	//size of an equipment slot (16px icon + 2px each side)
#macro MENU_EQUIP_TOP 16	//slots start this far below the box's top
#macro MENU_EQUIP_GAP 8	//space between equipment slots

///menu_draw_rect(x, y, w, h, colour);
function menu_draw_rect(argument0, argument1, argument2, argument3, argument4) {
	draw_sprite_ext(spr_pixel, 0, argument0, argument1, argument2, argument3, 0, argument4, 1);


}

///menu_draw_frame(x, y, w, h, thickness, colour);
function menu_draw_frame(argument0, argument1, argument2, argument3, argument4, argument5) {
	//Outline only, drawn inside the w x h area
	var xx = argument0;
	var yy = argument1;
	var w = argument2;
	var h = argument3;
	var t = argument4;
	menu_draw_rect(xx, yy, w, t, argument5);
	menu_draw_rect(xx, yy + h - t, w, t, argument5);
	menu_draw_rect(xx, yy, t, h, argument5);
	menu_draw_rect(xx + w - t, yy, t, h, argument5);


}

///menu_draw_box(x, y, w, h);
function menu_draw_box(argument0, argument1, argument2, argument3) {
	//Black edge, gold trim (darker on its inside edge), black inside
	menu_draw_rect(argument0, argument1, argument2, argument3, c_black);
	menu_draw_frame(argument0 + 1, argument1 + 1, argument2 - 2, argument3 - 2, 1, MENU_COL_BORDER);
	menu_draw_frame(argument0 + 2, argument1 + 2, argument2 - 4, argument3 - 4, 1, MENU_COL_TRIM_DARK);
	menu_draw_rect(argument0 + 3, argument1 + 3, argument2 - 6, argument3 - 6, MENU_COL_BOX);


}

///menu_draw_text(x, y, string);
function menu_draw_text(argument0, argument1, argument2) {
	//White text with a 1px black shadow. Uses the current font and alignment.
	menu_draw_text_colour(argument0, argument1, argument2, c_white);


}

///menu_draw_text_colour(x, y, string, colour);
function menu_draw_text_colour(argument0, argument1, argument2, argument3) {
	draw_set_colour(c_black);
	draw_text(argument0 + 1, argument1 + 1, argument2);
	draw_set_colour(argument3);
	draw_text(argument0, argument1, argument2);
	draw_set_colour(c_white);


}

///menu_draw_choice(centre_x, y, string, selected);
function menu_draw_choice(argument0, argument1, argument2, argument3) {
	//A centred menu choice (menu font). The selected one is yellow with blinking markers
	//on both sides. Leaves the alignment centred.
	draw_set_halign(fa_center);
	if (!argument3) {
		menu_draw_text(argument0, argument1, argument2);
		return;
	}
	menu_draw_text_colour(argument0, argument1, argument2, MENU_COL_CURSOR);
	if ((current_time div 250) mod 2 == 0) {
		var half = string_length(argument2) * 4;	//letters are 8 wide
		menu_draw_rect(argument0 - half - 9, argument1 + 2, 4, 4, MENU_COL_CURSOR);
		menu_draw_rect(argument0 + half + 5, argument1 + 2, 4, 4, MENU_COL_CURSOR);
	}


}

///menu_draw_equipment(x, y, w, h, title, sprites, frames, have);
function menu_draw_equipment(argument0, argument1, argument2, argument3, argument4, argument5, argument6, argument7) {
	//Box with a centred title and a row of centred slots underneath.
	//sprites, frames, have: arrays, one entry per slot. Slots you don't have stay empty.
	//Returns the x of the first slot.
	var xx = argument0;
	var yy = argument1;
	var w = argument2;
	var spr = argument5;
	var frame = argument6;
	var have = argument7;
	var n = array_length(spr);

	menu_draw_box(xx, yy, w, argument3);
	draw_set_halign(fa_center);
	menu_draw_text(xx + w div 2, yy + 5, argument4);
	draw_set_halign(fa_left);

	var sx = xx + (w - (n * MENU_EQUIP_SLOT + (n - 1) * MENU_EQUIP_GAP)) div 2;
	for (var i = 0; i < n; i++) {
		var ex = sx + i * (MENU_EQUIP_SLOT + MENU_EQUIP_GAP);
		menu_draw_rect(ex, yy + MENU_EQUIP_TOP, MENU_EQUIP_SLOT, MENU_EQUIP_SLOT, MENU_COL_SLOT);
		if (have[i]) {draw_sprite(spr[i], frame[i], ex + 2, yy + MENU_EQUIP_TOP + 2)}
	}
	return sx;


}

///menu_draw_text_commas(x, y, string, colour);
function menu_draw_text_commas(argument0, argument1, argument2, argument3) {
	//Left-aligned menu font text with a shadow, like menu_draw_text_colour. The menu font has
	//no comma, so a comma is drawn as an apostrophe moved down to the bottom of the letter.
	var str = argument2;
	draw_set_halign(fa_left);
	menu_draw_text_colour(argument0, argument1, string_replace_all(str, ",", " "), argument3);
	if (string_pos(",", str) == 0) return;
	for (var i = 1; i <= string_length(str); i++) {
		if (string_char_at(str, i) == ",") {menu_draw_text_colour(argument0 + (i - 1) * 8, argument1 + 5, "'", argument3)}	//letters are 8 wide
	}


}

///menu_draw_bracket(x, y, right, colour);
function menu_draw_bracket(argument0, argument1, argument2, argument3) {
	//A [ (right = false) or ] (right = true), 4x8 like a menu font letter, with a shadow.
	//The menu font has no brackets.
	var xx = argument0;
	var yy = argument1;
	var cols = [c_black, argument3];
	for (var i = 0; i < 2; i++) {
		var o = 1 - i;	//shadow first, 1px down and right
		var vx = xx + o + 1;
		if (argument2) {vx = xx + o + 2}
		menu_draw_rect(vx, yy + o, 1, 8, cols[i]);
		menu_draw_rect(xx + o + 1, yy + o, 2, 1, cols[i]);
		menu_draw_rect(xx + o + 1, yy + o + 7, 2, 1, cols[i]);
	}


}

///menu_map_build();
function menu_map_build() {
	//What menu_draw_map draws, taken before the pause screen deactivates everything.
	//Rooms with obj_cam_zone (dungeons, the overworld): one rectangle per zone, biggest first
	//so zones inside others draw on top. Other rooms: one rectangle per flip-screen.
	//Each rectangle is [left, top, right, bottom, Link's room?].
	var map = {rooms: [], link_x: -1, link_y: -1};
	if (instance_exists(obj_link)) {
		map.link_x = obj_link.x;
		map.link_y = obj_link.y;
	}

	//Dungeons with floors: one floor at a time (see the dungeon_map script)
	if (instance_exists(obj_floor) && global.dungeon > 0) {return dungeon_map_build(map)}

	if (instance_exists(obj_cam_zone)) {
		with (obj_cam_zone) {
			array_push(map.rooms, [bbox_left, bbox_top, bbox_right + 1, bbox_bottom + 1, id == global.cam_zone]);
		}
		array_sort(map.rooms, function(a, b) {
			return (b[2] - b[0]) * (b[3] - b[1]) - (a[2] - a[0]) * (a[3] - a[1]);
		});
		return map;
	}

	var vw = room_width;
	var vh = room_height;
	if (view_enabled) {
		vw = camera_get_view_width(view_camera[0]);
		vh = camera_get_view_height(view_camera[0]);
	}
	var cols = max(1, ceil(room_width / vw));
	var rows = max(1, ceil(room_height / vh));
	var lx = clamp(map.link_x div vw, 0, cols - 1);
	var ly = clamp(map.link_y div vh, 0, rows - 1);
	for (var j = 0; j < rows; j++) {
		for (var i = 0; i < cols; i++) {
			array_push(map.rooms, [i * vw, j * vh, min((i + 1) * vw, room_width), min((j + 1) * vh, room_height), i == lx && j == ly]);
		}
	}
	return map;


}

///menu_draw_map(x, y, w, h, map);
function menu_draw_map(argument0, argument1, argument2, argument3, argument4) {
	//The room's map from menu_map_build, as big as fits in the w x h area and centred in it.
	//Rooms have a 1px black border, Link's room is green and Link is a blinking dot.
	var map = argument4;
	var n = array_length(map.rooms);
	if (n == 0) return;

	var sc = min((argument2 - 2) / room_width, (argument3 - 2) / room_height);
	var ox = argument0 + (argument2 - floor(room_width * sc)) div 2;
	var oy = argument1 + (argument3 - floor(room_height * sc)) div 2;

	for (var i = 0; i < n; i++) {
		var r = map.rooms[i];
		var rx = ox + floor(r[0] * sc);
		var ry = oy + floor(r[1] * sc);
		var rw = max(1, ox + floor(r[2] * sc) - rx);
		var rh = max(1, oy + floor(r[3] * sc) - ry);
		var col = MENU_COL_MAP;
		if (r[4]) {col = MENU_COL_MAP_HERE}
		menu_draw_rect(rx - 1, ry - 1, rw + 2, rh + 2, c_black);
		menu_draw_rect(rx, ry, rw, rh, col);
	}

	if (map.link_x >= 0 && (current_time div 250) mod 2 == 0) {
		menu_draw_rect(ox + floor(map.link_x * sc) - 1, oy + floor(map.link_y * sc) - 1, 3, 3, MENU_COL_CURSOR);
	}


}
