/// @description HUD layout (Zelda 1 style)

//Positions inside the HUD band (top HUD_HEIGHT pixels of the view)
hud_y = 4;
life_x = 8;		//hearts and magic
count_x = 80;	//counters, 2x2: money/keys, then bombs/arrows
count_y = 6;
count_col = 44;	//space between counter columns
count_row = 12;	//space between counter rows
btn_b_x = 168;	//item boxes
btn_a_x = 192;
btn_y = 4;
map_x = 220;	//minimap area
map_y = 4;
map_w = 28;
map_h = 24;

//Placeholder colours
hud_bg_col = c_black;
hud_map_col = make_colour_rgb(116,116,116);
hud_dot_col = make_colour_rgb(128,208,16);

hud_set_gui_size();
