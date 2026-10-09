//The title's PLAY screens (run by obj_title, see its menu variable):
//	3 FILE SELECT	the three save files: name, hearts, sword, play time, deaths and Bun pieces, or - EMPTY -
//	4 FILE			a used file was picked: START or ERASE
//	5 ERASE?		NO / YES
//	6 NAME ENTRY	an empty file was picked: a letter grid, then the new game starts
//The files themselves are in the save_files script.

#macro FILE_SELECT_MUSIC FileSelect	//the file select's music (-1: the Title music keeps playing)
#macro FILE_SLOT_Y 34			//top of the first file's panel
#macro FILE_SLOT_H 38			//from one file's panel to the next
#macro NAME_GRID_X 38			//the name entry's letter grid: left edge, top, space between letters
#macro NAME_GRID_Y 66
#macro NAME_GRID_DX 18
#macro NAME_GRID_DY 16

///file_select_open();
function file_select_open() {
	//Shows the three files (reads them again, so an erased or new file shows right)
	menu = 3;
	fs_slots = [];
	for (var i = 0; i < SAVE_SLOTS; i++) {fs_slots[i] = save_summary(i)}
	fs_cursor = clamp(fs_cursor, 0, SAVE_SLOTS - 1);
	if (FILE_SELECT_MUSIC != -1 && !audio_is_playing(FILE_SELECT_MUSIC)) {
		audio_stop_sound(Title);
		audio_play_sound(FILE_SELECT_MUSIC, 1, true);
	}


}

///file_select_music_stop();
function file_select_music_stop() {
	//The game is starting: the area's music takes over
	if (FILE_SELECT_MUSIC != -1) {audio_stop_sound(FILE_SELECT_MUSIC)}


}

///name_entry_rows();
function name_entry_rows() {
	//The letter grid (only letters the menu font has). Under it: SPACE, DEL, END.
	return ["ABCDEFGHIJ", "KLMNOPQRST", "UVWXYZ-.!?", "0123456789"];


}

///name_entry_open();
function name_entry_open() {
	menu = 6;
	name_text = "";
	name_col = 0;
	name_row = 0;	//4 = the SPACE / DEL / END row (name_col 0-2 there)


}

///file_select_step(accept);
function file_select_step(argument0) {
	//Run by obj_title's Step for menus 3-6 (after input_get). accept: A, Start or Enter.
	var accept = argument0;
	switch (menu) {
		//The three files: pick one, B goes back to the title's choices
		case 3:
			if (act_b) {
				menu = 0;
				cursor = 0;
				audio_play_sound(menu_switch, 2, false);
				//Back to the title: its music again, from the main theme
				if (FILE_SELECT_MUSIC != -1) {
					file_select_music_stop();
					music = audio_play_sound(Title, 1, false);
					audio_sound_set_track_position(music, TITLE_THEME_START);
				}
				break;
			}
			if (menu_move != 0) {
				fs_cursor = (fs_cursor + menu_move + SAVE_SLOTS) mod SAVE_SLOTS;
				audio_play_sound(menu_switch, 2, false);
			}
			if (accept) {
				audio_play_sound(menu_select, 3, false);
				if (fs_slots[fs_cursor].used) {
					menu = 4;
					fs_action = 0;
				} else {
					name_entry_open();
				}
			}
			break;

		//A used file: START or ERASE
		case 4:
			if (act_b) {
				menu = 3;
				audio_play_sound(menu_switch, 2, false);
				break;
			}
			if (menu_move_h != 0 || menu_move != 0) {
				fs_action = 1 - fs_action;
				audio_play_sound(menu_switch, 2, false);
			}
			if (accept) {
				audio_play_sound(menu_select, 3, false);
				if (fs_action == 0) {
					file_select_music_stop();
					if (!save_load_game(fs_cursor)) {file_select_open()}	//the file couldn't be read
				} else {
					menu = 5;
					fs_confirm = 0;
				}
			}
			break;

		//Erase this file? NO / YES
		case 5:
			if (act_b) {
				menu = 4;
				audio_play_sound(menu_switch, 2, false);
				break;
			}
			if (menu_move_h != 0 || menu_move != 0) {
				fs_confirm = 1 - fs_confirm;
				audio_play_sound(menu_switch, 2, false);
			}
			if (accept) {
				if (fs_confirm == 1) {
					save_erase(fs_cursor);
					sfx_play(SFX_BOMB);
					file_select_open();
				} else {
					audio_play_sound(menu_switch, 2, false);
					menu = 4;
				}
			}
			break;

		case 6:
			name_entry_step();
			break;
	}


}

