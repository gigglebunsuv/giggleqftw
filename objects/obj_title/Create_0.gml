/// @description Title screen: Play, Settings, Debug
//menu: 0 the main choices, 1 the Debug list, 2 the Options screen (options_menu script),
//3-6 the file select and name entry (file_select script).
//PLAY: the three save files (save_files script). DEBUG: start anywhere with a set of items, no save file.
//Debug list: the name shown, the room, and where Link starts in it. An optional fifth entry
//is a function run once Link is made (the items he starts with there).

main_choices = ["PLAY", "SETTINGS", "DEBUG"];
debug_choices = [
	["OVERWORLD", rm_overworld, WORLD_START_X, WORLD_START_Y, world_start_new_game],
	["SOUTHERN TOWER", rm_southern_tower, TOWER_START_X, TOWER_START_Y, dungeon_start_southern_tower],
	["BOG TOWER", rm_bog_tower, BOG_START_X, BOG_START_Y, dungeon_start_bog_tower],
	["LADHELLIN", rm_ladhellin_tower, LADHELLIN_START_X, LADHELLIN_START_Y, dungeon_start_ladhellin],
	["TEST DUNGEON", rm_test_dungeon, 384, 640],
	["DEBUG ROOM", rm_debug, DEBUG_START_X, DEBUG_START_Y],
	["ITEM TEST", rm_item_test, 264, 184],
	["HAVEN", rm_haven, 792, 840]
];
debug_names = [];
for (var i = 0; i < array_length(debug_choices); i++) {debug_names[i] = debug_choices[i][0]}
menu = 0;
cursor = 0;
fs_cursor = 0;		//file select: the file picked
fs_action = 0;		//0 START, 1 ERASE
fs_confirm = 0;		//erase? 0 NO, 1 YES
fs_slots = [];
name_text = "";		//name entry
name_col = 0;
name_row = 0;
options_open(16);	//the Options box fills the window (200 tall: 16 lines of controls)
menu_font = font_add_sprite_ext(spr_menu_font, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/", false, 0);
small_font = font_add_sprite_ext(spr_font_small, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/", false, 0);
gui_ready = false;

//Story crawl, then the background fades in and the logo slides down (title_intro script).
//intro: 0 story crawl, 1 background fading in, 2 logo sliding in, 3 menu.
//This object plays the Title music (once, no loop) so it can keep the crawl in time with it.
//After TITLE_IDLE_TIME on the menu with no button pressed, it all plays again.
title_intro_start();
logo = asset_get_index("spr_title_logo");	//-1 until it's imported, then the logo is just skipped
