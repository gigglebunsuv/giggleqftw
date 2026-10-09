/// @description Switch pages, close, then the open page's controls

input_get();

if (!opened) {
	opened = true;
	exit;
}

//Close with Start/Enter, or B (on the Options screen B goes back instead)
if (act_start || (act_b && !show_options)) {
	pause_close();
	exit;
}

//Switch pages: [ and ] (LB and RB)
if (menu_page != 0) {
	page = (page + menu_page + PAUSE_PAGES) mod PAUSE_PAGES;
	show_options = false;
	confirm_quit = false;
	audio_play_sound(menu_switch, 2, false);
	exit;
}

switch (page) {
	case 0: pause_step_items(); break;
	case 1: dungeon_map_step(map); break;
	case 2: pause_step_settings(); break;
}
