/// @description Planks with dark edges

dungeon_draw_tiles(sprite_index, x, y, sprite_width, sprite_height);
draw_sprite_ext(spr_pixel, 0, x, y, sprite_width, 2, 0, c_black, 0.6);
draw_sprite_ext(spr_pixel, 0, x, y + sprite_height - 2, sprite_width, 2, 0, c_black, 0.6);
