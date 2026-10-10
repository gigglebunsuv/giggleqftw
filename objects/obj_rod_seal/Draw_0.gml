/// @description The seal of its hall, glowing

var a = 0.8 + 0.2 * sin(current_time / 200);
draw_sprite_ext(sprite_index, clamp(hall - 1, 0, 2), x, y, 1, 1, 0, c_white, a);
