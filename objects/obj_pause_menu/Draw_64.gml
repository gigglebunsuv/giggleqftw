/// @description Draw the pause screen

var gw = display_get_gui_width();
var gh = display_get_gui_height();
var pad = 0;
if (global.input_using_pad) {pad = 2}

//Frozen game, darkened (half see-through over black)
menu_draw_rect(0, 0, gw, gh, c_black);
draw_sprite_stretched_ext(snap, 0, 0, 0, gw, gh, c_white, 0.5);

draw_set_font(menu_font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

//--- Items (left)
menu_draw_box(items_x, items_y, items_w, items_h);
menu_draw_text(items_x + 8, items_y + 6, "ITEMS");

for (var i = 0; i < grid_cols * grid_rows; i++) {
	var sx = grid_x + (i mod grid_cols) * cell;
	var sy = grid_y + (i div grid_cols) * cell;
	menu_draw_rect(sx + 2, sy + 2, cell - 4, cell - 4, MENU_COL_SLOT);

	if (i < ITEM.COUNT && global.item_have[i]) {
		draw_sprite(item_get_sprite(i), 0, sx + (cell - 16) div 2, sy + (cell - 16) div 2);
		//Small A glyph on the equipped item
		if (i == global.itemA) {
			draw_sprite(spr_hud_glyph, 0 + pad, sx + cell - sprite_get_width(spr_hud_glyph), sy + cell - sprite_get_height(spr_hud_glyph));
		}
	}
}

//Blinking cursor
if ((current_time div 250) mod 2 == 0) {
	menu_draw_frame(grid_x + (cursor mod grid_cols) * cell, grid_y + (cursor div grid_cols) * cell, cell, cell, 2, MENU_COL_CURSOR);
}

//Button hints
var hint_y = grid_y + grid_rows * cell + 6;
draw_sprite(spr_hud_glyph, 0 + pad, items_x + 8, hint_y - 1);
menu_draw_text(items_x + 20, hint_y, "EQUIP");
var close_str = "ENTER: CLOSE";
if (global.input_using_pad) {close_str = "START: CLOSE"}
menu_draw_text(items_x + 8, hint_y + 12, close_str);

//--- Selected item (top right)
menu_draw_box(side_x, sel_y, side_w, sel_h);
if (cursor < ITEM.COUNT && global.item_have[cursor]) {
	draw_sprite(item_get_sprite(cursor), 0, side_x + (side_w - 16) div 2, sel_y + 8);
	draw_set_halign(fa_center);
	menu_draw_text(side_x + side_w div 2, sel_y + 28, item_get_name(cursor));
	draw_set_halign(fa_left);
}

//--- The Bun
menu_draw_box(side_x, bun_y, side_w, bun_h);
draw_set_halign(fa_center);
menu_draw_text(side_x + side_w div 2, bun_y + 6, "THE BUN");
draw_set_halign(fa_left);
var bun_gap = 8;
var bun_x = side_x + (side_w - (BUN_PIECES * 16 + (BUN_PIECES - 1) * bun_gap)) div 2;
for (var i = 0; i < BUN_PIECES; i++) {
	var frame = 0;
	if (global.bunPieces[i]) {frame = i + 1}
	draw_sprite(spr_menu_bun, frame, bun_x + i * (16 + bun_gap), bun_y + 24);
}

//--- Equipment: sword, shield, armor with their tier underneath
menu_draw_box(side_x, equip_y, side_w, equip_h);
draw_set_halign(fa_center);
menu_draw_text(side_x + side_w div 2, equip_y + 6, "EQUIPMENT");
var eq_spr = [spr_menu_sword, spr_menu_shield, spr_menu_armor];
var eq_tier = [global.swordTier, global.shieldTier, global.armorTier];
var eq_gap = 12;
var eq_x = side_x + (side_w - (3 * 16 + 2 * eq_gap)) div 2;
for (var i = 0; i < 3; i++) {
	var ex = eq_x + i * (16 + eq_gap);
	if (eq_tier[i] > 0) {
		draw_sprite(eq_spr[i], eq_tier[i] - 1, ex, equip_y + 22);
		menu_draw_text(ex + 8, equip_y + 42, "L" + string(eq_tier[i]));
	} else {
		menu_draw_text(ex + 8, equip_y + 42, "-");
	}
}
draw_set_halign(fa_left);
