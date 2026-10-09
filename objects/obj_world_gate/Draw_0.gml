/// @description Shimmering, tiled (not stretched)

var frame = (current_time div 180) mod 2;
var sw = sprite_get_width(sprite_index);
var sh = sprite_get_height(sprite_index);
var a = 0.75 + 0.25 * sin(current_time / 200);
for (var yy = 0; yy < sprite_height; yy += sh) {
	for (var xx = 0; xx < sprite_width; xx += sw) {
		draw_sprite_part_ext(sprite_index, frame, 0, 0, min(sw, sprite_width - xx), min(sh, sprite_height - yy), x + xx, y + yy, 1, 1, c_white, a);
	}
}