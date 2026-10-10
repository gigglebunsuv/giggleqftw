/// @description Title screen (dungeon demo): Play or Settings
//menu: 0 the main choices, 2 the Options screen (options_menu script).
//PLAY: straight into the Southern Tower with the demo's items, no save file (demo_start, demo script).

main_choices = ["PLAY", "SETTINGS"];
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
