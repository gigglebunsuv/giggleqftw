/// @description The guard, its sword in its hand (see guard_hand), "!" when it spots Link

var sx = guard_sword_x();
var sy = guard_sword_y();
var sf = enemy_dir4(face) div 90;
draw_self();
draw_sprite_ext(spr_guard_sword, sf, sx, sy, 1, 1, 0, image_blend, image_alpha);

if (state == "alert") {
	var col = make_colour_rgb(222, 124, 112);
	draw_sprite_ext(spr_pixel, 0, x - 1, y - 27, 2, 5, 0, col, 1);	//over its helmet (the guard is 24 tall)
	draw_sprite_ext(spr_pixel, 0, x - 1, y - 21, 2, 2, 0, col, 1);
}
