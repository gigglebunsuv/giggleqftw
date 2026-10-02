/// @description Draw HUD

if (!instance_exists(obj_link)) exit;

//Background band over the top of the view
draw_sprite_ext(spr_pixel, 0, 0, 0, display_get_gui_width(), HUD_HEIGHT, 0, hud_bg_col, 1);

//Hearts, magic underneath (space is kept for the full 16 hearts)
var hearts_rows = ceil(PLAYER_HEARTS_MAX / HUD_HEARTS_PER_ROW);
hud_draw_hearts(life_x, hud_y);
hud_draw_magic(life_x, hud_y + sprite_get_height(spr_hud_heart) * hearts_rows + 2);

//Counters
hud_draw_counter(count_x, count_y, 0, global.pMoney);
hud_draw_counter(count_x, count_y + count_row, 1, global.pKeys);
hud_draw_counter(count_x + count_col, count_y, 2, global.pBombs);
hud_draw_counter(count_x + count_col, count_y + count_row, 3, global.pArrows);

//Item boxes: B then A
hud_draw_button(btn_b_x, btn_y, 1, global.itemB);
hud_draw_button(btn_a_x, btn_y, 0, global.itemA);

//Minimap
hud_draw_minimap(map_x, map_y, map_w, map_h, hud_map_col, hud_dot_col);
