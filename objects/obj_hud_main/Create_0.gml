/// @description HUD layout

//Top: hearts and magic, counters, item boxes in the right corner
hud_y = 4;
life_x = 8;		//hearts and magic
count_x = 80;	//money, bombs, arrows (one row)
count_gap = 4;	//space between counters
btn_margin = 8;	//item boxes, from the right edge
btn_gap = 4;	//space between the B and A boxes

//Bottom left: minimap with the key counter next to it
map_x = 8;
map_margin = 6;	//from the bottom edge
map_w = 32;
map_h = 24;
key_gap = 4;	//space between the map and the key counter

//Placeholder colours
hud_map_col = make_colour_rgb(116,116,116);
hud_dot_col = make_colour_rgb(128,208,16);

hud_set_gui_size();
