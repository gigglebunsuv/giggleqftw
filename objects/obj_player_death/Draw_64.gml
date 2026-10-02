/// @description Fade and GAME OVER screen

var gw = display_get_gui_width();
var gh = display_get_gui_height();

if (fade > 0) {
	draw_sprite_ext(spr_pixel, 0, 0, 0, gw, gh, 0, c_black, fade);
}

if (phase == "menu") {
	draw_set_font(menu_font);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);

	menu_draw_text_colour(gw div 2, 56, "GAME OVER", make_colour_rgb(216, 40, 0));
	var col = c_white;
	if (cursor == 0) {col = MENU_COL_CURSOR}
	menu_draw_text_colour(gw div 2, 92, "CONTINUE", col);
	col = c_white;
	if (cursor == 1) {col = MENU_COL_CURSOR}
	menu_draw_text_colour(gw div 2, 108, "QUIT", col);

	draw_set_halign(fa_left);
}
