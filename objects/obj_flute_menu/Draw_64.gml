/// @description The warp menu

if (!menu) exit;

var gw = display_get_gui_width();
var gh = display_get_gui_height();
//Frozen game, darkened, with the HUD bar still showing over it
var area = hud_play_area();
menu_draw_rect(0, 0, gw, gh, c_black);
draw_sprite_stretched_ext(snap, 0, area[0], area[1], area[2], area[3], c_white, 0.5);
hud_draw_bar();

var n = array_length(spot_name);
var bw = 160;
var bh = 30 + n * 12;
var bx = (gw - bw) div 2;
var by = area[1] + (area[3] - bh) div 2;
menu_draw_box(bx, by, bw, bh);

draw_set_font(menu_font);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
menu_draw_text(gw div 2, by + 6, "WARP TO");
for (var i = 0; i < n; i++) {
	if (i == cursor) {menu_draw_text_colour(gw div 2, by + 22 + i * 12, spot_name[i], MENU_COL_CURSOR)}
	else {menu_draw_text(gw div 2, by + 22 + i * 12, spot_name[i])}
}
draw_set_halign(fa_left);
