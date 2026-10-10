//HUD drawing helpers. Call from a Draw GUI event.
//All HUD sprites use a top-left origin (0,0).
//
//Neutopia style: a black bar across the top of the window, above the play area.
//The window is SCREEN_W x SCREEN_H game pixels: the bar (HUD_HEIGHT) plus the 256x176 view
//underneath it, so Link can never walk under the HUD. The GUI layer covers the whole window
//(GUI y 0 is the top of the bar); hud_play_area() says where the view is on it.

#macro HUD_HEARTS_PER_ROW 8
#macro HUD_HEIGHT 32		//the black bar
#macro SCREEN_W 256			//whole window in game pixels (bar + 256x176 view)
#macro SCREEN_H 208
#macro SCREEN_SCALE 4		//window = 1024x832
#macro HUD_MAGIC_LEN_UP 62	//the magic meter's length once the magic upgrade has tripled it (the frame is 54)

///hud_set_gui_size();
function hud_set_gui_size() {
	//Window, application surface and GUI. Run at the start of every room (obj_hud_main).
	//The room's view port is left as it is in the room editor (1024x704 at 0,0), so GameMaker
	//draws the view 1:1 onto the application surface. The surface is then drawn under the
	//HUD bar by hud_draw_app_surface (obj_hud_main's Post Draw), not by GameMaker.
	//Moving the port with view_set_yport doesn't work for this: GameMaker keeps scaling the
	//room editor's port onto the surface, which stretched the view and cut off the bottom.
	var ww = SCREEN_W * SCREEN_SCALE;
	var wh = SCREEN_H * SCREEN_SCALE;

	//The window starts at the first room's port size (1024x704)
	if (!window_get_fullscreen() && (window_get_width() != ww || window_get_height() != wh)) {
		window_set_size(ww, wh);
		window_set_position((display_get_width() - ww) div 2, (display_get_height() - wh) div 2);
	}

	//Application surface = this room's view port
	if (view_enabled) {
		var sw = view_get_wport(0);
		var sh = view_get_hport(0);
		if (surface_get_width(application_surface) != sw || surface_get_height(application_surface) != sh) {
			surface_resize(application_surface, sw, sh);
		}
	}
	application_surface_draw_enable(false);

	hud_fit_gui();


}

///hud_fit_gui();
function hud_fit_gui() {
	//GUI = SCREEN_W x SCREEN_H stretched over the whole window, the same way as the game.
	//display_set_gui_size can't be used: with "Keep aspect ratio" it fits the GUI into the
	//application surface's box (1024x704), which squashed it and pushed the bar down over the view.
	//Run every frame (Post Draw) because window_set_size only takes effect a frame later.
	var ww = window_get_width();
	var wh = window_get_height();
	if (ww <= 0 || wh <= 0) {exit}
	display_set_gui_maximise(ww / SCREEN_W, wh / SCREEN_H, 0, 0);


}

///hud_play_area_window();
function hud_play_area_window() {
	//Where the application surface goes in the window, at SCREEN_SCALE: [x, y, w, h]
	//Rooms with Link put it under the HUD bar, other rooms (title screen) centre it.
	var ww = SCREEN_W * SCREEN_SCALE;
	var wh = SCREEN_H * SCREEN_SCALE;
	var sw = surface_get_width(application_surface);
	var sh = surface_get_height(application_surface);
	var top = 0;
	//Remember the room Link was seen in: menus that freeze the game (the flute, fishing) deactivate him too
	if (instance_exists(obj_link)) {global.hud_link_room = room}
	if (variable_global_exists("hud_link_room") && global.hud_link_room == room) {top = HUD_HEIGHT * SCREEN_SCALE}
	return [(ww - sw) div 2, top + (wh - top - sh) div 2, sw, sh];


}

