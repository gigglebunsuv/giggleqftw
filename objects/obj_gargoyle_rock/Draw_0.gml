/// @description Shadow on the ground, the rock high above it (only in the last part of the fall)

var t = 1 - timer / max(1, fall_time);
var sw = 4 + round(10 * t);
draw_sprite_ext(spr_pixel, 0, x - sw / 2, y - 2, sw, 4, 0, c_black, 0.45);
if (timer < 30) {draw_sprite(sprite_index, 0, x, y - timer * 4)}
