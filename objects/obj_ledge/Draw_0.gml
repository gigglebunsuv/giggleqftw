/// @description Tiled, with a shadow along the front face

dungeon_draw_tiles(sprite_index, x, y, sprite_width, sprite_height);
draw_sprite_ext(spr_pixel, 0, x, y + sprite_height - 4, sprite_width, 4, 0, c_black, 0.35);
