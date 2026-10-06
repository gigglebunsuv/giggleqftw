/// @description The chest, closed or open

if (sprite_exists(sprite_index)) {
	draw_sprite_ext(sprite_index, opened, x + sprite_get_xoffset(sprite_index), y + sprite_get_yoffset(sprite_index), 1, 1, 0, c_white, image_alpha);
	exit;
}

//No sprite imported yet: a plain box (brown, gold band, dark inside once it's open)
var bx = x;
var by = y;
draw_sprite_ext(spr_pixel, 0, bx + 1, by + 2, 14, 12, 0, make_colour_rgb(50, 19, 0), 1);
draw_sprite_ext(spr_pixel, 0, bx + 2, by + 3, 12, 10, 0, make_colour_rgb(200, 145, 62), 1);
draw_sprite_ext(spr_pixel, 0, bx + 2, by + 6, 12, 1, 0, make_colour_rgb(217, 218, 157), 1);
if (opened) {
	draw_sprite_ext(spr_pixel, 0, bx + 2, by + 3, 12, 3, 0, c_black, 1);
} else {
	draw_sprite_ext(spr_pixel, 0, bx + 7, by + 6, 2, 3, 0, make_colour_rgb(166, 167, 37), 1);
}
