/// @description In the air: its shadow stays on the ground

if (z > 0) {draw_sprite_ext(spr_pixel, 0, x - 4, y + 5, 8, 2, 0, c_black, 0.4)}
draw_sprite_ext(sprite_index, image_index, x, y - round(z), image_xscale, image_yscale, 0, image_blend, image_alpha);