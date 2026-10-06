//The Options screen: the controls list and the sound volume.
//Shared by the title screen (obj_title) and the pause screen's Settings page (obj_pause_menu):
//call options_open() when it opens, options_step() each step (after input_get) and
//options_draw() in Draw GUI with the menu font set.
//The volume is kept in settings.ini so it stays the same after the game closes or restarts.

#macro OPTIONS_FILE "settings.ini"
#macro OPTIONS_VOLUME_DEFAULT 10	//percent, until the player changes it
#macro OPTIONS_VOLUME_STEP 5		//percent per press of left / right
#macro OPTIONS_SLIDER_W 100			//width of the volume slider (1 pixel per percent)

//Runs once at game start: load the volume and turn the game down to it
ini_open(OPTIONS_FILE);
global.volume = clamp(ini_read_real("sound", "volume", OPTIONS_VOLUME_DEFAULT), 0, 100);
ini_close();
audio_master_gain(global.volume / 100);

///options_volume_apply();
function options_volume_apply() {
	//Sets the game's overall volume to global.volume (0-100)
	audio_master_gain(global.volume / 100);


}

///options_volume_set(percent);
function options_volume_set(argument0) {
	//Changes the volume (0-100), applies it and saves it
	global.volume = clamp(argument0, 0, 100);
	options_volume_apply();
	ini_open(OPTIONS_FILE);
	ini_write_real("sound", "volume", global.volume);
	ini_close();


}

///options_open(rows);
function options_open(argument0) {
	//Sets on the calling instance. rows: how many lines of the controls list fit
	//(the box's height - 40, div 10).
	opt_cursor = 0;			//0 controls, 1 volume, 2 back
	opt_controls = false;	//showing the controls list
	opt_binds = input_bind_list();
	opt_scroll = 0;			//first row shown on the controls list
	opt_rows = argument0;


}

///options_step(accept);
function options_step(argument0) {
	//accept: the confirm button was pressed (A, or A / Enter on the title screen).
	//B goes back. Returns true when the player leaves the Options screen.

	//Controls list: up and down scroll it, A or B goes back
	if (opt_controls) {
		if (argument0 || act_b) {
			opt_controls = false;
			audio_play_sound(menu_switch, 2, false);
			return false;
		}
		if (menu_move != 0) {
			var top = clamp(opt_scroll + menu_move, 0, max(0, array_length(opt_binds) - opt_rows));
			if (top != opt_scroll) {
				opt_scroll = top;
				audio_play_sound(menu_switch, 2, false);
			}
		}
		return false;
	}

	if (act_b) {
		audio_play_sound(menu_switch, 2, false);
		return true;
	}

	if (menu_move != 0) {
		opt_cursor = (opt_cursor + menu_move + 3) mod 3;
		audio_play_sound(menu_switch, 2, false);
	}

	//Volume: left and right (the blip plays at the new volume)
	if (opt_cursor == 1 && menu_move_h != 0) {
		var vol = clamp(global.volume + menu_move_h * OPTIONS_VOLUME_STEP, 0, 100);
		if (vol != global.volume) {
			options_volume_set(vol);
			audio_play_sound(menu_switch, 2, false);
		}
	}

	if (!argument0) return false;
	switch (opt_cursor) {
		case 0:
			opt_controls = true;
			opt_scroll = 0;
			audio_play_sound(menu_select, 3, false);
			break;
		case 2:
			audio_play_sound(menu_switch, 2, false);
			return true;
	}
	return false;


}

