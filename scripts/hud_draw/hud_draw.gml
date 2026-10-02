//HUD drawing helpers. Call from a Draw GUI event.
//All HUD sprites use a top-left origin (0,0).
//Zelda 1 style band drawn over the top HUD_HEIGHT pixels of the view.

#macro HUD_HEARTS_PER_ROW 8
#macro HUD_HEIGHT 32

///hud_set_gui_size();
function hud_set_gui_size() {
	//Draw the GUI at game resolution so the pixel art lines up with the view
	if (view_enabled) {
		display_set_gui_size(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]));
	} else {
		display_set_gui_size(room_width, room_height);
	}


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
	//Fill is stretched across the frame's inside (2px border on each side)
	var xx = argument0;
	var yy = argument1;
	var len = sprite_get_width(spr_hud_magic_frame) - 4;
	var fill = 0;
	if (global.pMagicMax > 0) {
		fill = floor(len * global.pMagic / global.pMagicMax);
	}

	draw_sprite(spr_hud_magic_frame, 0, xx, yy);
	if (fill > 0) {
		draw_sprite_ext(spr_hud_magic_fill, 0, xx + 2, yy + 2, fill, 1, 0, c_white, 1);
	}


}

///hud_draw_counter(x, y, icon, value);
function hud_draw_counter(argument0, argument1, argument2, argument3) {
	//Zelda 1 style "icon x 12".
	//spr_hud_counters frames: 0 money, 1 keys, 2 bombs, 3 arrows.
	//spr_hud_digits frames: 0-9, 10 = "x".
	var xx = argument0;
	var yy = argument1;
	var str = string(argument3);
	var w = sprite_get_width(spr_hud_digits);

	draw_sprite(spr_hud_counters, argument2, xx, yy);
	draw_sprite(spr_hud_digits, 10, xx + w, yy);
	for (var i = 1; i <= string_length(str); i++) {
		draw_sprite(spr_hud_digits, real(string_char_at(str, i)), xx + w * (i + 1), yy);
	}


}

///hud_draw_button(x, y, button, item_sprite);
function hud_draw_button(argument0, argument1, argument2, argument3) {
	//Zelda 1 style item box with the button glyph sitting on its top edge.
	//button: 0 = A, 1 = B. item_sprite: -1 for an empty slot.
	//spr_hud_glyph frames: 0 Z key, 1 X key, 2 pad A, 3 pad B.
	//The item is drawn 2px inside the slot's border.
	var xx = argument0;
	var yy = argument1;
	var spr = argument3;
	var glyph = argument2;
	if (global.input_using_pad) {glyph += 2}

	var gw = sprite_get_width(spr_hud_glyph);
	var gh = sprite_get_height(spr_hud_glyph);
	var sy = yy + gh - 4;	//glyph overlaps the slot by 4px

	draw_sprite(spr_hud_slot, 0, xx, sy);
	if (spr != -1) {
		draw_sprite(spr, 0, xx + 2 + sprite_get_xoffset(spr), sy + 2 + sprite_get_yoffset(spr));
	}
	draw_sprite(spr_hud_glyph, glyph, xx + (sprite_get_width(spr_hud_slot) - gw) div 2, yy);


}

///hud_draw_minimap(x, y, w, h, map_colour, link_colour);
function hud_draw_minimap(argument0, argument1, argument2, argument3, argument4, argument5) {
	//One cell per flip-screen in this room, Link's screen is highlighted.
	//The map is centred inside the w x h area. Cells are 8px at most.
	if (!view_enabled || !instance_exists(obj_link)) exit;

	var vw = camera_get_view_width(view_camera[0]);
	var vh = camera_get_view_height(view_camera[0]);
	var cols = max(1, ceil(room_width / vw));
	var rows = max(1, ceil(room_height / vh));
	var cell = max(1, min(argument2 div cols, argument3 div rows, 8));
	var mw = cols * cell;
	var mh = rows * cell;
	var mx = argument0 + (argument2 - mw) div 2;
	var my = argument1 + (argument3 - mh) div 2;

	var cx = clamp(obj_link.x div vw, 0, cols - 1);
	var cy = clamp(obj_link.y div vh, 0, rows - 1);
	var dot = max(1, cell - 1);

	draw_sprite_ext(spr_pixel, 0, mx, my, mw, mh, 0, argument4, 1);
	draw_sprite_ext(spr_pixel, 0, mx + cx * cell, my + cy * cell, dot, dot, 0, argument5, 1);


}
