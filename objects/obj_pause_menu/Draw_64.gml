/// @description Draw the pause screen

//Black over the whole window (the HUD bar too)
menu_draw_rect(0, 0, display_get_gui_width(), display_get_gui_height(), c_black);

draw_set_font(menu_font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

if (debug) {
	debug_menu_draw();
	exit;
}

pause_draw_tabs();
switch (page) {
	case 0: pause_draw_items(); break;
	case 1: pause_draw_quest(); break;
	case 2: pause_draw_settings(); break;
}