///options_draw(x, y, w, h);
function options_draw(argument0, argument1, argument2, argument3) {
	//The Options screen (or the controls list) in a box
	var bx = argument0;
	var by = argument1;
	var bw = argument2;
	var bh = argument3;
	var cx = bx + bw div 2;
	var foot_y = by + bh - 14;	//the hint line at the bottom
	var pad = 0;
	if (global.input_using_pad) {pad = 3}

	menu_draw_box(bx, by, bw, bh);
	if (opt_controls) {
		options_draw_controls(bx, by, bw, bh);
	} else {
		draw_set_halign(fa_center);
		menu_draw_text(cx, by + 6, "OPTIONS");

		menu_draw_choice(cx, by + 36, "CONTROLS", opt_cursor == 0);

		//--- Sound: the volume slider
		var sy = by + 60;
		draw_set_halign(fa_left);
		menu_draw_text_colour(bx + 8, sy, "SOUND", MENU_COL_BORDER);
		menu_draw_rect(bx + 56, sy + 4, bw - 64, 1, MENU_COL_TRIM_DARK);

		var vy = sy + 16;
		var sel = (opt_cursor == 1);
		var col = c_white;
		if (sel) {col = MENU_COL_CURSOR}
		menu_draw_text_colour(bx + 16, vy, "VOLUME", col);
		options_draw_slider(bx + 80, vy, sel);
		draw_set_halign(fa_right);
		menu_draw_text_colour(bx + bw - 16, vy, string(global.volume), col);

		menu_draw_choice(cx, vy + 32, "BACK", opt_cursor == 2);
	}

	//Hints along the bottom
	draw_set_halign(fa_left);
	draw_sprite(spr_hud_glyph, 1 + pad, bx + 8, foot_y - 1);
	menu_draw_text(bx + 20, foot_y, "BACK");
	draw_set_halign(fa_right);
	if (opt_controls) {
		menu_draw_text(bx + bw - 8, foot_y, "UP/DOWN: SCROLL");
	} else if (opt_cursor == 1) {
		menu_draw_text(bx + bw - 8, foot_y, "LEFT/RIGHT: VOLUME");
	}
	draw_set_halign(fa_left);


}

///options_draw_slider(x, y, selected);
function options_draw_slider(argument0, argument1, argument2) {
	//The volume bar, filled up to global.volume, lined up with an 8 tall line of text.
	//While it's selected it's yellow, with arrows at the ends that blink.
	var sx = argument0;
	var sy = argument1 + 1;
	var fill = round(OPTIONS_SLIDER_W * global.volume / 100);
	var col = MENU_COL_BORDER;
	if (argument2) {col = MENU_COL_CURSOR}

	menu_draw_rect(sx - 1, sy - 1, OPTIONS_SLIDER_W + 2, 8, MENU_COL_TRIM_DARK);
	menu_draw_rect(sx, sy, OPTIONS_SLIDER_W, 6, MENU_COL_SLOT);
	menu_draw_rect(sx, sy, fill, 6, col);
	menu_draw_rect(sx + fill - 1, sy - 2, 3, 10, c_white);	//the knob

	if (argument2 && (current_time div 250) mod 2 == 0) {
		var lx = sx - 7;
		var rx = sx + OPTIONS_SLIDER_W + 4;
		for (var i = 0; i < 3; i++) {
			menu_draw_rect(lx + i, sy + 2 - i, 1, 2 + i * 2, col);
			menu_draw_rect(rx + 2 - i, sy + 2 - i, 1, 2 + i * 2, col);
		}
	}


}

///options_draw_controls(x, y, w, h);
function options_draw_controls(argument0, argument1, argument2, argument3) {
	//The controls list (see input_bind_list), opt_rows lines from opt_scroll
	var bx = argument0;
	var by = argument1;
	var bw = argument2;

	draw_set_halign(fa_center);
	menu_draw_text(bx + bw div 2, by + 6, "CONTROLS");
	draw_set_halign(fa_left);

	var row_y = by + 20;
	var last = min(array_length(opt_binds), opt_scroll + opt_rows);
	for (var i = opt_scroll; i < last; i++) {
		var row = opt_binds[i];
		var ty = row_y + (i - opt_scroll) * 10;
		switch (row[0]) {
			case 0: menu_draw_text_colour(bx + 8, ty, row[1], MENU_COL_CURSOR); break;
			case 1:
				menu_draw_text(bx + 8, ty, row[1]);
				menu_draw_text(bx + 120, ty, row[2]);
				menu_draw_text(bx + 192, ty, row[3]);
				break;
			case 2:
				menu_draw_text(bx + 16, ty, row[1]);
				menu_draw_text(bx + 64, ty, row[2]);
				break;
			case 3: menu_draw_text(bx + 8, ty, row[1]); break;
		}
	}

	//More above / below
	var ax = bx + bw - 12;
	if (opt_scroll > 0) {
		menu_draw_rect(ax + 2, row_y, 2, 1, MENU_COL_BORDER);
		menu_draw_rect(ax + 1, row_y + 1, 4, 1, MENU_COL_BORDER);
		menu_draw_rect(ax, row_y + 2, 6, 1, MENU_COL_BORDER);
	}
	if (last < array_length(opt_binds)) {
		var ay = row_y + opt_rows * 10 - 6;
		menu_draw_rect(ax, ay, 6, 1, MENU_COL_BORDER);
		menu_draw_rect(ax + 1, ay + 1, 4, 1, MENU_COL_BORDER);
		menu_draw_rect(ax + 2, ay + 2, 2, 1, MENU_COL_BORDER);
	}


}
