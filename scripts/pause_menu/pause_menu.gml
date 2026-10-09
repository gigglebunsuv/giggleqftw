//The pause screen's pages. Run by obj_pause_menu (its Step and Draw GUI events).
//[ and ] (LB and RB) switch pages:
//	0 ITEMS		the item grid (put items on A or Y), the buttons, preassigned equipment (sword, boots)
//	1 QUEST		passive equipment (gloves, armor, flippers), The Bun, the map of this room
//				(in a dungeon: one floor at a time, up/down for the others, see the dungeon_map script)
//	2 SETTINGS	resume, save (save_files script), options (the controls list, the volume: options_menu script),
//				back to the title screen
//The screen covers the whole window (the HUD bar too). GUI is 256x208.

#macro PAUSE_PAGES 3

///pause_page_name(page);
function pause_page_name(argument0) {
	switch (argument0) {
		case 0: return "ITEMS";
		case 1: return "QUEST";
		case 2: return "SETTINGS";
	}
	return "";


}

///pause_close();
function pause_close() {
	//Back to the game. Link ignores the button that closed it.
	instance_activate_all();
	global.pause_block = true;
	instance_destroy();


}

///pause_step_items();
function pause_step_items() {
	//Move around the grid (wraps at the edges)
	if (menu_move_h != 0 || menu_move != 0) {
		var cx = ((cursor mod grid_cols) + menu_move_h + grid_cols) mod grid_cols;
		var cy = ((cursor div grid_cols) + menu_move + grid_rows) mod grid_rows;
		cursor = cy * grid_cols + cx;
		audio_play_sound(menu_switch, 2, false);
	}

	//Put the item under the cursor on A or Y (swaps if it's on the other one)
	var sel = grid[cursor];
	if ((act_a || act_y) && sel != ITEM.NONE && global.item_have[sel]) {
		if (act_a) {item_equip(sel, 0)}
		else {item_equip(sel, 1)}
		audio_play_sound(menu_select, 3, false);
	}


}

///pause_step_settings();
function pause_step_settings() {
	//Options screen: B or its Back goes back to the list
	if (show_options) {
		if (options_step(act_a)) {show_options = false}
		return;
	}

	//Resume, Save and continue, Save and quit (to the title), Options, Main menu
	//(A twice: starts the whole game again from the title, without saving)
	if (save_msg_timer > 0) {save_msg_timer--}
	if (menu_move != 0) {
		set_cursor = (set_cursor + menu_move + array_length(set_choices)) mod array_length(set_choices);
		confirm_quit = false;
		audio_play_sound(menu_switch, 2, false);
	}
	if (!act_a) return;
	switch (set_cursor) {
		case 0:
			pause_close();
			break;
		case 1:
		case 2:
			//Save to this game's file (save_files script). Games from the DEBUG menu have none.
			confirm_quit = false;
			save_msg_timer = 60;
			if (!save_current_game()) {
				save_msg = "NO SAVE FILE";
				audio_play_sound(snd_bonk, 2, false);
				break;
			}
			save_msg = "SAVED";
			audio_play_sound(menu_select, 3, false);
			if (set_cursor == 2) {
				instance_activate_all();
				game_restart();	//the title screen is the first room
			}
			break;
		case 3:
			show_options = true;
			options_open((page_h - 40) div 10);
			audio_play_sound(menu_select, 3, false);
			break;
		case 4:
			if (confirm_quit) {
				audio_play_sound(menu_select, 3, false);
				instance_activate_all();
				game_restart();	//the title screen is the first room
				break;
			}
			confirm_quit = true;
			audio_play_sound(menu_switch, 2, false);
			break;
	}


}

///pause_draw_page_hint(x, y);
function pause_draw_page_hint(argument0, argument1) {
	//"[ ]: PAGE" (keyboard) or "LB RB: PAGE" (gamepad)
	if (global.input_using_pad) {
		menu_draw_text(argument0, argument1, "LB RB: PAGE");
	} else {
		menu_draw_bracket(argument0, argument1, false, c_white);
		menu_draw_bracket(argument0 + 8, argument1, true, c_white);
		menu_draw_text(argument0 + 16, argument1, ": PAGE");
	}


}

///pause_draw_tabs();
function pause_draw_tabs() {
	//The page names along the top, the open one highlighted, [ and ] (LB and RB) at the ends
	var gw = display_get_gui_width();
	menu_draw_box(4, 4, gw - 8, 16);

	draw_set_halign(fa_center);
	var inner_x = 28;
	var inner_w = gw - 56;
	for (var i = 0; i < PAUSE_PAGES; i++) {
		var tx = inner_x + inner_w * (2 * i + 1) div (PAUSE_PAGES * 2);
		var col = MENU_COL_DIM;
		if (i == page) {col = MENU_COL_CURSOR}
		menu_draw_text_colour(tx, 8, pause_page_name(i), col);
	}

	if (global.input_using_pad) {
		draw_set_halign(fa_left);
		menu_draw_text(9, 8, "LB");
		draw_set_halign(fa_right);
		menu_draw_text(gw - 9, 8, "RB");
	} else {
		menu_draw_bracket(10, 8, false, c_white);
		menu_draw_bracket(gw - 14, 8, true, c_white);
	}
	draw_set_halign(fa_left);


}

