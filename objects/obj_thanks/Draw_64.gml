/// @description Thank you for playing, the Bun, the stats, how to go back to the title

var gw = display_get_gui_width();
var gh = display_get_gui_height();
menu_draw_rect(0, 0, gw, gh, c_black);

draw_set_valign(fa_top);
draw_set_halign(fa_center);
draw_set_font(menu_font);
menu_draw_text_colour(gw div 2, 18, "DUNGEON DEMO", MENU_COL_CURSOR);
menu_draw_text(gw div 2, 34, "THANK YOU FOR PLAYING!");

//The piece of the Bun Sir Gigglebuns got back, bobbing
var bob = round(sin(timer / 20) * 2);
draw_sprite(spr_menu_bun, 1, gw div 2 - 8, 52 + bob);

draw_set_font(small_font);
menu_draw_text_colour(gw div 2, 76, "SIR GIGGLEBUNS III HAS TAKEN BACK", c_ltgray);
menu_draw_text_colour(gw div 2, 85, "THE FIRST PIECE OF THE BUN.", c_ltgray);

//The stats (taken when the boss's room was left, see the demo script): names on the left,
//numbers on the right, in a thin frame
var px = gw div 2 - 76;
var pw = 152;
var top = 102;
menu_draw_frame(px, top - 5, pw, array_length(stats) * 11 + 7, 1, MENU_COL_DIM);
for (var i = 0; i < array_length(stats); i++) {
	draw_set_halign(fa_left);
	menu_draw_text_colour(px + 8, top + i * 11, stats[i][0], c_ltgray);
	draw_set_halign(fa_right);
	menu_draw_text(px + pw - 8, top + i * 11, stats[i][1]);
}
draw_set_halign(fa_center);

if (timer >= THANKS_WAIT && (timer div 30) mod 2 == 0) {
	menu_draw_text(gw div 2, 172, global.input_using_pad ? "PRESS A" : "PRESS ENTER");
}
menu_draw_text(gw div 2, gh - 12, "UNKNOWN VENGEANCE STUDIOS");
draw_set_halign(fa_left);

//Fading in from black, and out again when leaving
var a = 1 - min(1, timer / THANKS_FADE);
if (leaving) {a = min(1, leave_timer / THANKS_FADE)}
if (a > 0) {draw_sprite_ext(spr_pixel, 0, 0, 0, gw, gh, 0, c_black, a)}
