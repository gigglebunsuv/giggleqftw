//Drawing helpers for the pause screen. Call from a Draw GUI event.
//Everything is drawn with spr_pixel (1x1 white) so the colours are easy to change here.

#macro MENU_COL_BOX make_colour_rgb(0,0,88)
#macro MENU_COL_SLOT make_colour_rgb(0,0,56)
#macro MENU_COL_BORDER c_white
#macro MENU_COL_CURSOR make_colour_rgb(248,216,0)

///menu_draw_rect(x, y, w, h, colour);
function menu_draw_rect(argument0, argument1, argument2, argument3, argument4) {
	draw_sprite_ext(spr_pixel, 0, argument0, argument1, argument2, argument3, 0, argument4, 1);


}

///menu_draw_frame(x, y, w, h, thickness, colour);
function menu_draw_frame(argument0, argument1, argument2, argument3, argument4, argument5) {
	//Outline only, drawn inside the w x h area
	var xx = argument0;
	var yy = argument1;
	var w = argument2;
	var h = argument3;
	var t = argument4;
	menu_draw_rect(xx, yy, w, t, argument5);
	menu_draw_rect(xx, yy + h - t, w, t, argument5);
	menu_draw_rect(xx, yy, t, h, argument5);
	menu_draw_rect(xx + w - t, yy, t, h, argument5);


}

///menu_draw_box(x, y, w, h);
function menu_draw_box(argument0, argument1, argument2, argument3) {
	//Black edge, white border, dark blue inside
	menu_draw_rect(argument0, argument1, argument2, argument3, c_black);
	menu_draw_rect(argument0 + 1, argument1 + 1, argument2 - 2, argument3 - 2, MENU_COL_BORDER);
	menu_draw_rect(argument0 + 2, argument1 + 2, argument2 - 4, argument3 - 4, MENU_COL_BOX);


}

///menu_draw_text(x, y, string);
function menu_draw_text(argument0, argument1, argument2) {
	//White text with a 1px black shadow. Uses the current font and alignment.
	menu_draw_text_colour(argument0, argument1, argument2, c_white);


}

///menu_draw_text_colour(x, y, string, colour);
function menu_draw_text_colour(argument0, argument1, argument2, argument3) {
	draw_set_colour(c_black);
	draw_text(argument0 + 1, argument1 + 1, argument2);
	draw_set_colour(argument3);
	draw_text(argument0, argument1, argument2);
	draw_set_colour(c_white);


}