///pause_draw_items();
function pause_draw_items() {
	var pad = 0;
	if (global.input_using_pad) {pad = 3}
	var gl_w = sprite_get_width(spr_hud_glyph);
	var gl_h = sprite_get_height(spr_hud_glyph);

	//--- Item grid (left), the selected item's name underneath
	menu_draw_box(items_x, page_y, items_w, page_h);
	menu_draw_text(items_x + 8, page_y + 6, "ITEMS");

	for (var i = 0; i < grid_cols * grid_rows; i++) {
		var sx = grid_x + (i mod grid_cols) * cell;
		var sy = grid_y + (i div grid_cols) * cell;
		menu_draw_rect(sx + 2, sy + 2, cell - 4, cell - 4, MENU_COL_SLOT);

		var it = grid[i];
		if (it != ITEM.NONE && global.item_have[it]) {
			draw_sprite(item_get_sprite(it), item_get_frame(it), sx + (cell - 16) div 2, sy + (cell - 16) div 2);
			//Small A / Y glyph on the equipped items (A bottom right, Y bottom left)
			if (it == global.itemA) {
				draw_sprite(spr_hud_glyph, 0 + pad, sx + cell - gl_w, sy + cell - gl_h);
			}
			if (it == global.itemY) {
				draw_sprite(spr_hud_glyph, 2 + pad, sx, sy + cell - gl_h);
			}
		}
	}

	//Blinking cursor
	if ((current_time div 250) mod 2 == 0) {
		menu_draw_frame(grid_x + (cursor mod grid_cols) * cell, grid_y + (cursor div grid_cols) * cell, cell, cell, 2, MENU_COL_CURSOR);
	}

	var sel = grid[cursor];
	var sel_y = grid_y + grid_rows * cell + 8;
	menu_draw_rect(items_x + 8, sel_y - 4, items_w - 16, 1, MENU_COL_TRIM_DARK);
	if (sel != ITEM.NONE && global.item_have[sel]) {
		draw_sprite(item_get_sprite(sel), item_get_frame(sel), items_x + (items_w - 16) div 2, sel_y + 4);
		draw_set_halign(fa_center);
		menu_draw_text(items_x + items_w div 2, sel_y + 26, item_get_name(sel));
		draw_set_halign(fa_left);
	}

	//--- Buttons: what's on Y, B and A right now (same boxes as the HUD)
	menu_draw_box(side_x, page_y, side_w, 46);
	draw_set_halign(fa_center);
	menu_draw_text(side_x + side_w div 2, page_y + 5, "BUTTONS");
	draw_set_halign(fa_left);
	var sw = sprite_get_width(spr_hud_slot);
	var bx = side_x + (side_w - sw * 3 - 8) div 2;
	var sword_spr = -1;
	if (global.swordTier > 0) {sword_spr = spr_menu_sword}
	hud_draw_button(bx, page_y + 16, 2, item_get_sprite(global.itemY), item_get_frame(global.itemY));
	hud_draw_button(bx + sw + 4, page_y + 16, 1, sword_spr, global.swordTier - 1);
	hud_draw_button(bx + (sw + 4) * 2, page_y + 16, 0, item_get_sprite(global.itemA), item_get_frame(global.itemA));

	//--- Preassigned equipment: sword (always on B, by tier), running boots (run button)
	var pre_y = page_y + 50;
	var pre_spr = [spr_menu_sword, spr_menu_boots];
	var pre_frame = [global.swordTier - 1, 0];
	var pre_have = [global.swordTier > 0, global.hasBoots];
	var pre_x = menu_draw_equipment(side_x, pre_y, side_w, 40, "PREASSIGNED", pre_spr, pre_frame, pre_have);
	//B glyph on the sword slot's corner
	draw_sprite(spr_hud_glyph, 1 + pad, pre_x + MENU_EQUIP_SLOT - gl_w + 3, pre_y + MENU_EQUIP_TOP + MENU_EQUIP_SLOT - gl_h + 1);

	//--- Button hints
	var hint_y = pre_y + 44;
	var hint_h = page_y + page_h - hint_y;
	menu_draw_box(side_x, hint_y, side_w, hint_h);
	var ty = hint_y + 10;
	draw_sprite(spr_hud_glyph, 0 + pad, side_x + 8, ty - 1);
	menu_draw_text(side_x + 20, ty, "EQUIP");
	draw_sprite(spr_hud_glyph, 2 + pad, side_x + 8, ty + 15);
	menu_draw_text(side_x + 20, ty + 16, "EQUIP");
	var close_str = "ENTER: CLOSE";
	if (global.input_using_pad) {close_str = "START: CLOSE"}
	menu_draw_text(side_x + 8, ty + 32, close_str);
	pause_draw_page_hint(side_x + 8, ty + 48);


}