///hud_draw_app_surface();
function hud_draw_app_surface() {
	//Post Draw: the application surface in its place in the window (black around it).
	//The window is stretched to fit the same way as the GUI, so the two always line up.
	var a = hud_play_area_window();
	var sx = window_get_width() / (SCREEN_W * SCREEN_SCALE);
	var sy = window_get_height() / (SCREEN_H * SCREEN_SCALE);
	draw_clear(c_black);
	gpu_set_blendenable(false);
	draw_surface_stretched(application_surface, a[0] * sx, a[1] * sy, a[2] * sx, a[3] * sy);
	gpu_set_blendenable(true);


}

///hud_play_area();
function hud_play_area() {
	//Where the view is on the GUI layer: [x, y, w, h]
	var a = hud_play_area_window();
	var sx = display_get_gui_width() / (SCREEN_W * SCREEN_SCALE);
	var sy = display_get_gui_height() / (SCREEN_H * SCREEN_SCALE);
	return [round(a[0] * sx), round(a[1] * sy), round(a[2] * sx), round(a[3] * sy)];


}

///hud_snapshot();
function hud_snapshot() {
	//Picture of the play area only (not the bar), for menus that freeze the game.
	//Draw it over the view (Draw event) or over hud_play_area() (Draw GUI).
	//The application surface is only the view, so this is the whole surface.
	var s = application_surface;
	return sprite_create_from_surface(s, 0, 0, surface_get_width(s), surface_get_height(s), false, false, 0, 0);


}

///hud_draw_letterbox();
function hud_draw_letterbox() {
	//Black over everything outside the play area (the window is bigger than some views)
	var gw = display_get_gui_width();
	var gh = display_get_gui_height();
	var a = hud_play_area();
	menu_draw_rect(0, 0, gw, a[1], c_black);
	menu_draw_rect(0, a[1] + a[3], gw, gh - a[1] - a[3], c_black);
	menu_draw_rect(0, a[1], a[0], a[3], c_black);
	menu_draw_rect(a[0] + a[2], a[1], gw - a[0] - a[2], a[3], c_black);


}

///hud_draw_bar();
function hud_draw_bar() {
	//The black bar: hearts with magic underneath on the left, money/keys and bombs/arrows
	//in the middle, the X, Y, B and A item boxes on the right. Everything is laid out for the
	//biggest it can get (16 hearts, the full bomb bag and quiver, the tripled magic meter and
	//its "3x"), so nothing moves or overlaps.
	var gw = display_get_gui_width();
	menu_draw_rect(0, 0, gw, HUD_HEIGHT, c_black);

	//Hearts (two rows of HUD_HEARTS_PER_ROW), magic underneath
	var life_x = 4;
	var life_y = 3;
	var hearts_w = sprite_get_width(spr_hud_heart) * HUD_HEARTS_PER_ROW;
	var hearts_h = sprite_get_height(spr_hud_heart) * ceil(PLAYER_HEARTS_MAX / HUD_HEARTS_PER_ROW);
	hud_draw_hearts(life_x, life_y);
	hud_draw_magic(life_x, life_y + hearts_h + 2);

	//Item boxes in the right corner: X = third item, Y = second item, B = sword (by tier), A = equipped item
	var sw = sprite_get_width(spr_hud_slot);
	var btn_gap = 2;
	var btn_h = sprite_get_height(spr_hud_glyph) - 4 + sprite_get_height(spr_hud_slot);
	var btn_x = gw - 4 - sw * 4 - btn_gap * 3;
	var btn_y = (HUD_HEIGHT - btn_h) div 2;
	var sword_spr = -1;
	if (global.swordTier > 0) {sword_spr = spr_menu_sword}
	hud_draw_button(btn_x, btn_y, 3, item_get_sprite(global.itemX), item_get_frame(global.itemX));
	hud_draw_button(btn_x + sw + btn_gap, btn_y, 2, item_get_sprite(global.itemY), item_get_frame(global.itemY));
	hud_draw_button(btn_x + (sw + btn_gap) * 2, btn_y, 1, sword_spr, global.swordTier - 1);
	hud_draw_button(btn_x + (sw + btn_gap) * 3, btn_y, 0, item_get_sprite(global.itemA), item_get_frame(global.itemA));

	//Counters, two columns centred in the space between: money over bombs, keys over arrows.
	//Bombs and arrows are spaced for the biggest bag and quiver (64 and 80).
	var col_gap = 6;
	var col1_w = max(hud_counter_width(global.pMoneyMax), hud_counter_width(64));
	var col2_w = max(hud_counter_width(global.pKeysMax), hud_counter_width(80));
	var left = max(life_x + hearts_w, life_x + HUD_MAGIC_LEN_UP + 18);	//past the hearts, and the long magic meter's "3x"
	var cx = left + (btn_x - left - (col1_w + col_gap + col2_w)) div 2;
	var row1 = 6;
	var row2 = 18;
	hud_draw_counter(cx, row1, 0, global.pMoney);
	hud_draw_counter(cx, row2, 2, global.pBombs);
	hud_draw_counter(cx + col1_w + col_gap, row1, 1, global.pKeys);
	hud_draw_counter(cx + col1_w + col_gap, row2, 3, global.pArrows);


}

