/// @description Placeholder hole: black, with a dark lip along the top edge

var w = sprite_width;
var h = sprite_height;
draw_sprite_ext(spr_pixel, 0, x, y, w, h, 0, c_black, 1);
draw_sprite_ext(spr_pixel, 0, x, y, w, 3, 0, make_colour_rgb(60, 60, 60), 1);
draw_sprite_ext(spr_pixel, 0, x, y + 3, w, 1, 0, make_colour_rgb(82, 82, 82), 1);