///pause_draw_quest();
function pause_draw_quest() {
	var gw = display_get_gui_width();
	var half_w = (gw - 12) div 2;

	//--- Passive equipment: strength gloves, armor (by tier), flippers. Always on.
	var pas_spr = [spr_menu_gloves, spr_menu_armor, spr_menu_flippers];
	var pas_frame = [0, global.armorTier - 1, 0];
	var pas_have = [global.hasGloves, global.armorTier > 0, global.hasFlippers];
	menu_draw_equipment(4, page_y, half_w, 40, "PASSIVE", pas_spr, pas_frame, pas_have);

	//--- The Bun
	var bun_box_x = 8 + half_w;
	menu_draw_box(bun_box_x, page_y, half_w, 40);
	draw_set_halign(fa_center);
	menu_draw_text(bun_box_x + half_w div 2, page_y + 5, "THE BUN");
	draw_set_halign(fa_left);
	var bun_gap = 8;
	var bun_x = bun_box_x + (half_w - (BUN_PIECES * 16 + (BUN_PIECES - 1) * bun_gap)) div 2;
	for (var i = 0; i < BUN_PIECES; i++) {
		var frame = 0;
		if (global.bunPieces[i]) {frame = i + 1}
		draw_sprite(spr_menu_bun, frame, bun_x + i * (16 + bun_gap), page_y + 18);
	}
	//Star Iron for the smith (in the box's corner, once Link has had any)
	if (smith_ore_seen()) {
		var ore_x = bun_box_x + half_w - 22;
		draw_sprite(spr_star_iron, 0, ore_x, page_y + 17);
		draw_set_font(small_font);
		menu_draw_text(ore_x + 11, page_y + 28, string(global.swordOre));
		draw_set_font(menu_font);
	}
	//The hammer's trading chain: what Link is carrying to trade (in the other corner, see the trade_quest script)
	var trade = trade_at();
	if (trade >= TRADE_FISH && trade < TRADE_DONE) {draw_sprite(spr_trade_item, trade - 1, bun_box_x + 6, page_y + 17)}
	//The knight's medal from the Old Well, until it's been handed back (see dlg_village_guard)
	else if (flag_get(QUEST_MEDAL_FLAG) && !flag_get("got_first_sword")) {draw_sprite(spr_quest_item, 0, bun_box_x + 6, page_y + 17)}

	//--- Map of this room (taken when the menu opened, see menu_map_build)
	var map_y = page_y + 44;
	var map_h = page_h - 44;
	menu_draw_box(4, map_y, gw - 8, map_h);
	if (variable_struct_exists(map, "floors")) {
		dungeon_map_draw(4, map_y, gw - 8, map_h, map);
		return;
	}
	draw_set_halign(fa_center);
	menu_draw_text(gw div 2, map_y + 5, "MAP");
	draw_set_halign(fa_left);
	menu_draw_map(10, map_y + 17, gw - 20, map_h - 23, map);


}

///pause_draw_settings();
function pause_draw_settings() {
	var gw = display_get_gui_width();
	var pad = 0;
	if (global.input_using_pad) {pad = 3}
	var bx = 4;
	var bw = gw - 8;

	//--- Options screen (see the options_menu script)
	if (show_options) {
		options_draw(bx, page_y, bw, page_h);
		return;
	}

	menu_draw_box(bx, page_y, bw, page_h);
	var foot_y = page_y + page_h - 14;	//the hint line at the bottom

	//--- Resume, Options, Main menu
	draw_set_halign(fa_center);
	menu_draw_text(gw div 2, page_y + 6, "SETTINGS");
	var n = array_length(set_choices);
	var top = page_y + 52;
	for (var j = 0; j < n; j++) {
		menu_draw_choice(gw div 2, top + j * 16, set_choices[j], j == set_cursor);
	}
	draw_set_halign(fa_left);

	//Saved (or there's no file to save to)
	if (save_msg_timer > 0 && !confirm_quit) {
		draw_set_halign(fa_center);
		menu_draw_text_colour(gw div 2, top + n * 16 + 8, save_msg, MENU_COL_CURSOR);
		draw_set_halign(fa_left);
	}

	//Main menu needs A twice (unsaved progress is lost)
	if (confirm_quit) {
		var msg = "AGAIN TO GO TO THE TITLE";
		var qx = (gw - (string_length(msg) * 8 + 12)) div 2;
		var qy = top + n * 16 + 8;
		draw_sprite(spr_hud_glyph, 0 + pad, qx, qy - 1);
		menu_draw_text_colour(qx + 12, qy, msg, MENU_COL_CURSOR);
	}

	var close_str = "ENTER: CLOSE";
	if (global.input_using_pad) {close_str = "START: CLOSE"}
	menu_draw_text(bx + 8, foot_y, close_str);
	draw_set_halign(fa_right);
	if (global.input_using_pad) {
		menu_draw_text(bx + bw - 8, foot_y, "LB RB: PAGE");
	} else {
		menu_draw_text(bx + bw - 8, foot_y, ": PAGE");
		menu_draw_bracket(bx + bw - 8 - 64, foot_y, false, c_white);
		menu_draw_bracket(bx + bw - 8 - 56, foot_y, true, c_white);
	}
	draw_set_halign(fa_left);


}