///hud_draw_hearts(x, y);
function hud_draw_hearts(argument0, argument1) {
	//One heart = 2 health. Frames: 0 full, 1 half, 2 empty. HUD_HEARTS_PER_ROW per row.
	//Returns the height of the hearts drawn.
	var xx = argument0;
	var yy = argument1;
	var hearts = ceil(global.pHealthMax / 2);
	var w = sprite_get_width(spr_hud_heart);
	var h = sprite_get_height(spr_hud_heart);

	for (var i = 0; i < hearts; i++) {
		var hp = global.pHealth - (i * 2);
		var frame = 2;
		if (hp >= 2) {frame = 0}
		else if (hp == 1) {frame = 1}
		draw_sprite(spr_hud_heart, frame, xx + (i mod HUD_HEARTS_PER_ROW) * w, yy + (i div HUD_HEARTS_PER_ROW) * h);
	}

	return ceil(hearts / HUD_HEARTS_PER_ROW) * h;


}

///hud_draw_magic(x, y);
function hud_draw_magic(argument0, argument1) {
	//Fill is stretched across the frame's inside (2px border on each side).
	//After the magic upgrade (it triples the magic, see magic_upgraded) the meter is a little
	//longer (HUD_MAGIC_LEN_UP) and a small "3x" sits after it.
	var xx = argument0;
	var yy = argument1;
	var fw = sprite_get_width(spr_hud_magic_frame);
	var fh = sprite_get_height(spr_hud_magic_frame);
	var up = magic_upgraded();
	var total = up ? HUD_MAGIC_LEN_UP : fw;
	var len = total - 4;
	var fill = 0;
	if (global.pMagicMax > 0) {
		fill = floor(len * global.pMagic / global.pMagicMax);
	}

	if (up) {
		//The frame's ends as they are, its middle column stretched in between
		var cap = 4;
		draw_sprite_part(spr_hud_magic_frame, 0, 0, 0, cap, fh, xx, yy);
		draw_sprite_part_ext(spr_hud_magic_frame, 0, cap, 0, 1, fh, xx + cap, yy, total - cap * 2, 1, c_white, 1);
		draw_sprite_part(spr_hud_magic_frame, 0, fw - cap, 0, cap, fh, xx + total - cap, yy);
	} else {
		draw_sprite(spr_hud_magic_frame, 0, xx, yy);
	}
	if (fill > 0) {
		draw_sprite_ext(spr_hud_magic_fill, 0, xx + 2, yy + 2, fill, 1, 0, c_white, 1);
	}
	//"3x" (the counters' digits, with their shadow)
	if (up) {
		var dx = xx + total + 2;
		var dy = yy;
		draw_sprite_ext(spr_hud_digits, 3, dx + 1, dy + 1, 1, 1, 0, c_black, 1);
		draw_sprite(spr_hud_digits, 3, dx, dy);
		draw_sprite_ext(spr_hud_digits, 10, dx + 8, dy + 1, 1, 1, 0, c_black, 1);
		draw_sprite(spr_hud_digits, 10, dx + 7, dy);
	}


}

