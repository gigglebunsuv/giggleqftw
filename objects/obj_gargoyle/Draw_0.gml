/// @description Shadow on the ground, the Gargoyle z pixels above it

var frame = gargoyle_frame();
var bx = x;
if (state == "wake") {bx += choose(-1, 0, 1)}

//Shadow (smaller the higher it is). Not while it sits on a pillar.
if (state != "dormant" && state != "perched") {
	var sw = max(8, 24 - z * 0.3);
	draw_sprite_ext(spr_pixel, 0, x - sw / 2, y + 6, sw, 4, 0, c_black, 0.4);
	draw_sprite_ext(spr_pixel, 0, x - sw / 2 + 2, y + 5, sw - 4, 6, 0, c_black, 0.4);
}

draw_sprite_ext(sprite_index, frame, bx, y - round(z), 1, 1, 0, image_blend, image_alpha);
