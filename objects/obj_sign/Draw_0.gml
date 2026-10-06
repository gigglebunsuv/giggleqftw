/// @description The sign, on its 16x16 spot (placed by its middle, like NPCs)

if (sprite_exists(sprite_index)) {
	//Bottom middle of the sprite on the bottom middle of the spot (sprites of any size or origin line up)
	var sx = x - sprite_get_width(sprite_index) / 2 + sprite_get_xoffset(sprite_index);
	var sy = y + 8 - sprite_get_height(sprite_index) + sprite_get_yoffset(sprite_index);
	draw_sprite_ext(sprite_index, 0, sx, sy, 1, 1, 0, c_white, image_alpha);
	exit;
}

//No sprite imported yet: a board on a post
var bx = x - 8;
var by = y - 8;
draw_sprite_ext(spr_pixel, 0, bx + 6, by + 10, 4, 5, 0, make_colour_rgb(50, 19, 0), 1);
draw_sprite_ext(spr_pixel, 0, bx + 7, by + 10, 2, 5, 0, make_colour_rgb(111, 63, 0), 1);
draw_sprite_ext(spr_pixel, 0, bx + 1, by + 2, 14, 9, 0, make_colour_rgb(50, 19, 0), 1);
draw_sprite_ext(spr_pixel, 0, bx + 2, by + 3, 12, 7, 0, make_colour_rgb(232, 208, 170), 1);
draw_sprite_ext(spr_pixel, 0, bx + 3, by + 4, 10, 1, 0, make_colour_rgb(111, 63, 0), 1);
draw_sprite_ext(spr_pixel, 0, bx + 3, by + 6, 8, 1, 0, make_colour_rgb(111, 63, 0), 1);
draw_sprite_ext(spr_pixel, 0, bx + 3, by + 8, 9, 1, 0, make_colour_rgb(111, 63, 0), 1);
