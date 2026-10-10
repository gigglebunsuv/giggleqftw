/// @description Shimmering, tiled (not stretched)

var frame = (current_time div 180) mod 2;
var sw = sprite_get_width(sprite_index);
var sh = sprite_get_height(sprite_index);
var a = 0.75 + 0.25 * sin(current_time / 200);
//The lightning rod's gate: solid iron bars with a bolt on them, sparks crackling now and then
var spr = sprite_index;
if (need == "lightning") {
	spr = spr_iron_gate;
	frame = (current_time div 250) mod 2;
	a = 1;
}
for (var yy = 0; yy < sprite_height; yy += sh) {
	for (var xx = 0; xx < sprite_width; xx += sw) {
		draw_sprite_part_ext(spr, frame, 0, 0, min(sw, sprite_width - xx), min(sh, sprite_height - yy), x + xx, y + yy, 1, 1, c_white, a);
		if (spr == spr_iron_gate && (current_time div 120) mod 7 < 2) {
			draw_sprite_part_ext(spr, 2 + (current_time div 120) mod 2, 0, 0, min(sw, sprite_width - xx), min(sh, sprite_height - yy), x + xx, y + yy, 1, 1, c_white, 1);
		}
	}
}