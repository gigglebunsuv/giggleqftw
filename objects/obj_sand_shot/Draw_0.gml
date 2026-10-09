/// @description See-through under the lens if it's only haze

draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, image_angle, c_white, (fake && lens_active()) ? 0.2 : 1);
