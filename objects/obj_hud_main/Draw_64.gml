/// @description Draw HUD

if (!instance_exists(obj_link)) exit;

var gw = display_get_gui_width();
var gh = display_get_gui_height();

//Hearts, magic underneath (space is kept for the full 16 hearts)
var hearts_rows = ceil(PLAYER_HEARTS_MAX / HUD_HEARTS_PER_ROW);
hud_draw_hearts(life_x, hud_y);
hud_draw_magic(life_x, hud_y + sprite_get_height(spr_hud_heart) * hearts_rows + 2);

//Money, bombs, arrows in a row. Each one is as wide as its max value needs.
var cx = count_x;
hud_draw_counter(cx, hud_y, 0, global.pMoney);
cx += hud_counter_width(global.pMoneyMax) + count_gap;
hud_draw_counter(cx, hud_y, 2, global.pBombs);
cx += hud_counter_width(global.pBombsMax) + count_gap;
hud_draw_counter(cx, hud_y, 3, global.pArrows);

//Item boxes in the top right: B = sword (by tier), A = equipped item
var sw = sprite_get_width(spr_hud_slot);
var sword_spr = -1;
if (global.swordTier > 0) {sword_spr = spr_menu_sword}
hud_draw_button(gw - btn_margin - sw, hud_y, 0, item_get_sprite(global.itemA), 0);
hud_draw_button(gw - btn_margin - sw * 2 - btn_gap, hud_y, 1, sword_spr, global.swordTier - 1);

//Minimap in the bottom left, keys next to it lined up with the map's bottom edge
var map_y = gh - map_margin - map_h;
var map_drawn_w = hud_draw_minimap(map_x, map_y, map_w, map_h, hud_map_col, hud_dot_col);
hud_draw_counter(map_x + map_drawn_w + key_gap, gh - map_margin - sprite_get_height(spr_hud_digits), 1, global.pKeys);
