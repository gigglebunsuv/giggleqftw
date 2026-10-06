/// @description Shadow on the ground, the rock up in the air (spr_heavy_rock's origin is its top left)

draw_sprite_ext(spr_pixel, 0, x - 5, y + 3, 10, 3, 0, c_black, 0.4);
draw_sprite(spr_heavy_rock, 0, x - 8, y - 8 - round(z));
