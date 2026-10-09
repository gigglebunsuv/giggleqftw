/// @description Title screen: level select or options
//menu: 0 the main choices, 1 level select, 2 the Options screen (options_menu script).
//Level select: the name shown, the room, and where Link starts in it.
//Picking one makes Link (persistent) here and sends him to that room. An optional fifth entry
//is a function run once Link is made (the items he starts with there).

main_choices = ["LEVEL SELECT", "OPTIONS"];
level_choices = [
	["HAVEN", rm_haven, 792, 840],
	["SOUTHERN TOWER", rm_southern_tower, TOWER_START_X, TOWER_START_Y, dungeon_start_southern_tower],
	["TEST DUNGEON", rm_test_dungeon, 384, 640],
	["DEBUG ROOM", rm_debug, 640, 120]
];
level_names = [];
for (var i = 0; i < array_length(level_choices); i++) {level_names[i] = level_choices[i][0]}
menu = 0;
cursor = 0;
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