///hud_counter_width(max_value);
function hud_counter_width(argument0) {
	//Width of a counter showing up to max_value: icon + "x" + digits.
	//Use it to space counters so they don't shift as the numbers change.
	return (2 + string_length(string(argument0))) * sprite_get_width(spr_hud_digits);


}

///hud_draw_counter(x, y, icon, value);
function hud_draw_counter(argument0, argument1, argument2, argument3) {
	//Zelda 1 style "icon x 12".
	//spr_hud_counters frames: 0 money, 1 keys, 2 bombs, 3 arrows.
	//spr_hud_digits frames: 0-9, 10 = "x". Digits get a 1px black shadow.
	var xx = argument0;
	var yy = argument1;
	var str = string(argument3);
	var w = sprite_get_width(spr_hud_digits);

	draw_sprite(spr_hud_counters, argument2, xx, yy);
	for (var i = 0; i <= string_length(str); i++) {
		var frame = 10;
		if (i > 0) {frame = real(string_char_at(str, i))}
		draw_sprite_ext(spr_hud_digits, frame, xx + w * (i + 1) + 1, yy + 1, 1, 1, 0, c_black, 1);
		draw_sprite(spr_hud_digits, frame, xx + w * (i + 1), yy);
	}


}

///hud_draw_button(x, y, button, item_sprite, item_frame);
function hud_draw_button(argument0, argument1, argument2, argument3, argument4) {
	//Zelda 1 style item box with the button glyph sitting on its top edge.
	//button: 0 = A, 1 = B, 2 = Y, 3 = X. item_sprite: -1 for an empty slot.
	//The item is drawn 2px inside the slot's border.
	var xx = argument0;
	var yy = argument1;
	var spr = argument3;

	var gw = sprite_get_width(spr_hud_glyph);
	var gh = sprite_get_height(spr_hud_glyph);
	var sy = yy + gh - 4;	//glyph overlaps the slot by 4px

	draw_sprite(spr_hud_slot, 0, xx, sy);
	if (spr != -1) {
		draw_sprite(spr, argument4, xx + 2 + sprite_get_xoffset(spr), sy + 2 + sprite_get_yoffset(spr));
	}
	hud_draw_glyph(argument2, xx + (sprite_get_width(spr_hud_slot) - gw) div 2, yy);


}

///hud_draw_glyph(button, x, y);
function hud_draw_glyph(argument0, argument1, argument2) {
	//A button's glyph (9x9), keyboard or gamepad (whichever was used last).
	//button: 0 = A, 1 = B, 2 = Y, 3 = X.
	//spr_hud_glyph frames: 0 Z key, 1 X key, 2 C key, 3 pad A, 4 pad B, 5 pad Y.
	//spr_hud_glyph_x frames: 0 V key, 1 pad X.
	if (argument0 == 3) {
		draw_sprite(spr_hud_glyph_x, global.input_using_pad ? 1 : 0, argument1, argument2);
		return;
	}
	draw_sprite(spr_hud_glyph, argument0 + (global.input_using_pad ? 3 : 0), argument1, argument2);


}

///hud_draw_floor_name();
function hud_draw_floor_name() {
	//A dungeon floor's name ("2F") in the play area's top left for a moment after changing floors
	if (global.floor_name_timer <= 0) return;
	global.floor_name_timer--;
	if (!variable_global_exists("hud_font")) {
		global.hud_font = font_add_sprite_ext(spr_menu_font, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/", false, 0);
	}
	var a = hud_play_area();
	var w = string_length(global.floor_name) * 8 + 8;
	var fade = min(1, global.floor_name_timer / 15);
	draw_sprite_ext(spr_pixel, 0, a[0] + 6, a[1] + 6, w, 14, 0, c_black, fade);
	draw_set_alpha(fade);
	draw_set_font(global.hud_font);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	menu_draw_text(a[0] + 10, a[1] + 9, global.floor_name);
	draw_set_alpha(1);


}
