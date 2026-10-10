/// @description Story crawl and title reveal, then Play (the files), Settings or Debug, or replay the intro when left alone

//Window and GUI size, like the rooms with the HUD. obj_hud_main (persistent) sets them up
//and draws the game in the window (the view is centred here, see hud_play_area_window)
if (!gui_ready) {
	if (!instance_exists(obj_hud_main)) {instance_create_depth(0, 0, -100, obj_hud_main)}
	gui_ready = true;
}

input_get();
var skip = act_a || act_start || pad_accept;

//Story crawl and reveal: A or Start skips to the menu
if (intro < 3) {
	intro_steps += 1;
	intro_timer += 1;
	switch (intro) {
		case 0:
			if (skip) {
				//Jump the music to the main theme so the skip lands on the beat
				if (audio_is_playing(music)) {audio_sound_set_track_position(music, TITLE_THEME_START)}
				intro = 1;
				intro_timer = 0;
			} else if (title_intro_time(music, intro_steps) >= TITLE_THEME_START) {
				intro = 1;
				intro_timer = 0;
			}
			break;
		case 1:
			if (intro_timer >= TITLE_FADE_TIME) {
				intro = 2;
				intro_timer = 0;
			}
			if (skip) {intro = 3}
			break;
		case 2:
			if (intro_timer >= TITLE_SLIDE_TIME || skip) {intro = 3}
			break;
	}
	exit;	//the button that skipped doesn't also pick a choice
}

//Left alone on the main choices or the Debug list: play the story and reveal again
//(not on the Options screen or the files, so there's time to read and type)
idle_steps += 1;
if (skip || act_b || menu_move != 0 || menu_move_h != 0 || menu >= 2) {idle_steps = 0}
if (idle_steps >= TITLE_IDLE_TIME * game_get_speed(gamespeed_fps)) {
	title_intro_start();
	exit;
}

//The file select and name entry (file_select script)
if (menu >= 3) {
	file_select_step(skip);
	exit;
}

switch (menu) {
	//Play (the save files), Settings, Debug
	case 0:
		if (menu_move != 0) {
			cursor = (cursor + menu_move + array_length(main_choices)) mod array_length(main_choices);
			audio_play_sound(menu_switch, 2, false);
		}
		if (skip) {
			audio_play_sound(menu_select, 3, false);
			switch (cursor) {
				case 0:
					file_select_open();
					break;
				case 1:
					menu = 2;
					options_open(opt_rows);
					break;
				case 2:
					menu = 1;
					cursor = 0;
					break;
			}
		}
		break;

	//Debug: start anywhere (no save file). B goes back.
	case 1:
		if (act_b) {
			menu = 0;
			cursor = 2;
			audio_play_sound(menu_switch, 2, false);
			break;
		}
		var n = array_length(debug_choices);
		if (menu_move != 0) {
			cursor = (cursor + menu_move + n) mod n;
			audio_play_sound(menu_switch, 2, false);
		}
		if (skip) {
			audio_play_sound(menu_select, 3, false);
			var c = debug_choices[cursor];
			save_start_link(c[2], c[3]);
			save_debug_game();
			if (array_length(c) > 4) {
				if (is_method(c[4])) {c[4]()} else {script_execute(c[4])}
			}
			global.pause_block = true;	//so Link ignores the button that started the game
			room_goto(c[1]);
		}
		break;

	//Options screen: B or its Back goes back, with the cursor on Settings
	case 2:
		if (options_step(skip)) {
			menu = 0;
			cursor = 1;
		}
		break;
}