///name_entry_step();
function name_entry_step() {
	//Arrows move round the grid, A picks a letter (or SPACE / DEL / END), B or Backspace
	//deletes the last letter (or goes back when there are none), Enter / Start ends
	var rows = name_entry_rows();
	var cols = string_length(rows[0]);

	if (act_b || keyboard_check_pressed(vk_backspace)) {
		if (string_length(name_text) == 0) {
			if (act_b) {
				file_select_open();
				audio_play_sound(menu_switch, 2, false);
			}
			return;
		}
		name_text = string_copy(name_text, 1, string_length(name_text) - 1);
		audio_play_sound(menu_switch, 2, false);
		return;
	}
	if (act_start) {
		name_entry_finish();
		return;
	}

	//Moving: the bottom row has 3 buttons under the 10 columns
	if (menu_move_h != 0) {
		if (name_row == 4) {name_col = (name_col + menu_move_h + 3) mod 3}
		else {name_col = (name_col + menu_move_h + cols) mod cols}
		audio_play_sound(menu_switch, 2, false);
	}
	if (menu_move != 0) {
		var was = name_row;
		name_row = (name_row + menu_move + 5) mod 5;
		if (was == 4 && name_row != 4) {name_col = min(name_col * 4 + 1, cols - 1)}
		if (was != 4 && name_row == 4) {name_col = min(name_col * 3 div cols, 2)}
		audio_play_sound(menu_switch, 2, false);
	}

	if (!act_a) return;
	if (name_row == 4) {
		switch (name_col) {
			case 0:
				name_entry_add(" ");
				break;
			case 1:
				if (string_length(name_text) > 0) {name_text = string_copy(name_text, 1, string_length(name_text) - 1)}
				audio_play_sound(menu_switch, 2, false);
				break;
			case 2:
				name_entry_finish();
				break;
		}
		return;
	}
	name_entry_add(string_char_at(rows[name_row], name_col + 1));


}

///name_entry_add(letter);
function name_entry_add(argument0) {
	if (string_length(name_text) >= SAVE_NAME_MAX) {
		audio_play_sound(snd_bonk, 2, false);
		return;
	}
	name_text += argument0;
	audio_play_sound(menu_select, 3, false);
	//Full: jump to END
	if (string_length(name_text) >= SAVE_NAME_MAX) {
		name_row = 4;
		name_col = 2;
	}


}

///name_entry_finish();
function name_entry_finish() {
	//END: the new game starts on this file
	var nm = string_trim(name_text);
	if (nm == "") {nm = SAVE_DEFAULT_NAME}
	audio_play_sound(menu_select, 3, false);
	file_select_music_stop();
	save_new_game(fs_cursor, nm);


}

///file_select_time(seconds);
function file_select_time(argument0) {
	//Play time as H:MM (hours, minutes)
	var m = floor(argument0 / 60);
	var h = m div 60;
	m = m mod 60;
	return string(h) + ":" + ((m < 10) ? "0" : "") + string(m);


}

