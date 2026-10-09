/// @description Thank you for playing, the Bun, how to go back to the title

var gw = display_get_gui_width();
var gh = display_get_gui_height();
menu_draw_rect(0, 0, gw, gh, c_black);

draw_set_valign(fa_top);
draw_set_halign(fa_center);
draw_set_font(menu_font);
menu_draw_text_colour(gw div 2, 40, "DUNGEON DEMO", MENU_COL_CURSOR);
menu_draw_text(gw div 2, 64, "THANK YOU FOR PLAYING!");

//The piece of the Bun Sir Gigglebuns got back, bobbing
var bob = round(sin(timer / 20) * 2);
draw_sprite(spr_menu_bun, 1, gw div 2 - 8, 94 + bob);

draw_set_font(small_font);
menu_draw_text_colour(gw div 2, 124, "SIR GIGGLEBUNS III HAS TAKEN BACK", c_ltgray);
menu_draw_text_colour(gw div 2, 133, "THE FIRST PIECE OF THE BUN.", c_ltgray);
if (timer >= THANKS_WAIT && (timer div 30) mod 2 == 0) {
	menu_draw_text(gw div 2, 168, global.input_using_pad ? "PRESS A" : "PRESS ENTER");
}
menu_draw_text(gw div 2, gh - 12, "UNKNOWN VENGEANCE STUDIOS");
draw_set_halign(fa_left);

//Fading in from black, and out again when leaving
var a = 1 - min(1, timer / THANKS_FADE);
if (leaving) {a = min(1, leave_timer / THANKS_FADE)}
if (a > 0) {draw_sprite_ext(spr_pixel, 0, 0, 0, gw, gh, 0, c_black, a)}
