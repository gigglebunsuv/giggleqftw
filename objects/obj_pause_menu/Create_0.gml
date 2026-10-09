/// @description Pause screen (pages are in the pause_menu script)

sfx_play(SFX_PAUSE);

//The map needs Link and the camera zones, so take it before everything is deactivated
map = menu_map_build();
instance_deactivate_all(true);

menu_font = font_add_sprite_ext(spr_menu_font, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/", false, 0);
small_font = font_add_sprite_ext(spr_font_small, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/", false, 0);	//Star Iron count on the quest page

//Skip input on the first step: the button that opened the menu still counts as pressed
opened = false;

//Pages: 0 = items, 1 = quest, 2 = settings ([ and ] / LB and RB switch)
page = 0;

//Items page: the grid (slot number = item number, see the items script)
grid_cols = 5;
grid_rows = 4;
cell = 24;
grid = item_grid();	//which item is in each slot
cursor = max(0, item_grid_slot(global.itemA));	//start on the equipped item

//Settings page
set_choices = ["RESUME", "SAVE AND CONTINUE", "SAVE AND QUIT", "OPTIONS", "MAIN MENU"];
set_cursor = 0;
save_msg = "";		//"SAVED" (or "NO SAVE FILE") under the choices for a moment
save_msg_timer = 0;
confirm_quit = false;	//pressed A once on Main menu: press again to go to the title
show_options = false;	//showing the Options screen (controls, volume: see the options_menu script)

//Layout (GUI is the whole window, 256x208). The page names are along the top.
page_y = 24;	//pages start under the page names
page_h = 180;
items_x = 4;	//items page: grid on the left
items_w = 132;
grid_x = items_x + (items_w - grid_cols * cell) div 2;
grid_y = page_y + 18;
side_x = 140;	//items page: right column (wide enough for 13 letters)
side_w = 112;
options_open((page_h - 40) div 10);