///file_select_draw(gui_w, gui_h);
function file_select_draw(argument0, argument1) {
	//Run by obj_title's Draw GUI for menus 3-6, over the title art. Menu font set, valign top.
	var gw = argument0;
	var bx = 8;
	var by = 8;
	var bw = gw - 16;
	var bh = argument1 - 16;
	menu_draw_box(bx, by, bw, bh);
	if (menu == 6) {
		name_entry_draw(gw, by, bh);
		return;
	}

	draw_set_halign(fa_center);
	menu_draw_text(gw div 2, by + 8, "SELECT A FILE");
	draw_set_halign(fa_left);

	var px = bx + 8;
	var pw = bw - 16;
	var ph = FILE_SLOT_H - 4;
	for (var i = 0; i < SAVE_SLOTS; i++) {
		var py = FILE_SLOT_Y + i * FILE_SLOT_H;
		var s = fs_slots[i];
		menu_draw_rect(px, py, pw, ph, MENU_COL_SLOT);
		var col = c_white;
		if (i == fs_cursor) {col = MENU_COL_CURSOR}
		menu_draw_text_colour(px + 4, py + 4, string(i + 1), col);
		if (!s.used) {
			draw_set_halign(fa_center);
			menu_draw_text_colour(px + pw div 2, py + (ph - 8) div 2, "- EMPTY -", MENU_COL_DIM);
			draw_set_halign(fa_left);
		} else {
			menu_draw_text_colour(px + 18, py + 4, s.name, col);
			//Hearts (8 a row), then the Bun pieces on the right
			for (var h = 0; h < s.hearts; h++) {
				draw_sprite(spr_hud_heart, 0, px + 18 + (h mod 8) * 8, py + 15 + (h div 8) * 8);
			}
			//The middle: the sword, the play time and the deaths
			var mx = px + 88;
			if (s.sword > 0) {draw_sprite(spr_menu_sword, clamp(s.sword, 1, SWORD_TIER_MAX) - 1, mx, py + 9)}
			else {menu_draw_rect(mx + 4, py + 15, 8, 1, MENU_COL_DIM)}
			draw_set_font(small_font);
			menu_draw_text_colour(mx + 20, py + 8, "TIME " + file_select_time(s.time), col);
			menu_draw_text_colour(mx + 20, py + 18, "DEATHS " + string(s.deaths), col);
			draw_set_font(menu_font);
			for (var b = 0; b < BUN_PIECES; b++) {
				var frame = 0;
				if (s.bun[b]) {frame = b + 1}
				draw_sprite(spr_menu_bun, frame, px + pw - 4 - (BUN_PIECES - b) * 18, py + 9);
			}
		}
		//Blinking frame round the chosen file
		if (i == fs_cursor && (menu != 3 || (current_time div 250) mod 2 == 0)) {
			menu_draw_frame(px - 1, py - 1, pw + 2, ph + 2, 1, MENU_COL_CURSOR);
		}
	}

	//Bottom: START / ERASE, the erase question, or the hint
	var fy = FILE_SLOT_Y + SAVE_SLOTS * FILE_SLOT_H + 4;
	var cx = gw div 2;
	if (menu == 4) {
		menu_draw_choice(cx - 40, fy + 6, "START", fs_action == 0);
		menu_draw_choice(cx + 40, fy + 6, "ERASE", fs_action == 1);
	} else if (menu == 5) {
		draw_set_halign(fa_center);
		menu_draw_text_colour(cx, fy, "ERASE FILE " + string(fs_cursor + 1) + "?", MENU_COL_CURSOR);
		menu_draw_choice(cx - 32, fy + 13, "NO", fs_confirm == 0);
		menu_draw_choice(cx + 32, fy + 13, "YES", fs_confirm == 1);
	}
	draw_set_font(small_font);
	draw_set_halign(fa_center);
	var hint = "ARROWS: CHOOSE   Z: OK   X: BACK";
	if (global.input_using_pad) {hint = "DPAD: CHOOSE   A: OK   B: BACK"}
	menu_draw_text_colour(cx, by + bh - 11, hint, c_ltgray);
	draw_set_font(menu_font);
	draw_set_halign(fa_left);


}

///name_entry_draw(gui_w, box_y, box_h);
function name_entry_draw(argument0, argument1, argument2) {
	var gw = argument0;
	var cx = gw div 2;
	draw_set_halign(fa_center);
	menu_draw_text(cx, argument1 + 8, "ENTER YOUR NAME");

	//The name so far: one spot per letter, underlined, the next spot blinking
	var nx = cx - SAVE_NAME_MAX * 6;
	var ny = 36;
	for (var i = 0; i < SAVE_NAME_MAX; i++) {
		var lx = nx + i * 12 + 6;
		if (i < string_length(name_text)) {menu_draw_text(lx, ny, string_char_at(name_text, i + 1))}
		var ucol = MENU_COL_TRIM_DARK;
		if (i == string_length(name_text) && (current_time div 250) mod 2 == 0) {ucol = MENU_COL_CURSOR}
		menu_draw_rect(lx - 4, ny + 10, 9, 1, ucol);
	}

	//The letter grid
	var rows = name_entry_rows();
	for (var r = 0; r < array_length(rows); r++) {
		for (var c = 0; c < string_length(rows[r]); c++) {
			var gx = NAME_GRID_X + c * NAME_GRID_DX;
			var gy = NAME_GRID_Y + r * NAME_GRID_DY;
			var sel = (r == name_row && c == name_col);
			if (sel) {menu_draw_frame(gx - 6, gy - 3, 13, 14, 1, MENU_COL_CURSOR)}
			menu_draw_text_colour(gx + 1, gy, string_char_at(rows[r], c + 1), sel ? MENU_COL_CURSOR : c_white);
		}
	}
	var by = NAME_GRID_Y + array_length(rows) * NAME_GRID_DY + 8;
	var btn = ["SPACE", "DEL", "END"];
	for (var k = 0; k < 3; k++) {
		menu_draw_choice(cx - 64 + k * 64, by, btn[k], name_row == 4 && name_col == k);
	}

	draw_set_font(small_font);
	var hint = "Z: PICK   X: DELETE   ENTER: END";
	if (global.input_using_pad) {hint = "A: PICK   B: DELETE   START: END"}
	menu_draw_text_colour(cx, argument1 + argument2 - 11, hint, c_ltgray);
	draw_set_font(menu_font);
	draw_set_halign(fa_left);


}
