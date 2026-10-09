/// @description In the air: its shadow stays on the ground. The tongue.

if (z > 0) {draw_sprite_ext(spr_pixel, 0, x - 5, y + 5, 10, 2, 0, c_black, 0.4)}
var dy = y - round(z);
if (tongue > 0) {
	var tx = (face > 0) ? x + 6 : x - 6 - tongue;
	draw_sprite_ext(spr_pixel, 0, tx, dy + 1, tongue, 2, 0, make_colour_rgb(224, 112, 178), 1);
	draw_sprite_ext(spr_pixel, 0, (face > 0) ? x + 6 + tongue - 1 : x - 6 - tongue - 1, dy, 3, 4, 0, make_colour_rgb(132, 35, 92), 1);
}
draw_sprite_ext(sprite_index, image_index, x, dy, face, 1, 0, image_blend, image_alpha);
