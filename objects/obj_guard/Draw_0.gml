/// @description The guard, its sword (behind it while it faces up), "!" when it spots Link

var sx = guard_sword_x();
var sy = guard_sword_y();
var sf = enemy_dir4(face) div 90;
if (sf == 1) {draw_sprite_ext(spr_guard_sword, sf, sx, sy, 1, 1, 0, image_blend, image_alpha)}
draw_self();
if (sf != 1) {draw_sprite_ext(spr_guard_sword, sf, sx, sy, 1, 1, 0, image_blend, image_alpha)}

if (state == "alert") {
	var col = make_colour_rgb(222, 124, 112);
	draw_sprite_ext(spr_pixel, 0, x - 1, y - 17, 2, 5, 0, col, 1);
	draw_sprite_ext(spr_pixel, 0, x - 1, y - 11, 2, 2, 0, col, 1);
}
