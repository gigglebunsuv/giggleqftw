/// @description Story crawl, title art and logo, "DUNGEON DEMO", the choices in the field (or the Options screen), the studio name

//Fills the whole window (256x208, the same size as the HUD bar + play area in the game).
//spr_title_bg and spr_title_logo are stretched to it, so draw them at 256x208.
var gw = display_get_gui_width();
var gh = display_get_gui_height();
menu_draw_rect(0, 0, gw, gh, c_black);

//Story crawl on black
if (intro == 0) {
	draw_set_font(menu_font);
	title_intro_draw_crawl(title_intro_time(music, intro_steps), gw, gh);
	exit;
}

//The title art (spr_title_bg, no logo), fading in
var fade = 1;
if (intro == 1) {fade = intro_timer / TITLE_FADE_TIME}
draw_sprite_stretched_ext(spr_title_bg, 0, 0, 0, gw, gh, c_white, fade);

//The logo (spr_title_logo) slides down into place, already lined up in a full-screen image
if (intro == 1) {exit}
if (sprite_exists(logo)) {
	var slide = 1;
	if (intro == 2) {slide = title_intro_ease(intro_timer / TITLE_SLIDE_TIME)}
	draw_sprite(logo, 0, 0, round(TITLE_SLIDE_FROM * (1 - slide)));
}
if (intro == 2) {exit}

//"DUNGEON DEMO" under the logo, on a dark band so it reads over the art
draw_set_font(menu_font);
draw_set_valign(fa_top);
draw_set_halign(fa_center);
draw_sprite_ext(spr_pixel, 0, gw div 2 - 58, TITLE_DEMO_Y - 3, 116, 14, 0, c_black, 0.55);
menu_draw_text_colour(gw div 2, TITLE_DEMO_Y, "DUNGEON DEMO", MENU_COL_CURSOR);
draw_set_halign(fa_left);

//Options screen: a box over the whole window (options_menu script)
draw_set_font(menu_font);
draw_set_valign(fa_top);
if (menu == 2) {
	options_draw(4, 4, gw - 8, gh - 8);
	exit;
}

//Choices, in the field to the right of the cliff, on a see-through panel so the rocks
//behind don't make them hard to read
var names = main_choices;
var n = array_length(names);
var cx = TITLE_MENU_X;
var top = TITLE_MENU_Y;
var pw = 120;
var ph = 14 + n * 12;
draw_sprite_ext(spr_pixel, 0, cx - pw / 2, top - 4, pw, ph, 0, c_black, 0.45);

for (var i = 0; i < n; i++) {
	menu_draw_choice(cx, top + i * 12, names[i], i == cursor);
}

//Small text: how to pick (under the choices) and the studio (bottom left)
draw_set_font(small_font);
var hint = "UP/DOWN AND ENTER";
if (global.input_using_pad) {hint = "DPAD AND A"}
menu_draw_text_colour(cx, top + n * 12 + 1, hint, c_ltgray);
draw_set_halign(fa_left);
menu_draw_text(3, gh - 9, "UNKNOWN VENGEANCE STUDIOS");
