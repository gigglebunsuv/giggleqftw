/// @description The NPC, standing on their 16x16 spot (sprites of any size or origin line up)

if (!sprite_exists(sprite_index)) {
	//No sprite imported yet: a plain square
	draw_sprite_ext(spr_pixel, 0, bbox_left, bbox_top, 16, 16, 0, make_colour_rgb(248,120,248), image_alpha);
	exit;
}

var frame = 0;
if (sprite_get_number(sprite_index) >= 4) {frame = facing}
//Bottom middle of the sprite on the bottom middle of the 16x16 body
var sx = (bbox_left + bbox_right + 1) / 2 - sprite_get_width(sprite_index) / 2 + sprite_get_xoffset(sprite_index);
var sy = bbox_bottom + 1 - sprite_get_height(sprite_index) + sprite_get_yoffset(sprite_index);
draw_sprite_ext(sprite_index, frame, sx, sy, 1, 1, 0, c_white, image_alpha);
